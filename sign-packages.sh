#!/usr/bin/env bash

GIT_ROOT=$PWD
APT_REPO_DIR=$GIT_ROOT/live-persistence/apt/deb-repo/oracle-java8
# TODO: allow choice of fingerprint via envvar
GPG_KEYID=0x2ED437F7FC76AE12

echo "Copying packages to $APT_REPO_DIR..."
rsync -az *.deb $APT_REPO_DIR

echo -n "Checking for at least one GPG key... "
gpg --with-colons --list-secret-keys | grep "fpr" 1>/dev/null || (echo "No GPG key present. Exiting." && exit 1)
echo "ok"

cd $APT_REPO_DIR

echo "Signing deb packages..."
dpkg-sig --batch=1 --g "--batch" -k "$GPG_KEYID" --sign builder *.deb
echo "ok."

echo -n "Generating signed package and release files... "
apt-ftparchive packages . > Packages
gzip --to-stdout Packages > Packages.gz
apt-ftparchive release . > Release
gpg --default-key="$GPG_KEYID" --batch --yes --clearsign --output InRelease Release
gpg --default-key="$GPG_KEYID" --batch --yes --armor --detach-sign --sign --output Release.gpg Release
echo "ok."

echo -n "Generating trusted keyring... "
gpg --armor --export "$GPG_KEYID" > $GIT_ROOT/live-persistence/apt/trusted.gpg.d/_local-repo.gpg
echo "ok."
