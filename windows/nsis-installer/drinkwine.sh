#!/bin/bash

export WINEDEBUG=-all,+fixme-ntdll
export WINEARCH="win32"

if ! wine --version | grep -q wine-1.9; then
    echo "Error: $0 requires Wine 1.9"
    exit 1
fi

if [ -z $WINEPREFIX ]; then
    echo "Error: please setup a custom WINEPREFIX first:"
    echo "$ export WINEPREFIX=\"$HOME/oqtest\""
    exit 1
else
    echo "Using WINEPREFIX=$WINEPREFIX"
fi

export PATH="$(pwd)/python2.7:$PATH"
export PYTHONPATH="$(pwd)/lib"

oq_root=$(pwd)
nosetests="python.exe -m nose"

cd lib/openquake
for d in */; do
    echo "Running $d tests"
    cd $d
    $nosetests -v -a '!slow'
    cd ..
done
