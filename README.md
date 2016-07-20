
Confluent Stream Data Platform on Docker
========================================

**Size-reduced (Alpine-linux-based) images for the Confluent Stream Data Platform v.3.0**

Images are further minimized by removing kafka-connect & confluent-control-center from the images to reduce size.

No need to build, just use the available images at https://hub.docker.com/u/kingcontext:
- kingcontext/confluent-platform:confluent3-alpine-min
- kingcontext/confluent-zookeeper:confluent3-alpine-min
- kingcontext/confluent-kafka:confluent3-alpine-min
- kingcontext/confluent-schema-registry:confluent3-alpine-min
- kingcontext/confluent-rest-proxy:confluent3-alpine-min
- kingcontext/confluent-tools:confluent3-alpine-min (*)
 
(*) For confluent-tools, keep in mind that kafka-connect has been removed from the confluent3-alpine-min images. As an alternative, use image kingcontext/confluent-tools-hadoop:confluent3-alpine that has a fully functional confluent-tools (incl. kafka-connect) and also has hadoop installed (for easy hdfs access).

See [upstream repo](https://github.com/confluentinc/docker-images) for usage instructions.

For the alpine-based images of Confluent2, check the repository tags.
