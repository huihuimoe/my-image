# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.21

# set version label
ARG BUILD_DATE
LABEL build_version="Linuxserver.io Build-date:- ${BUILD_DATE}"
LABEL maintainer="huihuimoe"

# add local files
COPY linuxserver-wireguard/root /

RUN \
  echo "**** install dependencies ****" && \
  apk add --no-cache \
    bc \
    # coredns \
    grep \
    iproute2 \
    iptables \
    # iptables-legacy \
    ip6tables \
    iputils \
    kmod \
    libcap-utils \
    libqrencode-tools \
    net-tools \
    openresolv \
    wireguard-tools && \
  echo "wireguard" >> /etc/modules && \
  # cd /sbin && \
  # for i in ! !-save !-restore; do \
  #   rm -rf iptables$(echo "${i}" | cut -c2-) && \
  #   rm -rf ip6tables$(echo "${i}" | cut -c2-) && \
  #   ln -s iptables-legacy$(echo "${i}" | cut -c2-) iptables$(echo "${i}" | cut -c2-) && \
  #   ln -s ip6tables-legacy$(echo "${i}" | cut -c2-) ip6tables$(echo "${i}" | cut -c2-); \
  # done && \
  sed -i 's|\[\[ $proto == -4 \]\] && cmd sysctl -q net\.ipv4\.conf\.all\.src_valid_mark=1|[[ $proto == -4 ]] \&\& [[ $(sysctl -n net.ipv4.conf.all.src_valid_mark) != 1 ]] \&\& cmd sysctl -q net.ipv4.conf.all.src_valid_mark=1|' /usr/bin/wg-quick && \
  rm -rf /etc/wireguard && \
  ln -s /config/wg_confs /etc/wireguard && \
  printf "Linuxserver.io Build-date: ${BUILD_DATE}" > /build_version && \
  echo "**** clean up ****" && \
  rm -rf \
    /tmp/* && \
  # add nftables
  apk add --no-cache nftables && \
  # disable coredns forever
  sed -i "s/if netstat/USE_COREDNS=\"false\"\nif netstat/" /etc/s6-overlay/s6-rc.d/svc-coredns/run
