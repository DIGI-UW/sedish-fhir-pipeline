#!/usr/bin/env python3
"""Load the FHIR that SQLMesh produced into SEDISH, via OpenHIM — incrementally.

Each run pushes only what changed since the last run. The `fhir.*` models carry a
`changed_at` column (latest consolidated-server write time); this loader keeps a
per-resource high-water mark in its own state table and, each cycle:

  1. reads patients / encounters / observations with changed_at > last watermark
  2. routes by resource type — no mode flag, the type IS the routing decision:
       IDENTITY  Patient   -> PUT {OPENCR_URL}/Patient?identifier=<src-key>   (OpenCR / MPI)
       CLINICAL  enc/obs/… -> POST {SHR_URL}  transaction Bundle per patient  (SHR)
       GLOBAL    location  -> PUT {SHR_URL}/{type}/{id}                        (SHR)
  3. advances each resource's watermark to the max changed_at it processed

Identity and clinical run every cycle off their OWN watermarks, so a single deployment
sends demographics to OpenCR and clinical to the SHR at the same time — you never redeploy
to "switch modes." A patient goes to the SHR when its clinical changes (not when only its
demographics change: demographics live in OpenCR, not the SHR). OpenCR de-dups identities;
the SHR re-points clinical refs onto the golden record. Idempotent — re-runs and overlaps
converge. First run (watermark epoch) pushes everything, i.e. the initial load.

Identity is paged (the ~2.39M initial load won't fit in memory) and upserts on the source
key (mspp_code+patient_id) per the CHARESS spec. To run identity-only (e.g. a go-live where
the SHR isn't validated yet), set CLINICAL_VIEWS= (empty) — no clinical is read or pushed;
no redeploy of logic, just config.

Env (defaults = stock SEDISH swarm):
  FHIR_DB_HOST/PORT/USER/PASS/NAME    where SQLMesh wrote the fhir.* views (NAME=fhir)
  STATE_DB                            isolated db for the watermark table (default loader_state)
  OPENHIM_USER/OPENHIM_PASS           OpenHIM client basic-auth — ONE client for both channels
                                      (default `consolidated`, role emr, allowed on /CR and /SHR)
  OPENCR_URL                          CR channel on OpenHIM (identity / MPI)
  SHR_URL                             SHR channel on OpenHIM (clinical + globals)
  CLINICAL_VIEWS                      patient-scoped clinical views to bundle to the SHR
                                      (empty = identity-only)
  DRY_RUN=1                           preview; don't POST and don't advance the watermark
"""
import base64
import collections
import json
import os
import time
import urllib.error
import urllib.request
import pymysql

def env(k, d): return os.environ.get(k, d)

FHIR_DB = dict(host=env("FHIR_DB_HOST", "fhir-mysql"), port=int(env("FHIR_DB_PORT", "3306")),
               user=env("FHIR_DB_USER", "root"), password=env("FHIR_DB_PASS", "root"),
               database=env("FHIR_DB_NAME", "fhir"))
STATE_DB   = env("STATE_DB", "loader_state")
OPENCR_URL = env("OPENCR_URL", "http://openhim-core:5001/CR/fhir").rstrip("/")
SHR_URL    = env("SHR_URL",    "http://openhim-core:5001/SHR/fhir").rstrip("/")
# /CR and /SHR are both OpenHIM channels, so we authenticate as a single OpenHIM client.
# The `consolidated` client (role 'emr') is allowed on both channels — one credential, not two.
OPENHIM = (env("OPENHIM_USER", "consolidated"), env("OPENHIM_PASS", "consolidated"))
DRY_RUN = env("DRY_RUN", "") not in ("", "0", "false")
# Idempotency key per the CHARESS spec: OpenCR upserts the source record on the source key
# (mspp_code+patient_id). Must match the `source_key_system` the patient model stamps, and be
# listed in OpenCR's `internalid` systems. Requires OpenCR conditional-update support.
SOURCE_KEY_SYSTEM = env("SOURCE_KEY_SYSTEM", "http://sedish-haiti.org/fhir/source-key")
EPOCH = "1970-01-01 00:00:00"
# Phase 1 processes patients in pages to avoid OOM on the ~2.39M patient initial load.
BATCH_SIZE = int(env("BATCH_SIZE", "500"))
# patient-scoped clinical views to push (each carries fhir_id, patient_fhir_id, changed_at).
# Add a resource = a SQLMesh model + an entry here.
CLINICAL_VIEWS = [v.strip() for v in env("CLINICAL_VIEWS", "encounter,observation,allergy_intolerance,condition,medication_request").split(",") if v.strip()]
# global (non-patient-scoped) resources: pushed to the SHR directly (not bundled per
# patient, not enrolled in OpenCR). Small reference resources, re-pushed each cycle (idempotent).
GLOBAL_VIEWS = [v.strip() for v in env("GLOBAL_VIEWS", "location").split(",") if v.strip()]

def _auth(c): return "Basic " + base64.b64encode(f"{c[0]}:{c[1]}".encode()).decode()

