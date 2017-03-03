#!/bin/bash
# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (C) 2016-2017 GEM Foundation
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

OQ_PREFIX=/build
mkdir -p $OQ_PREFIX/src
mkdir -p $OQ_PREFIX/wheelhouse

if [ $GEM_SET_PY ]; then
    PY="$GEM_SET_PY"
else
    PY="36"
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
export OQ_PREFIX

export LD_LIBRARY_PATH=${OQ_PREFIX}/lib
export CPATH=${OQ_PREFIX}/include
export PATH=${OQ_PREFIX}/bin:${PATH}
export HDF5_DIR=$OQ_PREFIX

function get {
    for PYVER in $PY; do
        for PYBIN in /opt/python/cp${PYVER}*/bin; do
            # Download python dependencies
            ${PYBIN}/pip install $1 
        done
    done
}

function build {

    for PYVER in $PY; do
        for PYBIN in /opt/python/cp${PYVER}*/bin; do
            # Download python dependencies
            ${PYBIN}/pip wheel --no-binary :all: -w $OQ_PREFIX/wheelhouse $1
        done
    done
}

function post {
    # Bundle external shared libraries into the wheels
    for whl in $OQ_PREFIX/wheelhouse/*.whl; do
        auditwheel repair $whl -w /io/wheelhouse/
        rm $whl
    done

    chown -R $HUID.$HGID /io/wheelhouse
}

get Cython

