ARG VERSION=v2026061404

# https://github.com/huihuimoe/juicefs

FROM --platform=$BUILDPLATFORM ghcr.io/gythialy/golang-cross-builder:latest AS base
ARG VERSION
RUN set -ex && \
    apt-get update && apt-get install -y musl-tools && apt -y autoremove && \
    apt-get clean && rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    cd /go && \
    git clone --depth=1 https://github.com/huihuimoe/juicefs -b main

FROM --platform=$BUILDPLATFORM base AS builder-amd64
ARG TARGETOS
ARG TARGETARCH
ARG GOEXPERIMENT=greenteagc
RUN set -ex && \
    cd /go/juicefs && \
    env CC=x86_64-linux-gnu-gcc \
        CGO_ENABLED=1 \
        GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
        GOAMD64=v3 \
        make juicefs

FROM --platform=$BUILDPLATFORM base AS builder-arm64
ARG TARGETOS
ARG TARGETARCH
ARG GOEXPERIMENT=greenteagc
RUN set -ex && \
    cd /go/juicefs && \
    env CC=aarch64-linux-gnu-gcc \
        CGO_ENABLED=1 \
        GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
        make juicefs

FROM --platform=$BUILDPLATFORM builder-${TARGETARCH} AS builder

FROM localhost:5000/juicefs-base:latest-${TARGETARCH}
ARG TARGETARCH
ARG VERSION
LABEL org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.source="https://github.com/huihuimoe/juicefs"
COPY --from=builder /go/juicefs/juicefs /usr/local/bin/juicefs
CMD ["juicefs", "version"]
