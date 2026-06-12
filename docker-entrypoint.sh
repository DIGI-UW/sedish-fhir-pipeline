#!/usr/bin/env sh
# Render config.yaml from env, ensure the output schema is built, then serve.
set -e

: "${FHIR_DB_HOST:=consolidated-db}"
: "${FHIR_DB_PORT:=3306}"
: "${FHIR_DB_USER:=root}"
: "${FHIR_DB_PASS:=consolidated}"
: "${FHIR_DB_NAME:=fhir}"
: "${FHIR_TEST_DB:=fhir_test}"
: "${NATIONAL_ID_SYSTEM:=http://isanteplus.org/openmrs/fhir2/6-biometrics-national-reference-code}"
: "${RUN_MODE:=kafka}"

cat > /app/config.yaml <<YAML
gateways:
  mysql:
    connection: {type: mysql, host: ${FHIR_DB_HOST}, port: ${FHIR_DB_PORT}, user: ${FHIR_DB_USER}, password: ${FHIR_DB_PASS}, database: ${FHIR_DB_NAME}}
    test_connection: {type: mysql, host: ${FHIR_DB_HOST}, port: ${FHIR_DB_PORT}, user: ${FHIR_DB_USER}, password: ${FHIR_DB_PASS}, database: ${FHIR_TEST_DB}}
default_gateway: mysql
model_defaults: {dialect: mysql}
variables: {national_id_system: '${NATIONAL_ID_SYSTEM}'}
disable_anonymized_analytics: true
YAML

# Build/refresh the output schema. Retry: consolidated_db (the source the external
# models read) may still be initialising / unpopulated when we start.
echo "entrypoint: applying initial sqlmesh plan (retrying until consolidated_db is ready)"
until sqlmesh plan --auto-apply; do
  echo "entrypoint: plan not ready yet, retrying in 10s"
  sleep 10
done

case "${RUN_MODE}" in
  kafka) echo "entrypoint: RUN_MODE=kafka"; exec python loader/run_kafka.py ;;
  poll)  echo "entrypoint: RUN_MODE=poll";  exec sh loader/run_continuous.sh ;;
  *) echo "entrypoint: unknown RUN_MODE='${RUN_MODE}' (use kafka|poll)"; exit 1 ;;
esac
