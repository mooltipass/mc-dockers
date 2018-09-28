FROM ubuntu:18.04

MAINTAINER Raoul Hecky "raoul.hecky@gmail.com"

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

RUN apt-get update -qq && \
    apt-get install -y wget curl jq bash lftp openssh-client file

RUN wget https://github.com/whiteinge/ok.sh/raw/master/ok.sh -O /usr/bin/ok.sh && \
    chmod +x /usr/bin/ok.sh

COPY scripts /scripts
ENV OK_SH_JQ_BIN /usr/bin/jq
ADD netrc /root/.netrc

COPY start.sh /
ENTRYPOINT ["/start.sh"]
CMD ["/start"]

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
