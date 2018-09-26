#/bin/env bash

set -e

VERSION=$1
DISTRO=$2

if [ -z $VERSION ]
then
    echo "No version defined."
    echo "Usage:"
    echo "  upload_source.sh 1.2.3 cosmic"
    exit 1
fi

if [ -z $DISTRO ]
then
    echo "No distro defined."
    echo "Usage:"
    echo "  upload_source.sh 1.2.3 cosmic"
    exit 1
fi

if [ ! -e $HOME/.gnupg/gpg.conf ]
then
    echo Setup gpg keys
    gpg --list-keys
    echo use-agent > $HOME/.gnupg/gpg.conf
    echo pinentry-mode loopback >> $HOME/.gnupg/gpg.conf
    echo allow-loopback-pinentry > ~/.gnupg/gpg-agent.conf
    echo RELOADAGENT | gpg-connect-agent

    #import keys
    gpg --import /moolticute/gpgkey_pub.asc
    gpg --no-tty --passphrase-file /moolticute/passphrase.txt --allow-secret-key-import --import /moolticute/gpgkey_sec.asc
fi

function endsWith()
{
    case $2 in *"$1") true;; *) false;; esac;
}

gpg --list-keys
gpg --list-secret-keys

VERSION="${VERSION}~${DISTRO}"
WK=/work
MCDIR=$(basename /moolticute/moolticute-*)
WKMC=$WK/$MCDIR
KEYID="6A270B4394A56AD91FCF7B975806858045DE5C23"
GPG_PROG="gpg --passphrase-file /moolticute/passphrase.txt --no-tty"
DEB_VERSION=$(echo ${VERSION} | tr 'v' ' ' | xargs)

rm -fr $WK/*

mkdir -p $WK
cp -R /moolticute/$MCDIR $WK/
rm -f $WKMC/debian/changelog

echo Update changelog
pushd $WKMC
DEBEMAIL="Mooltipass Team <support@themooltipass.com>" dch --create --package moolticute --distribution $DISTRO --newversion $DEB_VERSION "Release $DEB_VERSION"
cat debian/changelog
popd

echo Preparing changes file and sign it
pushd $WKMC
debuild -S -k$KEYID -p"$GPG_PROG"
popd

pushd $WK
cat *.changes

echo Upload to PPA

ssh-keyscan -p 22 -H ppa.launchpad.net >> $HOME/.ssh/known_hosts

if endsWith -testing "$VERSION"
then
    dput mc-beta *.changes
else
    dput mc *.changes
fi
popd

echo Source uploaded to launchpad
