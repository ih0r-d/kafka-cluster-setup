#!/bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 must contains one of arguments [start|stop|status]"
    exit 1
fi


# Start cluster
start_cluster() {
  # Load environment variables from .env file
  source .env
  # Start all services using Docker Compose
  echo "✔ Starting kafka...✅"
  docker-compose -f docker-compose-kafka-no-zookeeper.yml up -d --remove-orphans
  echo "✔ Kafka is ready\t✅"
  echo ''
  echo ''
  docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
}

# Status of cluster
status_cluster(){
  docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
}

# Stop cluster
stop_cluster() {
  docker-compose -f docker-compose-kafka-no-zookeeper.yml down
  echo "✔ Kafka is stopped\t✅"
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
