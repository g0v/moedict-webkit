# 
# Dockerfile to build miaoski/moedict_amis
#
FROM ubuntu:14.04
MAINTAINER miaoski

ENV DEBIAN_FRONTEND noninteractive

# Pick a Ubuntu apt mirror site for better speed
# ref: https://launchpad.net/ubuntu/+archivemirrors
#
# For developers to build this image in Taiwan,
# please consider to use one of these mirrors:
#  - ftp.ubuntu-tw.net
#  - ftp.yzu.edu.tw

ENV UBUNTU_APT_SITE ubuntu.cs.utah.edu
RUN sed -E -i "s/([a-z]+.)?archive.ubuntu.com/$UBUNTU_APT_SITE/g" /etc/apt/sources.list
RUN sed -i "s/security.ubuntu.com/$UBUNTU_APT_SITE/g" /etc/apt/sources.list

# Disable src package as we don't need them
RUN sed -i 's/^deb-src\ /\#deb-src\ /g' /etc/apt/sources.list

RUN apt-get update                              && \
    apt-get install -y                       \
        git                                  \
        tree                                 \
        vim                                  \
        screen                               \
        curl                                 \
        build-essential                      \
        perl                                 \
        ruby                                 \
        ruby-sass                            \
        ruby-compass                         \
        python                               \
        python-lxml                          \
        unzip                                \
        libjson-perl                         \
        libfile-slurp-unicode-perl           \
        nodejs                               \
        nodejs-legacy                        \
        npm                                     && \
    apt-get clean                               && \
    rm -rf /var/lib/apt/lists/*
RUN npm install -g LiveScript jade gulp

# Switch locale
RUN locale-gen zh_TW.UTF-8
ENV LC_ALL zh_TW.UTF-8

COPY ./ /usr/local/src/moedict-webkit
WORKDIR /usr/local/src/moedict-webkit
RUN npm install

# make offline
RUN make offline-dev

# Default port is 8888
EXPOSE 8888
