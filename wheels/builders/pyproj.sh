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

yum install -y autoconf curl gzip libtool tar

cd /tmp/src

curl -Lo proj-4.8.0.tar.gz https://github.com/OSGeo/proj.4/archive/4.8.0.tar.gz
tar xvf proj-4.8.0.tar.gz
cd proj.4-4.8.0
# Workaround for an autogen.sh bug
./autogen.sh || true
./autogen.sh
./configure --prefix=/usr/local
make -j $NPROC
make install

cd /tmp/wheelhouse

build pyproj==1.9.5.1

post
