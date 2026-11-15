# gRPC Cross ARM
> Cross compile gRPC for ARM with Docker.

[![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/rolandjitsu/grpc-cross-arm/test.yml?branch=master&label=tests&style=flat-square)](https://github.com/rolandjitsu/grpc-cross-arm/actions?query=workflow%3ATest)

## Overview
This repository provides a reproducible Docker-based pipeline to cross-compile C++ [gRPC](https://grpc.io/) applications for ARM architectures (32-bit ARM `armhf` and 64-bit `aarch64`) from an x86_64 host without needing native ARM hardware.

For automated tools and AI coding agents, see [AGENTS.md](file:///Users/roland.groza/Work/grpc-cross-arm/AGENTS.md) for detailed architectural context and workflow instructions.

## Prerequisites
Install the following tools:
* [Docker](https://docs.docker.com/engine) (Docker Desktop or Docker Engine >= 20.10 with [Buildx](https://github.com/docker/buildx))

## Setup Docker
Create a Buildx builder:
```bash
docker buildx create --name my-builder --driver docker-container --use
```

Then inspect and bootstrap it:
```bash
docker buildx inspect --bootstrap
```

## Compile
To compile the binaries with default settings:
```bash
docker buildx build -f Dockerfile -o type=local,dest=./bin .
```

*Tip:* To bypass cache, append `--no-cache`.

## Bake
To simplify the build command and make use of caching, you can use [buildx bake](https://docs.docker.com/build/bake/):

```bash
# Default build (32-bit ARM, output to ./bin)
docker buildx bake

# Target 32-bit ARM specifically (output to ./bin/armhf)
docker buildx bake armhf

# Target 64-bit ARM (output to ./bin/aarch64)
docker buildx bake aarch64

# Build both architectures in parallel
docker buildx bake all
```

## Learning Material
* [Docker Buildx](https://docs.docker.com/buildx/working-with-buildx/)
* [Getting started with Docker for ARM on Linux](https://www.docker.com/blog/getting-started-with-docker-for-arm-on-linux/)
* [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
* [gRPC C++ Quick start](https://grpc.io/docs/languages/cpp/quickstart/)
