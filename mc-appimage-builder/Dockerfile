# Install official Qt's binary build using https://github.com/benlau/qtci
# Examples of how to use it: https://github.com/rabits/dockerfiles

FROM ubuntu:14.04

MAINTAINER Alexander Sashnov "sashnov@ngs.ru"

ENV DEBIAN_FRONTEND noninteractive

ENV QT_VERSION  5.12.7
ENV QT_PATH /opt/Qt
ENV QT_DESKTOP $QT_PATH/${QT_VERSION}/gcc_64
ENV QT_CI_LOGIN FILLME@mailsy.top 
ENV QT_CI_PASSWORD FILLME@mailsy.top 

ENV PATH    $QT_DESKTOP/bin:$PATH
ENV HOME    /home/ubuntu

# WORKDIR directive will create the directory automatically
WORKDIR     /home/ubuntu

# Install updates & requirements:
#  * git, openssh-client, ca-certificates - clone & build
#  * locales, sudo - useful to set utf-8 locale & sudo usage
#  * curl - to download Qt bundle
#  * build-essential, pkg-config, libgl1-mesa-dev - basic Qt build requirements
#  * libsm6, libice6, libxext6, libxrender1, libfontconfig1, libdbus-1-3 - dependencies of the Qt bundle run-file
#  * libcairo2 needed for running appimagetool
#  * libusb-1.0-0-dev needed by Moolticute daemon
RUN apt update && apt full-upgrade -y && apt install -y --no-install-recommends \
    git \
    openssh-client \
    ca-certificates \
    locales \
    sudo \
    curl \
    build-essential \
    pkg-config \
    libcairo2 \
    libegl1-mesa \
    libfuse2 \
    libgl1-mesa-dev \
    libsm6 \
    libice6 \
    libxext6 \
    libxrender1 \
    libfontconfig1 \
    libdbus-1-3 \
    libudev-dev \
    libxi6 \
    libxkbcommon-x11-0 \
    unzip \
    wget

RUN curl -4 -Lo qtci.zip  https://github.com/tsteven4/qtci/archive/isolate2.zip \
    && unzip qtci.zip \
    && rm qtci.zip \
    && chmod +x qtci-isolate2/recipes/install-qt \
    && chmod +x qtci-isolate2/recipes/install-qt-online \
    && chmod +x qtci-isolate2/bin/extract-qt-installer \
    && sed -i 's/if (installer.isOfflineOnly()) {/if (installer.isOfflineOnly() || true) {'/g qtci-isolate2/bin/qt-install.qs

RUN env VERBOSE=true PATH=$PATH:qtci-isolate2/bin:qtci-isolate2/recipes \
    install-qt-online qt.$(echo "${QT_VERSION}" | tr -d .).gcc_64 "/opt"

# Reconfigure locale
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

# Add group & user + sudo
RUN groupadd -r ubuntu && useradd --create-home --gid ubuntu ubuntu && echo 'ubuntu ALL=NOPASSWD: ALL' > /etc/sudoers.d/ubuntu

# dirty hack. Probably it's better try to switch on rhel7 template which is officially supported by Qt 5.9.6:
# https://wiki.qt.io/Qt_5.9_Tools_and_Versions
# For QtDBus.so libdbus 1.3 is needed.
#
# Also, upgrade OpenSSL from 1.0.1f (ubuntu 14.04)   to  1.0.2g (ubuntu 16.04)
# With version from Ubuntu 14.04 QSslSocket prints:
#
# WARNING: :0 - QSslSocket: cannot resolve SSL_set_alpn_protos
# WARNING: :0 - QSslSocket: cannot resolve SSL_CTX_set_alpn_select_cb
# WARNING: :0 - QSslSocket: cannot resolve SSL_get0_alpn_selected
# - stil not prints it's not compatible, so seems OK, but:
#
# Updates checking in Moolticute doesn't work:
#
# INFO: :0 - Checking software updates from  "https://api.github.com/repos/mooltipass/moolticute/releases"
# (then no output)
#
# TO CHECK: Maybe this is because the lack of "engines/" directory for libcrypto.
RUN echo "deb http://archive.ubuntu.com/ubuntu/ xenial main" > /etc/apt/sources.list.d/xenial.list && \
    apt-get update && \
    apt-get install -y libdbus-1-3 libssl1.0.0


# Inside Docker fuse mount will not work, so extract AppImages:
# https://github.com/AppImage/AppImageKit/issues/405

# get linuxdeploy
RUN curl -4 -LO "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage" && \
    chmod +x linuxdeploy-x86_64.AppImage && \
    ./linuxdeploy-x86_64.AppImage --appimage-extract && \
    rm -f linuxdeploy-x86_64.AppImage && \
    mv squashfs-root linuxdeploy-x86_64.AppDir

# get linuxdeploy Qt plugin:
RUN curl -4 -LO "https://github.com/linuxdeploy/linuxdeploy-plugin-qt/releases/download/continuous/linuxdeploy-plugin-qt-x86_64.AppImage" && \
    chmod +x linuxdeploy-plugin-qt-x86_64.AppImage && \
    ./linuxdeploy-plugin-qt-x86_64.AppImage --appimage-extract && \
    rm -f linuxdeploy-plugin-qt-x86_64.AppImage && \
    mv squashfs-root linuxdeploy-plugin-qt-x86_64.AppDir

COPY scripts /scripts

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
