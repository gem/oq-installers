#!/bin/bash

set -x
set -e

OQ_PREFIX=/opt/openquake
OQ_BRANCH=master

rm -Rf $OQ_PREFIX

#FIXME
BUILD_OS=ubuntu
if [ "$BUILD_OS" == "ubuntu" ]; then
    apt-get update
    apt-get upgrade -y 
    apt-get install -y build-essential autoconf libtool libsqlite3-dev libreadline-dev zlib1g-dev libbz2-dev wget xz-utils git
elif [ "$BUILD_OS" == "redhat" ]; then
    yum -y upgrade
    yum groupinstall 'Development Tools'
    yum install autoconf libtool sqlite-devel readline-devel zlib-devel bzip2-devel wget xz git
else
    echo "Build OS not uspported"
    exit 1
fi

mkdir -p build/src
mkdir $OQ_PREFIX

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

rm -Rf openssl-1.0.2h
tar xvf src/openssl-1.0.2h.tar.gz
cd openssl-1.0.2h/
./config --prefix=$OQ_PREFIX shared
make
make install
cd ..

rm -Rf Python-2.7.11
tar xvf src/Python-2.7.11.tar.xz
cd Python-2.7.11
./configure --prefix=$OQ_PREFIX
make
make install
cd ..

rm -Rf hdf5-1.8.17
tar xvf src/hdf5-1.8.17.tar.gz
cd hdf5-1.8.17
export HDF5_DIR=$OQ_PREFIX
./configure --prefix=$OQ_PREFIX
make
make install
cd ..

rm -Rf libgeos-3.5.0
tar xvf src/3.5.0.tar.gz
cd libgeos-3.5.0
./autogen.sh
./configure --prefix=$OQ_PREFIX
make
make install
cd ..

python src/get-pip.py
pip install -r $OQ_PREFIX/requirements.txt

for g in hazardlib risklib engine;
do 
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

tar -C /opt -cpzvf opt-openquake-${OQ_ENGINE_DEV}.tar.gz openquake

exit 0
