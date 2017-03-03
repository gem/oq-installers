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

MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z $OQ_PREFIX ]; then source $MYDIR/../build-common.sh; fi

yum install -y autoconf curl gzip libtool tar

cd $OQ_PREFIX/src

curl -Lo libgeos-3.5.0.tar.gz https://github.com/libgeos/libgeos/archive/3.5.0.tar.gz
tar xvf libgeos-3.5.0.tar.gz
cd libgeos-3.5.0
# Workaround for an autogen.sh bug
./autogen.sh || true
./autogen.sh
./configure --prefix=$OQ_PREFIX
make -j $NPROC
make install

cd $OQ_PREFIX/wheelhouse

build Shapely==1.5.13

post
