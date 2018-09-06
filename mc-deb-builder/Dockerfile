FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

# FIXME: do we need all of them?
# Docker Image size is 1.43 Gb, but mc-appimage-builder is just 611 Mb only
RUN apt-get update -qq && \
    apt-get install -y \
        curl \
        debhelper \
        dh-make \
        dpkg-dev \
        git-buildpackage \
        lftp \
        libqt5websockets5-dev \
        libusb-1.0-0-dev \
        libusb-dev \
        pkg-config \
        qt5-default \
        qt5-qmake \
        qt-sdk

# Command-line JSON processor for OK library
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && \
    mv jq-linux64 /usr/bin/jq && \
    chmod +x /usr/bin/jq

ENV OK_SH_JQ_BIN /usr/bin/jq

RUN git clone https://github.com/whiteinge/ok.sh.git /usr/lib/ok.sh && \
    chmod +x /usr/lib/ok.sh/ok.sh && \
    ln -s /usr/lib/ok.sh/ok.sh /usr/bin/ok.sh

CMD ["/bin/bash"]
