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

# start the dbserver in background
oq-engine/bin/oq dbserver start &

# update the sources first at (almost)
# the same time to avoid out of sync
for l in oq-hazardlib oq-engine; do
    cd ${HOME}/${l}
    git fetch
    # FIXME fallback must be added
    if [ -z $branch ]; then
        git checkout $branch
    fi;
    git pull
done

# run tests
for l in oq-hazardlib oq-engine; do
    echo "RUN $l tests"
    #nosetests -v -a '!slow'
    nosetests -v -a '!slow'
done
