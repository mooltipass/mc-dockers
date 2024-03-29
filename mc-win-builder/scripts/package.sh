#/bin/env bash

set -ev

SCRIPTDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
source $SCRIPTDIR/funcs.sh

build_dir=/moolticute/build_win
MXE_BIN=/mxe/usr/i686-w64-mingw32.shared.posix
WDIR=$HOME/.wine/drive_c/moolticute_build
PKDIR=/moolticute/packages
mkdir -p $PKDIR

cd /moolticute
VERSION="$(get_version .)"
FILENAME=moolticute_setup_$VERSION

mkdir -p $WDIR/cli
cd $build_dir/..

#Get 3rd party tools
wget_retry https://calaos.fr/mooltipass/tools/windows/mc-agent.exe -O $WDIR/cli/mc-agent.exe
wget_retry https://calaos.fr/mooltipass/tools/windows/mc-cli.exe -O $WDIR/cli/mc-cli.exe

#Get emulator
wget_retry https://github.com/mooltipass/minible/releases/latest/download/minible_emu.exe -O $WDIR/minible_emu.exe
wget_retry https://github.com/mooltipass/minible/releases/latest/download/miniblebundle.img -O $WDIR/miniblebundle.img

for f in $MXE_BIN/bin/libgcc_s_sjlj-1.dll \
         $MXE_BIN/bin/libstdc++-6.dll \
         $MXE_BIN/bin/libwinpthread-1.dll \
         $MXE_BIN/bin/libcrypto-3.dll \
         $MXE_BIN/bin/libssl-3.dll \
         $MXE_BIN/bin/libzstd.dll \
         $MXE_BIN/bin/zlib1.dll \
         $MXE_BIN/bin/icudt70.dll \
         $MXE_BIN/bin/icuin70.dll \
         $MXE_BIN/bin/icuuc70.dll \
         $MXE_BIN/bin/libpng16-16.dll \
         $MXE_BIN/bin/libjpeg-9.dll \
         $MXE_BIN/qt6/bin/Qt6Core.dll \
         $MXE_BIN/qt6/bin/Qt6Gui.dll \
         $MXE_BIN/qt6/bin/Qt6Network.dll \
         $MXE_BIN/qt6/bin/Qt6Widgets.dll \
         $MXE_BIN/qt6/bin/Qt6WebSockets.dll \
         $MXE_BIN/qt6/plugins/imageformats \
         $MXE_BIN/qt6/plugins/platforms \
         $MXE_BIN/qt6/plugins/styles \
         $MXE_BIN/qt6/plugins/tls \
         /moolticute/win/snoretoast/SnoreToast.exe \
         /moolticute/win/snoretoast/icon.png \
         $build_dir/release/moolticute.exe \
         $build_dir/release/moolticuted.exe
do
    cp -R $f $WDIR
done

find_and_sign $WDIR

pushd win

echo "#define MyAppVersion \"$VERSION\"" > build.iss
cat installer.iss >> build.iss
iscc build.iss

sign_binary build/$FILENAME.exe
mv build/$FILENAME.exe $PKDIR

#Create a portable zip for windows
ZIPFILE=moolticute_portable_win32_${VERSION}.zip
pushd $WDIR/..
mv moolticute_build moolticute_$VERSION
WDIR=$(pwd)
zip --compression-method deflate -r $ZIPFILE moolticute_$VERSION
popd

mv $WDIR/$ZIPFILE $PKDIR

popd

