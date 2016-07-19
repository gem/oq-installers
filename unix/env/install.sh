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
python virtualenv/virtualenv.py $FDEST > /dev/null
mkdir $FDEST/etc
cp openquake.cfg $FDEST/etc
cp -R {README.md,LICENSE,demos} $FDEST

echo "export OQ_SITE_CFG_PATH=\${VIRTUAL_ENV}/etc/openquake.cfg" >> $FDEST/bin/activate

source $FDEST/bin/activate
echo "Installing the files in $FDEST. Please wait."
pip install wheelhouse/*.whl > /dev/null

echo "Installation completed. To enable it run 'source $FDEST/bin/activate'"
exit 0
