FROM registry.timmertech.nl/docker/alpine-glibc:latest

ARG BUILD_DATE
ARG VCS_REF

ARG GOLANG_VERSION=1.9
ARG GOLANG_SRC_URL=https://golang.org/dl/go${GOLANG_VERSION}.src.tar.gz
ARG GOLANG_SRC_SHA256=a4ab229028ed167ba1986825751463605264e44868362ca8e7accc8be057e993

ARG PROTOC_VERSION=3.4.0
ARG PROTOC_URL=https://github.com/google/protobuf/releases/download/v${PROTOC_VERSION}/protoc-${PROTOC_VERSION}-linux-x86_64.zip

LABEL \
	maintainer="G.J.R. Timmer <gjr.timmer@gmail.com>" \
	nl.timmertech.build-date=${BUILD_DATE} \
	nl.timmertech.name=alpine-golang \
	nl.timmertech.vendor=timmertech.nl \
	nl.timmertech.vcs-url="https://github.com/GJRTimmer/docker-alpine-golang.git" \
	nl.timmertech.vcs-ref=${VCS_REF} \
	nl.timmertech.license=MIT

RUN apk add --no-cache --update ca-certificates wget git curl unzip openssh && \
	apk upgrade --update --no-cache

# https://golang.org/issue/14851 (Go 1.8 & 1.7)
# https://golang.org/issue/17847 (Go 1.7)
COPY *.patch /go-alpine-patches/

RUN set -ex && \
	apk add --no-cache \
		bash \
		gcc \
		musl-dev \
		openssl \
		openssl-dev \
		alpine-sdk \
		go && \
	export \
		# set GOROOT_BOOTSTRAP such that we can actually build Go
		GOROOT_BOOTSTRAP="$(go env GOROOT)" \
		# ... and set "cross-building" related vars to the installed system's values so that we create a build targeting the proper arch
		# (for example, if our build host is GOARCH=amd64, but our build env/image is GOARCH=386, our build needs GOARCH=386)
		GOOS="$(go env GOOS)" \
		GOARCH="$(go env GOARCH)" \
		GO386="$(go env GO386)" \
		GOARM="$(go env GOARM)" \
		GOHOSTOS="$(go env GOHOSTOS)" \
		GOHOSTARCH="$(go env GOHOSTARCH)" \
	; \
	\
	wget -q "${GOLANG_SRC_URL}" -O golang.tar.gz && \
	echo "${GOLANG_SRC_SHA256}  golang.tar.gz" | sha256sum -c - && \
	tar -C /usr/local -xzf golang.tar.gz && \
	rm golang.tar.gz && \
	cd /usr/local/go/src && \
	for p in /go-alpine-patches/*.patch; do \
		[ -f "$p" ] || continue; \
		patch -p2 -i "$p"; \
	done; \
	\
	ls /usr/local/go && \
	cd .. && \
	ls && \
	./make.bash && \
	\
	rm -rf /go-alpine-patches

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
		github.com/golang/protobuf/protoc-gen-go \
		github.com/golang/dep/cmd/dep

# EOF