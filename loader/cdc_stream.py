#!/usr/bin/env python3
"""CDC reader: stream Consolidé's binlog into the local pipeline-db (event-driven sync).

Drop-in alternative to the date_updated POLL (loader/sync_source.py), selected with SYNC_MODE=cdc.
Because it reads the binlog directly it captures every INSERT/UPDATE/DELETE regardless of whether
Consolidé populates `date_updated` — and it copies only the changed rows, not the whole DB each
cycle. (In the test instance every `date_updated` is NULL, which breaks the poll's incremental path
and forces full re-copies; CDC sidesteps that entirely.)

Flow:
  1. BOOTSTRAP (first run, no stored offset): pin the binlog position (SHOW MASTER STATUS) BEFORE a
     full snapshot copy of the source tables into pipeline-db, then store that offset. Events that
     overlap the snapshot get re-applied later — harmless, applies are idempotent upserts by PK.
  2. STREAM: read row events from the stored offset; apply each to the local copy and advance the
     offset in `cdc_state` (apply + offset committed together → at-least-once).
  3. As it applies a changed row it stamps the LOCAL copy's `date_updated = <event time>`, so the
     existing SQLMesh `changed_at` + loader watermark detect the change downstream — even though
     Consolidé's own `date_updated` may be NULL.
  4. After draining a batch of events it triggers one `sqlmesh run` + push cycle (debounced).

Requires on Consolidé: log_bin=ON, binlog_format=ROW (already set), and a user with
REPLICATION SLAVE + REPLICATION CLIENT (+ SELECT for the snapshot). DDL/schema changes are NOT
handled — a source schema change needs a re-snapshot (delete the cdc_state row).

Env (in addition to sync_source's SRC_*/FHIR_DB_*):
  CDC_SERVER_ID   unique replica id for this reader (default 42424242)
  CDC_DEBOUNCE_S  seconds to batch events before triggering a downstream cycle (default 5)
"""
import os
import subprocess
import time
from datetime import datetime, timezone

import pymysql
from pymysqlreplication import BinLogStreamReader
from pymysqlreplication.row_event import DeleteRowsEvent, UpdateRowsEvent, WriteRowsEvent

import sync_source as S  # reuse env, SRC/DST connection settings, DST_DB, source_tables(), sync_table

SERVER_ID = int(os.environ.get("CDC_SERVER_ID", "42424242"))
DEBOUNCE = float(os.environ.get("CDC_DEBOUNCE_S", "5"))
DST_DB = S.DST_DB
SRC_DB = S.SRC["database"]

_HAS_COL = {}  # cache: (table, col) -> bool


def has_col(dcur, table, col):
    key = (table, col)
    if key not in _HAS_COL:
        dcur.execute(
            "SELECT 1 FROM information_schema.columns "
            "WHERE table_schema=%s AND table_name=%s AND column_name=%s LIMIT 1",
            (DST_DB, table, col),
        )
        _HAS_COL[key] = dcur.fetchone() is not None
    return _HAS_COL[key]


def ensure_cdc_state(dcur):
    dcur.execute(
        f"CREATE TABLE IF NOT EXISTS `{DST_DB}`.cdc_state "
        "(id TINYINT PRIMARY KEY, log_file VARCHAR(255) NOT NULL, log_pos BIGINT NOT NULL)"
    )


def get_offset(dcur):
    dcur.execute(f"SELECT log_file, log_pos FROM `{DST_DB}`.cdc_state WHERE id=1")
    r = dcur.fetchone()
    return (r[0], r[1]) if r else (None, None)


def set_offset(dcur, log_file, log_pos):
    dcur.execute(
        f"INSERT INTO `{DST_DB}`.cdc_state (id, log_file, log_pos) VALUES (1, %s, %s) "
        "ON DUPLICATE KEY UPDATE log_file=VALUES(log_file), log_pos=VALUES(log_pos)",
        (log_file, log_pos),
    )


