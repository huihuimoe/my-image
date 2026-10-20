# syntax=docker/dockerfile:1
FROM alpine:3.24

ARG BUILD_DATE
LABEL build_version="huihuimoe build-date:- ${BUILD_DATE}"
LABEL maintainer="huihuimoe"
LABEL org.opencontainers.image.source="https://github.com/huihuimoe/my-image"
LABEL org.opencontainers.image.description="Minimal WireGuard image using wg-quick and nftables"

RUN \
  echo "**** install dependencies ****" && \
  apk add --no-cache \
    bash \
    flock \
    iproute2 \
    libqrencode-tools \
    nftables \
    openresolv \
    wireguard-tools && \
  echo "**** prepare config layout ****" && \
  mkdir -p /config/wg_confs && \
  rm -rf /etc/wireguard && \
  ln -s /config/wg_confs /etc/wireguard && \
  printf '%s\n' "${BUILD_DATE}" > /build_version

COPY root/ /

VOLUME ["/config"]
EXPOSE 51820/udp
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["supervise"]
