# BIRD 3

`ghcr.io/huihuimoe/my-image/bird` contains the official Wolfi `bird` APK and its
runtime dependencies. The Wolfi package enables libssh and includes `birdc` and
`birdcl`. [apko](https://github.com/chainguard-dev/apko) assembles the image;
this repository does not compile BIRD from source. No shell or iproute2 is added.

Supported platforms: `linux/amd64`, `linux/arm64`.

## Run

Mount your configuration at `/etc/bird/bird.conf`:

```sh
docker run -d --name bird \
  --network host \
  --cap-add NET_ADMIN \
  --mount "type=bind,src=$PWD/bird.conf,dst=/etc/bird/bird.conf,readonly" \
  ghcr.io/huihuimoe/my-image/bird:3

docker exec bird /usr/bin/birdc show status
docker exec bird /usr/bin/birdc show protocols
docker exec bird /usr/bin/birdc configure
```

The image runs as root. Host networking lets BIRD use the host's interfaces and
listen on TCP port 179. Add `NET_ADMIN` when BIRD must modify kernel routes.
With host networking, those route changes affect the host. Protocols that use raw
sockets may also need `NET_RAW` if your runtime does not grant it by default.

The default command is `/usr/bin/bird -f -R -c /etc/bird/bird.conf`. `-R` enables
graceful restart recovery. Arguments supplied after the image name replace these
default arguments. Use `--entrypoint /usr/bin/birdc` to override the executable.
The control socket is `/run/bird.ctl`.

The image preserves Wolfi's example at `/etc/bird.conf` and links
`/etc/bird/bird.conf` to it. You can also mount a whole configuration directory at
`/etc/bird`. Configure `log stderr all;` for container logs: the packaged sample
uses syslog, and the image does not run a syslog daemon.

[example/bird.conf](example/bird.conf) provides a minimal configuration with
stderr logging. It keeps a static route inside BIRD without exporting kernel
routes. Replace its router ID and protocols for your deployment.

## Releases

The [BIRD workflow](../.github/workflows/bird.yaml) runs daily at 04:23 UTC and
can also be started manually. It does not run on pull requests or pushes.

1. Read the official Wolfi indexes for `x86_64` and `aarch64`.
2. Select the newest stable BIRD `3.x.y-rN` package available on both architectures.
3. Check the package's tags through the GitHub Packages API.
4. If the full package version tag is absent, lock dependencies and publish both
   architectures with apko. Package signatures remain verified by apko.

For example, `3.4.0-r2` publishes tags `3.4.0-r2`, `3.4.0`, `3`, and `latest`.
The full tag tracks the APK revision; the other tags move to the latest release.
A new BIRD version or Wolfi revision triggers a release. Changes limited to other
dependencies do not trigger one. Use the manual workflow's `force` input to
rebuild the current package with updated dependencies.

The workflow uses `GITHUB_TOKEN` with `packages: write`; no additional secret is
required. The package must allow this repository's Actions to access it. After
the first release, set package visibility in GHCR if anonymous pulls are needed.
Dependency locks, resolved image configuration, SBOMs, and published digest
references are saved as workflow artifacts.

## Local assembly

From the repository root, with Docker and Python 3 installed:

```sh
# Resolves the latest common BIRD 3 package and writes bird.resolved.yaml.
python3 bird/check-version.py
mkdir -p bird-output/sboms
docker run --rm \
  --mount "type=bind,src=$PWD,dst=/work" \
  cgr.dev/chainguard/apko@sha256:d6c63be291b6c6a8fe37cb9b5d656e84db4f209983e38f1f18d2c233b9f60e04 \
  build bird.resolved.yaml bird:local bird-output/bird.tar \
  --sbom-path /work/bird-output/sboms
docker load -i bird-output/bird.tar
docker run --rm bird:local-amd64 --version
```

The archive contains `bird:local-amd64` and `bird:local-arm64`. Run the tag that
matches your host, or configure emulation. To assemble the checked-in baseline
instead of detecting a release, use `bird/apko.yaml` as the input configuration.

Sources: [Wolfi package recipe](https://github.com/wolfi-dev/os/blob/main/bird.yaml),
[BIRD releases](https://bird.nic.cz/get-bird/),
[reference image](https://github.com/akafeng/docker-bird).
