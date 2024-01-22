FROM confluentinc/cp-kafka:7.5.1

USER root

ADD scripts/configure.sh /etc/confluent/docker/configure
ADD scripts/ensure.sh /etc/confluent/docker/ensure
RUN chmod -R 777 /etc/confluent/docker/

RUN echo "kafka-storage format --ignore-formatted -t $(kafka-storage random-uuid) -c /etc/kafka/kafka.properties" >> /etc/confluent/docker/ensure.sh