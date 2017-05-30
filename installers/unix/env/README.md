## Docker

To support as most distros as possible the default build target for Linux is CentOS 6.

### Automatic build

```bash
sudo docker run [-e GEM_SET_BRANCH='master'] --rm -v $(pwd):/io centos6-builder /io/build-pyenv-unix.sh
```

### Manual build

```bash
sudo docker run --rm -t -i -v $(pwd):/io centos6-builder /bin/bash
$ cd /io
$ [GEM_SET_BRANCH='master'] bash /io/build-pyenv-unix.sh
```

## macOS

https://www.python.org/ftp/python/3.5.3/python-3.5.3-macosx10.6.pkg must be installed first

```bash
./build-pyenv-unix.sh
```

## Script parameters

The following environment variables are understood by the script:

- GEM_SET_DEBUG=<true|false>: enable debug (set -x)
- GEM_SET_NPROC=n: it will pass 'n' to `make -j` (default is 2)
- GEM_SET_BRANCH='branch': build the selected branch (by default is master)
