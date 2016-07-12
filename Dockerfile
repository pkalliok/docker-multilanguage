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

COPY docker-java-home /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-java-home
RUN test "$JAVA_HOME" = "$(docker-java-home)"
RUN /var/lib/dpkg/info/ca-certificates-java.postinst configure

# Clojure + Leiningen

RUN curl https://raw.githubusercontent.com/technomancy/leiningen/stable/bin/lein \
 > /usr/local/bin/lein \
 && chmod +x /usr/local/bin/lein \
 && (echo | lein repl)

