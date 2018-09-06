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
APPDIR="$BASE_PATH/$APP.AppDir/"

# it's just 7 sec to re-create, and linuxdeploy fails if it's not clean
rm -rf "$APPDIR"
rm -f  "$BASE_PATH/Moolticute-x86_64.AppImage"

( cd $BUILD_DIR ; make install INSTALL_ROOT=$APPDIR )

cp data/moolticute.sh "$APPDIR/usr/bin/"
sed -i 's#Exec=/usr/bin/moolticute#Exec=moolticute.sh#g' "$APPDIR/usr/share/applications/moolticute.desktop"

cd $BASE_PATH

# Example on how to use linuxdeploy Qt plugin properly:
# https://github.com/linuxdeploy/linuxdeploy-plugin-qt-examples/blob/master/build_appimages.sh

# https://docs.appimage.org/packaging-guide/from-source/native-binaries.html#qmake


# Fix for "ERROR: Could not find dependency: libicuuc.so.56"
export LD_LIBRARY_PATH="/opt/Qt/5.9.6/gcc_64/lib/:${LD_LIBRARY_PATH:-}"

# Use appimage plugin to create .AppImage also: https://github.com/linuxdeploy/linuxdeploy-plugin-appimage
~/linuxdeploy-x86_64.AppDir/AppRun --appdir "$APPDIR" --output appimage


# FIXME: Qt plugins are not packed into
# and PATH, LD_LIBRARY_PATH, QTDIR seems also to be not set.
# TODO: read packing manual, see examples of Qt apps package
# (when it's packed from .deb package in AppImage/AppImages .deb doesn't include Qt plugins, right?
# TODO: read through https://github.com/AppImage/AppImageSpec/blob/master/draft.md
# TODO: look through AppRun sources- does it setup this variables?
