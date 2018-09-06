#!/bin/bash

set -e
set -x
set -u

cd /moolticute

export ARCH=$(arch)

APP=moolticute
LOWERAPP=${APP,,}


BASE_PATH="$PWD/build-appimage"

BUILD_DIR="$BASE_PATH/build-qmake-release"


# https://docs.appimage.org/packaging-guide/from-source/native-binaries.html#qmake
mkdir -p $BUILD_DIR
cd $BUILD_DIR

qmake CONFIG+=release PREFIX=/usr ../../Moolticute.pro
make
