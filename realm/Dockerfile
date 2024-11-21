# https://github.com/zhboner/realm/releases
# FROM cgr.dev/chainguard/cc-dynamic
# FROM cgr.dev/chainguard/glibc-dynamic
FROM cgr.dev/chainguard/static
ARG TARGETOS
ARG TARGETARCH

COPY dist/${TARGETARCH}/ /usr/local/bin

# change user from 65532(nonroot) to 0(root)
# USER root
# ENTRYPOINT [ "tini", "--", "realm" ]
STOPSIGNAL SIGINT
ENTRYPOINT [ "realm" ]
CMD ["-v"]
