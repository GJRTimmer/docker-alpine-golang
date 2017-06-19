FROM registry.timmertech.nl/docker/alpine-glibc:latest
MAINTAINER G.J.R. Timmer <gjr.timmer@gmail.com>

ARG BUILD_DATE
ARG VCS_REF

ARG GOLANG_VERSION=1.8.3
ARG GOLANG_SRC_URL=https://golang.org/dl/go${GOLANG_VERSION}.src.tar.gz
ARG GOLANG_SRC_SHA256=5f5dea2447e7dcfdc50fa6b94c512e58bfba5673c039259fd843f68829d99fa6

ARG PROTOC_VERSION=3.3.0
ARG PROTOC_URL=https://github.com/google/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip

LABEL \
	nl.timmertech.build-date=${BUILD_DATE} \
	nl.timmertech.name=alpine-golang \
	nl.timmertech.vendor=timmertech.nl \
	nl.timmertech.vcs-url="https://github.com/GJRTimmer/docker-alpine-golang.git" \
	nl.timmertech.vcs-ref=${VCS_REF} \
	nl.timmertech.license=MIT

RUN apk add --no-cache --update ca-certificates wget git curl unzip openssh && \
	apk upgrade --update --no-cache

# https://golang.org/issue/14851
COPY no-pic.patch /

RUN set -ex && \
	apk add --no-cache \
		bash \
		gcc \
		musl-dev \
		openssl \
		openssl-dev \
		alpine-sdk \
		go && \
	export GOROOT_BOOTSTRAP="$(go env GOROOT)" && \
	wget -q "${GOLANG_SRC_URL}" -O golang.tar.gz && \
	echo "${GOLANG_SRC_SHA256}  golang.tar.gz" | sha256sum -c - && \
	tar -C /usr/local -xzf golang.tar.gz && \
	rm golang.tar.gz && \
	cd /usr/local/go/src && \
	patch -p2 -i /no-pic.patch && \
	./make.bash && \
	rm -rf /*.patch

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

RUN git config --global http.https://gopkg.in.followRedirects true && \
	curl https://glide.sh/get | sh && \
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