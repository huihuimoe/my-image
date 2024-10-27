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
    localhost:5000/juicefs-base:latest \
    juicefs-base.tar

# https://github.com/docker/buildx/issues/301#issuecomment-755164475
docker run -d --name registry --network=host registry:2
docker load < juicefs-base.tar
docker push localhost:5000/juicefs-base:latest-amd64
docker push localhost:5000/juicefs-base:latest-arm64
docker images
