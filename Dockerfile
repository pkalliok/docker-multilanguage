FROM buildpack-deps

ENV LANG C.UTF-8

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV JAVA_VERSION 8u91
ENV JAVA_DEBIAN_VERSION 8u91-b14-1~bpo8+1
ENV CA_CERTIFICATES_JAVA_VERSION 20140324

ENV LEIN_VERSION=2.6.1
ENV LEIN_INSTALL=/usr/local/bin/
ENV PATH=$PATH:$LEIN_INSTALL
ENV LEIN_ROOT 1

RUN echo 'deb http://httpredir.debian.org/debian jessie-backports main' \
	> /etc/apt/sources.list.d/jessie-backports.list

RUN apt-get purge -y python.*

RUN apt-get update && apt-get install -y --no-install-recommends \
	bzip2 \
	unzip \
	xz-utils \
	curl \
	procps \
	bison \
	libgdbm-dev \
	rlfe \
	ruby \
	openjdk-8-jdk="$JAVA_DEBIAN_VERSION" \
	ca-certificates-java="$CA_CERTIFICATES_JAVA_VERSION" \
	&& rm -rf /var/lib/apt/lists/*

# Java

COPY docker-java-home /usr/local/bin
RUN chmod +x /usr/local/bin/docker-java-home \
 && test "$JAVA_HOME" = "$(docker-java-home)" \
 && /var/lib/dpkg/info/ca-certificates-java.postinst configure

# Clojure + Leiningen

WORKDIR /tmp
RUN mkdir -p $LEIN_INSTALL \
  && wget --quiet https://github.com/technomancy/leiningen/archive/$LEIN_VERSION.tar.gz \
  && echo "f7643a14fd8a4d5c19eeb416db8ea549d8d2c18a *$LEIN_VERSION.tar.gz" | sha1sum -c - \
  && mkdir ./leiningen \
  && tar -xzf $LEIN_VERSION.tar.gz  -C ./leiningen/ --strip-components=1 \
  && mv leiningen/bin/lein-pkg $LEIN_INSTALL/lein \
  && rm -rf $LEIN_VERSION.tar.gz ./leiningen \
  && chmod 0755 $LEIN_INSTALL/lein \
  && wget --quiet https://github.com/technomancy/leiningen/releases/download/$LEIN_VERSION/leiningen-$LEIN_VERSION-standalone.zip \
  && wget --quiet https://github.com/technomancy/leiningen/releases/download/$LEIN_VERSION/leiningen-$LEIN_VERSION-standalone.zip.asc \
  && gpg --keyserver pool.sks-keyservers.net --recv-key 2E708FB2FCECA07FF8184E275A92E04305696D78 \
  && gpg --verify leiningen-$LEIN_VERSION-standalone.zip.asc \
  && rm leiningen-$LEIN_VERSION-standalone.zip.asc \
  && mv leiningen-$LEIN_VERSION-standalone.zip /usr/share/java/leiningen-$LEIN_VERSION-standalone.jar \

