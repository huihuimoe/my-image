FROM cgr.dev/chainguard/glibc-dynamic
ARG TARGETOS
ARG TARGETARCH

COPY --chmod=755 dist/${TARGETARCH} /usr/local/bin/
CMD ["ssserver", "--version"]
