#!/bin/bash
# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (C) 2016-2019 GEM Foundation
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

mkdir -p /tmp/src
mkdir -p /tmp/wheelhouse

if [ $GEM_SET_PY ]; then
    PY="$GEM_SET_PY"
else
    PY="36 37"
fi

if [ $GEM_SET_NPROC ]; then
    NPROC=$GEM_SET_NPROC
else
    #Everyone has at least two cores
    NPROC=2
fi

HUID=$(stat -c '%u' ${BASH_SOURCE[0]})
HGID=$(stat -c '%g' ${BASH_SOURCE[0]})

export PY
export NPROC

export OQ_ENV_SET=true
export HDF5_DIR=/usr/local

function build_libtool {
    if [ ! -f /usr/local/bin/libtool ]; then
        cd /tmp/src
        curl -O https://ftp.gnu.org/gnu/libtool/libtool-2.4.tar.gz
        tar xzf libtool-2.4.tar.gz
        cd libtool-2.4
        ./configure
        make -j $NPROC && make install
    fi
}

function build_dep {
    case $1 in
        'expat')
            if [ ! -f /usr/local/lib/libexpat.so ]; then
                cd /tmp/src
                curl -f -L -O https://github.com/libexpat/libexpat/releases/download/R_2_2_5/expat-2.2.5.tar.bz2
                tar xjf expat-2.2.5.tar.bz2
                cd expat-2.2.5
                ./configure --prefix=/usr/local
                make -j $NPROC
                make install
            fi
            ;;
        'geos')
            if [ ! -f /usr/local/lib/libgeos-3.6.1.so ]; then
                cd /tmp/src
                curl -f -L -O http://download.osgeo.org/geos/geos-3.6.1.tar.bz2
                tar jxf geos-3.6.1.tar.bz2
                cd geos-3.6.1
                ./configure
                make -j $NPROC
                make install
            fi
            ;;
        'proj')
            if [ ! -f /usr/local/lib/libproj.so.12.0.0 ]; then
                cd /tmp/src
                curl -f -L -O http://download.osgeo.org/proj/proj-4.9.3.tar.gz
                tar xzf proj-4.9.3.tar.gz
                cd proj-4.9.3
                ./configure
                make -j $NPROC
                make install
                cd /tmp/src
                curl -f -L -O https://download.osgeo.org/proj/proj-datumgrid-1.8.zip
                unzip -d /usr/local/share/proj proj-datumgrid-1.8.zip
            fi
            ;;
        'jasper')
            if [ ! -f /usr/local/lib/libjasper.so.1.0.0 ]; then
                cd /tmp/src
                curl -f -L -O http://download.osgeo.org/gdal/jasper-1.900.1.uuid.tar.gz
                tar xzf jasper-1.900.1.uuid.tar.gz
                cd jasper-1.900.1.uuid
                ./configure --disable-debug --enable-shared
                make -j $NPROC
                make install
            fi
            ;;
    esac
}

function get {
    REQ=$(echo $1 | cut -d "=" -f 1)
    REQ_VER=$(echo $1 | cut -d "=" -f 3)

    for PYVER in $PY; do
        for PYBIN in /opt/python/cp${PYVER}*/bin; do
            # Download python dependencies
            if cache=$(ls /io/wheelhouse/${REQ}-${REQ_VER}*${PYVER}*.whl); then
                ${PYBIN}/pip install -U $cache
            else
                ${PYBIN}/pip install -U $1
            fi
        done
    done
}

function build {
    for PYVER in $PY; do
        for PYBIN in /opt/python/cp${PYVER}*/bin; do
            # Download python dependencies
            ${PYBIN}/pip wheel --no-deps --no-binary :all: -w /tmp/wheelhouse $1
        done
    done
}

function post {
    # Bundle external shared libraries into the wheels
    for whl in /tmp/wheelhouse/*.whl; do
        auditwheel repair $whl -w /io/wheelhouse/
        rm $whl
    done

    chown -R $HUID.$HGID /io/wheelhouse
}
