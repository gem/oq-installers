#!/bin/bash

set -x
set -e

# Default software distribution
PY="3.5.3"
PY_ZIP="python-${PY}-embed-amd64.zip"
PIP="get-pip.py"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/../src && pwd

if [ ! -d py -o ! -d py35 ]; then
    echo "Please download python dependencies first."
    exit 1
fi

# Cleanup
rm -Rf python3.5
rm -Rf Lib
rm -Rf Scripts
rm -Rf ../demos

## This is an alternative method that we cannot use because we need extra data
## not packaged in the python packages
# pip wheel --no-deps https://github.com/gem/oq-hazardlib/archive/master.zip
# pip wheel --no-deps https://github.com/gem/oq-engine/archive/master.zip


# Extract Python, to be included in the installation
if [ ! -f ${HOME}/${PY_ZIP} ]; then
    wget -q https://www.python.org/ftp/python/${PY}/${PY_ZIP}
else
    PY_ZIP=${HOME}/${PY_ZIP}
fi
unzip -q $PY_ZIP -d python3.5
# Workaround for https://bugs.python.org/issue24960
unzip -q python3.5/python35.zip -d python3.5/Lib && rm python3.5/python35.zip

if [ ! -f ${HOME}/${PIP} ]; then
    wget -q https://bootstrap.pypa.io/${PIP}
else
    PIP=${HOME}/${PIP}
fi
wine python3.5/python.exe $PIP

for i in oq-engine oq-hazardlib; do
    if [ ! -d $i ]; then
        git clone --depth=1 https://github.com/gem/${i}.git
    fi
    wine python3.5/Scripts/pip3.exe wheel --disable-pip-version-check --no-deps ./$i
done

# Extract wheels to be included in the installation
wine python3.5/Scripts/pip3.exe install --disable-pip-version-check --force-reinstall --ignore-installed --upgrade --no-deps --no-index py/*.whl py35/*.whl openquake.*.whl

cd ..

# Get the demo and the README
cp -r src/oq-engine/demos .
for d in hazard risk; do
    cd demos/${d}
    for z in *; do
        zip -q -r ${z}.zip $z
    done
    cd -
done

python -m markdown src/oq-engine/README.md > README.html

# Get a copy of the OQ manual if not yet available
if [ ! -f OpenQuake\ manual.pdf ]; then
    wget -O- https://ci.openquake.org/job/builders/job/pdf-builder/lastSuccessfulBuild/artifact/oq-engine/doc/manual/oq-manual.pdf > OpenQuake\ manual.pdf
fi

wine ${HOME}/.wine/drive_c/Program\ Files\ \(x86\)/NSIS/makensis /V4 installer.nsi
