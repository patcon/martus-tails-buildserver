#!/usr/bin/env bash

APT_REPO_DIR=$PWD/live-persistence/apt/deb-repo/oracle-java8
# TODO: allow choice of fingerprint via envvar
GPG_KEYID=0x2ED437F7FC76AE12

echo "Copying packages to $APT_REPO_DIR..."
rsync -avz *.deb $APT_REPO_DIR

echo -n "Checking for at least one GPG key... "
gpg --with-colons --list-secret-keys | grep "fpr" 1>/dev/null || (echo "No GPG key present. Exiting." && exit 1)
echo "ok"

echo "Signing deb packages..."
cd $APT_REPO_DIR
dpkg-sig -k "$GPG_KEYID" --sign builder *.deb
apt-ftparchive packages . > Packages
gzip --to-stdout Packages > Packages.gz
apt-ftparchive release . > Release
gpg --clearsign --output InRelease Release
gpg --armor --detach-sign --sign --output Release.gpg Release

echo -n "Generating trusted keyring... "
gpg --armor --export "$GPG_KEYID" > $PWD/live-persistence/apt/trusted.gpg.d/_local-repo.gpg
echo "ok."
