FROM ubuntu:18.04

MAINTAINER Raoul Hecky "raoul.hecky@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

ENV HOME /home/ubuntu
RUN mkdir -p $HOME

#required packages
RUN apt-get update -qq && \
    apt-get install -y build-essential wget git curl software-properties-common unzip zip gnupg debhelper ubuntu-dev-tools apt-file ssh \
        libqt5websockets5-dev libusb-1.0-0-dev qt5-qmake qttools5-dev-tools pkg-config

COPY scripts /scripts

COPY start.sh /
ENTRYPOINT ["/start.sh"]
CMD ["/start"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
