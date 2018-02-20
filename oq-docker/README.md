# Build OpenQuake Docker images #

<img src="https://upload.wikimedia.org/wikipedia/commons/7/79/Docker_%28container_engine%29_logo.png" width="150px"> [![Build Status](https://ci.openquake.org/buildStatus/icon?job=builders/docker-builder)](h    ttps://ci.openquake.org/job/builders/docker-builder)

Introduction: https://github.com/gem/oq-engine/blob/update-doc/doc/installing/docker.md


## Python3 base image (required by all images)

```bash
$ docker build -t openquake/base -f Dockerfile.base .
```

## OpenQuake Engine (single node)

```bash
$ docker build -t openquake/engine -f Dockerfile .
```

## OpenQuake Engine master node container (cluster)

```bash
$ docker build -t openquake/engine-master -f Dockerfile.master .
```

## OpenQuake Engine worker node container (cluster)

```bash
$ docker build -t openquake/engine-worker -f Dockerfile.worker .
```

## Custom build args

```bash
--build-arg oq_branch=master      ## oq-engine branch
--build-arg tools_branch=mater    ## oq standalone tools branch
```

See also https://github.com/gem/oq-engine/blob/master/doc/installing/docker.md
For future plans see: https://github.com/gem/oq-builders/issues/88
