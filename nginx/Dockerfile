# https://github.com/huihuimoe/my-scripts/releases
FROM debian:bookworm-slim AS builder
ARG TAG=v20240516
ARG VERSION=1.27.0
ARG APP=nginx-huihui
ARG TARGETOS
ARG TARGETARCH

# only support linux and amd64/arm64 now
COPY --from=gcr.io/distroless/base-nossl / /build
RUN apt-get update && \
    apt-get install -y wget && \
    mkdir -p /build && \
    cd /build && \
    mkdir temp_download && \
    chmod 777 temp_download && \
    cd temp_download && \
    apt-get download libgcc-s1 && \
    # if APP contains boringssl, download libstdc++6
    if [ $(echo ${APP} | grep -c boringssl) -eq 1 ]; then apt-get download libstdc++6; fi && \
    mv *.deb /build && \
    cd /build && \
    wget -q https://github.com/huihuimoe/my-scripts/releases/download/${TAG}/${APP}_${VERSION}_${TARGETARCH}.deb && \
    find . -name "*.deb" -exec dpkg -x {} . \; && \
    rm -rf temp_download *.deb usr/share/doc usr/lib/systemd etc/nginx/*.default && \
    sed -i '1s/^/user nonroot nonroot;/' etc/nginx/nginx.conf
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
