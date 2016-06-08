#!/bin/bash
# -*- coding: utf-8 -*-
# vim: tabstop=4 shiftwidth=4 softtabstop=4
#
# Copyright (C) 2010-2016 GEM Foundation
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

help() {
    cat <<HSD
The command line arguments are as follows:

    -s, --src            Path to the installation source (.tar.gz)
    -d, --dest           Path to the destination folder
    -h, --help           This help
HSD
    exit 0
}

realpath() {
    cd $(eval echo "$1") &>/dev/null && pwd || {
        echo -e "!! Please specify a valid destination." >&2
        exit 1
    }
}

IFS="
"
SRC=openquake
PREFIX=/tmp/build-openquake-dist/qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq

while (( "$#" )); do
    case "$1" in
        -s|--src) SRC="$2"; shift;;
        -d|--dest) DEST="$2"; shift;;
        -h|--help) help;;
    esac
    shift
done

if [ ! -d $SRC ]; then
    echo -e "!! Please specify a valid source." >&2
    exit 1
fi
if [ -z $DEST ]; then

    echo -n "Type the path where you want to install OpenQuake, followed by [ENTER]: "
    read DEST
fi
FDEST=$(realpath "$DEST")
if [ -d $FDEST/openquake ]; then
    echo -e "!! An installation already exists in $FDEST. Please remove it first." >&2
    exit 1
fi

echo "Copying the files in $FDEST/openquake. Please wait."
cp -R $SRC $FDEST

PREFIX_COUNT=${#PREFIX}
FDEST_COUNT=${#FDEST}
COUNT=$(($PREFIX_COUNT - $FDEST_COUNT))

for i in $(seq 1 $COUNT); do
    NUL=${NUL}'\x00'
    BLA=${BLA}' ' 
done

echo "Finalizing the installation. Please wait."

REWRITE=':loop;s@'${PREFIX}'\([^\x00\x22\x27]*[\x27\x22]\)@'${FDEST}'\1'${BLA}'@g;s@'${PREFIX}'\([^\x00\x22\x27]*\x00\)@'${FDEST}'\1'${NUL}'@g;s@'${PREFIX}'\([^\x00\x22\x27]*\)$@'${FDEST}'\1'${BLA}'@g;t loop'
find ${FDEST}/openquake -type f -exec ${FDEST}/openquake/bin/sed -i $REWRITE "{}" \;

echo "Installation completed. To enable it run 'source $FDEST/openquake/env.sh'"
exit 0
