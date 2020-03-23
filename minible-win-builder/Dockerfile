FROM ubuntu:18.04

MAINTAINER Raoul Hecky "raoul.hecky@gmail.com"

ENV DEBIAN_FRONTEND noninteractive

ENV HOME /home/ubuntu
RUN mkdir -p $HOME

#required packages
RUN dpkg --add-architecture i386 && \
    apt-get update -qq && \
    apt-get install -y build-essential wget git curl software-properties-common wine-stable wine32 unzip zip

#mingw+qt toolchain
RUN cd $HOME && \
    wget https://calaos.fr/download/misc/mxe_qt5121.tar.xz && \
    tar xJf mxe_qt5121.tar.xz

COPY scripts /scripts

COPY start.sh /
ENTRYPOINT ["/start.sh"]
CMD ["/start"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
