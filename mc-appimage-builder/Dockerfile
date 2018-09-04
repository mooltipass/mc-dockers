# Official Qt installer is based on https://github.com/rabits/dockerfiles


FROM ubuntu:14.04

MAINTAINER Alexander Sashnov "sashnov@ngs.ru"

ENV DEBIAN_FRONTEND noninteractive

ENV QT_VERSION  5.9.6
ENV QT_PATH /opt/Qt
ENV QT_DESKTOP $QT_PATH/${QT_VERSION}/gcc_64

ENV PATH    $QT_DESKTOP/bin:$PATH
ENV HOME    /home/ubuntu

WORKDIR     /home/ubuntu

# Install updates & requirements:
#  * git, openssh-client, ca-certificates - clone & build
#  * locales, sudo - useful to set utf-8 locale & sudo usage
#  * curl - to download Qt bundle
#  * build-essential, pkg-config, libgl1-mesa-dev - basic Qt build requirements
#  * libsm6, libice6, libxext6, libxrender1, libfontconfig1, libdbus-1-3 - dependencies of the Qt bundle run-file
RUN apt update && apt full-upgrade -y && apt install -y --no-install-recommends \
    git \
    openssh-client \
    ca-certificates \
    locales \
    sudo \
    curl \
    build-essential \
    pkg-config \
    libgl1-mesa-dev \
    libsm6 \
    libice6 \
    libxext6 \
    libxrender1 \
    libfontconfig1 \
    libdbus-1-3

COPY extract-qt-installer.sh /tmp/qt/

# Download & unpack Qt toolchains & clean
# Note curl -4 option: this is workaround for 'unable to resolve host' in ubuntu:14.04 container
RUN curl -4 -Lo /tmp/qt/installer.run "https://download.qt.io/official_releases/online_installers/qt-unified-linux-x64-online.run" \
    && QT_CI_PACKAGES=qt.$(echo "${QT_VERSION}" | tr -d .).gcc_64 /tmp/qt/extract-qt-installer.sh /tmp/qt/installer.run "$QT_PATH" \
    && find "$QT_PATH" -mindepth 1 -maxdepth 1 ! -name "${QT_VERSION}" -exec echo 'Cleaning Qt SDK: {}' \; -exec rm -r '{}' \; \
    && rm -rf /tmp/qt

# Reconfigure locale
RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

# Add group & user + sudo
RUN groupadd -r ubuntu && useradd --create-home --gid ubuntu ubuntu && echo 'ubuntu ALL=NOPASSWD: ALL' > /etc/sudoers.d/ubuntu


# FIXME: put it in a list afterwards: (do not change the order now to leverage 'docker build' cache)
RUN apt-get install -y libfuse2

# get linuxdeploy's AppImage
RUN curl -4 -LO "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage" && \
    chmod +x linuxdeploy-x86_64.AppImage && \
    ./linuxdeploy-x86_64.AppImage --appimage-extract && \
    rm -f linuxdeploy-x86_64.AppImage && \
    mv squashfs-root linuxdeploy-x86_64.AppDir && \
    chown -R ubuntu:ubuntu linuxdeploy-x86_64.AppDir


# fixme: put to common packages list above (here just to leverage Docker build cache)
RUN apt-get install -y libusb-1.0-0-dev

RUN apt-get install -y libdbus-1-dev  # that's too old for Qt 5.9.6 - doesn't link


# dirty hack. Probably it's better try to switch on rhel7 template which is officially supported by Qt 5.9.6:
# https://wiki.qt.io/Qt_5.9_Tools_and_Versions
# Also git tag --points-at=HEAD --sort version:refname         doesn't work with git from Ubuntu 14.04 (unknown option --sort)
RUN echo "deb http://archive.ubuntu.com/ubuntu/ xenial main" > /etc/apt/sources.list.d/xenial.list && \
    apt-get update && \
    apt-get install -y libdbus-1-3 git

# 'appimagetool' will be downloaded during build process by appimage_functions.sh, no need to download here

# USER ubuntu
