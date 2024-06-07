# https://github.com/zhboner/realm/releases
FROM alpine
ARG VERSION=2.6.0
ARG TARGETOS=linux
ARG TARGETARCH=amd64

# only support linux and amd64/arm64 now

RUN apk add --no-cache ca-certificates-bundle && \
    mkdir temp && \
    if [ "$TARGETARCH" = "amd64" ]; then ARCH2="x86_64"; else ARCH2="aarch64"; fi && \
    wget https://github.com/zhboner/realm/releases/download/v${VERSION}/realm-${ARCH2}-unknown-${TARGETOS}-musl.tar.gz -O temp/bin.tar.gz && \
    tar xf temp/bin.tar.gz -C temp && \
    mv temp/realm /usr/local/bin/realm && \
    rm -rf temp

ENTRYPOINT [ "realm" ]
CMD ["-v"]
