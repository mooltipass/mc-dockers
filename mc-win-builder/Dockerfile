FROM calaos/winbuilder:latest

MAINTAINER Raoul Hecky "raoul.hecky@gmail.com"

#codesign
RUN sudo apt update && sudo apt-get --no-install-recommends -y install \
    osslsigncode

COPY scripts /scripts

#Map uid/gid to travis-ci
RUN sudo groupmod -g 2000 xusers && \
    sudo usermod -u 2000 -g 2000 xclient

