#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 must contains one of arguments [start|stop|status]"
    exit 1
fi

# Check if the cluster is already set up
if [ -d "kafka-volume" ]; then
    sudo rm -r kafka-volume
fi

# Function to create volumes for various services
__create_volumes() {
    service=$1
    shift

    echo "Creating volumes for ${service} ..."
    for item in "$@"
    do
        echo "$item"
        mkdir -p "$item"
        sudo chown -R "$(id -u)" "$item"
        sudo chgrp -R "$(id -g)" "$item"
        sudo chmod -R u+rwX,g+rX,o+wrx "$item"
        echo "$item volume is created."
    done
    echo "Volumes for ${service} created ✅"
    echo
}
# Check readiness for Kafka Connect
_check_connect_readiness(){
  # for item in connect connect2 connect3
  for item in conne ct
  do
      connect_host="$item"
      # shellcheck disable=SC2153
      connect_port="${CONNECT_PORT}"
      echo "Wait for ${connect_host}:${connect_port} ..."
      docker exec -it zookeeper cub connect-ready "$connect_host" "$connect_port" $timeout > /dev/null
      echo "${connect_host}:${connect_port} is ready ✅"
      echo ''
  done
}
# Check readiness for Kafka brokers
_check_brokers_readiness(){
  for item in broker:${BROKER_INTERNAL_PORT} broker2:${BROKER2_INTERNAL_PORT}
  do
      broker="$item"
      echo "Wait for ${broker} ..."
      docker exec -it zookeeper cub kafka-ready -b "$broker" 1 $timeout > /dev/null
      echo "${broker} is ready ✅"
      echo ''
  done

  # Check readiness for Schema Registry
  schema_registry_host="schema-registry"
  # shellcheck disable=SC2153
  schema_registry_port="$SCHEMA_REGISTRY_PORT"
  echo "Wait for ${schema_registry_host}:${schema_registry_port} ..."
  docker exec -it zookeeper cub sr-ready "$schema_registry_host" "$schema_registry_port" $timeout > /dev/null
  echo "${schema_registry_host}:${schema_registry_port} is ready ✅"
  echo ''
}
# Check readiness for Zookeeper
_check_zookeeper_readiness(){
  zookeeper="zookeeper:${ZOOKEEPER_CLIENT_PORT}"
  echo "Wait for ${zookeeper} ..."
  docker exec -it zookeeper cub zk-ready "$zookeeper" $timeout > /dev/null
  echo "${zookeeper} is ready ✅"
  echo ''
}
# # Create volumes for different services
_create_all_volumes(){
  __create_volumes zookeeper kafka-volume/zk/data kafka-volume/zk/txn-logs
  __create_volumes brokers kafka-volume/broker/data kafka-volume/broker2/data kafka-volume/broker3/data kafka-volume/broker4/data
  __create_volumes schema-registry kafka-volume/schema-registry/data
  __create_volumes connect kafka-volume/connect/data kafka-volume/connect/plugins
  __create_volumes ksqldb-cli kafka-volume/ksqldb-cli/scripts
  __create_volumes filepulse kafka-volume/connect/data/filepulse/xml
}



# Start cluster
start_cluster() {
  # Load environment variables from .env file
  source .env
  _create_all_volumes

  PWD=$(pwd)
  export PWD

  # Start all services using Docker Compose
  echo "✔ Starting all kafka services..."
  docker compose -f docker-compose-kafka-cluster-ksqldb.yml up -d

  # Set timeout for readiness checks
  timeout=100
  echo ''

  _check_zookeeper_readiness
  _check_brokers_readiness
  _check_connect_readiness
  echo -e "✔ Kafka cluster is ready\t✅"
}

# Status of cluster
status_cluster(){
  docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
}

# Stop cluster
stop_cluster() {
  docker-compose -f docker-compose-kafka-cluster-ksqldb.yml down
  echo ''
  echo -e "✔ Kafka cluster is stopped\t✅"
}


# Execute the appropriate function based on the command-line argument
case "$1" in
    start)
        start_cluster
        ;;
    status)
        status_cluster
        ;;
    stop)
        stop_cluster
        ;;
    *)
        echo "Invalid argument. Usage: $0 [start|stop|status]"
        exit 1
        ;;
esac
