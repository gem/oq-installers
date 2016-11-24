# Testing OpenQuake on Docker #

Currently runs only `oq-hazardlib` and `oq-engine`.

## Build images ##

```bash
>$ sudo docker build--rm=true -t openquake-centos7 -f Dockerfile.centos .
```

## Run a container ##

```bash
>$ sudo docker run --name myoqtestcontainer --rm -i -t openquake-centos7
```

### Run a custom branch

```bash
>$ sudo docker run --name myoqtestcontainer --rm -e "branch=mybranch" -i -t openquake-centos7
```

### Run the tests

```bash
>$ sudo docker run --name myoqtestcontainer --rm -i -t openquake-centos7 ./runtests.sh
```

### Force deps upgrade

```bash
>$ sudo docker run -e "upgrade=yes" [...]
```

## Disclaimer ##

This work is experimental and is not supported by GEM. Use at your own risk.
