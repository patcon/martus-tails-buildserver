## Usage

* These instructions are incompatible with `polipo` which is used instead of `torsocks` in Tails before v1.3, specifically the `proxychains` command. You will need at minimum tails-1.3-rc1 to run this build.

    cat /etc/os-release

### Preparing buildserver USB

* You should have a single GPG key imported, and note it's <fingerprint>

```
git clone https://github.com/patcon/martus-tails-buildserver
cd martus-tails-buildserver

# For preparing the oracle-java8 build environment
sudo apt-get install debhelper curl unzip proxychains

# For running build scripts through Tor
sudo apt-get install proxychains

# For building oracle-java8 packages
sudo apt-get install fakeroot build-essential lsb-release libasound2 unixodbc libxi6 libxt6 libxtst6 libxrender1

bash build-java8.sh

bash sign-packages.sh

STAGING_DIR=$GIT_ROOT/live-persistence

# Copy these to system: local.list, deb-repo, trusted keyring

# Run `apt-get update` (system)

# Copy apt-lists to staging

# Copy apt-caches (specific debs) to staging
apt-get --option Dir::Cache::Archives=$STAGING_DIR/apt/cache --download-only install oracle-java8-jre

bash download-install-martus.sh
```

### Generating child USBs

```
sudo bash # Enter root password
patch -p0 < format-external-persistence-vol.diff
tails-persistence-setup --steps bootstrap --override-boot-device=/org/freedesktop/UDisks/devices/sdc
# rsync staging to child usb
rsync --archive --compress $STAGING_DIR /media/TailsData/
tails-fix-persistent-volume-permissions
```
