#!/bin/bash
# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (C) 2010-2019 GEM Foundation
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

PYTHON=python3.6

help() {
    cat <<HSD
The command line arguments are as follows:

    -d, --dest           Path to the destination folder
    -y, --yes            Force 'yes' answers
    -n, --no             Force 'no' answers
    -h, --help           This help
HSD
    exit 0
}

check_dep() {
    for i in $*; do
        command -v $i &> /dev/null || {
            echo -e "!! Please install $i first. Aborting." >&2
            exit 1
        }
    done
}

realpath() {
    DIR=$(eval echo "$1")
    if [ -d $DIR ]; then
        echo -e "!! An installation already exists in $DIR. Please remove it first." >&2
        exit 1
    else
        mkdir $DIR &>/dev/null && cd $DIR &>/dev/null && pwd || {
            echo -e "!! Please specify a valid destination." >&2
            exit 1
        }
    fi
}

IFS="
"
MACOS=$(echo $OSTYPE | grep darwin || true)
if [ $MACOS ]; then
    RC=$HOME/.profile;
    SED_ARGS="-i ''"
else
    RC=$HOME/.bashrc;
    SED_ARGS="-i"
fi

while (( "$#" )); do
    case "$1" in
        -d|--dest) DEST="$2"; shift;;
        -y|--yes) FORCE="y";;
        -n|--no) FORCE="n";;
        -h|--help) help;;
    esac
    shift
done

check_dep $PYTHON

# We do not support Anaconda using this installer. Anaconda users must install the Engine manually
/usr/bin/env $PYTHON -c "import sys; sys.exit('Anaconda Python isn\'t supported by this package. Please install the official Python from python.org.') if 'conda' in sys.version else ''"

if [ -z $DEST ]; then
    PROMPT="Type the path where you want to install OpenQuake, followed by [ENTER]. Otherwise leave blank, it will be installed in ${HOME}/openquake: "
    read -e -p "$PROMPT" DEST
    [ -z "$DEST" ] && DEST=$HOME/openquake
fi
FDEST=$(realpath "$DEST")

echo "Creating a new python environment in ${FDEST}. Please wait."
/usr/bin/env $PYTHON -m venv $FDEST > /dev/null


[ $MACOS ] && \
    cat <<EOF >> ${FDEST}/env.sh
    export LC_ALL=en_US.UTF-8
    export LAN=en_US.UTF-8
EOF

cat <<EOF >> ${FDEST}/env.sh
. ${FDEST}/bin/activate
EOF

source ${FDEST}/env.sh
echo "Installing the OpenQuake Engine. Please wait."
# Update pip first
/usr/bin/env pip3 install --disable-pip-version-check -U wheelhouse/pip*.whl > /dev/null
/usr/bin/env pip3 install --disable-pip-version-check wheelhouse/*.whl > /dev/null
mkdir -p $FDEST/share
cp -R src/{README.md,LICENSE,demos,doc} $FDEST/share
cat <<EOF >> $FDEST/share/uninstall.sh
#!/bin/bash

if [[ "\$1" != "-f" ]]; then
    while ! (echo "\$CONFIRM" | grep -qE '^[nNyY]$'); do
        PROMPT="Are you sure you want to uninstall OQ and remove $FDEST? [y/n]: "
        read -e -p "\$PROMPT" CONFIRM
    done
else
    CONFIRM='y'
fi

if [[ "\$CONFIRM" == 'Y' || "\$CONFIRM" == 'y' ]]; then
    rm -Rf $FDEST
    [ -f $RC ] && sed $SED_ARGS '/alias oq=.*/d; /function oq().*/d' $RC

    echo "The OpenQuake Engine has been uninstalled"
else
    echo "Operation cancelled"
fi
EOF
chmod +x $FDEST/share/uninstall.sh

## Tools installation
# A question Y/N is prompt to the user: if answer is Y tools (IPT...) will be installed together with
# the OpenQuake Engine, otherwise with N only the Engine is installed and configured.
# To allow unattended installations a "force" flag can be passed, either force Y (--yes) or force N (--no)
if [ -z $FORCE ]; then
    while ! (echo "$TOOLS" | grep -qE '^[nNyY]$'); do
        PROMPT="Do you want to install the OpenQuake Tools (IPT, TaxtWeb, Taxonomy Glossary)? [y/n]: "
        read -e -p "$PROMPT" TOOLS
    done
else
    TOOLS=$FORCE
fi
if [[ "$TOOLS" == 'Y' || "$TOOLS" == 'y' ]]; then
    PYPREFIX=$(python -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())')
    /usr/bin/env pip3 install --disable-pip-version-check wheelhouse/tools/*.whl > /dev/null
fi

## 'oq' command alias
if [ -z $FORCE ]; then
    while ! (echo "$OQ" | grep -qE '^[nNyY]$'); do
        PROMPT="Do you want to make the 'oq' command available by default? [y/n]: "
        read -e -p "$PROMPT" OQ
    done
else
    OQ=$FORCE
fi
echo -n "Installation completed."
if [[ "$OQ" == 'Y' || "$OQ" == 'y' ]]; then
    [ -f $RC ] && sed $SED_ARGS '/alias oq=.*/d; /function oq().*/d' $RC
    echo "alias oq='${FDEST}/bin/oq'" >> $RC
    echo "The 'oq' command is now available opening a new terminal (see 'oq --help' for more commands)"
else
    echo "To make the 'oq' command available you must enable the environment first running 'source ${FDEST}/env.sh'"
fi

exit 0
