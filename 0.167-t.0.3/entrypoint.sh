#!/usr/bin/env sh

# Populate node.id from uuidgen by replacing template with the node uuid
sed -i "s/\$(uuid-generated-nodeid)/$(uuidgen)/g" /etc/presto/node.properties

# Update the Presto config.properties file with values for the coordinator and
# workers. Only if the following 3 parameters are set.
[[ -n "${HTTP_SERVER_PORT}" && -n "${PRESTO_MAX_MEMORY}" && -n "${PRESTO_MAX_MEMORY_PER_NODE}" ]] && \
if [[ -z "${COORDINATOR}" ]]; then
  (
    echo "coordinator=true"
    echo "node-scheduler.include-coordinator=false"
    echo "http-server.http.port=${HTTP_SERVER_PORT}"
    echo "query.max-memory=${PRESTO_MAX_MEMORY}GB"
    echo "query.max-memory-per-node=${PRESTO_MAX_MEMORY_PER_NODE}GB"
    echo "discovery-server.enabled=true"
    echo "discovery.uri=http://localhost:${HTTP_SERVER_PORT}"
  ) >/etc/presto/config.properties
else
  (
    echo "coordinator=false"
    echo "http-server.http.port=${HTTP_SERVER_PORT}"
    echo "query.max-memory=${PRESTO_MAX_MEMORY}GB"
    echo "query.max-memory-per-node=${PRESTO_MAX_MEMORY_PER_NODE}GB"
    echo "discovery-server.enabled=true"
    echo "discovery.uri=http://${COORDINATOR}:${HTTP_SERVER_PORT}"
  ) >/etc/presto/config.properties
fi

# Update the JVM configuration for any node. Only if the PRESTO_JVM_HEAP_SIZE
# parameter is set.
[[ -n "${PRESTO_JVM_HEAP_SIZE}" ]] && \
sed -i "s/-Xmx.*G/-Xmx${PRESTO_JVM_HEAP_SIZE}G/" /etc/presto/jvm.config

# Create a Hadoop connector as metastore. Only if the metastore host and port
# parameters are set.
[[ -n "${HIVE_METASTORE_HOST}" && -n "${HIVE_METASTORE_PORT}" ]] && \
(
  echo "connector.name=hive-hadoop2"
  echo "hive.metastore.uri=thrift://${HIVE_METASTORE_HOST}:${HIVE_METASTORE_PORT}"
) >/etc/presto/catalog/hive.properties

exec $@
