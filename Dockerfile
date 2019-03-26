FROM adoptopenjdk/openjdk11:x86_64-alpine-jre-11.0.2.9
LABEL maintainer="Mathew Moon <mmoon@quinovas.com>"

WORKDIR /tmp

RUN set -ex && \
    apk add --no-cache --virtual .build-deps \
       ca-certificates \
       gnupg \
       libressl \
       wget \
      shadow && \
    apk add --no-cache bash \
      su-exec && \
    adduser -D pulsar && \
    wget -nv "https://www.apache.org/dist/pulsar/pulsar-2.3.0/apache-pulsar-2.3.0-bin.tar.gz" && \
    wget -nv "https://www.apache.org/dist/pulsar/pulsar-2.3.0/apache-pulsar-2.3.0-bin.tar.gz.asc" && \
    wget -nv "https://www.apache.org/dist/pulsar/pulsar-2.3.0/apache-pulsar-2.3.0-bin.tar.gz.sha512" && \
    sha512sum -c apache-pulsar-2.3.0-bin.tar.gz.sha512 && \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-key "AC055FD2" && \
    gpg --batch --verify "apache-pulsar-2.3.0-bin.tar.gz.asc" "apache-pulsar-2.3.0-bin.tar.gz" && \
    tar -xzf "apache-pulsar-2.3.0-bin.tar.gz" && \
    mv apache-pulsar-2.3.0 /pulsar && \
    wget -nv https://www.apache.org/dist/pulsar/pulsar-2.3.0/apache-pulsar-offloaders-2.3.0-bin.tar.gz && \
    wget -nv https://www.apache.org/dist/pulsar/pulsar-2.3.0/apache-pulsar-offloaders-2.3.0-bin.tar.gz.asc && \
    wget -nv https://www.apache.org/dist/pulsar/pulsar-2.3.0/apache-pulsar-offloaders-2.3.0-bin.tar.gz.sha512 && \
    sha512sum -c apache-pulsar-offloaders-2.3.0-bin.tar.gz.sha512 && \
    gpg --batch --verify apache-pulsar-offloaders-2.3.0-bin.tar.gz.asc apache-pulsar-offloaders-2.3.0-bin.tar.gz && \
    tar zxfv apache-pulsar-offloaders-2.3.0-bin.tar.gz && \
    mv apache-pulsar-offloaders-2.3.0/offloaders/ /pulsar/ && \
    mkdir /conf && \
    wget -nv -O jmx_prometheus_javaagent-0.11.0.jar https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.11.0/jmx_prometheus_javaagent-0.11.0.jar && \
    wget -nv https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.11.0/jmx_prometheus_javaagent-0.11.0.jar.asc && \
    wget -nv https://repo1.maven.org/maven2/io/prometheus/jmx/jmx_prometheus_javaagent/0.11.0/jmx_prometheus_javaagent-0.11.0.jar.md5 && \
    gpg --keyserver pgp.key-server.io --recv-key EA64F2BA && \
    gpg --verify jmx_prometheus_javaagent-0.11.0.jar.asc jmx_prometheus_javaagent-0.11.0.jar && \
    mv jmx_prometheus_javaagent-0.11.0.jar /usr/bin/ && \
    rm -rf ./* && \
    rm -rf /pulsar/bin/* && \
    apk del --no-cache .build-deps


COPY pulsar /pulsar/bin
COPY log4j.properties /conf
COPY pulsar.conf /conf
COPY prometheus.yml /conf

RUN chmod +x /pulsar/bin/*

ENV PATH=$PATH:/pulsar/bin

WORKDIR /pulsar