# syntax=docker/dockerfile:1

FROM --platform=$BUILDPLATFORM tonistiigi/xx:1.10.0 AS xx
FROM --platform=$BUILDPLATFORM cgr.dev/chainguard/wolfi-base:latest AS build

COPY --from=xx / /

ARG TARGETPLATFORM
ARG BIRD_VERSION
ENV XX_VENDOR=unknown

RUN apk add --no-cache curl && \
    curl -fsSL https://packages.wolfi.dev/os/wolfi-signing.rsa.pub \
      -o /etc/apk/keys/wolfi-signing.rsa.pub && \
    echo https://packages.wolfi.dev/os > /etc/apk/repositories && \
    apk add --no-cache \
      autoconf automake bash bison build-base clang curl flex flock lld patch

# Install target libraries without executing target-architecture programs.
RUN set -eux; \
    arch="$(xx-info alpine-arch)"; \
    apk --arch "$arch" --root /sysroot --initdb --no-scripts \
      --keys-dir /etc/apk/keys --repositories-file /etc/apk/repositories \
      add --no-cache gcc glibc-dev libssh-dev linux-headers ncurses-dev readline-dev; \
    apk --arch "$arch" --root /image --initdb --no-scripts \
      --keys-dir /etc/apk/keys --repositories-file /etc/apk/repositories \
      add --no-cache ca-certificates-bundle glibc libssh ncurses readline wolfi-baselayout

WORKDIR /src
COPY patches/ /patches/

RUN set -eux; \
    : "${BIRD_VERSION:?BIRD_VERSION is required}"; \
    curl -fsSL "https://bird.nic.cz/download/bird-${BIRD_VERSION}.tar.gz" -o bird.tar.gz; \
    tar -xzf bird.tar.gz --strip-components=1; \
    for patch in /patches/*.patch; do patch --batch --forward --fuzz=0 -p1 < "$patch"; done; \
    target_flags=''; \
    if [ "$(xx-info arch)" = amd64 ]; then target_flags='-march=x86-64-v2'; fi; \
    CC="xx-clang --no-default-config --sysroot=/sysroot --gcc-toolchain=/sysroot/usr $target_flags" \
      ./configure --build="$(./tools/config.guess)" --host="$(xx-info triple)" \
        --prefix=/usr --sbindir=/usr/bin --sysconfdir=/etc \
        --localstatedir=/var --runstatedir=/run --enable-libssh || { cat config.log; exit 1; }; \
    make -j"$(nproc)"; \
    make install DESTDIR=/image; \
    llvm-strip /image/usr/bin/bird /image/usr/bin/birdc /image/usr/bin/birdcl; \
    mkdir -p /image/etc/bird /image/run; \
    ln -s /etc/bird.conf /image/etc/bird/bird.conf

FROM scratch
ARG BIRD_VERSION
COPY --from=build /image/ /

LABEL org.opencontainers.image.title="BIRD" \
      org.opencontainers.image.description="Patched BIRD routing daemon on Wolfi" \
      org.opencontainers.image.source="https://github.com/huihuimoe/my-image" \
      org.opencontainers.image.licenses="GPL-2.0-or-later" \
      org.opencontainers.image.version="$BIRD_VERSION"

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
USER 0
ENTRYPOINT ["/usr/bin/bird"]
CMD ["-f", "-R", "-c", "/etc/bird/bird.conf"]
