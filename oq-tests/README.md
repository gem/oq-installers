# Testing OpenQuake on Docker #

Currently runs only `oq-hazardlib` and `oq-engine`.

## Build images ##

```bash
>$ sudo docker build --rm=true -t openquake-centos7 -f oq-centos7/Dockerfile .
```

## Run a container ##

```bash
>$ sudo docker run -i -t openquake-centos7
```

### Run a custom branch

```bash
>$ sudo docker run -e "branch=mybranch" -i -t openquake-centos7
```

### Run in debug mode (run `/bin/bash`)

```bash
>$ sudo docker run -i -t openquake-centos7 /bin/bash
```


## Disclaimer ##

This work is experimental and is not supported by GEM nor the OpenQuake development team.
