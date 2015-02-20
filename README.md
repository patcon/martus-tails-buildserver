## Usage

* These instructions are incompatible with `polipo` which is used instead of `torsocks` in Tails before v1.3, specifically the `proxychains` command. You will need at minimum tails-1.3-rc1 to run this build.

```
git clone https://github.com/patcon/martus-tails-buildserver
cd martus-tails-buildserver
git submodule update --init --recursive

cd oracle-java8
sudo apt-get install debhelper curl unzip proxychains --yes
proxychains ./prepare.sh
sudo apt-get install build-essential lsb-release libasound2 unixodbc libxi6 libxt6 libxtst6 libxrender1 --yes
dpkg-buildpackage -uc -us
```

