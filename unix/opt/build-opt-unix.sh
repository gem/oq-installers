#!/bin/bash
# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (C) 2010-2016 GEM Foundation
#
# OpenQuake is free software: you can redistribute it and/or modify it
# under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# OpenQuake is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with OpenQuake. If not, see <http://www.gnu.org/licenses/>.

if [ $GEM_SET_DEBUG ]; then
    set -x
fi
set -e

check_dep() {
    for i in $*; do
        command -v $i &> /dev/null || {
            echo -e "!! Please install $i first. Aborting." >&2
            exit 1
        }
    done
}

not_supported() {
    echo "!! This operating system is not unsupported. Aborting." >&2
    exit 1
}

OQ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OQ_ROOT=/tmp/build-openquake-dist
OQ_REL=qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
OQ_PREFIX=${OQ_ROOT}/${OQ_REL}/openquake
CLEANUP=true

if [ $GEM_SET_NPROC ]; then
    NPROC=$GEM_SET_NPROC
else
    #Everyone has at least two cores
    NPROC=2
fi
if [ $GEM_SET_BRANCH ]; then
    OQ_BRANCH=$GEM_SET_BRANCH
else
    OQ_BRANCH=master
fi

rm -Rf $OQ_ROOT
cd $OQ_DIR

if $(echo $OSTYPE | grep -q linux); then
    BUILD_OS='linux64'
    if [ $GEM_SET_VENDOR ]; then
        VENDOR=$GEM_SET_VENDOR
    else
        VENDOR='redhat'
    fi
    if [ "$VENDOR" == "redhat" ]; then
        yum -y upgrade
        yum -y groupinstall 'Development Tools'
        yum -y install epel-release
        yum -y install autoconf bzip2-devel curl git gzip libtool makeself readline-devel spatialindex-devel sqlite-devel tar which xz zlib-devel
    elif [ "$VENDOR" == "ubuntu" ]; then
        sudo apt-get update
        sudo apt-get upgrade -y
        sudo apt-get install -y autoconf build-essential curl debianutils git gzip libbz2-dev libreadline-dev libspatialindex-dev libsqlite3-dev libtool makeself tar xz-utils zlib1g-dev
    else
        not_supported
    fi
elif $(echo $OSTYPE | grep -q darwin); then
    BUILD_OS='macos'
    check_dep xcode-select makeself
    sudo xcode-select --install || true

else
    not_supported
fi

mkdir -p build/src
mkdir -p $OQ_PREFIX

cp install.sh build/

cd build/src

curl -LOz sed-4.2.2.tar.gz http://ftp.gnu.org/gnu/sed/sed-4.2.2.tar.gz
curl -LOz openssl-1.0.2h.tar.gz https://www.openssl.org/source/openssl-1.0.2h.tar.gz
curl -LOz Python-2.7.11.tar.xz https://www.python.org/ftp/python/2.7.11/Python-2.7.11.tar.xz
curl -LOz hdf5-1.8.17.tar.gz http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.17.tar.gz
curl -LOz 1.8.5.tar.gz https://github.com/libspatialindex/libspatialindex/archive/1.8.5.tar.gz
curl -LOz get-pip.py https://bootstrap.pypa.io/get-pip.py

if [ "$BUILD_OS" == "linux64" ]; then
    curl -LOz 3.5.0.tar.gz https://github.com/libgeos/libgeos/archive/3.5.0.tar.gz
fi

cd ..

cat <<EOF >> $OQ_PREFIX/requirements.txt
pkgconfig==1.1.0
Cython==0.23.4
mock==1.3.0
# h5py must be installed after everything else
# to avoid SSL errors on MacOS X
# h5py==2.6.0
nose==1.3.7
numpy==1.11.1
scipy==0.17.1
psutil==3.4.2
shapely==1.5.13
docutils==0.12
decorator==4.0.10
funcsigs==1.0.2
pbr==1.8.0
six==1.10.0
futures==3.0.5
django==1.8.7
requests==2.9.1
pyshp==1.2.3
#Rtree needs master to work with a custom LD_LIBRARY_PATH
https://github.com/Toblerity/rtree/archive/master.zip
EOF

cat <<EOF >> $OQ_PREFIX/env.sh
PREFIX=$OQ_PREFIX

