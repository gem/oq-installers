## Docker

### Automatic build

```bash
sudo docker run --rm -v $(pwd):/io ubuntu:14.04 /io/build-opt-unix.sh [-e GEM_SET_BRANCH='master']
```

### Manual build

```bash
sudo docker run --rm -t -i -v $(pwd):/io ubuntu:14.04 /bin/bash
$ cd /io
$ [GEM_SET_BRANCH='master'] bash build-opt-unix.sh
```

## LXC or bare-metal

### LXC bootstrap

```bash
sudo lxc-create -n ubuntu14-opt-builder -t ubuntu -- -r trusty
sudo lxc-start -n ubuntu14-opt-builder
sudo lxc-console -n ubuntu14-opt-builder
```

### LXC, bare-metal Ubuntu 14.04 or macOS

```bash
$ git clone https://github.com/gem/oq-installers.git
$ cd oq-installers/unix/opt
$ [GEM_SET_BRANCH='master'] bash build-opt-unix.sh
```

## Script parameters

The following environment variables are understood by the script:

- GEM_SET_DEBUG=<true|false>: enable debug (set -x)
- GEM_SET_NPROC=n: it will pass 'n' to `make -j` (default is 2)
- GEM_SET_BRANCH='branch': build the selected branch (by default is master)
