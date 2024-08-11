FROM cgr.dev/chainguard/cc-dynamic
ARG TARGETOS
ARG TARGETARCH

COPY --chmod=755 dist/${TARGETARCH} /usr/local/bin/
CMD ["ssserver", "--version"]
