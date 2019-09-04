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
# 
# Part of the included code has been derived from:
# https://github.com/youngpm/gdalmanylinux
# gdal/gdalinit.py and gdal/setup.py are 
# Copyright (c) 2016 Patrick M Young under MIT License

if [ $GEM_SET_DEBUG ]; then
    set -x
fi
set -e

MYDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z $OQ_ENV_SET ]; then source $MYDIR/../build-common.sh; fi

yum install -qy json-c-devel zlib-devel libtiff-devel openssl-devel

build_dep expat
build_dep geos
build_dep jasper
build_dep proj

cd /tmp/src
curl -f -L -O http://download.osgeo.org/gdal/2.4.1/gdal-2.4.1.tar.gz
tar xzf gdal-2.4.1.tar.gz
cd gdal-2.4.1
./configure \
 --with-threads \
 --disable-debug \
 --disable-static \
 --without-grass \
 --without-libgrass \
 --without-jpeg12 \
 --with-jasper=/usr/local \
 --with-libtiff \
 --with-jpeg \
 --with-gif \
 --with-png \
 --with-geotiff=internal \
 --with-sqlite3=/usr \
 --with-pcraster=internal \
 --with-pcidsk=internal \
 --with-bsb \
 --with-grib \
 --with-pam \
 --with-geos=/usr/local/bin/geos-config \
 --with-static-proj4=/usr/local \
 --with-expat=/usr/local \
 --with-libjson-c \
 --with-libiconv-prefix=/usr \
 --with-libz=/usr \
 --with-curl=curl-config \
 --without-python
make -j $NPROC
make install

# Replace SWIG's setup.py with this modified one, which gets numpy in
# there as a dependency.
cp $MYDIR/gdal/setup.py /tmp/src/gdal-2.4.1/swig/python/setup.py
# Replace the osgeo module __init__.py with this modified one, which
# sets the GDAL_DATA and PROJ_LIB variables on import to where they've
# been copied to.
cp $MYDIR/gdal/gdalinit.py /tmp/src/gdal-2.4.1/swig/python/osgeo/__init__.py

cd  /tmp/src/gdal-2.4.1/swig/python

# numpy is disabled to avoid recompiling GDAL every time numpy is updated
# get numpy==1.16.5
build .

post
