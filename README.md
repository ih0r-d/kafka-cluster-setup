# Kafka Cluster

This repository contains files to set up a Kafka environment using Docker Compose. The project includes configuration files, a startup script, and an environment file.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Usage](#usage)

## Prerequisites

Before you begin, ensure you have the following installed on your machine:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Getting Started

1. Clone the repository:

    ```bash
    git clone https://github.com/ih0r-d/kafka-cluster-setup.git
    ```

2. Change into the project directory:

    ```bash
    cd kafka-cluster-setup
    ```

## Configuration

Review and customize the configuration files according to your needs:

- **kafka.yaml**: Defines the Docker services, including next services:
  - zookeeper
  - schema registry
  - connect
  - ksqldb server
  - ksqldb cli
  - rest proxy
  - kafka ui
  - brokers (for default 2 brokers)
  - init kafka (for create topics)
- **cluster.sh**: Startup script to initialize the Kafka cluster environment.
- **.env**: Environment variables file for configuring Kafka settings.


## Usage

* Start the Kafka environment:

    ```bash
    ./cluster.sh
    ```
   * If necessary, you have the option to manually run specific services instead of using `cluster.sh`.
   
   ```bash
   docker-compose -f kafka.yaml up -d {service} 
   ```
   > **_NOTE:_** `{service}` in this command means one of included services in compose file.


* Monitor the Logs: Keep an eye on the logs to ensure that all processes are running smoothly.
