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

OQ_ROOT=/tmp/build-openquake-dist
OQ_REL=qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq
OQ_PREFIX=${OQ_ROOT}/${OQ_REL}/openquake
OQ_BRANCH=master

rm -Rf $OQ_ROOT

#FIXME
BUILD_OS=ubuntu
if [ "$BUILD_OS" == "ubuntu" ]; then
    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get install -y build-essential autoconf libtool libsqlite3-dev libreadline-dev zlib1g-dev libbz2-dev wget xz-utils git
elif [ "$BUILD_OS" == "redhat" ]; then
    sudo yum -y upgrade
    sudo yum groupinstall 'Development Tools'
    sudo yum install autoconf libtool sqlite-devel readline-devel zlib-devel bzip2-devel wget xz git
else
    echo "Build OS not uspported"
    exit 1
fi

mkdir -p build/src
mkdir -p $OQ_PREFIX

cp install.sh build/

cd build/src

wget -nc https://www.openssl.org/source/openssl-1.0.2h.tar.gz
wget -nc https://www.python.org/ftp/python/2.7.11/Python-2.7.11.tar.xz
wget -nc http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.17.tar.gz
wget -nc https://github.com/libgeos/libgeos/archive/3.5.0.tar.gz
wget -nc https://bootstrap.pypa.io/get-pip.py

cd ..

cat <<EOF >> $OQ_PREFIX/requirements.txt
futures==3.0.5
mock==1.3.0
h5py==2.6.0
nose==1.3.7
numpy==1.11.0
pbr==1.8.0
psutil==3.4.2
scipy==0.17.0
shapely==1.5.13
six==1.10.0
django==1.8.7
docutils==0.12
decorator==4.0.6
EOF

cat <<EOF >> $OQ_PREFIX/env.sh
PREFIX=$OQ_PREFIX

export LD_LIBRARY_PATH=\${PREFIX}/lib
export CPATH=\${PREFIX}/include
export PATH=\${PREFIX}/bin:$PATH
export OQ_SITE_CFG_PATH=\${PREFIX}/etc/openquake.cfg
EOF

source $OQ_PREFIX/env.sh

if $CLEANUP; then rm -Rf openssl-1.0.2h; fi
tar xvf src/openssl-1.0.2h.tar.gz
cd openssl-1.0.2h/
./config --prefix=$OQ_PREFIX shared
make depend
make
make install
cd ..

if $CLEANUP; then rm -Rf Python-2.7.11; fi
tar xvf src/Python-2.7.11.tar.xz
cd Python-2.7.11
./configure --prefix=$OQ_PREFIX
make
make install
cd ..

if $CLEANUP; then rm -Rf hdf5-1.8.17; fi
tar xvf src/hdf5-1.8.17.tar.gz
cd hdf5-1.8.17
export HDF5_DIR=$OQ_PREFIX
./configure --prefix=$OQ_PREFIX
make
make install
cd ..

if $CLEANUP; then rm -Rf libgeos-3.5.0; fi
tar xvf src/3.5.0.tar.gz
cd libgeos-3.5.0
./autogen.sh
./configure --prefix=$OQ_PREFIX
make
make install
cd ..

python src/get-pip.py
python $(which pip) install -r $OQ_PREFIX/requirements.txt

for g in hazardlib risklib engine;
do 
    rm -Rf oq-${g}
    git clone --depth=1 -b $OQ_BRANCH https://github.com/gem/oq-${g}.git
    cd oq-${g}
    declare OQ_${g^^}_DEV=$(git rev-parse --short HEAD)
    python setup.py install
    cd ..
done

mkdir $OQ_PREFIX/etc
mkdir $OQ_PREFIX/share/openquake
cp oq-engine/openquake.cfg $OQ_PREFIX/etc
cp -R oq-risklib/demos $OQ_PREFIX/share/openquake

tar -C ${OQ_ROOT}/${OQ_REL} -cpzvf openquake-${OQ_ENGINE_DEV}.tar.gz openquake
sed -i 's/%_SOURCE_%/'openquake-${OQ_ENGINE_DEV}.tar.gz'/g' install.sh
GZIP=-1 tar -cpzvf openquake-opt-${OQ_ENGINE_DEV}.tar.gz openquake-${OQ_ENGINE_DEV}.tar.gz install.sh

exit 0
