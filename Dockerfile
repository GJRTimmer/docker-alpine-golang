FROM registry.timmertech.nl/docker/alpine-glibc:latest
MAINTAINER G.J.R. Timmer <gjr.timmer@gmail.com>

ARG BUILD_DATE
ARG VCS_REF

ARG GOLANG_VERSION=1.7.4
ARG GOLANG_SRC_URL=https://golang.org/dl/go${GOLANG_VERSION}.src.tar.gz
ARG GOLANG_SRC_SHA256=4c189111e9ba651a2bb3ee868aa881fab36b2f2da3409e80885ca758a6b614cc

ARG PROTOC_VERSION=3.2.0
ARG PROTOC_URL=https://github.com/google/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip

LABEL \
	nl.timmertech.build-date=${BUILD_DATE} \
	nl.timmertech.name=alpine-golang \
	nl.timmertech.vendor=timmertech.nl \
	nl.timmertech.vcs-url="https://github.com/GJRTimmer/docker-alpine-golang.git" \
	nl.timmertech.vcs-ref=${VCS_REF} \
	nl.timmertech.license=MIT

RUN apk add --no-cache --update ca-certificates wget git curl unzip && \
	apk upgrade --update --no-cache

# https://golang.org/issue/14851
COPY no-pic.patch /
# https://golang.org/issue/17847
COPY 17847.patch /

RUN set -ex && \
	apk add --no-cache --virtual .build-deps \
		bash \
		gcc \
		musl-dev \
		openssl \
		go && \
	export GOROOT_BOOTSTRAP="$(go env GOROOT)" && \
	wget -q "${GOLANG_SRC_URL}" -O golang.tar.gz && \
	echo "${GOLANG_SRC_SHA256}  golang.tar.gz" | sha256sum -c - && \
	tar -C /usr/local -xzf golang.tar.gz && \
	rm golang.tar.gz && \
	cd /usr/local/go/src && \
	patch -p2 -i /no-pic.patch && \
	patch -p2 -i /17847.patch && \
	./make.bash && \
	rm -rf /*.patch && \
	apk del .build-deps

RUN wget -q "${PROTOC_URL}" -O protoc.zip && \
	cd /usr && \
	unzip ../protoc.zip && \
	rm -rf /protoc.zip && \
	rm -rf /usr/readme.txt && \
	apk del --purge unzip
	
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && \
	chmod -R 777 "$GOPATH"
WORKDIR $GOPATH

COPY go-wrapper /usr/local/bin/

RUN curl https://glide.sh/get | sh && \
	go get -u -v \
		golang.org/x/tools/cmd/godoc \
		github.com/DATA-DOG/godog/cmd/godog \
		github.com/DATA-DOG/godog \
		cmd/gofmt \
		golang.org/x/tools/cmd/goimports \
		golang.org/x/tools/cmd/stringer \
		github.com/golang/protobuf/proto \
		github.com/golang/protobuf/protoc-gen-go

# EOF