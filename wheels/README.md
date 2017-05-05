## Build all wheels on Docker

`sudo docker run --rm -v $(pwd):/io quay.io/pypa/manylinux1_x86_64 /io/build-wheels-docker.sh`

## Build a single wheel on Docker

`sudo docker run --rm -v $(pwd):/io quay.io/pypa/manylinux1_x86_64 /io/builders/numpy.sh`

### Build a single wheel for a custom Python release

`sudo docker run -e "GEM_SET_PY=36" --rm -v $(pwd):/io quay.io/pypa/manylinux1_x86_64 /io/builders/numpy.sh`

## Run an interactive Docker

`sudo docker run --rm -t -i -v $(pwd):/io quay.io/pypa/manylinux1_x86_64 /bin/bash`
