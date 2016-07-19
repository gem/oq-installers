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
    if [ $GEM_SET_VENDOR ]; then
        VENDOR=$GEM_SET_VENDOR
    else
        VENDOR='ubuntu'
    fi
    if [ "$VENDOR" == "ubuntu" ]; then
        sudo apt-get update
        sudo apt-get upgrade -y
        sudo apt-get install -y curl gcc git makeself python python-dev
    elif [ "$VENDOR" == "redhat" ]; then
        sudo yum -y upgrade
        sudo yum -y groupinstall 'Development Tools'
        sudo yum -y install curl gcc git makeself python python-devel
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

for g in hazardlib engine;
do 
    rm -Rf oq-${g}
    git clone --depth=1 -b $OQ_BRANCH https://github.com/gem/oq-${g}.git
done

curl -LOz get-pip.py https://bootstrap.pypa.io/get-pip.py
python get-pip.py

curl -Lo virtualenv-15.0.2.tar.gz https://github.com/pypa/virtualenv/archive/15.0.2.tar.gz
cd $OQ_ROOT/dist
tar xzf ../virtualenv-15.0.2.tar.gz
mv virtualenv-15.0.2 virtualenv
cd ..

pip wheel --wheel-dir=$OQ_WHEEL -r oq-engine/requirements-py27-linux64.txt
pip install $OQ_WHEEL/*
 
for g in hazardlib engine;
do
    cd oq-${g}
    python setup.py bdist_wheel -d $OQ_WHEEL
    declare OQ_$(echo $g | tr '[:lower:]' '[:upper:]')_DEV=$(git rev-parse --short HEAD)
    cd ..
done
cp -R oq-engine/{README.md,LICENSE,openquake.cfg,demos,doc} $OQ_ROOT/dist
rm -Rf $OQ_ROOT/dist/doc/sphinx
## utils is not copied for now, since it does not contain anything useful here
cp install.sh ${OQ_ROOT}/dist

makeself ${OQ_ROOT}/${dist} ../openquake-py27-${BUILD_OS}-${OQ_ENGINE_DEV}.run "installer for the OpenQuake Engine" ./install.sh

exit 0
