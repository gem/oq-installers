#!/bin/bash
# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (C) 2010-2017 GEM Foundation
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

check_dep() {
    for i in $*; do
        command -v $i &> /dev/null || {
            echo -e "!! Please install $i first. Aborting." >&2
            exit 1
        }
    done
}

not_supported() {
    echo "!! This operating system is not unsupported. Aborting." >&2
    exit 1
}

OQ_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OQ_ROOT=$OQ_DIR/build
OQ_WHEEL=$OQ_ROOT/dist/wheelhouse
CLEANUP=true

if [ $GEM_SET_NPROC ]; then
    NPROC=$GEM_SET_NPROC
else
    #Everyone has at least two cores
    NPROC=2
fi
if [ $GEM_SET_BRANCH ]; then
    OQ_BRANCH=$GEM_SET_BRANCH
else
    OQ_BRANCH=master
fi

rm -Rf $OQ_ROOT

mkdir -p $OQ_WHEEL
cd $OQ_ROOT

if $(echo $OSTYPE | grep -q linux); then
    BUILD_OS='linux64'
    if [ -f /etc/redhat-release ]; then
        sudo yum -y upgrade
        sudo yum -y install epel-release
        sudo yum -y install curl gcc git makeself zip
        # CentOS (with SCL)
        sudo yum -y install centos-release-scl
        sudo yum -y install rh-python35
        export PATH=/opt/rh/rh-python35/root/usr/bin:$PATH
        export LD_LIBRARY_PATH=/opt/rh/rh-python35/root/usr/lib64
    else
        not_supported
    fi
elif $(echo $OSTYPE | grep -q darwin); then
    BUILD_OS='macos'
    check_dep xcode-select makeself
    sudo xcode-select --install || true
else
    not_supported
fi

/usr/bin/env python3.5 -m venv pybuild
source pybuild/bin/activate

for g in hazardlib engine;
do 
    rm -Rf oq-${g}
    git clone --depth=1 -b $OQ_BRANCH https://github.com/gem/oq-${g}.git
done

/usr/bin/env pip install -U pip
/usr/bin/env pip install -U wheel
# Include an updated version of pip
/usr/bin/env pip wheel --wheel-dir=$OQ_WHEEL pip
/usr/bin/env pip wheel --wheel-dir=$OQ_WHEEL -r oq-engine/requirements-py35-${BUILD_OS}.txt
/usr/bin/env pip install $OQ_WHEEL/*
 
for g in hazardlib engine;
do
    cd oq-${g}
    /usr/bin/env pip wheel --no-deps . -w $OQ_WHEEL
    declare OQ_$(echo $g | tr '[:lower:]' '[:upper:]')_DEV=$(git rev-parse --short HEAD)
    cd ..
done
cp -R ${OQ_ROOT}/oq-engine/{README.md,LICENSE,demos,doc} ${OQ_ROOT}/dist
rm -Rf $OQ_ROOT/dist/doc/sphinx

# Make a zipped copy of each demo
for d in hazard risk; do
    cd ${OQ_ROOT}/dist/demos/${d}
    for z in *; do
        zip -r ${z}.zip $z
    done
    cd -
done

## utils is not copied for now, since it does not contain anything useful here
cp $OQ_DIR/install.sh ${OQ_ROOT}/dist

makeself ${OQ_ROOT}/dist ../openquake-py35-${BUILD_OS}-${OQ_ENGINE_DEV}.run "installer for the OpenQuake Engine" ./install.sh

exit 0
