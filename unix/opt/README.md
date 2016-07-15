## Docker

### Automatic build

```bash
sudo docker run --rm -v $(pwd):/io ubuntu:14.04 /io/build-opt-unix.sh [-e GEM_SET_BRANCH='master']
```

### Manual build

```bash
sudo docker run --rm -t -i -v $(pwd):/io ubuntu:14.04 /bin/bash
$ cd /io
$ bash build-opt-unix.sh
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
$ bash build-opt-unix.sh
```
