#!/usr/bin/env bash

echo -n "Checking whether you are running Tails >= 1.3... "
grep "1\.3" /etc/os-release 1>/dev/null || (echo "Not running Tails 1.3" && exit 1)
echo "ok." 

echo -n "Checking out oracle-java8 builder submodule... "
git submodule update --init --recursive 1>/dev/null
git submodule foreach "git checkout --force" 1>/dev/null
echo "ok."

cd oracle-java8

echo -n "Applying patch to increase oracle-java8 package priorities... "
git apply ../increase-java8-package-priority.diff
echo "ok."

echo "Running oracle-java8 build scripts..."
proxychains ./prepare.sh

echo "Building oracle-java8 packages..."
dpkg-buildpackage -uc -us
