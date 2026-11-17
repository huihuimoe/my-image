# ZeroTier One

`ghcr.io/huihuimoe/my-image/zerotier:latest` runs ZeroTier One on Wolfi with the
local [direct-only data plane patches](patches/README.md). It includes
`zerotier-one`, `zerotier-cli`, `zerotier-idtool`, and the embedded network
controller (`ZT_NONFREE=1`, without SSO).

Platforms: `linux/amd64` and `linux/arm64`.

## Run

```sh
docker run -d --name zerotier \
  --restart=unless-stopped \
  --network host \
  --cap-add NET_ADMIN \
  --device /dev/net/tun \
  -v /var/lib/zerotier-one:/var/lib/zerotier-one \
  ghcr.io/huihuimoe/my-image/zerotier:latest

docker exec zerotier zerotier-cli info
docker exec zerotier zerotier-cli join <network-id>
```

## Configuration

When `/var/lib/zerotier-one/local.conf` does not exist (or when
`ZT_OVERRIDE_LOCAL_CONF=true`), `/entrypoint.sh` generates it from environment
variables:

| Variable | Default | Description |
| --- | --- | --- |
| `ZT_PRIMARY_PORT` | `9993` | Primary UDP/TCP port (`settings.primaryPort`) |
| `ZT_PORT_MAPPING_ENABLED` | `true` | UPnP / NAT-PMP port mapping (`settings.portMappingEnabled`) |
| `ZT_ALLOW_MANAGEMENT_FROM` | `""` | Comma-separated CIDRs allowed for management API (`settings.allowManagementFrom`) |
| `ZT_ALLOW_TCP_FALLBACK_RELAY` | `true` | Allow TCP fallback relay (`settings.allowTcpFallbackRelay`) |
| `ZT_DIRECT_DATA_ONLY` | `false` | Restrict data-plane verbs to direct peer-to-peer paths (`settings.directDataOnly`) |
| `ZT_OVERRIDE_LOCAL_CONF` | `false` | Overwrite `/var/lib/zerotier-one/local.conf` on container start |

See [patches/README.md](patches/README.md) for details on `directDataOnly`.

## Local build

From the repository root:

```sh
docker buildx build --platform linux/amd64 --load \
  --build-arg ZT_VERSION=1.16.2 -t zerotier:local zerotier
```

Use `--platform linux/arm64` to cross-compile the arm64 image.
