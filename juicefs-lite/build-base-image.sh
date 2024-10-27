#!/bin/bash
set -ex
cd $(dirname $0)
docker pull cgr.dev/chainguard/apko 
docker run \
  --rm \
  -v ${PWD}:/work \
  -w /work \
  cgr.dev/chainguard/apko \
    build \
    juicefs-base.yaml \
    localhost/juicefs-base:latest \
    juicefs-base.tar

docker load < juicefs-base.tar
docker images
