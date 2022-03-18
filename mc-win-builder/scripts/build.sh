#/bin/env bash

set -ev

PATH=/mxe/usr/bin:$PATH
MXE_BASE=/mxe
build_dir=/moolticute/build_win

ls -l /moolticute

#get snoretoast.exe
wget https://github.com/mooltipass/snoretoast/releases/download/v0.6.0/SnoreToast.exe -O /moolticute/win/snoretoast/SnoreToast.exe

rm -fr $build_dir && mkdir -p $build_dir && cd $build_dir

$MXE_BASE/usr/i686-w64-mingw32.shared.posix/qt6/bin/host-qmake ../Moolticute.pro
make -j$(nproc --all)

