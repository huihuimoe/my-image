# https://github.com/SagerNet/sing-box/releases

FROM docker.io/library/golang:alpine AS builder
ARG VERSION
ARG TARGETOS
ARG TARGETARCH
RUN set -ex && \
    apk add --no-cache git git-lfs make && \
    git clone --depth=1 https://github.com/SagerNet/sing-box -b v${VERSION} && \
    cd sing-box && \
    env GOOS=${TARGETOS} GOARCH=${TARGETARCH} GOAMD64=v3 make build

FROM docker.io/library/alpine
COPY --from=builder /go/sing-box/sing-box /usr/local/bin/
ENTRYPOINT ["sing-box"]
