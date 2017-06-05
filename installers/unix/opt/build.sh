#!/bin/bash
# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (C) 2010-2017 GEM Foundation
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

unset LD_LIBRARY_PATH

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
OQ_PREFIX=${OQ_ROOT}/${OQ_REL}/dist
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
    check_dep sudo
    if [ "$VENDOR" == "redhat" ]; then
        sudo yum -q -y upgrade
        sudo yum -q -y groupinstall 'Development Tools'
        sudo yum -q -y install epel-release
        sudo yum -q -y install autoconf bzip2-devel curl git gzip libtool makeself readline-devel spatialindex-devel tar which xz zip zlib-devel
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
curl -LOz openssl-1.0.2l.tar.gz https://www.openssl.org/source/openssl-1.0.2l.tar.gz
curl -LOz sqlite-autoconf-3190200.tar.gz https://www.sqlite.org/2017/sqlite-autoconf-3190200.tar.gz
curl -LOz Python-2.7.13.tar.xz https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tar.xz
# FIXME Rtree is currently unsupported
# curl -LOz 1.8.5.tar.gz https://github.com/libspatialindex/libspatialindex/archive/1.8.5.tar.gz
curl -LOz get-pip.py https://bootstrap.pypa.io/get-pip.py

cd ..

cat <<EOF >> $OQ_PREFIX/env.sh
PREFIX=$OQ_PREFIX

export LD_LIBRARY_PATH=\${PREFIX}/lib
export CPATH=\${PREFIX}/include
export PATH=\${PREFIX}/bin:\${PATH}
# FIXME Rtree is currently unsupported
# export SPATIALINDEX_LIBRARY=\$LD_LIBRARY_PATH/libspatialindex.so
# export SPATIALINDEX_C_LIBRARY=\$LD_LIBRARY_PATH/libspatialindex_c.so
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
tar xf src/sed-4.2.2.tar.gz
cd sed-4.2.2
./configure --prefix=$OQ_PREFIX
make -s -j $NPROC
make -s install
cd ..

if $CLEANUP; then rm -Rf openssl-1.0.2l; fi
tar xf src/openssl-1.0.2l.tar.gz
cd openssl-1.0.2l/
if [ "$BUILD_OS" == "macos" ]; then
    ./Configure darwin64-x86_64-cc shared enable-ec_nistp_64_gcc_128 no-ssl2 no-ssl3 no-comp --prefix=$OQ_PREFIX
else
    ./config shared --prefix=$OQ_PREFIX
fi
make -s -j $NPROC depend
make -s -j $NPROC
make -s install
cd ..

if $CLEANUP; then rm -Rf sqlite-autoconf-3190200; fi
tar xf src/sqlite-autoconf-3190200.tar.gz
cd sqlite-autoconf-3190200
./configure --prefix=$OQ_PREFIX
make -s -j $NPROC
make -s install
cd ..

if $CLEANUP; then rm -Rf Python-2.7.13; fi
tar xJf src/Python-2.7.13.tar.xz
cd Python-2.7.13
./configure --prefix=$OQ_PREFIX --enable-unicode=ucs4 --with-ensurepip
make -s -j $NPROC
make -s install
cd ..

# FIXME Rtree is currently unsupported
# if $CLEANUP; then rm -Rf 1.8.5; fi
# tar xvf src/1.8.5.tar.gz
# cd libspatialindex-1.8.5
# ./autogen.sh || true
# ./autogen.sh
# ./configure --prefix=$OQ_PREFIX
# make -s -j $NPROC
# make -s install
# cd ..

$OQ_PREFIX/bin/python src/get-pip.py

rm -Rf oq-engine
git clone -q --depth=1 -b $OQ_BRANCH https://github.com/gem/oq-engine.git
cd oq-engine
declare OQ_$(echo 'engine' | tr '[:lower:]' '[:upper:]')_DEV=$(git rev-parse --short HEAD)
$OQ_PREFIX/bin/python2.7 -m pip -q install -r requirements-py27-${BUILD_OS}.txt
$OQ_PREFIX/bin/python2.7 -m pip -q install .
cd ..

mkdir -p $OQ_PREFIX/share/openquake/engine
cp oq-engine/README.md oq-engine/LICENSE $OQ_PREFIX
cp -R oq-engine/demos $OQ_PREFIX/share/openquake/engine
cp -R oq-engine/doc $OQ_PREFIX/share/openquake/engine
rm -Rf $OQ_PREFIX/share/openquake/engine/doc/sphinx

# Make a zipped copy of each demo
for d in hazard risk; do
    cd ${OQ_PREFIX}/share/openquake/engine/demos/${d}
    for z in *; do
        zip -q -r ${z}.zip $z
    done
    cd -
done

# utils is not copied for now, since it does not contain anything useful here
cp install.sh ${OQ_ROOT}/${OQ_REL}

makeself -q ${OQ_ROOT}/${OQ_REL} ../openquake-py27-${BUILD_OS}-${OQ_ENGINE_DEV}.run "installer for the OpenQuake Engine" ./install.sh

exit 0
