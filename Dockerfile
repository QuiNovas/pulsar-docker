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
    wget -nv "https://www.apache.org/dist/pulsar/pulsar-2.3.1/apache-pulsar-2.3.1-bin.tar.gz" && \
    wget -nv "https://www.apache.org/dist/pulsar/pulsar-2.3.1/apache-pulsar-2.3.1-bin.tar.gz.asc" && \
    wget -nv "https://www.apache.org/dist/pulsar/pulsar-2.3.1/apache-pulsar-2.3.1-bin.tar.gz.sha512" && \
    sha512sum -c apache-pulsar-2.3.1-bin.tar.gz.sha512 && \
    wget http://www.apache.org/dist/pulsar/KEYS && \
    gpg --import < KEYS && \
    gpg --batch --verify "apache-pulsar-2.3.1-bin.tar.gz.asc" "apache-pulsar-2.3.1-bin.tar.gz" && \
    tar -xzf "apache-pulsar-2.3.1-bin.tar.gz" && \
    mv apache-pulsar-2.3.1 /pulsar && \
    wget -nv https://www.apache.org/dist/pulsar/pulsar-2.3.1/apache-pulsar-offloaders-2.3.1-bin.tar.gz && \
    wget -nv https://www.apache.org/dist/pulsar/pulsar-2.3.1/apache-pulsar-offloaders-2.3.1-bin.tar.gz.asc && \
    wget -nv https://www.apache.org/dist/pulsar/pulsar-2.3.1/apache-pulsar-offloaders-2.3.1-bin.tar.gz.sha512 && \
    sha512sum -c apache-pulsar-offloaders-2.3.1-bin.tar.gz.sha512 && \
    gpg --batch --verify apache-pulsar-offloaders-2.3.1-bin.tar.gz.asc apache-pulsar-offloaders-2.3.1-bin.tar.gz && \
    tar zxfv apache-pulsar-offloaders-2.3.1-bin.tar.gz && \
    mv apache-pulsar-offloaders-2.3.1/offloaders/ /pulsar/ && \
    mkdir /conf && \
    rm -rf ./* && \
    rm -rf /pulsar/bin/* && \
    apk del --no-cache .build-deps


COPY pulsar /pulsar/bin
COPY log4j.properties /conf
COPY pulsar.conf /conf
COPY pulsar.conf /conf/client.conf

RUN chmod +x /pulsar/bin/*

ENV PATH=$PATH:/pulsar/bin

WORKDIR /pulsar
