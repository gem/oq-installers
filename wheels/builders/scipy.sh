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

if [ -z $OQ_ENV_SET ]; then source $MYDIR/../build-common.sh; fi

cd /tmp/src

yum install -y libgfortran.x86_64

if [ ! -f /usr/local/lib/libopenblasp-r0.2.18.so ]; then
    curl -Lo OpenBLAS-0.2.18.tar.gz https://github.com/xianyi/OpenBLAS/archive/v0.2.18.tar.gz
    tar xvf OpenBLAS-0.2.18.tar.gz
    cd OpenBLAS-0.2.18
    make DYNAMIC_ARCH=1 USE_OPENMP=0 NUM_THREADS=64
    make PREFIX=/usr/local install
fi

cd /tmp/wheelhouse

get numpy==1.11.1
build scipy==0.17.1

post
