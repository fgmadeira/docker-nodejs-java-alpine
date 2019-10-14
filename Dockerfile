FROM node:10.16.3-alpine

# install JRE 8 see: https://github.com/docker-library/openjdk/blob/master/8/jre/alpine/Dockerfile

# Default to UTF-8 file.encoding
ENV LANG C.UTF-8

# Downloading and installing Gradle
# 1- Define a constant with the version of gradle you want to install
ARG GRADLE_VERSION=4.10

# 2- Define the URL where gradle can be downloaded from
ARG GRADLE_BASE_URL=https://services.gradle.org/distributions

# 3- Define the SHA key to validate the gradle download
#    obtained from here https://gradle.org/release-checksums/
ARG GRADLE_SHA=e53ce3a01cf016b5d294eef20977ad4e3c13e761ac1e475f1ffad4c6141a92bd

# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

RUN set -x \
	&& apk add --no-cache \
		curl \
		openjdk8="$JAVA_ALPINE_VERSION" \
		git="$GIT_VERSION"\
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]
	
# 4- Create the directories, download gradle, validate the download, install it, remove downloaded file and set links
RUN mkdir -p /usr/share/gradle /usr/share/gradle/ref \
	&& echo "Downlaoding gradle hash" \
	&& curl -fsSL -o /tmp/gradle.zip ${GRADLE_BASE_URL}/gradle-${GRADLE_VERSION}-bin.zip \
	\
	&& echo "Checking download hash" \
	&& echo "${GRADLE_SHA}  /tmp/gradle.zip" | sha256sum -c - \
	\
	&& echo "Unziping gradle" \
	&& unzip -d /usr/share/gradle /tmp/gradle.zip \
	\
	&& echo "Cleaning and setting links" \
	&& rm -f /tmp/gradle.zip \
	&& ln -s /usr/share/gradle/gradle-${GRADLE_VERSION} /usr/bin/gradle
  
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u212
ENV JAVA_ALPINE_VERSION 8.212.04-r1
ENV GIT_VERSION 2.20.1-r0

ENV GRADLE_VERSION 4.10
ENV GRADLE_HOME /usr/bin/gradle
ENV GRADLE_USER_HOME /cache

ENV PATH $PATH:$GRADLE_HOME/bin

VOLUME $GRADLE_USER_HOME

