FROM buildpack-deps

ENV LANG C.UTF-8

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

# Keys

RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

# Java

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV JAVA_VERSION 8u91
ENV JAVA_DEBIAN_VERSION 8u91-b14-1~bpo8+1
ENV CA_CERTIFICATES_JAVA_VERSION 20140324

COPY docker-java-home /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-java-home
RUN test "$JAVA_HOME" = "$(docker-java-home)"
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

# Clojure + Leiningen

ENV LEIN_VERSION=2.6.1
ENV LEIN_INSTALL=/usr/local/bin/
ENV PATH=$PATH:$LEIN_INSTALL
ENV LEIN_ROOT 1

RUN curl https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein \
 > /usr/local/bin/lein \
 && chmod +x /usr/local/bin/lein \
 && (echo | lein repl)

# Node

ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 6.3.0

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt

