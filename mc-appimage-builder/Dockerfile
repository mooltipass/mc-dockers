FROM ubuntu:14.04

MAINTAINER Alexander Sashnov "sashnov@ngs.ru"

ENV     QT_VERSION      5.9.6


ENV DEBIAN_FRONTEND noninteractive

ENV HOME    /home/ubuntu

WORKDIR     /home/ubuntu


# Production:
#RUN apt-get update && apt-get install -y \
#    wget \
# && rm -rf /var/lib/apt/lists/*

# Test:
RUN apt-get update && apt-get install -y \
    apt-file \
    wget \
    libfreetype6 \
    libfontconfig1 \
    libx11-6 \
    libx11-xcb1 \
 && apt-file update



# Download Qt online installer and let Docker cache that filesystem layer to avoid loading it again (31 Mb)
# This is good for debugging as I'm going to run 'docker build' over and over again
# but for production we don't need this layer and will combine those commands in one RUN:
#  ---------------------
#RUN wget https://download.qt.io/official_releases/online_installers/qt-unified-linux-x64-online.run && \
#    chmod +x qt-unified-linux-x64-online.run
COPY qt-unified-linux-x64-online.run .


# We put volatile elements inside to leverate Docker cache

# TESTONLY:
ENV QT_CI_JUST_DO_LIST_PACKAGES 1

ENV     QT_CI_PACKAGES  list of packages to be filled

# copy command follows after first RUN to invalidate Docker layers cache starting from here when we change the script file
COPY qt-install.js /home/ubuntu/

# RUN ./qt-unified-linux-x64-online.run --platform minimal --script qt-install.js

# RUN rm -f qt-unified-linux-x64-online.run
#  ---------------------


# COPY scripts /scripts
# COPY start.sh /
# ENTRYPOINT ["/start.sh"]

CMD ["/bin/bash"]
