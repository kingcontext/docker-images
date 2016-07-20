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

# start generate tools banner
cp ./tools/confluent-tools-template.sh ./tools/confluent-tools.sh

cat >> ./tools/confluent-tools.sh <<EOL
if [ "\$1" = "alias" ]; then
EOL

while read COMMAND; do
  echo "    echo alias ${COMMAND}=\'docker run --rm --interactive --net=host \"confluent/tools:${CONFLUENT_PLATFORM_VERSION}\" ${COMMAND}\'" >> ./tools/confluent-tools.sh
done <$TOOLS_COMMAND_LIST

echo else >> ./tools/confluent-tools.sh

while read COMMAND; do
  echo "    echo ${COMMAND}" >> ./tools/confluent-tools.sh
done <$TOOLS_COMMAND_LIST

echo fi >> ./tools/confluent-tools.sh
# end generate tools banner

KAFKA_IMAGES="tools"

for IMAGE in ${KAFKA_IMAGES}; do
  docker build $DOCKER_BUILD_OPTS -t "confluent/${IMAGE}:${KAFKA_VERSION}" "${IMAGE}/"
  TAGS="${TAGS} confluent/${IMAGE}:${KAFKA_VERSION}"
  docker tag $DOCKER_TAG_OPTS "confluent/${IMAGE}:${KAFKA_VERSION}" "confluent/${IMAGE}:latest"
  TAGS="${TAGS} confluent/${IMAGE}:latest"
done
