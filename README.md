# gRPC Cross ARM
> Cross compile gRPC for ARM with Docker.

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/rolandjitsu/grpc-cross-arm/Test?label=tests&style=flat-square)](https://github.com/rolandjitsu/grpc-cross-arm/actions?query=workflow%3ATest)

## Prerequisites
Install the following tools:
* [Docker](https://docs.docker.com/engine) >= `19.03.13`
* [buildx](https://github.com/docker/buildx#installing) >= `v0.4.1`

## Setup Docker
Create a builder:
```bash
docker buildx create --name my-builder --driver docker-container --use
```

Then inspect and bootstrap it:
```bash
docker buildx inspect --bootstrap
```

## Compile
To compile the binaries:
```bash
docker buildx build -f Dockerfile -o type=local,dest=./bin .
```

*P.S.* To bust the cache, use `--no-cache`.

## Bake
To make things easier, you can use the [bake](https://github.com/docker/buildx#buildx-bake-options-target) command.

To compile the binaries:
```bash
docker buildx bake
```

## Learning Material
* [Docker Buildx](https://docs.docker.com/buildx/working-with-buildx/)
* [Getting started with Docker for ARM on Linux](https://www.docker.com/blog/getting-started-with-docker-for-arm-on-linux/)
* [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
