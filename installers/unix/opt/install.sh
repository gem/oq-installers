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

PYTHON=python2.7

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
PREFIX=/tmp/build-openquake-dist/qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq/prefix

while (( "$#" )); do
    case "$1" in
        -d|--dest) DEST="$2"; shift;;
        -y|--yes) FORCE="y";;
        -n|--no) FORCE="n";;
        -h|--help) help;;
    esac
    shift
done

check_dep find

if [ -z $DEST ]; then
    PROMPT="Type the path where you want to install OpenQuake, followed by [ENTER]. Otherwise leave blank, it will be installed in ${HOME}/openquake: "
    read -e -p "$PROMPT" DEST
    [ -z "$DEST" ] && DEST=$HOME/openquake
fi
FDEST=$(realpath "$DEST")

echo "Installing Python in $FDEST. Please wait."
cp -R src/* $FDEST

PREFIX_COUNT=${#PREFIX}
FDEST_COUNT=${#FDEST}
COUNT=$(($PREFIX_COUNT - $FDEST_COUNT))

for i in $(seq 1 $COUNT); do
    NUL=${NUL}'\x00'
    BLA=${BLA}' ' 
done

[ $MACOS ] && \
    cat <<EOF >> ${FDEST}/env.sh
    export LC_ALL=en_US.UTF-8
    export LAN=en_US.UTF-8
EOF

echo "Updating the installation. Please wait."
REWRITE=':loop;s@'${PREFIX}'\([^\x00\x22\x27]*[\x27\x22]\)@'${FDEST}'\1'${BLA}'@g;s@'${PREFIX}'\([^\x00\x22\x27]*\x00\)@'${FDEST}'\1'${NUL}'@g;s@'${PREFIX}'\([^\x00\x22\x27]*\)$@'${FDEST}'\1'${BLA}'@g;t loop'
find ${FDEST} -type f -exec ${FDEST}/bin/sed -i $REWRITE "{}" \;

source ${FDEST}/env.sh
echo "Installing the OpenQuake Engine. Please wait."
/usr/bin/env pip install --disable-pip-version-check wheelhouse/*.whl > /dev/null
mkdir $FDEST/share
cp -R src/{README.md,LICENSE,demos,doc} $FDEST/share

## Tools installation
if [ -z $FORCE ]; then
    PROMPT="Do you want to install the OpenQuake Tools (IPT, TaxtWeb, Taxonomy Glossary)? [Y/n]: "
    read -e -p "$PROMPT" TOOLS
else
    TOOLS=$FORCE
fi
if [[ "$TOOLS" != 'N' && "$TOOLS" != 'n' ]]; then
    PYPREFIX=$(python -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())')
    /usr/bin/env pip install --disable-pip-version-check wheelhouse/tools/*.whl > /dev/null
    cp ${PYPREFIX}/openquake/server/local_settings.py.standalone ${PYPREFIX}/openquake/server/local_settings.py
fi

## 'oq' command alias
if [ -z $FORCE ]; then
    PROMPT="Do you want to make the 'oq' command available by default? [Y/n]: "
    read -e -p "$PROMPT" OQ
else
    OQ=$FORCE
fi
if [[ "$OQ" != 'N' && "$OQ" != 'n' ]]; then
    if [ $MACOS ]; then
        RC=$HOME/.profile;
        SED_ARGS="-i ''"
    else
        RC=$HOME/.bashrc;
        SED_ARGS="-i"
    fi

    [ -f $RC ] && sed $SED_ARGS '/alias oq=.*/d; /function oq().*/d' $RC
    echo "function oq() { ( . ${FDEST}/env.sh && ${FDEST}/bin/oq \$* ) }" >> $RC
fi

echo "Installation completed. To enable it run 'source ${FDEST}/env.sh'"
exit 0
