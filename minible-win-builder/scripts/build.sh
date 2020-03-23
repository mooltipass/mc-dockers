#/bin/env bash

set -ev

PATH=$HOME/mxe/usr/bin:$PATH
MXE_BASE=$HOME/mxe
build_dir=/minible/build_win
output_dir=/minible/output

cd /minible
git submodule update --init --recursive
rm -fr $build_dir && mkdir -p $build_dir && cd $build_dir

$MXE_BASE/usr/i686-w64-mingw32.shared.posix/qt5/bin/qmake ../source_code/main_mcu/minible_emu.pro
make -j$(nproc --all)
mkdir -p $output_dir
mv release/minible_emu.exe $output_dir
