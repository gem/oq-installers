# Running OpenQuake on Docker #

Exposes the WebUI and a `oq` cli.

## Build images ##

```bash
>$ sudo docker build --rm=true -t openquake/engine -f Dockerfile.centos .
```

## Run a container ##


### TTY ###

```bash
>$ sudo docker run --name myoqcontainer -i -t -p 8800:8800 openquake-centos7
```

### Headless ###

```bash
>$ sudo docker run --name myoqcontainer -d -p 8800:8800 openquake-centos7
```

### Start and stop ###

```bash
>$ sudo docker start myoqcontainer
>$ sudo docker stop myoqcontainer
```


## Disclaimer ##

This work is experimental and is not supported by GEM. Use at your own risk.
