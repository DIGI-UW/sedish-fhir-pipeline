#!/usr/bin/env bash
# Continuous micro-batch: keep consolidated_db → OpenCR/SHR in sync in near-real-time.
#
# This pipeline is NOT a one-time run. A patient created at a site reaches the
# consolidated server (CDC), and from there must flow into SEDISH on its own. This
# loop is the simplest way to run that continuously:
#
#   forever:
#     1. sqlmesh run          -> incrementally refresh fhir.* for rows changed since last cycle
#     2. push_to_openhim.py   -> PUT new/changed Patients to OpenCR, POST clinical Bundles to SHR
#     3. sleep INTERVAL
#
# Latency ≈ INTERVAL. Both stages are idempotent (SQLMesh tracks the high-water mark;
# the loader upserts by source key), so a re-run never double-creates — it converges.
set -uo pipefail
INTERVAL="${INTERVAL:-30}"   # seconds between cycles
echo "continuous loader: cycle every ${INTERVAL}s (Ctrl-C to stop)"
while true; do
  sqlmesh run                   || echo "$(date -u +%T) sqlmesh run failed — retry next cycle"
  python loader/push_to_openhim.py || echo "$(date -u +%T) load failed — retry next cycle"
  sleep "$INTERVAL"
done
