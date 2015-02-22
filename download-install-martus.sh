#!/usr/bin/env bash

# Curl fails so we need to troop through it for now... :/
# set -e

MARTUS_VERSION="5.0.2"
MARTUS_FILENAME="Martus-${MARTUS_VERSION}.zip"
GIT_ROOT=$PWD

echo "Downloading $MARTUS_FILENAME..."
proxychains curl --location --continue-at - --progress-bar --retry 3 --retry-delay 3 -O \
	https://martus.org/installers/${MARTUS_FILENAME}

echo -n "Unzipping to live-persistence/dotfiles/.local/share/java..."
unzip -oq $MARTUS_FILENAME -d $PWD/live-persistence/dotfiles/.local/share/java/
echo "ok."
