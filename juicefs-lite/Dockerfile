# https://github.com/juicedata/juicefs/releases

FROM --platform=$BUILDPLATFORM ghcr.io/gythialy/golang-cross-builder:latest AS base
ARG VERSION
RUN set -ex && \
    apt-get update && apt-get install -y musl-tools && apt -y autoremove && \
    apt-get clean && rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    cd /go && \
    git clone --depth=1 https://github.com/juicedata/juicefs -b v${VERSION} && \
    cd juicefs && \
    # enable badger
    sed -i 's/,nobadger//' Makefile && \
    # fixing build error on old github.com/grafana/pyroscope-go
    go get -v github.com/grafana/pyroscope-go && \
    go mod tidy

FROM --platform=$BUILDPLATFORM base AS builder-amd64
ARG TARGETOS
ARG TARGETARCH
RUN set -ex && \
    cd /go/juicefs && \
    env CC=x86_64-linux-gnu-gcc \
        CGO_ENABLED=1 \
        GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
        GOAMD64=v3 \
        make juicefs.lite

FROM --platform=$BUILDPLATFORM base AS builder-arm64
ARG TARGETOS
ARG TARGETARCH
RUN set -ex && \
    cd /go/juicefs && \
    env CC=aarch64-linux-gnu-gcc \
        CGO_ENABLED=1 \
        GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
        make juicefs.lite

FROM --platform=$BUILDPLATFORM builder-${TARGETARCH} AS builder

FROM localhost/juicefs-base:latest-${TARGETARCH}
ARG TARGETARCH
COPY --from=builder /go/juicefs/juicefs.lite /usr/local/bin/juicefs
CMD ["juicefs", "version"]
