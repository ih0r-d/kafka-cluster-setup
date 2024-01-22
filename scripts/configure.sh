#!/usr/bin/env bash
#
# Copyright 2016 Confluent Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

. /etc/confluent/docker/bash-config

#dub ensure.sh KAFKA_ADVERTISED_LISTENERS

# By default, LISTENERS is derived from ADVERTISED_LISTENERS by replacing
# hosts with 0.0.0.0. This is good default as it ensures that the broker
# process listens on all ports.
#if [[ -z "${KAFKA_LISTENERS-}" ]]
#then
#  export KAFKA_LISTENERS
#  KAFKA_LISTENERS=$(cub listeners "$KAFKA_ADVERTISED_LISTENERS")
#fi

dub path /etc/kafka/ writable

if [[ -z "${KAFKA_LOG_DIRS-}" ]]
then
  export KAFKA_LOG_DIRS
  KAFKA_LOG_DIRS="/var/lib/kafka/data"
fi

# advertised.host, advertised.port, host and port are deprecated. Exit if these properties are set.
if [[ -n "${KAFKA_ADVERTISED_PORT-}" ]]
then
  echo "advertised.port is deprecated. Please use KAFKA_ADVERTISED_LISTENERS instead."
  exit 1
fi

if [[ -n "${KAFKA_ADVERTISED_HOST-}" ]]
then
  echo "advertised.host is deprecated. Please use KAFKA_ADVERTISED_LISTENERS instead."
  exit 1
fi

if [[ -n "${KAFKA_HOST-}" ]]
then
  echo "host is deprecated. Please use KAFKA_ADVERTISED_LISTENERS instead."
  exit 1
fi

if [[ -n "${KAFKA_PORT-}" ]]
then
  echo "port is deprecated. Please use KAFKA_ADVERTISED_LISTENERS instead."
  exit 1
fi

# Set if ADVERTISED_LISTENERS has SSL:// or SASL_SSL:// endpoints.
if [[ $KAFKA_ADVERTISED_LISTENERS == *"SSL://"* ]]
then
  echo "SSL is enabled."

  dub ensure KAFKA_SSL_KEYSTORE_FILENAME
  export KAFKA_SSL_KEYSTORE_LOCATION="/etc/kafka/secrets/$KAFKA_SSL_KEYSTORE_FILENAME"
  dub path "$KAFKA_SSL_KEYSTORE_LOCATION" exists

  dub ensure KAFKA_SSL_KEY_CREDENTIALS
  KAFKA_SSL_KEY_CREDENTIALS_LOCATION="/etc/kafka/secrets/$KAFKA_SSL_KEY_CREDENTIALS"
  dub path "$KAFKA_SSL_KEY_CREDENTIALS_LOCATION" exists
  export KAFKA_SSL_KEY_PASSWORD
  KAFKA_SSL_KEY_PASSWORD=$(cat "$KAFKA_SSL_KEY_CREDENTIALS_LOCATION")

  dub ensure KAFKA_SSL_KEYSTORE_CREDENTIALS
  KAFKA_SSL_KEYSTORE_CREDENTIALS_LOCATION="/etc/kafka/secrets/$KAFKA_SSL_KEYSTORE_CREDENTIALS"
  dub path "$KAFKA_SSL_KEYSTORE_CREDENTIALS_LOCATION" exists
  export KAFKA_SSL_KEYSTORE_PASSWORD
  KAFKA_SSL_KEYSTORE_PASSWORD=$(cat "$KAFKA_SSL_KEYSTORE_CREDENTIALS_LOCATION")

  if [[ -n "${KAFKA_SSL_CLIENT_AUTH-}" ]] && ( [[ $KAFKA_SSL_CLIENT_AUTH == *"required"* ]] || [[ $KAFKA_SSL_CLIENT_AUTH == *"requested"* ]] )
  then
      dub ensure KAFKA_SSL_TRUSTSTORE_FILENAME
      export KAFKA_SSL_TRUSTSTORE_LOCATION="/etc/kafka/secrets/$KAFKA_SSL_TRUSTSTORE_FILENAME"
      dub path "$KAFKA_SSL_TRUSTSTORE_LOCATION" exists

      dub ensure KAFKA_SSL_TRUSTSTORE_CREDENTIALS
      KAFKA_SSL_TRUSTSTORE_CREDENTIALS_LOCATION="/etc/kafka/secrets/$KAFKA_SSL_TRUSTSTORE_CREDENTIALS"
      dub path "$KAFKA_SSL_TRUSTSTORE_CREDENTIALS_LOCATION" exists
      export KAFKA_SSL_TRUSTSTORE_PASSWORD
      KAFKA_SSL_TRUSTSTORE_PASSWORD=$(cat "$KAFKA_SSL_TRUSTSTORE_CREDENTIALS_LOCATION")
  fi
  
fi

# Set if KAFKA_ADVERTISED_LISTENERS has SASL_PLAINTEXT:// or SASL_SSL:// endpoints.
if [[ $KAFKA_ADVERTISED_LISTENERS =~ .*SASL_.*://.* ]]
then
  echo "SASL" is enabled.

  dub ensure KAFKA_OPTS

  if [[ ! $KAFKA_OPTS == *"java.security.auth.login.config"*  ]]
  then
    echo "KAFKA_OPTS should contain 'java.security.auth.login.config' property."
  fi
fi

if [[ -n "${KAFKA_JMX_OPTS-}" ]]
then
  if [[ ! $KAFKA_JMX_OPTS == *"com.sun.management.jmxremote.rmi.port"*  ]]
  then
    echo "KAFKA_OPTS should contain 'com.sun.management.jmxremote.rmi.port' property. It is required for accessing the JMX metrics externally."
  fi
fi

dub template "/etc/confluent/docker/${COMPONENT}.properties.template" "/etc/${COMPONENT}/${COMPONENT}.properties"
dub template "/etc/confluent/docker/log4j.properties.template" "/etc/${COMPONENT}/log4j.properties"
dub template "/etc/confluent/docker/tools-log4j.properties.template" "/etc/${COMPONENT}/tools-log4j.properties"
