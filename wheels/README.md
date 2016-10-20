## Run build on Docker

`sudo docker run --rm -v $(pwd):/io quay.io/pypa/manylinux1_x86_64 /io/build-wheels-docker.sh`

## Run build on Docker manually

`sudo docker run --rm -t -i -v $(pwd):/io quay.io/pypa/manylinux1_x86_64 /bin/bash`
