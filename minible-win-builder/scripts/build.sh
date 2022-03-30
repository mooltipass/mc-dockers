#/bin/env bash

set -ev

PATH=/mxe/usr/bin:$PATH
MXE_BASE=/mxe
build_dir=/minible/build_win
output_dir=/minible/output

ls -l /minible

mkdir -p $output_dir
cd /minible
git submodule update --init --recursive
rm -fr $build_dir && mkdir -p $build_dir && cd $build_dir
cp ../source_code/main_mcu/emu_assets/miniblebundle.img $output_dir

$MXE_BASE/usr/i686-w64-mingw32.shared.posix/qt6/bin/host-qmake ../source_code/main_mcu/minible_emu.pro
make -j$(nproc --all)

mv release/minible_emu.exe $output_dir
