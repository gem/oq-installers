#!/bin/bash

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
