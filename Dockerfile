# Deployable pipeline image: SQLMesh transform + loader, driven by Kafka events
# (RUN_MODE=kafka, default) or a poll (RUN_MODE=poll). config.yaml is rendered
# from env at start, so the image carries no connection details.
FROM python:3.12-slim
WORKDIR /app
RUN pip install --no-cache-dir "sqlmesh>=0.235" "pymysql>=1.1.1" "kafka-python>=2.0" cryptography
COPY . /app
ENV HOME=/tmp
ENTRYPOINT ["/app/docker-entrypoint.sh"]
