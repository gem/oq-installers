#!/bin/bash

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


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
cd $DIR && pwd

if [ ! -d py -o ! -d py27 ]; then
    echo "Please download python dependencies first."
    exit 1
fi

# Cleanup
rm -Rf python-dist/python2.7/*
rm -Rf python-dist/Lib/*
rm -Rf demos/*

## This is an alternative method that we cannot use because we need extra data
## not packaged in the python packages
# pip wheel --no-deps https://github.com/gem/oq-engine/archive/master.zip

cd src
for app in oq-engine oq-platform-standalone oq-platform-ipt oq-platform-taxtweb oq-platform-taxonomy; do
    if [ ! -d $app ]; then
        git clone -q -b $OQ_BRANCH --depth=1 https://github.com/gem/${app}.git
    fi
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
