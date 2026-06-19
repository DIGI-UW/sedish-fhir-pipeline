#!/usr/bin/env python3
"""Sync the EXTERNAL (read-only) Consolidé consolidated_db into the LOCAL pipeline MySQL.

Why: SQLMesh runs one SQL statement per model and MySQL can't JOIN across servers, so the
source tables must live on the same server SQLMesh writes to. With only read-only access to
Consolidé we copy the source into a local MySQL and run SQLMesh against that copy. Read-only
`SELECT` is all this needs on the remote (no replication, no write).

Change detection with only SELECT: we don't have the binlog (that needs REPLICATION). Instead we
watermark on the most recent of whichever timestamp columns a table has —
`GREATEST(date_updated, date_changed, date_created)`. `date_created` is set on INSERT, so **new
rows are always caught** even when `date_updated`/`date_changed` are NULL (as in the Consolidé test
instance). Edits that don't move any timestamp, and DELETEs, can't be seen incrementally — a
periodic **full reconcile** (SYNC_RECONCILE_EVERY) re-copies everything on a slow cadence to catch
them. (If/when CHARESS grants REPLICATION, loader/cdc_stream.py replaces this with true CDC.)

Per table: create it locally if absent (from the remote DDL); then copy — incrementally by the
change expression where a timestamp exists (REPLACE by PK), full otherwise / on reconcile.
Idempotent; a per-table watermark lives in `<DST_DB>.sync_state`.

Env:
  SRC_HOST/SRC_PORT/SRC_USER/SRC_PASS   external Consolidé MySQL (read-only)
  SRC_DB   (default consolidated_db)
  FHIR_DB_HOST/PORT/USER/PASS           local pipeline MySQL (writable)
  DST_DB   (default consolidated_db)    local schema to sync into
  SYNC_BATCH (default 5000)             rows per insert batch
  SYNC_PROGRESS_EVERY (default 50000)   emit a progress line every N rows while copying a table
  SYNC_RECONCILE_EVERY (default 3600)   seconds between full reconciles (catches edits/deletes);
                                        0 disables (pure incremental = new rows only)
  SYNC_REFRESH_STATIC                   force a re-copy of static reference tables every cycle
"""
import os
import re
import time
import pymysql

def env(k, d=None): return os.environ.get(k, d)

def log(msg):
    # timestamped + flushed (stdout is block-buffered under `docker logs`)
    print(f"{time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())} {msg}", flush=True)

SRC = dict(host=env("SRC_HOST"), port=int(env("SRC_PORT", "3306")),
           user=env("SRC_USER"), password=env("SRC_PASS"),
           database=env("SRC_DB", "consolidated_db"), connect_timeout=10, read_timeout=600)
DST = dict(host=env("FHIR_DB_HOST", "pipeline-db"), port=int(env("FHIR_DB_PORT", "3306")),
           user=env("FHIR_DB_USER", "root"), password=env("FHIR_DB_PASS", "root"),
           connect_timeout=10)
DST_DB = env("DST_DB", "consolidated_db")
BATCH = int(env("SYNC_BATCH", "5000"))
# Emit a progress line roughly every this many rows while copying a (large) table.
PROGRESS_EVERY = int(env("SYNC_PROGRESS_EVERY", "50000"))
# Timestamp columns we'll watermark on, most-recent-wins. date_created catches INSERTs (new
# patients) even when the others are NULL.
CHANGE_COLS = ("date_updated", "date_changed", "date_created")
# Full reconcile cadence (seconds) — re-copy everything to catch edits/deletes the timestamps miss.
RECONCILE_EVERY = int(env("SYNC_RECONCILE_EVERY", "3600"))
# Tables without any change timestamp (concept/concept_name/dimensions) are static reference data:
# sync once, then skip while populated. SYNC_REFRESH_STATIC=1 forces a re-copy (e.g. CIEL update).
REFRESH_STATIC = env("SYNC_REFRESH_STATIC", "") not in ("", "0", "false")
EPOCH = "1970-01-01 00:00:00"

