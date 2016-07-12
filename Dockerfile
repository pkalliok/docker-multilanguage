FROM buildpack-deps

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
	ruby \
	&& rm -rf /var/lib/apt/lists/*

ENV LANG C.UTF-8

