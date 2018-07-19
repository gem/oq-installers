## Docker

To support as most distros as possible the default build target for Linux is CentOS 6.

To reduce the workload (downloading pre-requisites) a `Dockerfile` is provided to create a builder:

```bash
sudo docker build --build-arg uid=$(id -u) --rm=true -t centos6-builder -f Dockerfile.builder .
```

### Automatic build

```bash
sudo docker run [-e GEM_SET_BRANCH='master'] --rm -t -i -v $(pwd):/io centos6-builder /io/build.sh
```

### Manual build

```bash
sudo docker run --rm -t -i -v $(pwd):/io centos6-builder /bin/bash
$ cd /io
$ [GEM_SET_BRANCH='master'] bash /io/build.sh
```

## macOS

Xcode, GNU sed and (Python 3.6)[https://www.python.org/ftp/python/3.6.6/python-3.6.6-macosx10.9.pkg] must be installed first

```bash
./build.sh
```

## Script parameters

The following environment variables are understood by the script:

- GEM_SET_DEBUG=<true|false>: enable debug (set -x)
- GEM_SET_NPROC=n: it will pass 'n' to `make -j` (default is 2)
- GEM_SET_BRANCH='branch': build the selected branch (by default is master)
- GEM_SET_RELEASE=n: it set the builder to 'release mode'
