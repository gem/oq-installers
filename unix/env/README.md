## Docker

To support as most distros as possible the default build target for Linux is CentOS 6 (`$GEM_SET_VENDOR='redhat'`).

### Automatic build

```bash
sudo docker run [-e GEM_SET_BRANCH='master'] --rm -v $(pwd):/io centos:6 /io/build-pyenv-unix.sh
```

### Manual build

```bash
sudo docker run --rm -t -i -v $(pwd):/io centos:6 /bin/bash
$ cd /io
$ [GEM_SET_BRANCH='master'] bash build-pyenv-unix.sh
```

## Bare-metal

### On LXC, bare-metal or macOS

```bash
$ git clone https://github.com/gem/oq-installers.git
$ cd oq-installers/unix/env
$ [GEM_SET_BRANCH='master'] [GEM_SET_VENDOR='ubuntu|redhat'] bash build-pyenv-unix.sh
```

## Script parameters

The following environment variables are understood by the script:

- GEM_SET_DEBUG=<true|false>: enable debug (set -x)
- GEM_SET_NPROC=n: it will pass 'n' to `make -j` (default is 2)
- GEM_SET_BRANCH='branch': build the selected branch (by default is master)