def send(url, method, cred, body, retries=3):
    if DRY_RUN:
        return "DRY_RUN"
    data = json.dumps(body).encode()
    for attempt in range(retries):
        req = urllib.request.Request(url, data=data, method=method,
                headers={"Content-Type": "application/fhir+json", "Authorization": _auth(cred)})
        try:
            with urllib.request.urlopen(req, timeout=120) as r:
                return str(r.status)
        except urllib.error.HTTPError as e:
            if 500 <= e.code < 600 and attempt < retries - 1:
                time.sleep(2 ** attempt)
                continue
            return f"ERR {e.code}: {e.read().decode()[:160]}"
        except Exception as e:
            if attempt < retries - 1:
                time.sleep(2 ** attempt)
                continue
            return f"EXC {e}"

def ensure_state(cur):
    cur.execute(f"CREATE DATABASE IF NOT EXISTS {STATE_DB}")
    cur.execute(f"""CREATE TABLE IF NOT EXISTS {STATE_DB}.loader_state (
                      resource_type VARCHAR(32) PRIMARY KEY,
                      last_changed_at DATETIME NOT NULL)""")

def watermark(cur, rtype):
    cur.execute(f"SELECT last_changed_at FROM {STATE_DB}.loader_state WHERE resource_type=%s", (rtype,))
    row = cur.fetchone()
    return row[0].strftime("%Y-%m-%d %H:%M:%S") if row else EPOCH

def advance(cur, rtype, ts):
    cur.execute(f"""INSERT INTO {STATE_DB}.loader_state (resource_type, last_changed_at) VALUES (%s,%s)
                    ON DUPLICATE KEY UPDATE last_changed_at=VALUES(last_changed_at)""", (rtype, ts))

def delta(cur, view, cols, since):
    cur.execute(f"SELECT {cols}, changed_at FROM fhir.{view} WHERE changed_at > %s", (since,))
    return cur.fetchall()

def delta_page(cur, view, cols, since, limit, offset):
    """One page of changed rows ordered deterministically for stable LIMIT/OFFSET pagination."""
    cur.execute(
        f"SELECT {cols}, changed_at FROM fhir.{view} "
        f"WHERE changed_at > %s ORDER BY changed_at, fhir_id LIMIT %s OFFSET %s",
        (since, limit, offset),
    )
    return cur.fetchall()

# --- pure helpers (no I/O; unit-tested in loader/tests) -------------------
def build_bundle(patient, clinical):
    """FHIR transaction Bundle: patient + its clinical, each PUT by resourceType/id."""
    return {"resourceType": "Bundle", "type": "transaction",
            "entry": [{"resource": r, "request": {"method": "PUT", "url": f"{r['resourceType']}/{r['id']}"}}
                      for r in [patient] + clinical]}

def cr_upsert_url(mspp_code, patient_id):
    """FHIR conditional update on the source key — the CHARESS idempotency contract:
    PUT /Patient?identifier=<source_key_system>|<mspp_code>-<patient_id>. OpenCR upserts the
    source record by this key (0 matches -> create, 1 -> update), so re-runs and the parallel
    real-time feed converge without duplicating the source record."""
    return f"{OPENCR_URL}/Patient?identifier={SOURCE_KEY_SYSTEM}|{mspp_code}-{patient_id}"

def index_clinical(*row_groups):
    """rows (fhir_id, patient_fhir_id, resource_json, changed_at) -> {patient_fhir_id: [resource_dict]}."""
    out = collections.defaultdict(list)
    for rows in row_groups:
        for _, pid, res, _ in rows:
            out[pid].append(json.loads(res))
    return out

def latest_changed(rows):
    """max changed_at (last tuple element) across rows, or None when empty."""
    return max((r[-1] for r in rows), default=None)

def push_globals(cur):
    """Push global (non-patient-scoped) resources straight to the SHR by id. Idempotent;
    re-pushed each cycle (these tables are small reference data, often without a change
    timestamp). Returns the failure count. Globals never go to OpenCR."""
    pushed = ok = 0
    for view in GLOBAL_VIEWS:
        try:
            cur.execute(f"SELECT fhir_id, resource FROM fhir.{view}")
            rows = cur.fetchall()
        except Exception as e:  # noqa: BLE001 — view may not exist yet
            print(f"  globals: skip {view} ({e})")
            continue
        for _fid, res in rows:
            r = json.loads(res)
            st = send(f"{SHR_URL}/{r['resourceType']}/{r['id']}", "PUT", OPENHIM, r)
            ok += st in ("200", "201", "DRY_RUN")
            pushed += 1
    if pushed:
        print(f"  globals: pushed {ok}/{pushed} ({','.join(GLOBAL_VIEWS)})")
    return pushed - ok

