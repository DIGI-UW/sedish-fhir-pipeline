#!/usr/bin/env bash
# Continuous micro-batch: keep consolidated_db → OpenCR/SHR in near-real-time. Each cycle:
#   1. sqlmesh run          -> incrementally refresh fhir.* for rows changed since last cycle
#   2. push_to_openhim.py   -> POST changed per-patient bundles to the mediator (-> OpenCR + SHR)
#   3. sleep INTERVAL
# Idempotent (SQLMesh high-water mark + the loader watermark/PUT-by-id), so a re-run never double-creates.
set -uo pipefail
INTERVAL="${INTERVAL:-30}"   # seconds between cycles
echo "continuous loader: cycle every ${INTERVAL}s (Ctrl-C to stop)"
while true; do
  sqlmesh run                      || echo "$(date -u +%T) sqlmesh run failed — retry next cycle"
  python loader/push_to_openhim.py || echo "$(date -u +%T) load failed — retry next cycle"
  sleep "$INTERVAL"
done
