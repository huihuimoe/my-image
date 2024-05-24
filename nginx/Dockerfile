# https://github.com/huihuimoe/my-scripts/releases
FROM debian:bookworm-slim as builder
ARG TAG=v20240516
ARG VERSION=1.27.0
ARG APP=nginx-huihui
ARG TARGETOS=linux
ARG TARGETARCH=amd64

# only support linux and amd64/arm64 now
COPY --from=gcr.io/distroless/base-nossl / /build
RUN apt-get update && \
    apt-get install -y wget && \
    mkdir -p /build && \
    cd /build && \
    mkdir temp_download && \
    chmod 777 temp_download && \
    cd temp_download && \
    apt-get download libaudit1 libpam0g libcap-ng0 libgcc-s1 && \
    mv *.deb /build && \
    cd /build && \
    wget -q https://github.com/huihuimoe/my-scripts/releases/download/${TAG}/${APP}_${VERSION}_${TARGETARCH}.deb && \
    find . -name "*.deb" -exec dpkg -x {} . \; && \
    rm -rf temp_download *.deb usr/share/doc usr/lib/systemd etc/nginx/*.default && \
    sed -i '1s/^/user nonroot nonroot;/' etc/nginx/nginx.conf && \
    # @TODO delete it
    sed -i 's/geoip_country/#geoip_country/' etc/nginx/nginx.conf && \
    sed -i 's/geoip_city/#geoip_city/' etc/nginx/nginx.conf && \
    sed -i 's/geoip_org/#geoip_org/' etc/nginx/nginx.conf
    # @TODO add some include or init script

FROM scratch
LABEL maintainer="huihuimoe <github@huihui.contact>"
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    TZ=Asia/Hong_Kong
COPY --from=builder /build /
EXPOSE 80
STOPSIGNAL SIGQUIT
CMD ["nginx", "-g", "daemon off;"]
