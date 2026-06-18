#!/usr/bin/env bash
#
# Continuous micro-batch loop — keeps consolidated_db → OpenCR/SHR in near-real-time.
#
# Each cycle:
#   1. sync_source.py      (SYNC mode only) — copy changed rows of consolidated_db into the local DB
#   2. sqlmesh run         — incrementally rebuild fhir.* for rows changed since the last cycle
#   3. push_to_openhim.py  — POST changed per-patient bundles to the fhir-router mediator
#   4. sleep INTERVAL
#
# Every stage is idempotent (sync REPLACEs by PK, SQLMesh tracks its high-water mark, the loader
# upserts via PUT-by-id and holds its watermark on failure), so a failed or repeated cycle
# converges rather than duplicating. A stage failure is logged and retried next cycle, not fatal.
#
set -uo pipefail

INTERVAL="${INTERVAL:-30}"   # seconds between cycles
ts() { date -u +%H:%M:%S; }

echo "continuous loader: cycle every ${INTERVAL}s (Ctrl-C to stop)"
while true; do
  if [ -n "${SRC_HOST:-}" ]; then
    python loader/sync_source.py   || echo "$(ts) sync failed — retrying next cycle"
  fi
  sqlmesh run                      || echo "$(ts) sqlmesh run failed — retrying next cycle"
  python loader/push_to_openhim.py || echo "$(ts) load failed — retrying next cycle"
  sleep "$INTERVAL"
done
