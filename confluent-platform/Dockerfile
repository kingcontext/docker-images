# Builds a base docker image for the Confluent stream platform. It doesn't
# start up any particular service, just installs the platform. Other images
# inherit from this image to start up a particular service.

FROM alpine:latest

ENV SCALA_VERSION="2.11.7"
ENV JAVA_VERSION="8"
ENV CONFLUENT_MAJOR_VERSION="2.0"
ENV CONFLUENT_MINOR_VERSION="0"
ENV CONFLUENT_USER confluent
ENV CONFLUENT_GROUP confluent
ENV KAFKA_LOGS "/var/log/kafka"

RUN apk --no-cache add curl bash openjdk${JAVA_VERSION}-jre-base && \
	curl -sL http://packages.confluent.io/archive/${CONFLUENT_MAJOR_VERSION}/confluent-${CONFLUENT_MAJOR_VERSION}.${CONFLUENT_MINOR_VERSION}-${SCALA_VERSION}.tar.gz | tar -xz -C /tmp && \
	chown -R root:root /tmp/confluent-${CONFLUENT_MAJOR_VERSION}.${CONFLUENT_MINOR_VERSION} && \
	cp -aR /tmp/confluent-${CONFLUENT_MAJOR_VERSION}.${CONFLUENT_MINOR_VERSION}/bin/* /usr/bin/ && \
	cp -aR /tmp/confluent-${CONFLUENT_MAJOR_VERSION}.${CONFLUENT_MINOR_VERSION}/etc/* /etc/ && \
	cp -aR /tmp/confluent-${CONFLUENT_MAJOR_VERSION}.${CONFLUENT_MINOR_VERSION}/share/* /usr/share/ && \
	rm -Rf /tmp/* && \
	addgroup -S ${CONFLUENT_GROUP} && \
    adduser -G ${CONFLUENT_GROUP} -S ${CONFLUENT_USER} && \
    mkdir -p ${KAFKA_LOGS} && \ 
    chown -R ${CONFLUENT_USER}:${CONFLUENT_GROUP} ${KAFKA_LOGS}
