# Running OpenQuake on Docker #

Exposes the WebUI and a `oq` cli.

## Build images ##

```bash
>$ sudo docker build --rm=true -t openquake-centos7 -f Dockerfile.centos .
```

## Run a container ##

```bash
>$ sudo docker run --name myoqcontainer -i -t -p 8000:8000 openquake-centos7
```

### Start and stop ###

```bash
>$ sudo docker start myoqcontainer
>$ sudo docker stop myoqcontainer
```


## Disclaimer ##

This work is experimental and is not supported by GEM. Use at your own risk.
