#!/usr/bin/env python3
"""Event-driven driver: run the pipeline when the consolidated server publishes
patient-changed events to Kafka — the alternative to run_continuous.sh's poll.

The consolidated server's CDC reader already emits one event per changed binlog
row to KAFKA_TOPIC (default `fhir.patient.changed`). This consumer debounces a
burst of those events and then runs ONE pipeline cycle:

    sqlmesh run --ignore-cron      # incremental transform: consolidated_db -> fhir.*
    loader/push_to_openhim.py      # push the delta to OpenCR (/CR) + SHR (/SHR)

Design notes (why this is safe):
  * The event payload is IGNORED — events are a *trigger*, not data. Correctness
    comes from the incremental models + the loader's `date_updated` watermark, so a
    missed or duplicated event can't corrupt state; at worst it causes a redundant
    (idempotent) cycle.
  * A failed cycle does NOT advance the loader watermark, so the next event simply
    retries the outstanding delta — no event-replay bookkeeping needed.
  * Idle topic => no work (unlike the poll, which ran every INTERVAL regardless).

Env: KAFKA_BROKERS, KAFKA_TOPIC, KAFKA_GROUP, DEBOUNCE_SECONDS (default 5).
Plus the loader's env (OPENCR_*, SHR_*, FHIR_DB_*) and a SQLMesh config.yaml.
"""
import os
import sys
import time
import logging
import subprocess

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("kafka-driver")

BROKERS = [b.strip() for b in os.environ.get("KAFKA_BROKERS", "kafka:9092").split(",") if b.strip()]
TOPIC = os.environ.get("KAFKA_TOPIC", "fhir.patient.changed")
GROUP = os.environ.get("KAFKA_GROUP", "fhir-pipeline")
DEBOUNCE = float(os.environ.get("DEBOUNCE_SECONDS", "5"))

# the two steps of one pipeline cycle (overridable for tests)
CYCLE_STEPS = (
    ["sqlmesh", "run", "--ignore-cron"],
    [sys.executable, "loader/push_to_openhim.py"],
)


def run_cycle(n_events):
    """Run sqlmesh transform + loader once. Returns True iff every step succeeded."""
    log.info("pipeline cycle triggered by %d event(s)", n_events)
    for cmd in CYCLE_STEPS:
        rc = subprocess.run(cmd).returncode
        if rc != 0:
            log.error("step failed (rc=%s): %s — will retry on the next event", rc, " ".join(cmd))
            return False
    log.info("pipeline cycle complete")
    return True


def make_consumer():
    """Best-effort KafkaConsumer, retrying until the broker is reachable."""
    from kafka import KafkaConsumer
    while True:
        try:
            return KafkaConsumer(
                TOPIC, bootstrap_servers=BROKERS, group_id=GROUP,
                enable_auto_commit=True, auto_offset_reset="latest",
                consumer_timeout_ms=0,
            )
        except Exception as e:  # noqa: BLE001
            log.info("waiting for kafka %s (%s)", BROKERS, e)
            time.sleep(3)


def drain(consumer, first_count):
    """After the first event(s), keep collecting for DEBOUNCE seconds so a burst of
    row-level events collapses into a single pipeline cycle."""
    n = first_count
    deadline = time.time() + DEBOUNCE
    while time.time() < deadline:
        more = consumer.poll(timeout_ms=int(DEBOUNCE * 1000))
        if more:
            n += sum(len(v) for v in more.values())
        else:
            break
    return n


def main():
    consumer = make_consumer()
    log.info("listening on %s (topic=%s group=%s, debounce=%ss)", BROKERS, TOPIC, GROUP, DEBOUNCE)
    while True:
        batch = consumer.poll(timeout_ms=1000)
        if not batch:
            continue
        n = drain(consumer, sum(len(v) for v in batch.values()))
        run_cycle(n)


if __name__ == "__main__":
    sys.exit(main())
