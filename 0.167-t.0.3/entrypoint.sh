#!/usr/bin/env sh

# Populate node.id from uuidgen by replacing template with the node uuid
nodeid() {
  sed -i "s/\$(uuid-generated-nodeid)/$(uuidgen)/g" /etc/presto/node.properties
}

coordinator_config() {
  (
    echo "coordinator=true"
    echo "node-scheduler.include-coordinator=false"
    echo "http-server.http.port=${HTTP_SERVER_PORT}"
    echo "query.max-memory=${PRESTO_MAX_MEMORY}GB"
    echo "query.max-memory-per-node=${PRESTO_MAX_MEMORY_PER_NODE}GB"
    echo "discovery-server.enabled=true"
    echo "discovery.uri=http://localhost:${HTTP_SERVER_PORT}"
  ) >/etc/presto/config.properties
}

worker_config() {
  (
    echo "coordinator=false"
    echo "http-server.http.port=${HTTP_SERVER_PORT}"
    echo "query.max-memory=${PRESTO_MAX_MEMORY}GB"
    echo "query.max-memory-per-node=${PRESTO_MAX_MEMORY_PER_NODE}GB"
    echo "discovery-server.enabled=true"
    echo "discovery.uri=http://${COORDINATOR}:${HTTP_SERVER_PORT}"
  ) >/etc/presto/config.properties
}

jvm_config() {
  sed -i "s/-Xmx.*G/-Xmx${PRESTO_JVM_HEAP_SIZE}G/" /etc/presto/jvm.config
}

hive_catalog_config() {
  (
    echo "connector.name=hive-hadoop2"
    echo "hive.metastore.uri=thrift://${HIVE_METASTORE_HOST}:${HIVE_METASTORE_PORT}"
    echo "hive.s3.aws-access-key=${AWS_ACCESS_KEY_ID}"
    echo "hive.s3.aws-secret-key=${AWS_SECRET_ACCESS_KEY_ID}"
  ) >/etc/presto/catalog/hive.properties
}

mysql_catalog_config() {
  (
    echo "connector.name=mysql"
    echo "connection-url=jdbc:mysql://${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}"
    echo "connection-user=${MYSQL_USER}"
    echo "connection-password=${MYSQL_PASSWORD}"
  ) >/etc/presto/catalog/mysql.properties
}

nodeid

# Update the Presto config.properties file with values for the coordinator and
# workers. Only if the following 3 parameters are set.
[[ -n "${HTTP_SERVER_PORT}" && -n "${PRESTO_MAX_MEMORY}" && -n "${PRESTO_MAX_MEMORY_PER_NODE}" ]] && \
if [[ -z "${COORDINATOR}" ]]; then coordinator_config; else worker_config; fi

# Update the JVM configuration for any node. Only if the PRESTO_JVM_HEAP_SIZE
# parameter is set.
[[ -n "${PRESTO_JVM_HEAP_SIZE}" ]] && jvm_config


# Create a Hadoop connector as metastore. Only if the metastore host and port
# parameters are set.
[[ -n "${HIVE_METASTORE_HOST}" && -n "${HIVE_METASTORE_PORT}" ]] && hive_catalog_config

# Create a MySQL connector, only if the mysql url, user and password parameters
# are set.
[[ -n "${MYSQL_HOST}" && -n "${MYSQL_PORT}" && -n "${MYSQL_DATABASE}" && -n "${MYSQL_USER}" && -n "${MYSQL_PASSWORD}" ]] && mysql_catalog_config

exec $@
