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

if [ -z $GEM_FORCE_H5PY ]; then
    echo "Will not build h5py because is provided by upstream"
    exit 0
fi

MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z $OQ_ENV_SET ]; then source $MYDIR/../build-common.sh; fi

yum install -y curl gzip tar

cd /tmp/src

curl -LO https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8.17/src/hdf5-1.8.17.tar.gz
tar xzf hdf5-1.8.17.tar.gz
cd hdf5-1.8.17
./configure --prefix=/usr/local
make -j $NPROC
make install
cd ..

cd /tmp/wheelhouse

get numpy==1.11.1
build h5py==2.6.0

post