# Tables the SQLMesh models read — taken from external_models.yaml so it stays in lockstep.
def source_tables():
    here = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    txt = open(os.path.join(here, "external_models.yaml")).read()
    seen, out = set(), []
    for t in re.findall(r"`consolidated_db`\.`([a-z_]+)`", txt):
        if t not in seen:
            seen.add(t)
            out.append(t)
    return out

def has_column(cur, db, table, col):
    cur.execute("""SELECT 1 FROM information_schema.columns
                   WHERE table_schema=%s AND table_name=%s AND column_name=%s LIMIT 1""", (db, table, col))
    return cur.fetchone() is not None

def change_expr(scur, table):
    """SQL expr = most recent of whichever change timestamps `table` has, or None if it has none."""
    cols = [c for c in CHANGE_COLS if has_column(scur, SRC["database"], table, c)]
    if not cols:
        return None
    parts = [f"COALESCE(`{c}`, TIMESTAMP'{EPOCH}')" for c in cols]
    return f"GREATEST({', '.join(parts)})" if len(parts) > 1 else parts[0]

def primary_key_cols(dcur, table):
    """PK column name(s) of the local table — used to name a row in failure logs."""
    dcur.execute("""SELECT column_name FROM information_schema.key_column_usage
                    WHERE table_schema=%s AND table_name=%s AND constraint_name='PRIMARY'
                    ORDER BY ordinal_position""", (DST_DB, table))
    return [r[0] for r in dcur.fetchall()]

def ensure_state(dcur):
    dcur.execute(f"CREATE TABLE IF NOT EXISTS `{DST_DB}`.sync_state "
                 "(table_name VARCHAR(64) PRIMARY KEY, last_updated DATETIME NOT NULL)")

def watermark(dcur, table):
    dcur.execute(f"SELECT last_updated FROM `{DST_DB}`.sync_state WHERE table_name=%s", (table,))
    r = dcur.fetchone()
    return r[0].strftime("%Y-%m-%d %H:%M:%S") if r else EPOCH

def advance(dcur, table, ts):
    dcur.execute(f"INSERT INTO `{DST_DB}`.sync_state (table_name,last_updated) VALUES (%s,%s) "
                 "ON DUPLICATE KEY UPDATE last_updated=VALUES(last_updated)", (table, ts))

def due_for_reconcile(dcur):
    """True if a full reconcile is due (never run, or older than RECONCILE_EVERY). 0 disables."""
    if RECONCILE_EVERY <= 0:
        return False
    dcur.execute(f"SELECT TIMESTAMPDIFF(SECOND, last_updated, NOW()) FROM `{DST_DB}`.sync_state "
                 "WHERE table_name='__reconcile__'")
    r = dcur.fetchone()
    return r is None or r[0] is None or r[0] >= RECONCILE_EVERY

def mark_reconcile(dcur):
    dcur.execute(f"INSERT INTO `{DST_DB}`.sync_state (table_name,last_updated) VALUES ('__reconcile__', NOW()) "
                 "ON DUPLICATE KEY UPDATE last_updated=NOW()")

