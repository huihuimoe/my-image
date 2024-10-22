# https://github.com/zhboner/realm/releases
FROM cgr.dev/chainguard/cc-dynamic
ARG TARGETOS
ARG TARGETARCH

COPY dist/${TARGETARCH}/ /usr/local/bin

# change user from 65532(nonroot) to 0(root)
# USER root
ENTRYPOINT [ "tini", "--", "realm" ]
CMD ["-v"]
