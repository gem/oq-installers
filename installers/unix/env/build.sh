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
OQ_ROOT=/tmp/build-openquake-dist
OQ_DIST=${OQ_ROOT}/dist
OQ_WHEEL=${OQ_DIST}/wheelhouse
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

if [[ $GEM_SET_RELEASE =~ ^[0-9]+$ ]]; then
    PKG_REL=$GEM_SET_RELEASE
fi

if $(echo $OSTYPE | grep -q linux); then
    BUILD_OS='linux64'
    if [ -f /etc/redhat-release ]; then
        check_dep sudo
        sudo yum -y -q upgrade
        sudo yum -y -q install epel-release
        sudo yum -y -q install curl gcc git makeself zip
        # CentOS (with SCL)
        sudo yum -y -q install centos-release-scl
        sudo yum -y -q install rh-python36
        source /opt/rh/rh-python36/enable
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

rm -Rf $OQ_ROOT
mkdir -p $OQ_DIST/{wheelhouse,src}
cd $OQ_ROOT

/usr/bin/env python3.6 -m venv pybuild
source pybuild/bin/activate

rm -Rf oq-engine
echo "Cloning OpenQuake Engine"
git clone -q --depth=1 -b $OQ_BRANCH https://github.com/gem/oq-engine.git

rm -Rf oq-platform*
echo "Cloning OpenQuake Tools"
git clone -q --depth=1 -b $TOOLS_BRANCH https://github.com/gem/oq-platform-standalone.git
git clone -q --depth=1 -b $TOOLS_BRANCH https://github.com/gem/oq-platform-ipt.git
git clone -q --depth=1 -b $TOOLS_BRANCH https://github.com/gem/oq-platform-taxtweb.git
git clone -q --depth=1 -b $TOOLS_BRANCH https://github.com/gem/oq-platform-taxonomy.git

# Should be pip install -U pip, but pip is currently broken on macOS
# when starting from version 9.0.1. We cannot rely on pip here.
curl https://bootstrap.pypa.io/get-pip.py | /usr/bin/env python3
/usr/bin/env pip3 -q install -U wheel
# Include an updated version of pip
/usr/bin/env pip3 -q wheel pip -w $OQ_WHEEL
REQMIRROR=$(mktemp)
sed 's/cdn\.ftp\.openquake\.org/ftp.openquake.org/g' oq-engine/requirements-py35-${BUILD_OS}.txt > $REQMIRROR
/usr/bin/env pip3 -q wheel -r $REQMIRROR -w $OQ_WHEEL
 
cd oq-engine
/usr/bin/env pip3 -q wheel --no-deps . -w $OQ_WHEEL

if [ $PKG_REL ]; then
    OQ_VERSION="$(cat openquake/baselib/__init__.py | sed -n "s/^__version__[  ]*=[    ]*['\"]\([^'\"]\+\)['\"].*/\1/gp")-${PKG_REL}"
else
    OQ_VERSION=$(git rev-parse --short HEAD)
fi
cd ..

mkdir ${OQ_WHEEL}/tools
for app in oq-platform-*; do
    /usr/bin/env pip3 -q wheel --no-deps ${app}/ -w ${OQ_WHEEL}/tools
done

cp -R ${OQ_ROOT}/oq-engine/{README.md,LICENSE,demos,doc} ${OQ_DIST}/src
rm -Rf ${OQ_DIST}/src/doc/sphinx

# Make a zipped copy of each demo
${OQ_ROOT}/oq-engine/helpers/zipdemos.sh ${OQ_DIST}/src/demos

## utils is not copied for now, since it does not contain anything useful here
cp ${OQ_DIR}/install.sh ${OQ_DIST}

echo "Creating installation package"
makeself -q ${OQ_DIST} ${OQ_DIR}/openquake-setup-${BUILD_OS}-${OQ_VERSION}.run "installer for the OpenQuake Engine" ./install.sh

exit 0
