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

    -s, --skip-new       The new database will not be created
    -y, --yes            Don't pause for user input, assume yes on all questions
    -h, --help           This help
HSD
    exit 0
}

IFS="
"
SRC=%_SOURCE_%

for i in sed tar gzip; do
    command -v $i &> /dev/null || {
        echo -e "!! Please install $i first." >&2
        exit 1
    }
done

if [ -z $1 ]; then
    help
fi

while (( "$#" )); do
    case "$1" in
        -s|--src) SRC="$2"; shift;;
        -d|--dest) DEST="$2"; shift;;
        -h|--help) help;;
    esac
    shift
done

if [ ! -f $SRC ]; then
    echo -e "!! Please specify a valid source." >&2
    exit 1
fi
if [ -z $DEST -o ! -d $DEST ]; then
    echo -e "!! Please specify a valid destination." >&2
    exit 1
elif [ -d $DEST/openquake ]; then
    echo -e "!! An installation already exists in $DEST. Please remove it first." >&2
    exit 1
fi

echo $SRC
echo $DEST

echo "Extracting the archive in $DEST. Please wait."
tar -C $DEST -xzf $SRC 

SRC_COUNT=${#SRC}
DEST_COUNT=${#DEST}
COUNT=$(($SRC_COUNT - $DEST_COUNT))

echo $COUNT

for i in $(seq 1 $COUNT); do
    NUL=${NUL}'\x00'
    BLA=${BLA}' ' 
done

echo $NUL
echo "'"$BLA"'"

echo "Finisching the installation. Please wait."
find ${DEST}/openquake -type f -print -exec sed -i ':loop;s@'${SRC}'\([^\x00\x22\x27]*[\x27\x22]\)@'${DEST}'\1'${BLA}'@g;s@'${SRC}'\([^\x00\x22\x27]*\x00\)@'${DEST}'\1'${NUL}'@g;s@'${SRC}'\([^\x00\x22\x27]*\)$@'${DEST}'\1'${BLA}'@g;t loop' "{}" \;

echo "Installation cpmpleted. To enable it run 'source $DEST/openquake/env.sh'"
exit 0
