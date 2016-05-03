# Testing OpenQuake on Docker #

Currently runs only `oq-hazardlib` and `oq-risklib`

## Build images ##

```bash
>$ sudo docker build --rm=true -t openquake-f23 -f oq-fedora23/Dockerfile .
```

## Run a container ##

```bash
>$ sudo docker run -t openquake-f23
```

### Run a custom branch

```bash
>$ sudo docker run -e "branch=mybranch" -t openquake-f23
```
