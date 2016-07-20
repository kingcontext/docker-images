FROM kingcontext/confluent-tools:confluent3-alpine

USER root

ENV GROUP $CONFLUENT_USER
ENV HADOOP_USER $CONFLUENT_GROUP
ENV HADOOP_VERSION 2.7.2
ENV HADOOP_PREFIX /opt/hadoop
ENV HADOOP_CONF_DIR $HADOOP_PREFIX/etc/hadoop
ENV PATH $PATH:$JAVA_HOME/bin:$HADOOP_PREFIX/bin:$HADOOP_PREFIX/sbin:/

ENV HOST_MAPPING_DIR /shared
ENV DATA_MAPPING_DIR /data

RUN apk --no-cache add curl &&\
	curl -Ls http://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz | tar -xzf - -C /opt &&\
	ln -s /opt/hadoop-$HADOOP_VERSION $HADOOP_PREFIX &&\
	rm -Rf /opt/hadoop-$HADOOP_VERSION/share/doc &&\
	find /opt/hadoop-$HADOOP_VERSION/share/ -name "*-sources.jar" -type f -delete &&\
	find /opt/hadoop-$HADOOP_VERSION/share/ -name "*-tests.jar" -type f -delete &&\
	chown -R root:$GROUP /opt/hadoop* &&\
	chmod -R 750 /opt/hadoop* &&\
	chmod 4770 /opt/hadoop-$HADOOP_VERSION/bin/container-executor 

#ADD conf/* $HADOOP_CONF_DIR/

VOLUME $HOST_MAPPING_DIR
VOLUME $DATA_MAPPING_DIR

CMD ["confluent-tools"]
