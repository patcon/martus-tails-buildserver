#!/usr/bin/env bash

APT_REPO_DIR=$PWD/live-persistence/apt/deb-repo/oracle-java8

echo "Copying packages to $APT_REPO_DIR..."
rsync -avz *.deb $APT_REPO_DIR

echo -n "Checking for at least one GPG key... "
# TODO: allow choice of fingerprint via envvar
gpg --with-colons --list-secret-keys | grep "fpr" 1>/dev/null || (echo "No GPG key present. Exiting." && exit 1)
echo "ok"

echo "Signing deb packages..."
cd $APT_REPO_DIR
dpkg-sig --sign builder *.deb
apt-ftparchive packages . > Packages
gzip --to-stdout Packages > Packages.gz
apt-ftparchive release . > Release
gpg --clearsign --output InRelease Release
gpg --armor --detach-sign --sign --output Release.gpg Release