def sync_table(scur, dcur, table, force_full=False):
    # create locally from the remote DDL if missing (sql_mode='' tolerates legacy zero-dates)
    dcur.execute("SELECT 1 FROM information_schema.tables WHERE table_schema=%s AND table_name=%s", (DST_DB, table))
    if not dcur.fetchone():
        scur.execute(f"SHOW CREATE TABLE `{table}`")
        dcur.execute(f"USE `{DST_DB}`")
        dcur.execute(scur.fetchone()[1])
    expr = change_expr(scur, table)
    has_ts = expr is not None
    # static reference table (no change timestamp): sync once, then skip while already populated
    if not has_ts and not REFRESH_STATIC and not force_full:
        dcur.execute(f"SELECT EXISTS(SELECT 1 FROM `{DST_DB}`.`{table}` LIMIT 1)")
        if dcur.fetchone()[0]:
            return 0, 0, "static (cached)"
    since = watermark(dcur, table) if has_ts else EPOCH
    # Incremental only AFTER a baseline full copy and when not reconciling. The first sync is full,
    # so NULL-timestamp rows aren't missed; the reconcile periodically re-copies to catch edits/deletes.
    incremental = has_ts and since != EPOCH and not force_full
    if incremental:
        scur.execute(f"SELECT * FROM `{table}` WHERE {expr} > %s", (since,))
    else:
        dcur.execute(f"TRUNCATE `{DST_DB}`.`{table}`")
        scur.execute(f"SELECT * FROM `{table}`")
    cols = [c[0] for c in scur.description]
    collist = ",".join("`" + c + "`" for c in cols)
    ph = ",".join(["%s"] * len(cols))
    verb = "REPLACE" if incremental else "INSERT"
    sql = f"{verb} INTO `{DST_DB}`.`{table}` ({collist}) VALUES ({ph})"

    # name a row by its PK in failure logs (fall back to the first column if there's no PK)
    pk = primary_key_cols(dcur, table) or cols[:1]
    pk_idx = [cols.index(c) for c in pk if c in cols]
    def rowkey(row):
        return ", ".join(f"{cols[i]}={row[i]!r}" for i in pk_idx) if pk_idx else "?"

    conn = dcur.connection
    n = failed = logged = 0
    while True:
        rows = scur.fetchmany(BATCH)
        if not rows:
            break
        try:
            dcur.executemany(sql, rows)
            conn.commit()
            n += len(rows)
        except Exception as batch_err:  # noqa: BLE001 — isolate the bad row(s); keep the good ones
            conn.rollback()
            log(f"    {table}: batch of {len(rows)} failed ({str(batch_err)[:120]}); isolating rows…")
            for row in rows:
                try:
                    dcur.execute(sql, row)
                    conn.commit()
                    n += 1
                except Exception as row_err:  # noqa: BLE001
                    conn.rollback()
                    failed += 1
                    log(f"    {table}: SKIP row [{rowkey(row)}] — {str(row_err)[:160]}")
        if n - logged >= PROGRESS_EVERY:
            logged = n
            log(f"    {table}: {n} rows copied…")
    # advance the watermark to the latest change time on the source (so next run is incremental)
    if has_ts:
        scur.execute(f"SELECT MAX({expr}) FROM `{table}`")
        m = scur.fetchone()[0]
        if m is not None:
            mstr = m.strftime("%Y-%m-%d %H:%M:%S") if hasattr(m, "strftime") else str(m)
            if mstr > since:
                advance(dcur, table, mstr)
    mode = "reconcile (full)" if force_full else ("incremental" if incremental else "full")
    return n, failed, mode

def main():
    s = pymysql.connect(**SRC)
    d = pymysql.connect(**DST, autocommit=False)
    with s.cursor() as scur, d.cursor() as dcur:
        dcur.execute("SET SESSION sql_mode=''")
        dcur.execute("SET FOREIGN_KEY_CHECKS=0")
        dcur.execute(f"CREATE DATABASE IF NOT EXISTS `{DST_DB}`")
        ensure_state(dcur)
        force_full = due_for_reconcile(dcur)   # decided once so all tables reconcile together
        if force_full:
            log("sync: full reconcile this cycle (catches edits/deletes)")
        tables = source_tables()
        log(f"sync: {len(tables)} source tables -> {DST['host']}/{DST_DB}")
        total = bad = 0
        started = time.monotonic()
        for t in tables:
            t0 = time.monotonic()
            try:
                n, failed, mode = sync_table(scur, dcur, t, force_full)
                d.commit()   # commit the watermark advance (rows were committed per batch)
                total += n
                bad += failed
                secs = round(time.monotonic() - t0, 1)
                extra = f", {failed} row(s) SKIPPED" if failed else ""
                log(f"  sync {t}: {n} rows ({mode}) in {secs}s{extra}")
            except Exception as e:  # noqa: BLE001 — keep syncing the rest; surface the failure
                d.rollback()
                log(f"  sync {t}: FAILED — {str(e)[:200]}")
        if force_full:
            mark_reconcile(dcur)
            d.commit()
        elapsed = round(time.monotonic() - started, 1)
        verdict = f"{total} rows across {len(tables)} tables in {elapsed}s"
        log(f"sync done: {verdict}" + (f" — {bad} row(s) skipped (see SKIP lines above)" if bad else ""))

if __name__ == "__main__":
    main()
