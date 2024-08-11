# https://github.com/zhboner/realm/releases
FROM cgr.dev/chainguard/cc-dynamic
ARG TARGETOS
ARG TARGETARCH

COPY --chmod=755 dist/realm-${TARGETARCH} /usr/bin/realm

# change user from 65532(nonroot) to 0(root)
# USER root
ENTRYPOINT [ "/usr/bin/realm" ]
CMD ["-v"]
