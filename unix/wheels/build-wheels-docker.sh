#!/bin/bash
# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (C) 2010-2016 GEM Foundation
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

yum -y install autoconf curl gzip libtool tar unzip

if [ $GEM_SET_NPROC ]; then
    NPROC=$GEM_SET_NPROC
else
    #Everyone has at least two cores
    NPROC=2
fi
OQ_PREFIX=/build

rm -Rf $OQ_PREFIX
mkdir -p $OQ_PREFIX/src

cd $OQ_PREFIX/src

# Get sources
curl -Lo libgeos-3.5.0.tar.gz https://github.com/libgeos/libgeos/archive/3.5.0.tar.gz
curl -LO http://www.hdfgroup.org/ftp/HDF5/current/src/hdf5-1.8.17.tar.gz
curl -Lo py-h5py-2.6.0.tar.gz https://pypi.python.org/packages/source/h/h5py/h5py-2.6.0.tar.gz
curl -Lo py-shapely-1.5.13.tar.gz https://pypi.python.org/packages/source/S/Shapely/Shapely-1.5.13.tar.gz
curl -Lo py-psutil-3.4.2.tar.gz https://pypi.python.org/packages/source/p/psutil/psutil-3.4.2.tar.gz

export LD_LIBRARY_PATH=${OQ_PREFIX}/lib
export CPATH=${OQ_PREFIX}/include
export PATH=${OQ_PREFIX}/bin:${PATH}
export HDF5_DIR=$OQ_PREFIX

tar xzf hdf5-1.8.17.tar.gz
cd hdf5-1.8.17
./configure --prefix=$OQ_PREFIX
make -j $NPROC
make install
cd ..

tar xzf libgeos-3.5.0.tar.gz
cd libgeos-3.5.0
# Workaround for an autogen.sh bug
./autogen.sh || true
./autogen.sh
./configure --prefix=$OQ_PREFIX
make -j $NPROC
make install
cd ..

mkdir py && cd py
for i in ../py*.tar.gz; do
    tar xzf $i
done

# Compile wheels
# Exclude cp26, cp33 and cp34 because binary wheels are not
# available for numpy and/or we do not support those versions
for PYBIN in /opt/python/cp{27,35}*/bin; do
    # Download python dependencies
    ${PYBIN}/pip install numpy==1.11.1 Cython==0.23.4
    # Build wheels
    for py in *; do
        cd $py
        rm -Rf build dist
        ${PYBIN}/python setup.py bdist_wheel -d $OQ_PREFIX/wheelhouse/
        cd ..
    done
done

# Bundle external shared libraries into the wheels
for whl in $OQ_PREFIX/wheelhouse/*.whl; do
    auditwheel repair $whl -w /io/wheelhouse/
done

exit 0
