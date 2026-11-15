# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM tonistiigi/xx:1.10.0 AS xx
FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/wolfi-base:latest AS build

COPY --from=xx / /

ARG TARGETPLATFORM
ARG NDPPD_VERSION
ENV XX_VENDOR=unknown

RUN apk add --no-cache curl && \
    curl -fsSL https://packages.wolfi.dev/os/wolfi-signing.rsa.pub \
      -o /etc/apk/keys/wolfi-signing.rsa.pub && \
    echo https://packages.wolfi.dev/os > /etc/apk/repositories && \
    apk add --no-cache clang curl file lld make

RUN set -eux; \
    arch="$(xx-info alpine-arch)"; \
    apk --arch "$arch" --root /sysroot --initdb --no-scripts \
      --keys-dir /etc/apk/keys --repositories-file /etc/apk/repositories \
      add --no-cache gcc glibc-dev linux-headers; \
    apk --arch "$arch" --root /image --initdb --no-scripts \
      --keys-dir /etc/apk/keys --repositories-file /etc/apk/repositories \
      add --no-cache busybox glibc wolfi-baselayout; \
    ln -sf /bin/busybox /image/usr/bin/sh; \
    ln -sf /bin/busybox /image/usr/bin/cat

WORKDIR /src
RUN set -eux; \
    : "${NDPPD_VERSION:?NDPPD_VERSION is required}"; \
    curl -fsSL "https://github.com/DanielAdolfsson/ndppd/archive/refs/tags/${NDPPD_VERSION}.tar.gz" -o ndppd.tar.gz; \
    tar -xzf ndppd.tar.gz --strip-components=1; \
    make -j"$(nproc)" ndppd \
      CC="xx-clang --no-default-config --sysroot=/sysroot --gcc-toolchain=/sysroot/usr"; \
    xx-verify ndppd

FROM scratch
ARG NDPPD_VERSION

COPY --from=build /image/ /
COPY --from=build /src/ndppd /usr/local/sbin/ndppd
COPY --chmod=755 entrypoint.sh /entrypoint.sh

LABEL org.opencontainers.image.title="ndppd" \
      org.opencontainers.image.description="IPv6 Neighbor Discovery proxy on Wolfi" \
      org.opencontainers.image.source="https://github.com/huihuimoe/my-image" \
      org.opencontainers.image.licenses="GPL-3.0-or-later" \
      org.opencontainers.image.version="$NDPPD_VERSION"

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
USER 0
ENTRYPOINT ["/entrypoint.sh"]
