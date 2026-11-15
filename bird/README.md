# BIRD 3

`ghcr.io/huihuimoe/my-image/bird:3` runs BIRD 3 on Wolfi with the local
[patches](patches/README.md). It includes `birdc`, `birdcl`, and libssh support.

Platforms: `linux/amd64` (x86-64-v2 or later) and `linux/arm64`.

## Run

Mount your configuration at `/etc/bird/bird.conf`:

```sh
docker run -d --name bird \
  --network host \
  --cap-add NET_ADMIN \
  --cap-add NET_RAW \
  --mount "type=bind,src=$PWD/bird.conf,dst=/etc/bird/bird.conf,readonly" \
  ghcr.io/huihuimoe/my-image/bird:3

docker exec bird birdc show status
```

The container runs as root. With host networking, BIRD can change the host's
routes. Set `log stderr all;` in the configuration to see logs with `docker logs`.
See [example/bird.conf](example/bird.conf) for a minimal configuration.

The default command is `bird -f -R -c /etc/bird/bird.conf`. The control socket
is `/run/bird.ctl`.

## Releases

The [workflow](../.github/workflows/bird.yaml) checks for updates every three
days. It applies the local patches and fails if they do not apply.

To rebuild and republish the latest selected version:

```sh
gh workflow run bird.yaml --ref master -f force=true
```

The workflow updates the version tag, `3`, and `latest`. `force` does not select
a specific BIRD version.

## Local build

From the repository root:

```sh
BIRD_VERSION=$(python3 bird/check-version.py | sed -n 's/^upstream=//p')
docker buildx build --platform linux/amd64 --load \
  --build-arg "BIRD_VERSION=$BIRD_VERSION" -t bird:local bird
```

Use `--platform linux/arm64` to cross-compile the arm64 image.
