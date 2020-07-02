#!/bin/sh
# script to download and install the autoools versions that we currently use with COIN-OR/BuildTools
# original script by Pierre Bonami

acver=2.69
aaver=2019.01.06
amver=1.16.2
ltver=2.4.6

# exit immediately if something fails
set -e

if test -n "$COIN_AUTOTOOLS_DIR" ; then
  echo "Installation into $COIN_AUTOTOOLS_DIR"
  mkdir -p "$COIN_AUTOTOOLS_DIR"
  PREFIX="--prefix $COIN_AUTOTOOLS_DIR"
  # so that we can configure automake with the new (then installed) autoconf
  export PATH=$COIN_AUTOTOOLS_DIR/bin:"$PATH"
fi

# cleanup from previous (maybe failed) build
rm -rf autoconf-$acver* autoconf-archive-$aaver* automake-$amver* libtool-$ltver*

curl -O https://ftp.gnu.org/gnu/autoconf/autoconf-$acver.tar.gz
tar xvzf autoconf-$acver.tar.gz
cd autoconf-$acver
./configure $PREFIX
make install
cd ..
rm -rf autoconf-$acver*

curl -O https://ftp.gnu.org/gnu/autoconf-archive/autoconf-archive-$aaver.tar.xz
tar xvJf autoconf-archive-$aaver.tar.xz
cd autoconf-archive-$aaver
./configure $PREFIX
make install
cd ..
rm -rf autoconf-archive-$aaver*

curl -O https://ftp.gnu.org/gnu/automake/automake-$amver.tar.gz
tar xvzf automake-$amver.tar.gz
cd automake-$amver
./configure $PREFIX
make install
cd ..
rm -rf automake-$amver*

curl -O https://ftp.gnu.org/gnu/libtool/libtool-$ltver.tar.gz
tar xvzf libtool-$ltver.tar.gz
cd libtool-$ltver
./configure $PREFIX
make install
cd ..
rm -rf libtool-$ltver*
