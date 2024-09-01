# https://github.com/SagerNet/sing-box/releases
FROM alpine
ARG VERSION
ARG TARGETOS
ARG TARGETARCH
# https://github.com/SagerNet/sing-box/blob/dev-next/Dockerfile
RUN set -ex && \
    apk add --no-cache ca-certificates-bundle && \
    mkdir temp && \
    wget https://github.com/SagerNet/sing-box/releases/download/v${VERSION}/sing-box-${VERSION}-${TARGETOS}-amd64v3.tar.gz \
        -O temp/bin.tar.gz && \
    tar xf temp/bin.tar.gz -C temp && \
    mv temp/sing-box-${VERSION}-${TARGETOS}-amd64v3/sing-box /usr/local/bin/sing-box && \
    rm -rf temp

ENTRYPOINT ["sing-box"]
