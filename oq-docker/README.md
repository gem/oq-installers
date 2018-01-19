# Running OpenQuake on Docker #

Exposes the WebUI and a `oq` cli.

## Build images ##

### Python3 base image

```bash
$ docker build -t openquake/base -f Dockerfile.base .
```

### OpenQuake Engine

```bash
$ docker build -t openquake/engine -f Dockerfile .
```
### Custom build args

```bash
--build-arg oq_branch=master      ## oq-engine branch
--build-arg tools_branch=mater    ## oq standalone tools branch
```

### OpenQuake Engine master node container

```bash
$ docker build -t openquake/engine-master -f Dockerfile.master .
```

### OpenQuake Engine worker node container

```bash
$ docker build -t openquake/engine-worker -f Dockerfile.worker .
```

## Run a single node container ##


### TTY ###

```bash
$ sudo docker run --name myoqcontainer -i -t -p 8800:8800 openquake/engine
```

### Headless ###

```bash
$ sudo docker run --name myoqcontainer -d -p 8800:8800 openquake/engine
```

### Start and stop ###

```bash
$ sudo docker start myoqcontainer
$ sudo docker stop myoqcontainer
```

### Authentication support

Authentication support for the WebUI/API can be enabled passing the `LOCKDOWN=enable` environment variable to the Docker container:

```bash
$ sudo docker run -e LOCKDOWN=enable --name myoqcontainer -d -p 8800:8800 openquake/engine
```

You can login with the default `admin` user and `admin` password.


## Run an OpenQuake Engine cluster via docker-compose

```bash
$ docker-compose up
```

More workers can be started via

```bash
$ docker-compose up --scale worker=N
```

## Run an OpenQuake Engine cluster manually

### OQ internal network

```bash
$ docker network create --driver bridge oq-cluster-net
```

### RabbitMQ container

```bash
$ docker run -d --network=oq-cluster-net --name oq-cluster-rabbit -e RABBITMQ_DEFAULT_VHOST=openquake -e RABBITMQ_DEFAULT_USER=openquake -e RABBITMQ_DEFAULT_PASS=openquake rabbitmq:3
```

### Master node container

```bash
$ docker run -d --network=oq-cluster-net --name oq-cluster-master -p8800:8800 openquake/engine-master
```

### Worker nodes

```bash
$ docker run -d --network=oq-cluster-net --name oq-cluster-worker_1 openquake/engine-worker
```

See also https://github.com/gem/oq-engine/blob/master/doc/installing/docker.md
For future plans see: https://github.com/gem/oq-builders/issues/88
