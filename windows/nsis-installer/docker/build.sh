#!/bin/bash

set -x
set -e

PY="2.7.13"
PY_MSI="python-$PY.amd64.msi"

cd /io/src

if [ ! -d py -o ! -d py27 ]; then
    echo "Please download python dependencies first."
    exit 1
fi

# Cleanup
rm -Rf ../python-dist/python2.7/*
rm -Rf ../python-dist/Lib/*

## This is an alternative method that we cannot use because we need extra data
## not packaged in the python packages
# pip wheel --no-deps https://github.com/gem/oq-hazardlib/archive/master.zip
# pip wheel --no-deps https://github.com/gem/oq-engine/archive/master.zip

for i in oq-engine oq-hazardlib; do
    if [ ! -d $i ]; then
        git clone --depth=1 https://github.com/gem/${i}.git
    fi
done

ls $HOME
if [ ! -f $PY_MSI ]; then
    PY_MSI=$HOME/$PY_MSI
    echo "Using python from $PY_MSI"
fi
wine msiexec /a $PY_MSI /qb TARGETDIR=../python-dist/python2.7

## This would be the best option, since it checks also missing dependencies
## but in Docker is broken because of https://github.com/suchja/wine/issues/7
# wine $HOME/.wine/drive_c/Python27/Scripts/pip.exe install --disable-pip-version-check --force-reinstall --ignore-installed --upgrade --no-deps --no-index --prefix python-dist src/py/*.whl src/py27/*.whl src/openquake.*.whl
## So we unzip the wheels instead
find -name *.whl -exec unzip -o -x {} -d ../python-dist/Lib \;

cd ..

cp -r src/oq-engine/demos .
python -m markdown src/oq-engine/README.md > README.html
wine $HOME/.wine/drive_c/Program\ Files\ \(x86\)/NSIS/makensis /V4 installer.nsi
