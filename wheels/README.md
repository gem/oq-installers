## Build all wheels on Docker

`sudo docker run --rm -v $(pwd):/io quay.io/pypa/manylinux1_x86_64 /io/build-wheels-docker.sh`

## Build a single wheel on Docker

`sudo docker run --rm -v $(pwd):/io quay.io/pypa/manylinux1_x86_64 /io/builders/numpy.sh`

## Run an interactive Docker

`sudo docker run --rm -t -i -v $(pwd):/io quay.io/pypa/manylinux1_x86_64 /bin/bash`
