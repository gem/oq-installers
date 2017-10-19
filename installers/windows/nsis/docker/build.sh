#!/bin/bash
# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (C) 2017 GEM Foundation
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

# Default software distribution
PY="2.7.13"
PY_MSI="python-$PY.amd64.msi"


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd $DIR && pwd

# pre-cleanup
rm -Rf src/oq-*
rm -Rf python-dist/python2.7/*
rm -Rf python-dist/Lib/*
rm -Rf demos/*

cd src
if [ ! -d py -o ! -d py27 ]; then
    echo "Please download python dependencies first."
    exit 1
fi

## This is an alternative method that we cannot use because we need extra data
## not packaged in the python packages
# pip wheel --no-deps https://github.com/gem/oq-engine/archive/master.zip

## Core apps
echo "Downloading core apps"
for app in oq-engine; do
    git clone -q -b $OQ_BRANCH --depth=1 https://github.com/gem/${app}.git
    wine pip -q wheel --disable-pip-version-check --no-deps ./${app}
done

## Standalone apps
echo "Downloading standalone apps"
for app in oq-platform-standalone oq-platform-ipt oq-platform-taxtweb oq-platform-taxonomy; do
    git clone -q -b $TOOLS_BRANCH --depth=1 https://github.com/gem/${app}.git
    wine pip -q wheel --disable-pip-version-check --no-deps ./${app}
done

# Extract Python, to be included in the installation
if [ ! -f $PY_MSI ]; then
    PY_MSI=$HOME/$PY_MSI
    echo "Extracting python from $PY_MSI"
fi
wine msiexec /a $PY_MSI /qb TARGETDIR=../python-dist/python2.7

# Extract wheels to be included in the installation
echo "Extracting python wheels"
wine pip -q install --disable-pip-version-check --force-reinstall --ignore-installed --upgrade --no-deps --no-index --prefix ../python-dist py/*.whl py27/*.whl openquake.*.whl oq_platform*.whl

cd $DIR

ini_vers="$(cat src/oq-engine/openquake/baselib/__init__.py | sed -n "s/^__version__[  ]*=[    ]*['\"]\([^'\"]\+\)['\"].*/\1/gp")"
git_time="$(git -C src/oq-engine log --format=%ct -1)"

sed -i "s/\${MYVERSION}/$ini_vers/g" installer.nsi
if [ $PKG_REL ]; then
    sed -i "s/\${MYTIMESTAMP}/$PKG_REL/g" installer.nsi
else
    sed -i "s/\${MYTIMESTAMP}/$git_time/g" installer.nsi
fi

# Get the demo and the README
cp -r src/oq-engine/demos .
src/oq-engine/helpers/zipdemos.sh $(pwd)/demos

python -m markdown src/oq-engine/README.md > README.html

# Get a copy of the OQ manual if not yet available
if [ ! -f OpenQuake\ manual.pdf ]; then
    wget -O- https://ci.openquake.org/job/builders/job/pdf-builder/lastSuccessfulBuild/artifact/oq-engine/doc/manual/oq-manual.pdf > OpenQuake\ manual.pdf
fi

echo "Generating NSIS installer"
wine ${HOME}/.wine/drive_c/Program\ Files\ \(x86\)/NSIS/makensis /V4 installer.nsi
