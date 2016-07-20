#!/bin/bash

. settings.sh

if [ "$(uname)" = "Darwin" ]; then
  SHA1='shasum'
else
  SHA1='sha1sum'
fi


set -ex

if [ -z ${DOCKER_HOST+x} ];
then
  echo "DOCKER_HOST must be set before running this script.";
  exit 1
fi

mvn clean package

TAGS=""

STAGING_DIRECTORY='./target-docker'

DOCKER_UTILS_DIRECTORY="$(find target -name 'docker-utils*-package' -type d -maxdepth 1 -mindepth 1)"

TOOLS_COMMAND_LIST="${STAGING_DIRECTORY}/commands"

find "${STAGING_DIRECTORY}" -type d -maxdepth 1 -mindepth 1| xargs rm -rf

if [ ! -d "./${STAGING_DIRECTORY}" ];
then
  mkdir -p "./${STAGING_DIRECTORY}"
fi

for SCALA_VERSION in ${SCALA_VERSIONS}; do
    echo "Building confluent-platform-${SCALA_VERSION}"

    DOCKER_FILE="confluent-platform/Dockerfile.${SCALA_VERSION}"

    cp confluent-platform/Dockerfile "$DOCKER_FILE"

    TAR_NAME="confluent-${CONFLUENT_PLATFORM_VERSION}-${SCALA_VERSION}"
    DOWNLOAD_TAR_URL="${PACKAGE_URL}/${TAR_NAME}.tar.gz"
    DOWNLOAD_TAR_PATH="${STAGING_DIRECTORY}/${TAR_NAME}.tar.gz"
    DOWNLOAD_CHECKSUM_PATH="${STAGING_DIRECTORY}/${TAR_NAME}.tar.gz.sha1.txt"
    curl -Lo "${DOWNLOAD_TAR_PATH}.sha1.txt" "${DOWNLOAD_TAR_URL}.sha1.txt"

    if [ ! -f $DOWNLOAD_TAR_PATH ];
    then
      curl -Lo "${DOWNLOAD_TAR_PATH}" "${DOWNLOAD_TAR_URL}"
    fi

    cd "${STAGING_DIRECTORY}"
    $SHA1 -c "${TAR_NAME}.tar.gz.sha1.txt"

    if [ $? -neq 0 ];
    then
      echo "Checksums for ${DOWNLOAD_TAR_PATH} do not match. Figure that out."
      exit 1
    fi

    cd $OLDPWD

    if [ ! -d "./${STAGING_DIRECTORY}/${TAR_NAME}" ];
    then
      mkdir -p "./${STAGING_DIRECTORY}/${TAR_NAME}"
    fi

    tar xzvf "./${STAGING_DIRECTORY}/${TAR_NAME}.tar.gz" -C "./${STAGING_DIRECTORY}/${TAR_NAME}"
    TAR_ROOT="$(find ${STAGING_DIRECTORY}/${TAR_NAME} -type d -maxdepth 1 -mindepth 1)"

    ls -1 "${TAR_ROOT}/bin" | grep -v windows > "${TOOLS_COMMAND_LIST}"

    # Setup default configurations for kafka broker
    SERVER_PROPERTIES=`find "${TAR_ROOT}" -type f -name 'server.properties'`
    cp ./kafka/server.properties "${SERVER_PROPERTIES}"

    # Setup default configurations for rest-proxy
    KAFKA_REST_PROPERTIES=`find "${TAR_ROOT}" -type f -name 'kafka-rest.properties'`
    cp ./rest-proxy/kafka-rest.properties "${KAFKA_REST_PROPERTIES}"

    # Setup default configurations for schema-registry
    SCHEMA_REGISTRY_PROPERTIES=`find "${TAR_ROOT}" -type f -name 'schema-registry.properties'`
    cp ./schema-registry/schema-registry.properties "${SCHEMA_REGISTRY_PROPERTIES}"

    echo "ADD ${TAR_ROOT}/bin/ /usr/bin/" >> "$DOCKER_FILE"
    echo "ADD ${TAR_ROOT}/etc/ /etc/" >> "$DOCKER_FILE"
    echo "ADD ${TAR_ROOT}/share/ /usr/share/" >> "$DOCKER_FILE"
    echo "ADD ${DOCKER_UTILS_DIRECTORY}/bin/ /usr/bin/" >> "$DOCKER_FILE"
    echo "ADD ${DOCKER_UTILS_DIRECTORY}/share/ /usr/share/" >> "$DOCKER_FILE"

    TAG="confluent/platform-${SCALA_VERSION}:${CONFLUENT_PLATFORM_VERSION}"
    TAGS="${TAGS} ${TAG}"
    docker build $DOCKER_BUILD_OPTS -t $TAG -f "${DOCKER_FILE}" .
    docker tag $DOCKER_TAG_OPTS "${TAG}" "confluent/platform-${SCALA_VERSION}:latest"

    if [ "x$SCALA_VERSION" = "x$DEFAULT_SCALA_VERSION" ]; then
      docker tag $DOCKER_TAG_OPTS "${TAG}" "confluent/platform:latest"
      TAGS="${TAGS} confluent/platform:latest"
      docker tag $DOCKER_TAG_OPTS "${TAG}" "confluent/platform:${CONFLUENT_PLATFORM_VERSION}"
      TAGS="${TAGS} confluent/platform:${CONFLUENT_PLATFORM_VERSION}"
    fi
done

