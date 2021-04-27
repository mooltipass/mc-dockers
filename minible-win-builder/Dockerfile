FROM calaos/winbuilder:latest

MAINTAINER Raoul Hecky "raoul.hecky@gmail.com"

#codesign
RUN cd /work && wget https://github.com/mooltipass/osslsigncode/releases/download/1.7.1/osslsigncode_amd64.tar.xz && \
    tar xJvf osslsigncode_amd64.tar.xz && rm osslsigncode_amd64.tar.xz && \
    chmod +x osslsigncode && \
    sudo mv osslsigncode /usr/bin

COPY scripts /scripts

COPY start.sh /
ENTRYPOINT ["/start.sh"]
CMD ["/start"]
