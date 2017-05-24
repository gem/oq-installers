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
MACOS=$(echo $OSTYPE | grep -q darwin)

while (( "$#" )); do
    case "$1" in
        -d|--dest) DEST="$2"; shift;;
        -h|--help) help;;
    esac
    shift
done

if [ -z $DEST ]; then
    PROMPT="Type the path where you want to install OpenQuake, followed by [ENTER]. Otherwise leave blank, it will be installed in $HOME/openquake: "
    read -e -p "$PROMPT" DEST
    [ -z "$DEST" ] && DEST=$HOME/openquake
fi
FDEST=$(realpath "$DEST")

echo "Creating a new python environment in $FDEST. Please wait."
/usr/bin/python virtualenv/virtualenv.py $FDEST > /dev/null
cp -R {README.md,LICENSE,demos,doc} $FDEST

if [ $MACOS ]; then
    cat <<EOF >> $FDEST/env.sh
    export LC_ALL=en_US.UTF-8
    export LAN=en_US.UTF-8
EOF
fi

cat <<EOF >> $FDEST/env.sh
. $FDEST/bin/activate
EOF

source $FDEST/bin/activate
echo "Installing the files in $FDEST. Please wait."
pip install wheelhouse/*.whl > /dev/null

PROMPT="Do you want to make the 'oq' command available by default? [Y/n]: "
read -e -p "$PROMPT" OQ
if [ "$OQ" != 'N' && "$OQ" != 'n' ]; then
    if [ $MACOS ]; then
        echo "alias oq=\"${FDEST}/bin/oq\"" > $HOME/.profile
    else
        echo "alias oq=\"${FDEST}/bin/oq\"" > $HOME/.bashrc
    fi
fi

echo "Installation completed. To enable it run 'source $FDEST/env.sh'"
exit 0
