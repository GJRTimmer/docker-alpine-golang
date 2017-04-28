[![build status](https://gitlab.timmertech.nl/docker/alpine-golang/badges/master/build.svg)](https://gitlab.timmertech.nl/docker/alpine-golang/commits/master)
[![](https://images.microbadger.com/badges/image/datacore/alpine-golang.svg)](https://microbadger.com/images/datacore/alpine-golang)
[![](https://images.microbadger.com/badges/version/datacore/alpine-golang.svg)](https://microbadger.com/images/datacore/alpine-golang)
[![](https://images.microbadger.com/badges/commit/datacore/alpine-golang.svg)](https://microbadger.com/images/datacore/alpine-golang)
[![](https://images.microbadger.com/badges/license/datacore/alpine-golang.svg)](https://microbadger.com/images/datacore/alpine-golang)

# Alpine Linux Golang build image for GitLab

- [Docker Registries](#docker-registries)
- [Source Repositories](#source-repositories)
- [Installation](#installation)
  - [DockerHub](#install-from-dockerhub)
  - [TimmerTech](#install-from-timmertech)
- [Contents](#contents)


# Docker Registries

 - ```datacore/alpine-golang:latest``` (DockerHub)
 - ```registry.timmertech.nl/docker/alpine-golang:latest``` (registry.timmertech.nl)


# Source Repositories

- [github.com](https://github.com/GJRTimmer/docker-alpine-golang)
- [gitlab.timmertech.nl](https://gitlab.timmertech.nl/docker/alpine-golang)


# Installation

## Install from DockerHub
Download:
```bash
docker pull datacore/alpine-golang:latest
```

Build:
```bash
docker build -t datacore/alpine-golang https://github.com/GJRTimmer/docker-alpine-golang
```


## Install from timmertech

Download:
```bash
docker pull registry.timmertech.nl/docker/alpine-golang:latest
```

Build:
```bash
docker build -t datacore/alpine-golang https://gitlab.timmertech.nl/docker/alpine-golang
```

## Contents

| Item | Version | Description |
|------|---------|-------------|
| GO | 1.8.1 | - |
| Google ProtoBuf | 3.2.0 | - |
| Glide | 0.12.3 | Golang Package manager |
| godoc | latest | - |
| godog | latest | - |
| gofmt | latest | - |
| goimports | latest | - |
| stringer | latest | - |
| proto | latest | - |
| protoc-gen-go | - |
