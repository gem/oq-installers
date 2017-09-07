#!/bin/bash

if [ $GEM_SET_DEBUG ]; then
    set -x
fi
set -e

# Default software distribution
PY="2.7.13"
PY_MSI="python-$PY.amd64.msi"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/../src && pwd

if [ ! -d py -o ! -d py27 ]; then
    echo "Please download python dependencies first."
    exit 1
fi

# Cleanup
rm -Rf ../python-dist/python2.7/*
rm -Rf ../python-dist/Lib/*
rm -Rf ../demos/*

## This is an alternative method that we cannot use because we need extra data
## not packaged in the python packages
# pip wheel --no-deps https://github.com/gem/oq-engine/archive/master.zip

for app in oq-engine; do
    if [ ! -d $app ]; then
        git clone -q -b $OQ_BRANCH --depth=1 https://github.com/gem/${app}.git
    fi
done

# Extract Python, to be included in the installation
if [ ! -f $PY_MSI ]; then
    PY_MSI=$HOME/$PY_MSI
    echo "Extracting python from $PY_MSI"
fi
wine msiexec /a $PY_MSI /qb TARGETDIR=../python-dist/python2.7

# Extract wheels to be included in the installation
echo "Extracting python wheels"
wine pip -q install --disable-pip-version-check --force-reinstall --ignore-installed --upgrade --no-deps --no-index --prefix ../python-dist py/*.whl py27/*.whl

ZIP="OpenQuake_Engine_win64_dev$(date '+%y%m%d%H%M').zip"
OQPYPATH='s/PYTHONPATH=%mypath%\\lib\\site-packages/PYTHONPATH=%mypath%\\oq-engine;%mypath%\\lib\\site-packages/g'

echo "Generating zip archive"
for b in oq-console.bat oq-server.bat; do
    sed "$OQPYPATH" ../${b} > $b
    zip -qr ../${ZIP} $b
    rm $b
done
zip -qr ../${ZIP} oq-engine
cd ../python-dist
zip -qr ../${ZIP} Lib python2.7
