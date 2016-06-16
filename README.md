
Confluent Stream Data Platform on Docker
========================================

**Size-reduced (Alpine-based) images for the Confluent Stream Data Platform v.3.0**

Images are further minimized by removing kafka-connect & confluent-control-center from the images to reduce size.

No need to build, just use the available images at https://hub.docker.com/u/kingcontext:
- kingcontext/confluent-platform:confluent3-alpine-min
- kingcontext/confluent-zookeeper:confluent3-alpine-min
- kingcontext/confluent-kafka:confluent3-alpine-min
- kingcontext/confluent-schema-registry:confluent3-alpine-min
- kingcontext/confluent-rest-proxy:confluent3-alpine-min
- kingcontext/confluent-tools:confluent3-alpine-min

See [upstream repo](https://github.com/confluentinc/docker-images) for usage instructions.
