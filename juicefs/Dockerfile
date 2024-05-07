# https://github.com/juicedata/juicefs/releases
FROM alpine
ARG VERSION=1.1.1
ARG TARGETOS=linux
ARG TARGETARCH=amd64

RUN apk add --no-cache fuse bash && \
    mkdir temp && \
    wget https://github.com/juicedata/juicefs/releases/download/v${VERSION}/juicefs-${VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz -O temp/j.tar.gz && \
    tar xf temp/j.tar.gz -C temp && \
    mv temp/juicefs /usr/local/bin/juicefs && \
    rm -rf temp

CMD ["juicefs", "version"]