def push_identity(cur, conn):
    """Patient -> OpenCR. Paged (the ~2.39M initial load won't fit in memory) and upserted on
    the source key (mspp_code+patient_id) per the CHARESS spec, so re-runs and the parallel
    real-time feed converge without duplicating the source record. OpenCR does the matching/
    de-dup (decisionRules.json) — we are just the feeder. The patient watermark advances only
    when every push in the run succeeded; otherwise the delta is retried next cycle."""
    wm = watermark(cur, "patient")
    ok = fail = total = 0
    max_changed = None
    offset = 0
    while True:
        page = delta_page(cur, "patient", "fhir_id, mspp_code, patient_id, resource", wm, BATCH_SIZE, offset)
        if not page:
            break
        # sorted by fhir_id for deterministic ordering; the FHIR resource id stays the uuid
        # (so clinical bundles can reference Patient/{uuid}).
        for fhir_id, mspp_code, patient_id, res, _chg in sorted(page, key=lambda r: r[0]):
            cr = send(cr_upsert_url(mspp_code, patient_id), "PUT", OPENHIM, json.loads(res))
            good = cr in ("200", "201", "DRY_RUN")
            ok, fail = ok + good, fail + (not good)
            print(f"Patient/{fhir_id} (src {mspp_code}-{patient_id})  CR={cr}")
        batch_max = latest_changed(page)
        if batch_max and (max_changed is None or batch_max > max_changed):
            max_changed = batch_max
        total += len(page)
        offset += BATCH_SIZE
        if len(page) < BATCH_SIZE:
            break
    if not DRY_RUN:
        if fail == 0:
            if max_changed is not None:        # only commit when there was something to advance
                advance(cur, "patient", max_changed)
                conn.commit()
        else:
            print(f"  identity: holding watermark; {fail} CR push(es) failed; retried next cycle")
    print(f"  identity: patients={total} ok={ok} fail={fail}")
    return fail


def push_clinical(cur, conn):
    """Clinical (encounter/observation/…) -> SHR, as a transaction Bundle per patient. Driven
    only by the clinical watermarks (NOT the patient watermark), so a patient is sent to the
    SHR exactly when its clinical changes — a demographics-only change goes to OpenCR, not here.
    Adding a resource = a SQLMesh model + an entry in CLINICAL_VIEWS, nothing else here.
    Each view's watermark advances only when every push in the run succeeded."""
    wm = {v: watermark(cur, v) for v in CLINICAL_VIEWS}
    clinical = {v: delta(cur, v, "fhir_id, patient_fhir_id, resource", wm[v]) for v in CLINICAL_VIEWS}
    clin_by_pat = index_clinical(*clinical.values())
    touched = sorted(clin_by_pat)

    # fetch the current Patient resource for each touched patient (the bundle's reference target)
    patient_by_id = {}
    for i in range(0, len(touched), BATCH_SIZE):
        chunk = touched[i:i + BATCH_SIZE]
        fmt = ",".join(["%s"] * len(chunk))
        cur.execute(f"SELECT fhir_id, resource FROM fhir.patient WHERE fhir_id IN ({fmt})", chunk)
        for fid, res in cur.fetchall():
            patient_by_id[fid] = json.loads(res)

    ok = fail = 0
    for pid in touched:
        patient = patient_by_id.get(pid)
        if not patient:
            # No Patient row => voided/filtered. Skip; its clinical watermark still advances
            # (we won't retry). Safe: consolidated_db creates the person before its obs/encounter
            # (FK order), so a missing patient here means intentionally excluded, not a race.
            print(f"  skip {pid}: no Patient row (voided/absent)")
            continue
        shr = send(SHR_URL, "POST", OPENHIM, build_bundle(patient, clin_by_pat[pid]))
        good = shr in ("200", "201", "DRY_RUN")
        ok, fail = ok + good, fail + (not good)
        print(f"Patient/{pid}  SHR={shr}  changed_clinical={len(clin_by_pat[pid])}")

    if not DRY_RUN:
        if fail == 0:
            advanced = False
            for v, rows in clinical.items():
                latest = latest_changed(rows)
                if latest is not None:
                    advance(cur, v, latest)
                    advanced = True
            if advanced:                       # only commit when a watermark actually moved
                conn.commit()
        else:
            print(f"  clinical: holding watermark; {fail} SHR push(es) failed; retried next cycle")
    deltas = " ".join(f"{v}={len(rows)}" for v, rows in clinical.items())
    print(f"  clinical: patients={len(touched)} ok={ok} fail={fail}  (Δ {deltas})")
    return fail


def main():
    conn = pymysql.connect(**FHIR_DB, autocommit=False)
    with conn.cursor() as cur:
        ensure_state(cur)
        # One deployment, routing by resource type — no mode flag:
        #   Patient  -> OpenCR (identity / MPI)
        #   clinical -> SHR    (per-patient bundles)   [skipped if CLINICAL_VIEWS is empty]
        #   globals  -> SHR
        push_identity(cur, conn)
        if CLINICAL_VIEWS:
            push_clinical(cur, conn)
        if GLOBAL_VIEWS:
            push_globals(cur)
        print(f"DONE{'  [DRY_RUN]' if DRY_RUN else ''}")

if __name__ == "__main__":
    main()