export LD_LIBRARY_PATH=\${PREFIX}/lib
export CPATH=\${PREFIX}/include
export PATH=\${PREFIX}/bin:\${PATH}
export SPATIALINDEX_LIBRARY=\$LD_LIBRARY_PATH/libspatialindex.so
export SPATIALINDEX_C_LIBRARY=\$LD_LIBRARY_PATH/libspatialindex_c.so
export OQ_SITE_CFG_PATH=\${PREFIX}/etc/openquake.cfg
export PS1=(openquake)\${PS1}
EOF
if [ "$BUILD_OS" == "macos" ]; then
    cat <<EOF >> $OQ_PREFIX/env.sh
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
EOF
fi

source $OQ_PREFIX/env.sh

if $CLEANUP; then rm -Rf $HOME/.cache/pip; fi

if $CLEANUP; then rm -Rf sed-4.2.2; fi
tar xvf src/sed-4.2.2.tar.gz
cd sed-4.2.2
./configure --prefix=$OQ_PREFIX
make -j $NPROC
make install
cd ..

if $CLEANUP; then rm -Rf openssl-1.0.2h; fi
tar xvf src/openssl-1.0.2h.tar.gz
cd openssl-1.0.2h/
if [ "$BUILD_OS" == "macos" ]; then
    ./Configure darwin64-x86_64-cc shared enable-ec_nistp_64_gcc_128 no-ssl2 no-ssl3 no-comp --prefix=$OQ_PREFIX
else
    ./config shared --prefix=$OQ_PREFIX
fi
make -j $NPROC depend
make -j $NPROC
make install
cd ..

if $CLEANUP; then rm -Rf Python-2.7.11; fi
tar xvf src/Python-2.7.11.tar.xz
cd Python-2.7.11
./configure --prefix=$OQ_PREFIX --enable-unicode=ucs4
make -j $NPROC
make install
cd ..

if $CLEANUP; then rm -Rf hdf5-1.8.17; fi
tar xvf src/hdf5-1.8.17.tar.gz
cd hdf5-1.8.17
export HDF5_DIR=$OQ_PREFIX
./configure --prefix=$OQ_PREFIX
make -j $NPROC
make install
cd ..

if $CLEANUP; then rm -Rf 1.8.5; fi
tar xvf src/1.8.5.tar.gz
cd libspatialindex-1.8.5
./autogen.sh || true
./autogen.sh
./configure --prefix=$OQ_PREFIX
make -j $NPROC
make install
cd ..

if [ "$BUILD_OS" == "linux64" ]; then
    if $CLEANUP; then rm -Rf libgeos-3.5.0; fi
    tar xvf src/3.5.0.tar.gz
    cd libgeos-3.5.0
    # Workaround for an autogen.sh bug
    ./autogen.sh || true
    ./autogen.sh
    ./configure --prefix=$OQ_PREFIX
    make -j $NPROC
    make install
    cd ..
fi

python src/get-pip.py
python $(which pip) install -r $OQ_PREFIX/requirements.txt
# h5py must be installed after everything else
# to avoid SSL errors on MacOS X
python $(which pip) install h5py==2.6.0

for g in hazardlib engine;
do 
    rm -Rf oq-${g}
    git clone --depth=1 -b $OQ_BRANCH https://github.com/gem/oq-${g}.git
    cd oq-${g}
    declare OQ_$(echo $g | tr '[:lower:]' '[:upper:]')_DEV=$(git rev-parse --short HEAD)
    python setup.py install
    cd ..
done

mkdir $OQ_PREFIX/etc
mkdir -p $OQ_PREFIX/share/openquake/engine
cp oq-engine/README.md oq-engine/LICENSE $OQ_PREFIX
cp oq-engine/openquake.cfg $OQ_PREFIX/etc
cp -R oq-engine/demos $OQ_PREFIX/share/openquake/engine
cp -R oq-engine/doc $OQ_PREFIX/share/openquake/engine
rm -Rf $OQ_PREFIX/share/openquake/engine/doc/sphinx
# utils is not copied for now, since it does not contain anything useful here
cp install.sh ${OQ_ROOT}/${OQ_REL}

makeself ${OQ_ROOT}/${OQ_REL} ../openquake-setup-${BUILD_OS}-${OQ_ENGINE_DEV}.run "installer for the OpenQuake Engine" ./install.sh

exit 0
