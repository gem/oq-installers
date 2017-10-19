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

## Custom build args

```bash
--build-arg oq_branch=master      ## oq-engine branch
--build-arg tools_branch=mater ## oq standalone tools branch
```

See also https://github.com/gem/oq-engine/blob/master/doc/installing/docker.md
