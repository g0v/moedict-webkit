# 
# Dockerfile to build miaoski/moedict_amis:0.3
#
FROM ubuntu:14.04.1
MAINTAINER miaoski
 
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update
 
RUN apt-get install -y git
RUN apt-get install -y tree
RUN apt-get install -y vim
RUN apt-get install -y screen
 
RUN apt-get install -y curl
RUN apt-get install -y build-essential
RUN apt-get install -y g++

RUN apt-get install -y python perl ruby
RUN apt-get install -y python-software-properties
RUN apt-get install -y software-properties-common
RUN apt-get install -y python-lxml
RUN apt-get install -y unzip

RUN add-apt-repository -y ppa:chris-lea/node.js
RUN apt-get update
RUN apt-get install -y nodejs python-lxml curl
RUN npm install -g LiveScript jade
RUN apt-get install -y ruby-sass ruby-compass

# Switch locale
RUN locale-gen zh_TW.UTF-8
ENV LC_ALL zh_TW.UTF-8

# Copy script to build from GitHub
WORKDIR /usr/local/src
RUN git clone https://github.com/audreyt/moedict-webkit.git
WORKDIR /usr/local/src/moedict-webkit
RUN npm install -g gulp
RUN npm install webworker-threads

# make offline
WORKDIR /usr/local/src/moedict-webkit
RUN make offline

# Default port is 8888
EXPOSE 8888
