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

# Default software distribution
PY="2.7.13"
PY_MSI="python-$PY.amd64.msi"

TMPDIR=$(mktemp -d)
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

## Core apps
## oq-engine isn't included in the zip and must be downloaded manually
# for app in oq-engine; do
#     git clone -q -b $OQ_BRANCH --depth=1 https://github.com/gem/${app}.git
#     git -C $app archive --prefix=$app/ HEAD | tar -C $TMPDIR -xf -
# done

# Extract Python, to be included in the installation
if [ ! -f $PY_MSI ]; then
    PY_MSI=$HOME/$PY_MSI
    echo "Extracting python from $PY_MSI"
fi
wine msiexec /a $PY_MSI /qb TARGETDIR=../python-dist/python2.7

# Extract wheels to be included in the installation
echo "Extracting python wheels"
wine pip -q install --disable-pip-version-check --force-reinstall --ignore-installed --upgrade --no-deps --no-index --prefix ../python-dist py/*.whl py27/*.whl
# Development tools
if [ -d py27-dev ]; then
   wine pip -q install --disable-pip-version-check --force-reinstall --ignore-installed --upgrade --no-deps --no-index --prefix ../python-dist py27-dev/*.whl
fi

ZIP="OpenQuake_Engine_win64_dev$(date '+%y%m%d%H%M').zip"

echo "Generating zip archive"
cd $TMPDIR
cat > README_FIRST.txt <<EOF
## You must clone the oq-engine repo inside this folder first: ##

git clone https://github.com/gem/oq-engine.git
EOF
zip -qr $DIR/${ZIP} README_FIRST.txt
cd $DIR
zip -qr $DIR/${ZIP} oq-console-dev.bat
## Disabled
# zip -qr $DIR/$ZIP oq-engine
cd $DIR/python-dist
zip -qr $DIR/$ZIP Lib python2.7
