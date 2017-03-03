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

mkdir -p /tmp/src
mkdir -p /tmp/wheelhouse

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

export OQ_ENV_SET=true
export HDF5_DIR=/usr/local

function get {
    for PYVER in $PY; do
        for PYBIN in /opt/python/cp${PYVER}*/bin; do
            # Download python dependencies
            if cache=$(ls /io/wheelhouse/$1*${PYVER}*.whl); then
                ${PYBIN}/pip install $cache
            else
                ${PYBIN}/pip install $1
            fi
        done
    done
}

function build {
    for PYVER in $PY; do
        for PYBIN in /opt/python/cp${PYVER}*/bin; do
            # Download python dependencies
            ${PYBIN}/pip wheel --no-binary :all: -w /tmp/wheelhouse $1
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
