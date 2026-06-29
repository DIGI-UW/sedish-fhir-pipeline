#!/usr/bin/env bash
#
# Continuous micro-batch loop — keeps consolidated_db → OpenCR/SHR in near-real-time.
#
# Each cycle:
#   1. sync_source.py      (SYNC mode only) — copy changed rows of consolidated_db into the local DB
#   2. sqlmesh run --ignore-cron — rebuild fhir.* NOW for rows changed since the last cycle
#                            (--ignore-cron so latency is the loop INTERVAL, not the model's
#                            5-min cron; allow_partials lets it process the open interval)
#   3. push_to_openhim.py  — POST changed per-patient bundles to the fhir-router mediator
#   4. reconcile.py        — retract SHR clinical the source no longer produces (off unless
#                            RECONCILE_RETRACT_EVERY>0; self-gates on its own cadence)
#   5. sleep INTERVAL
#
# Change-gated (SYNC mode): the transform+push stages run only when sync_source actually copied
# new/changed rows (exit 0). When it reports "nothing changed" (exit 20) they are skipped, so an
# idle network doesn't re-scan the source every cycle. A `pending` flag forces a run on the next
# cycle if transform or push failed, so unfinished work is never stranded. DIRECT mode (no SRC_HOST)
# has no sync signal, so it always runs.
#
# Every stage is idempotent (sync REPLACEs by PK, SQLMesh tracks its high-water mark, the loader
# upserts via PUT-by-id and holds its watermark on failure), so a failed or repeated cycle
# converges rather than duplicating. A stage failure is logged and retried, not fatal.
#
set -uo pipefail

INTERVAL="${INTERVAL:-30}"   # seconds between cycles
NO_CHANGES_EXIT=20           # sync_source.py exit code meaning "clean run, nothing changed"
ts() { date -u +%H:%M:%S; }

echo "continuous loader: cycle every ${INTERVAL}s (Ctrl-C to stop)"
pending=1   # force a full run on boot (initial load)
while true; do
  changed=0
  if [ -n "${SRC_HOST:-}" ]; then
    python loader/sync_source.py
    rc=$?
    if [ "$rc" -eq 0 ]; then
      changed=1
    elif [ "$rc" -eq "$NO_CHANGES_EXIT" ]; then
      changed=0
    else
      echo "$(ts) sync failed — retrying next cycle"; changed=1   # on error, be safe and run
    fi
  else
    changed=1   # DIRECT mode: no sync signal, always run
  fi

  if [ "$changed" -eq 1 ] || [ "$pending" -eq 1 ]; then
    pending=0
    sqlmesh run --ignore-cron        || { echo "$(ts) sqlmesh run failed — retrying next cycle"; pending=1; }
    python loader/push_to_openhim.py || { echo "$(ts) load failed — retrying next cycle"; pending=1; }
  fi

  python loader/reconcile.py         || echo "$(ts) reconcile failed — retrying next cycle"
  sleep "$INTERVAL"
done
