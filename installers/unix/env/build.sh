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
OQ_ROOT=${OQ_DIR}/build
OQ_WHEEL=${OQ_ROOT}/dist/wheelhouse
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

if [ $GEM_SET_BRANCH_TOOLS ]; then
    TOOLS_BRANCH=$GEM_SET_BRANCH_TOOLS
else
    TOOLS_BRANCH=$OQ_BRANCH
fi

rm -Rf $OQ_ROOT

mkdir -p $OQ_WHEEL
cd $OQ_ROOT

if $(echo $OSTYPE | grep -q linux); then
    BUILD_OS='linux64'
    if [ -f /etc/redhat-release ]; then
        sudo yum -y -q upgrade
        sudo yum -y -q install epel-release
        sudo yum -y -q install curl gcc git makeself zip
        # CentOS (with SCL)
        sudo yum -y -q install centos-release-scl
        sudo yum -y -q install python27
        export PATH=/opt/rh/python27/root/usr/bin:$PATH
        export LD_LIBRARY_PATH=/opt/rh/python27/root/usr/lib64
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

curl -Lo virtualenv-15.0.2.tar.gz https://github.com/pypa/virtualenv/archive/15.0.2.tar.gz
cd ${OQ_ROOT}/dist
tar xzf ../virtualenv-15.0.2.tar.gz
mv virtualenv-15.0.2 virtualenv
cd ..

/usr/bin/env python dist/virtualenv/virtualenv.py pybuild
source pybuild/bin/activate

rm -Rf oq-engine
git clone -q --depth=1 -b $OQ_BRANCH https://github.com/gem/oq-engine.git

rm -Rf oq-platform*
git clone -q --depth=1 -b $OQ_BRANCH https://github.com/gem/oq-platform-standalone.git
git clone -q --depth=1 -b $OQ_BRANCH https://github.com/gem/oq-platform-ipt.git
git clone -q --depth=1 -b $OQ_BRANCH https://github.com/gem/oq-platform-taxtweb.git
git clone -q --depth=1 -b $OQ_BRANCH https://github.com/gem/oq-platform-taxonomy.git

/usr/bin/env pip -q install -U pip
/usr/bin/env pip -q install -U wheel
# Include an updated version of pip
/usr/bin/env pip -q wheel pip -w $OQ_WHEEL
/usr/bin/env pip -q wheel -r oq-engine/requirements-py27-${BUILD_OS}.txt -w $OQ_WHEEL
/usr/bin/env pip -q install ${OQ_WHEEL}/*
 
cd oq-engine
/usr/bin/env pip -q wheel --no-deps . -w $OQ_WHEEL
declare OQ_$(echo 'engine' | tr '[:lower:]' '[:upper:]')_DEV=$(git rev-parse --short HEAD)
cd ..

mkdir ${OQ_WHEEL}/tools
for app in oq-platform-*; do
    /usr/bin/env pip -q wheel --no-deps ${app}/ -w ${OQ_WHEEL}/tools
done

cp -R ${OQ_ROOT}/oq-engine/{README.md,LICENSE,demos,doc} ${OQ_ROOT}/dist
rm -Rf ${OQ_ROOT}/dist/doc/sphinx

# Make a zipped copy of each demo
${OQ_ROOT}/oq-engine/helpers/zipdemos.sh ${OQ_ROOT}/dist/demos

## utils is not copied for now, since it does not contain anything useful here
cp ${OQ_DIR}/install.sh ${OQ_ROOT}/dist

makeself -q ${OQ_ROOT}/dist ../openquake-py27-${BUILD_OS}-${OQ_ENGINE_DEV}.run "installer for the OpenQuake Engine" ./install.sh

exit 0
