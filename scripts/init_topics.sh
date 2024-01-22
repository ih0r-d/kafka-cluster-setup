#!/bin/bash

# Read the environment variable
INIT_TOPICS="${INIT_TOPICS}"

# Check if the variable is set
if [ -z "$INIT_TOPICS" ]; then
    echo "INIT_TOPICS is not set."
    exit 1
fi

kafka-topics --bootstrap-server broker:"${BROKER_INTERNAL_PORT}" --list
echo -e 'Creating kafka topics'

# Split the comma-separated values
IFS=',' read -ra TOPICS <<< "$INIT_TOPICS"

# Run kafka-topics command for each topic
for TOPIC in "${TOPICS[@]}"; do
    kafka-topics --bootstrap-server broker:"${BROKER_INTERNAL_PORT}" \
    --create --if-not-exists --topic "${TOPIC}" \
    --replication-factor "${REPLICATION_FACTOR}" --partitions "${PARTITIONS}"
done

echo -e 'Successfully created the following topics:'
kafka-topics --bootstrap-server broker:"${BROKER_INTERNAL_PORT}" --list