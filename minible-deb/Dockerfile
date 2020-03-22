FROM ubuntu:18.04

MAINTAINER Raoul Hecky "raoul.hecky@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

ENV HOME /home/ubuntu
RUN mkdir -p $HOME

#required packages
RUN apt-get update -qq && \
    apt-get install -y build-essential wget git curl software-properties-common unzip zip gnupg debhelper ubuntu-dev-tools apt-file ssh \
        qtbase5-dev pkg-config python3-paramiko dput-ng

COPY scripts /scripts
COPY dput.cf /home/ubuntu/.dput.cf

COPY start.sh /
ENTRYPOINT ["/start.sh"]
CMD ["/start"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
