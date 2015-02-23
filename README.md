# Martus Tails Buildserver

**Martus** is a free, open source, secure information collection and
management tool that empowers human rights and civil liberties
activists. [Website.](https://martus.org/)

**Tails** is a live operating system, that you can start on almost any
computer from a DVD, USB stick, or SD card. It aims at preserving your
privacy and anonymity. [Website.](https://tails.boum.org/)

**This project** aims to help software distributors like Martus run a
Tails buildserver for generating "child" Tails USBs that are
pre-configured to run the Martus software on first boot.

## Why?

Martus would benefit from a secure environment, but requires Java 8.
Neither Martus nor Java 8 have much hope of being deployed with stock
Tails in the near future, and so we need another solution.

## Goals

* Buildserver should be a Tails environment.
* While persistence on the Tails buildserver can be enabled to persist
  its Apt package signing key, it should be relatively easy to run the
  buildserver, and generate child Tails USBs with persistence disabled.
* The Buildserver should only need this repo and GPG key to sign
  generated packages.
* Child Tails USBs should be able to be created from the master Tails
  buildserver without needing to boot up the child USBs.
* The child USBs should run stock Tails (not custom images) and be able
  to leverage the official Tails update mechanisms.
* Any configuration for running Martus should be done via the official
  Tails persistence volume mechanism and features.
* Software running on child USB should be available on first-boot with
  zero or minimal effort.
* Child USBs are necessarily generated with a default password on their
  persistence volume (ideally randomized), but with instructions for the
  end-user to set a custom password immediately on receipt of the USB
  from the trusted distributor.

## Usage

These instructions, specifically where using the `proxychains` command
in scripts, are *incompatible* with `polipo` which is used in Tails
before v1.3. (Newer versions of Tails connect directly to Tor via
`torsocks`.)

You will need at minimum Tails 1.3-rc1 to run this build. You can check
your version most easily by running this command:

    cat /etc/os-release

#### Preparing buildserver USB

* You should have a single GPG key imported, and note it's $FINGERPRINT

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

# Copy these to system: local.list, deb-repo, trusted keyring
sudo cp -r live-persistence/apt/deb-repo/* /usr/local/deb

# TODO: Run `apt-get update` (system)

# TODO: Copy apt-lists to staging

# TODO: Copy apt-caches (specific debs) to staging
apt-get --option Dir::Cache::Archives=$STAGING_DIR/apt/cache --download-only install oracle-java8-jre

bash download-install-martus.sh
```

#### Generating child USBs

```
sudo bash # Enter root password
patch -p0 < format-external-persistence-vol.diff
tails-persistence-setup --steps bootstrap --override-boot-device=/org/freedesktop/UDisks/devices/sdc
# rsync staging to child usb
rsync --archive --compress $STAGING_DIR /media/TailsData/
tails-fix-persistent-volume-permissions
```

## What's Going On?

1. In `live-persistence/` directory of this git repo, we have a skeleton
   of the files we eventually want on the persistence volume of the
   child USB that will run our sofware.
2. We generate packages for oracle-java8 so that we can install JRE on
   the child. (Stock Tails only has OpenJDK 7.)
3. We generate a secure Apt repo for Java 8 and any files that will be
   required to later installation during child USB boot process.
   (trusted keyring, pre-generated apt lists, sources.list for local repo)
4. Now that we've generated a mirror on the persistence volume that we
   will later sync to the child Tails USB, we use Tails Installer to
   create a new Tails USB.
5. We do some magic to allow a persistent volume to be created on the
   newly imaged child Tails USB, setting a temporary password that the
   end-user will be instructed change on receipt of the USB.
6. We rsync our mirror from `live-persistence/` (in this git repo) to
   `/media/TailsData` (the mounted persistence volume for the newly
   created child USB).
7. We fix permissions so that the child will boot appropriately.
8. Done! We can boot the child USB, and Java 8 will be installed from
   the cached packages during boot. Martus will be ready to run with
   only a few extra seconds of boot time.
