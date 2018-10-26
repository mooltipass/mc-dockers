#!/bin/bash
# https://github.com/linuxdeploy/linuxdeploy-plugin-qt-examples/blob/master/build_appimages.sh
set -e
set -x
set -u

cd /moolticute

export ARCH=$(arch)

APP=moolticute
LOWERAPP=${APP,,}

BASE_PATH="$PWD/build-appimage"

BUILD_DIR="$BASE_PATH/build-qmake-release"
APPDIR="$BASE_PATH/$APP.AppDir"

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




# Copy OpenSSL 1.0 manually because QSslSocket loads it dynamically in runtime.
# QSslSocket class uses some hieristic to choose 'best' OpenSSL.
# So we have to create different symlinks to trick it
# and pick ours library from this AppImage bundle
mkdir -p "$APPDIR/usr/lib"
SSLLIBNAME="libssl.so.1.0.0"
cp "/lib/x86_64-linux-gnu/$SSLLIBNAME" "$APPDIR/usr/lib/"

# http://code.qt.io/cgit/qt/qtbase.git/tree/src/network/ssl/qsslsocket_openssl_symbols.cpp?h=5.9.6#n662
#    // The right thing to do is to load the library at the major version we know how
#    // to work with: the SHLIB_VERSION_NUMBER version (macro defined in opensslv.h)
#
# But there is no way to get this value from Qt5Network other than:
#   $ strings ~/moolticute/build-appimage/moolticute.AppDir/usr/lib/libQt5Network.so.5 | grep '^1\.0'
#   1.0.2k
SHLIB_VERSION_NUMBER=`strings "${QT_PATH}/${QT_VERSION}/gcc_64/lib/libQt5Network.so" | grep '^1\.0' | head -n 1`

if [ -n "$SHLIB_VERSION_NUMBER" ] ; then
    echo "This QSslSocket was compiled agains $SHLIB_VERSION_NUMBER"

    # Creating links to libssl.so.<SHLIB_VERSION_NUMBER> and libcrypto.so.<SHLIB_VERSION_NUMBER>
    # to trigger first attempt case so no other libraries will be checked:
    #
    # http://code.qt.io/cgit/qt/qtbase.git/tree/src/network/ssl/qsslsocket_openssl_symbols.cpp?h=5.9.6#n682
    #    // first attempt: the canonical name is libssl.so.<SHLIB_VERSION_NUMBER>
    #    libssl->setFileNameAndVersion(QLatin1String("ssl"), QLatin1String(SHLIB_VERSION_NUMBER));
    #    libcrypto->setFileNameAndVersion(QLatin1String("crypto"), QLatin1String(SHLIB_VERSION_NUMBER));
    #    if (libcrypto->load() && libssl->load()) {
    #        // libssl.so.<SHLIB_VERSION_NUMBER> and libcrypto.so.<SHLIB_VERSION_NUMBER> found
    #        return pair;

    ln -s "$SSLLIBNAME" "$APPDIR/usr/lib/libssl.so.${SHLIB_VERSION_NUMBER}"
    ln -s "libcrypto.so.1.0.0" "$APPDIR/usr/lib/libcrypto.so.${SHLIB_VERSION_NUMBER}"
fi

# Also get OpenSSL config:
mkdir -p "$APPDIR/usr/lib/ssl/"
cp "/usr/lib/ssl/openssl.cnf" "$APPDIR/usr/lib/ssl"


# Use appimage plugin to create .AppImage also: https://github.com/linuxdeploy/linuxdeploy-plugin-appimage
~/linuxdeploy-x86_64.AppDir/AppRun --verbosity=0 --appdir "$APPDIR"
~/linuxdeploy-plugin-qt-x86_64.AppDir/AppRun --appdir "$APPDIR"


# workaround: for some strange reasons moolticute.desktop and moolticute.svg are
# turned into a self-symlink
rm "$APPDIR/moolticute.desktop"
cp "$APPDIR/usr/share/applications/moolticute.desktop" "$APPDIR/"

rm "$APPDIR/moolticute.svg"
cp "$APPDIR//usr/share/icons/hicolor/scalable/apps/moolticute.svg" "$APPDIR/"

~/linuxdeploy-x86_64.AppDir/AppRun --verbosity=0 --appdir "$APPDIR" --output appimage