def bootstrap(s, d):
    """Pin the binlog position, then full-copy the source into pipeline-db. Position is taken
    BEFORE the copy so we never miss writes that land mid-snapshot (they re-apply idempotently)."""
    scur, dcur = s.cursor(), d.cursor()
    scur.execute("SHOW MASTER STATUS")
    row = scur.fetchone()
    if not row:
        raise RuntimeError("SHOW MASTER STATUS empty — is the binlog on / do we have REPLICATION CLIENT?")
    log_file, log_pos = row[0], row[1]
    print(f"cdc: bootstrap snapshot; pinned offset {log_file}:{log_pos}", flush=True)
    dcur.execute("SET SESSION sql_mode=''")
    dcur.execute("SET FOREIGN_KEY_CHECKS=0")
    dcur.execute(f"CREATE DATABASE IF NOT EXISTS `{DST_DB}`")
    for t in S.source_tables():
        n, mode = S.sync_table(scur, dcur, t)
        d.commit()
        print(f"  cdc snapshot {t}: {n} rows ({mode})", flush=True)
    ensure_cdc_state(dcur)
    set_offset(dcur, log_file, log_pos)
    d.commit()
    return log_file, log_pos


def _row_values(event, row):
    return row["after_values"] if isinstance(event, UpdateRowsEvent) else row["values"]


def apply_event(dcur, event, stamp):
    """Apply one binlog row event to the local copy. Returns rows applied. Only our source DB."""
    if event.schema != SRC_DB:
        return 0
    table = event.table
    pk = event.primary_key
    pk_cols = list(pk) if isinstance(pk, (list, tuple)) else ([pk] if pk else [])
    applied = 0
    for row in event.rows:
        if isinstance(event, DeleteRowsEvent):
            vals = row["values"]
            if not pk_cols:
                continue  # can't safely delete without a PK; skip (re-snapshot would reconcile)
            cond = " AND ".join(f"`{c}`=%s" for c in pk_cols)
            dcur.execute(f"DELETE FROM `{DST_DB}`.`{table}` WHERE {cond}", [vals[c] for c in pk_cols])
        else:
            vals = dict(_row_values(event, row))
            # stamp the LOCAL copy so SQLMesh changed_at advances even if Consolidé's date_updated is NULL
            if has_col(dcur, table, "date_updated"):
                vals["date_updated"] = stamp
            cols = list(vals.keys())
            collist = ",".join(f"`{c}`" for c in cols)
            ph = ",".join(["%s"] * len(cols))
            dcur.execute(
                f"REPLACE INTO `{DST_DB}`.`{table}` ({collist}) VALUES ({ph})",
                [vals[c] for c in cols],
            )
        applied += 1
    return applied


def trigger_cycle():
    """Run the downstream transform + push once (event-driven equivalent of run_continuous's body)."""
    subprocess.run(["sqlmesh", "run"], check=False)
    subprocess.run(["python", "loader/push_to_openhim.py"], check=False)


def main():
    s = pymysql.connect(**S.SRC)
    d = pymysql.connect(**S.DST, autocommit=False)
    dcur = d.cursor()
    ensure_cdc_state(dcur)
    d.commit()

    log_file, log_pos = get_offset(dcur)
    if not log_file:
        log_file, log_pos = bootstrap(s, d)
        trigger_cycle()  # push the snapshot

    stream = BinLogStreamReader(
        connection_settings=dict(
            host=S.SRC["host"], port=S.SRC["port"], user=S.SRC["user"], passwd=S.SRC["password"]
        ),
        server_id=SERVER_ID,
        only_schemas=[SRC_DB],
        only_events=[WriteRowsEvent, UpdateRowsEvent, DeleteRowsEvent],
        log_file=log_file,
        log_pos=log_pos,
        resume_stream=True,
        blocking=False,  # drain available events, then sleep + trigger a cycle (debounce)
    )
    print(f"cdc: streaming from {log_file}:{log_pos} (server_id={SERVER_ID})", flush=True)
    try:
        while True:
            applied = 0
            for event in stream:
                stamp = datetime.fromtimestamp(event.timestamp, tz=timezone.utc).strftime(
                    "%Y-%m-%d %H:%M:%S"
                )
                applied += apply_event(dcur, event, stamp)
                set_offset(dcur, stream.log_file, stream.log_pos)
                d.commit()  # apply + offset advance together
            if applied:
                print(f"cdc: applied {applied} change(s) -> {stream.log_file}:{stream.log_pos}", flush=True)
                trigger_cycle()
            time.sleep(DEBOUNCE)
    finally:
        stream.close()


if __name__ == "__main__":
    main()
