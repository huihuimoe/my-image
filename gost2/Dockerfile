# https://github.com/ginuerzh/gost/releases

FROM --platform=$BUILDPLATFORM docker.io/library/golang:alpine AS builder
ARG VERSION
ARG TARGETOS
ARG TARGETARCH
COPY patchs /patchs
RUN set -ex && \
    apk add --no-cache git git-lfs make patch && \
    git clone --depth=1 https://github.com/ginuerzh/gost -b v${VERSION} && \
    cd gost && \
    git apply /patchs/*.patch && \
    TARGETARCH2=$TARGETARCH && \
    if [ "$TARGETOS" = "linux" ] && [ "$TARGETARCH" = "amd64" ]; then TARGETARCH2=amd64v3; fi && \
    if [ "$TARGETOS" = "linux" ] && [ "$TARGETARCH" = "arm64" ]; then TARGETARCH2=armv8; fi && \
    TARGET=$TARGETOS-$TARGETARCH2 && \
    make $TARGET && \
    mv bin/gost-$TARGET gost

FROM docker.io/library/alpine
COPY --from=builder /go/gost/gost /usr/local/bin/
ENTRYPOINT ["gost"]
