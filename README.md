# Testing OpenQuake on Docker #

Currently runs only `oq-hazardlib` and `oq-risklib`.

## Build images ##

```bash
>$ sudo docker build --rm=true -t openquake-f23 -f oq-fedora23/Dockerfile .
```

## Run a container ##

```bash
>$ sudo docker run -i -t openquake-f23
```

### Run a custom branch

```bash
>$ sudo docker run -e "branch=mybranch" -i -t openquake-f23
```

## Disclaimer ##

This work is experimental and is not supported by GEM nor the OpenQuake development team.
