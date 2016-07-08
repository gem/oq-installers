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
curl -LO https://pypi.python.org/packages/22/82/64dada5382a60471f85f16eb7d01cc1a9620aea855cd665609adf6fdbb0d/h5py-2.6.0.tar.gz
curl -LO https://pypi.python.org/packages/ad/f9/4640d50324635fbdc7b109f8ef37de5f04456b89ed175cf2f71ae05efd8f/Shapely-1.5.13.tar.gz

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

tar xzf h5py-2.6.0.tar.gz
tar xzf Shapely-1.5.13.tar.gz

# Compile wheels
# Exclude cp26 and cp33 because binary wheels are not available
# for numpy and we do not support those versions
for PYBIN in /opt/python/cp{27,34,35}*/bin; do
    # Download python dependencies
    ${PYBIN}/pip install numpy==1.11.1 Cython==0.23.4
    # Build wheels
    cd h5py-2.6.0; ${PYBIN}/python setup.py bdist_wheel -d wheelhouse/; cd ..
    cd Shapely-1.5.13; ${PYBIN}/python setup.py bdist_wheel -d wheelhouse/; cd ..
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    auditwheel repair $whl -w /io/wheelhouse/
done

exit 0
