#/bin/env bash

set -ev

PATH=$HOME/mxe/usr/bin:$PATH
MXE_BASE=$HOME/mxe
build_dir=/moolticute/build_win

rm -fr $build_dir && mkdir -p $build_dir && cd $build_dir

$MXE_BASE/usr/i686-w64-mingw32.shared.posix/qt5/bin/qmake ../Moolticute.pro
make -j$(nproc --all)

