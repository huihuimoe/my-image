# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM tonistiigi/xx:1.10.0 AS xx
FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/wolfi-base:latest AS build

COPY --from=xx / /

ARG TARGETPLATFORM
ARG ZT_VERSION=1.16.2
ENV XX_VENDOR=unknown

RUN apk add --no-cache curl && \
    curl -fsSL https://packages.wolfi.dev/os/wolfi-signing.rsa.pub \
      -o /etc/apk/keys/wolfi-signing.rsa.pub && \
    echo https://packages.wolfi.dev/os > /etc/apk/repositories && \
    apk add --no-cache clang curl file lld llvm make patch

RUN set -eux; \
    arch="$(xx-info alpine-arch)"; \
    apk --arch "$arch" --root /sysroot --initdb --no-scripts \
      --keys-dir /etc/apk/keys --repositories-file /etc/apk/repositories \
      add --no-cache gcc glibc-dev libstdc++-dev linux-headers; \
    apk --arch "$arch" --root /image --initdb --no-scripts \
      --keys-dir /etc/apk/keys --repositories-file /etc/apk/repositories \
      add --no-cache busybox glibc libgcc libstdc++ wolfi-baselayout; \
    ln -sf /bin/busybox /image/bin/sh; \
    ln -sf /bin/busybox /image/usr/bin/sh; \
    mkdir -p /image/usr/sbin /image/var/lib/zerotier-one

WORKDIR /src
COPY patches/ /patches/

RUN set -eux; \
    : "${ZT_VERSION:?ZT_VERSION is required}"; \
    curl -fsSL "https://github.com/zerotier/ZeroTierOne/archive/refs/tags/${ZT_VERSION}.tar.gz" -o zerotier.tar.gz; \
    tar -xzf zerotier.tar.gz --strip-components=1; \
    for patch in /patches/*.patch; do patch --batch --forward --fuzz=0 -p1 < "$patch"; done; \
    make -j"$(nproc)" -f make-linux.mk one \
      ZT_NONFREE=1 \
      ZT_SSO_SUPPORTED=0 \
      CC="xx-clang --no-default-config --sysroot=/sysroot --gcc-toolchain=/sysroot/usr" \
      CXX="xx-clang++ --no-default-config --sysroot=/sysroot --gcc-toolchain=/sysroot/usr" \
      AS="xx-clang --no-default-config -c"; \
    xx-verify zerotier-one; \
    llvm-strip zerotier-one; \
    install -Dm755 zerotier-one /image/usr/sbin/zerotier-one; \
    ln -s zerotier-one /image/usr/sbin/zerotier-cli; \
    ln -s zerotier-one /image/usr/sbin/zerotier-idtool; \
    ln -s ../../../usr/sbin/zerotier-one /image/var/lib/zerotier-one/zerotier-one; \
    ln -s ../../../usr/sbin/zerotier-one /image/var/lib/zerotier-one/zerotier-cli; \
    ln -s ../../../usr/sbin/zerotier-one /image/var/lib/zerotier-one/zerotier-idtool

FROM scratch
ARG ZT_VERSION=1.16.2

COPY --from=build /image/ /
COPY --chmod=755 entrypoint.sh /entrypoint.sh

LABEL org.opencontainers.image.title="zerotier" \
      org.opencontainers.image.description="Patched ZeroTier One on Wolfi" \
      org.opencontainers.image.source="https://github.com/huihuimoe/my-image" \
      org.opencontainers.image.licenses="MPL-2.0" \
      org.opencontainers.image.version="$ZT_VERSION"

EXPOSE 9993/udp
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
USER 0
ENTRYPOINT ["/entrypoint.sh"]
CMD ["-U"]
