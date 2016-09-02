#!/bin/bash

if [ "$upgrade" == "yes" ]; then
    if [ -f /etc/redhat-release ]; then
        if [ -x /usr/bin/dnf ]; then
            sudo dnf upgrade -y
        else
            sudo yum upgrade -y
        fi
    elif [ -f /etc/debian_version ]; then
        sudo apt-get update
        sudo apt-get upgrade
    fi
fi

## $branch is a variable set via
## -e "branch=myoq"

for l in oq-hazardlib oq-engine; do
    echo "RUN $l tests"
    cd ${HOME}/${l}
    git fetch
    if [ -z $branch ]; then
        git checkout $branch
    fi;
    git pull
    nosetests -v -a '!slow'
done
