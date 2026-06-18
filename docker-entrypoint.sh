#!/usr/bin/env sh
# Render config.yaml, build the output schema, then serve the continuous loop.
#
# DIRECT mode (only mode): SQLMesh runs ON Consolidé — FHIR_DB_* points at the Consolidé server,
# which holds consolidated_db (read) and the fhir/sqlmesh/sqlmesh__fhir schemas (write). No copy.
set -e

# FHIR_DB_* = the MySQL SQLMesh reads (consolidated_db) and writes (fhir) — i.e. Consolidé.
: "${FHIR_DB_HOST:?FHIR_DB_HOST is required}"
: "${FHIR_DB_USER:?FHIR_DB_USER is required}"
: "${FHIR_DB_PASS:?FHIR_DB_PASS is required}"
: "${FHIR_DB_PORT:=3306}"
: "${FHIR_DB_NAME:=fhir}"
: "${FHIR_TEST_DB:=fhir_test}"   # empty omits the test gateway (prod — no `sqlmesh test`)
: "${ENSURE_DBS:=1}"             # 0 when schemas are pre-created (prod, no CREATE privilege)

TEST_CONN=""
if [ -n "${FHIR_TEST_DB}" ]; then
  TEST_CONN="
    test_connection: {type: mysql, host: ${FHIR_DB_HOST}, port: ${FHIR_DB_PORT}, user: ${FHIR_DB_USER}, password: ${FHIR_DB_PASS}, database: ${FHIR_TEST_DB}}"
fi

cat > /app/config.yaml <<YAML
gateways:
  mysql:
    connection: {type: mysql, host: ${FHIR_DB_HOST}, port: ${FHIR_DB_PORT}, user: ${FHIR_DB_USER}, password: ${FHIR_DB_PASS}, database: ${FHIR_DB_NAME}}${TEST_CONN}
default_gateway: mysql
model_defaults: {dialect: mysql}
disable_anonymized_analytics: true
YAML

# Wait for the DB. ENSURE_DBS=1 creates the schemas; ENSURE_DBS=0 (pre-created, no CREATE) just
# verifies it's reachable + exists. Idempotent.
echo "entrypoint: waiting for MySQL ${FHIR_DB_HOST} (ensure_dbs=${ENSURE_DBS})"
until python - <<PY 2>/dev/null
import pymysql
c = pymysql.connect(host="${FHIR_DB_HOST}", port=${FHIR_DB_PORT}, user="${FHIR_DB_USER}", password="${FHIR_DB_PASS}")
with c.cursor() as cur:
    if "${ENSURE_DBS}" == "1":
        cur.execute("CREATE DATABASE IF NOT EXISTS \`${FHIR_DB_NAME}\`")
        if "${FHIR_TEST_DB}":
            cur.execute("CREATE DATABASE IF NOT EXISTS \`${FHIR_TEST_DB}\`")
    cur.execute("USE \`${FHIR_DB_NAME}\`")
c.commit()
PY
do
  echo "entrypoint: MySQL not ready / ${FHIR_DB_NAME} missing, retrying in 5s"; sleep 5
done

echo "entrypoint: applying initial sqlmesh plan"
until sqlmesh plan --auto-apply --skip-tests; do
  echo "entrypoint: plan failed, retrying in 10s"; sleep 10
done

echo "entrypoint: starting the continuous loop"
exec sh loader/run_continuous.sh
