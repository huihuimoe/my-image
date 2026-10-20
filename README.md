# my-image

Some examples to build Docker images.

TLDR:

## [GOST V2](https://v2.gost.run/en/)

- Package: <https://github.com/huihuimoe/my-image/pkgs/container/my-image%2Fgost2>
- Size: 20-30MB(Base on Alpine)
- Run: `podman run --rm ghcr.io/huihuimoe/my-image/gost2:2.12.0 --help`
- Modification:
  1. Add MPTCP server/client support(via environment variable).
  2. Add smux parameter support(via environment variable).
  3. Can specify sni when using tls.
  4. Can use wintun.dll on Windows to improve tun performance.

## [juicefs](https://github.com/juicedata/juicefs)

- Package:
  - full: <https://github.com/users/huihuimoe/packages/container/package/my-image%2Fjuicefs>
  - lite: <https://github.com/users/huihuimoe/packages/container/package/my-image%2Fjuicefs-lite>
- Size:
  - full: ~100MB(Base on Chainguard)
  - lite: ~50MB(Base on Chainguard)
  - official image([docker.io/juicedata/mount](https://hub.docker.com/r/juicedata/mount)): ~500MB
- Run:

```bash
podman run \
  --device /dev/fuse \
  --cap-add SYS_ADMIN \
  --security-opt apparmor:unconfined \
  --volume SOMEDIR:CONTAINER_DIR \
  ghcr.io/huihuimoe/my-image/juicefs-lite:1.2.2 \
  juicefs mount \
  sqlite:///juicefs.db \
  /mnt/juicefs
```

- Modification:
  1. Reduce the size of the image to protect your hard drive.
  2. Add [juicefs-lite](https://github.com/juicedata/juicefs/blob/main/Makefile#L30) version, which only contains local-db(like sqlite,badgerdb) metadata engine.

## nginx

experimental image of [different ssl library support on nginx](https://github.com/huihuimoe/my-scripts).

- Size: ~30MB(Base on GoogleContainerTools/distroless/debian12)
- Package:
  - awslc: `ghcr.io/huihuimoe/my-image/nginx:1.27.4-awslc`
  - boringssl: `ghcr.io/huihuimoe/my-image/nginx:1.27.4-boringssl`
  - openssl: `ghcr.io/huihuimoe/my-image/nginx:1.27.4-openssl`

## [realm](https://github.com/zhboner/realm)

- Package: <https://github.com/users/huihuimoe/packages/container/package/my-image%2Frealm>
- Size: 8MB(Base on Chainguard)
- Run: `podman run --rm ghcr.io/huihuimoe/my-image/realm:v2.7.0 --help`
- Modification:
  1. Auto retry dns resolve *once* when failed(Timeouts often occur in some recursive DNS service).
  2. Add MPTCP server/client support(via `--listen-mptcp` and `--conn-mptcp`).
  3. UDP/TCP/ProxyProtocol timeout can be float number.
  4. Can retry tcp connect when failed or timeout.
  5. Support reload config file when receive SIGHUP signal.
  6. Would exit 1 when failed to start(like port has been used).
  7. When listen on unspecified address, the udp sockets will now listen on all available IP addresses to support connections from multiple source IPs.

## [sing-box](https://github.com/SagerNet/sing-box)

- Package: <https://github.com/users/huihuimoe/packages/container/package/my-image%2Fsing-box>
- Size: ~40MB(Base on Alpine)
- Run: `podman run --rm ghcr.io/huihuimoe/my-image/sing-box:v1.10.6 --help`
- Modification:
  1. Provide linux-amd64v3 OCI image due the official do not provide since v1.9.7 .

## [wireguard](https://github.com/huihuimoe/my-image/tree/master/wireguard)

Small self-maintained WireGuard image built on Alpine with `wg-quick` and
`nftables`. It only manages configs you provide: there is no env-driven config,
peer, or key generation. The container starts existing `/config/wg_confs/*.conf`
files and stays idle if there are none. Host networking is the primary mode.

- Package: <https://github.com/huihuimoe/my-image/pkgs/container/my-image%2Fwireguard>
- Size: ~7MB (Alpine)
- Run (host network, recommended):

```bash
podman run -d --name wireguard \
  --network host \
  --cap-add NET_ADMIN \
  -v ./wireguard:/config \
  ghcr.io/huihuimoe/my-image/wireguard
```

- Run (bridge network):

```bash
podman run -d --name wireguard \
  --cap-add NET_ADMIN \
  -p 51820:51820/udp \
  -v ./wireguard:/config \
  ghcr.io/huihuimoe/my-image/wireguard
```

Put wg-quick configs in `./wireguard/wg_confs/` (for example `wg0.conf`).
Optionally put nftables rules in `./wireguard/nftables.conf`. With no configs the
container idles; add one and run `docker exec wireguard wgctl reload`.

For forwarding/NAT, enable `net.ipv4.ip_forward=1` explicitly on the host (with
host networking) or with `--sysctl` (bridge network only); the image never changes
it.

### Files

```text
/config/
  wg_confs/*.conf      user-supplied wg-quick configs
  nftables.conf        optional table body for inet wgctl
  peers/<name>/        peer add output (conf, keys, QR text)
  .wgctl-resolv.conf   DNS backup used when a config has a DNS line
  .wgctl/applied/      copies of the configs last applied to the running interfaces
```

`/etc/wireguard` is a symlink to `/config/wg_confs`.

### `wgctl`

```bash
docker exec wireguard wgctl up                 # start missing configs
docker exec wireguard wgctl reload             # apply changed/new/removed configs
docker exec wireguard wgctl reload wg0         # one interface
docker exec wireguard wgctl reload --force     # restart all
docker exec wireguard wgctl down               # stop all managed + remove nft table
docker exec wireguard wgctl status
docker kill -s HUP wireguard                   # runs wgctl reload
```

- On start the container runs `wgctl reload`, so it applies whatever changed in
  `/config` while it was stopped.
- On stop the container leaves interfaces, routes, and the nft table in place by
  default, so restarting or updating the image does not interrupt traffic (with
  `--net host`). Set `WG_DOWN_ON_STOP=1` to run `wgctl down` on stop instead.
  Before removing the container for good, run `wgctl down` in it. With a bridge
  network, everything goes away with the container's network namespace anyway.

- `up` starts configs that are not running and leaves running interfaces alone.
- `reload` starts new configs, applies configs whose content changed, stops
  interfaces whose config disappeared, then applies nftables. Unchanged
  interfaces are untouched.
- A change limited to `[Peer]` sections is applied with `wg syncconf` without a
  restart, as long as the added or removed `AllowedIPs` are covered by the
  interface's own address route (or `Table = off`). Any other change restarts the
  interface (down/up); if the new config fails to start, the previous one is
  restored.
- Interfaces started by `wgctl` are marked with the link alias
  `wgctl:<WG_NFT_TABLE>`. The mark lives on the interface, so after a crash or a
  recreated container (with `--net host`), the new container recognizes its own
  interfaces and stops them with the config they were started from.
- `--force` restarts, or takes over a WireGuard interface without this mark (it is
  deleted with `ip link del`, so its PostDown does not run). Without it, `wgctl`
  refuses to touch an existing interface it does not manage. It never deletes a
  non-WireGuard link with the same name.
- The nftables file is validated before any interface is touched; an invalid file
  aborts `up`/`reload`. WireGuard configs are parsed with `wg-quick strip`, and
  deeper errors (keys, addresses, routes) are reported when `wg-quick` starts them.
  A failing config is skipped and the others are still applied. The container
  keeps running so the config can be fixed via CLI.
- `SaveConfig = true` is not supported; such configs are skipped.

### `wg-helper` (optional)

`wg-helper` adds peer management on top of the config files. It does not
reload or restart WireGuard itself. After changing a server config, review the
files and run `wgctl reload <server>` explicitly.

Peer commands:

```bash
docker exec wireguard wg-helper peer add alice \
  --endpoint vpn.example.com:51820 \
  --dns 1.1.1.1

docker exec wireguard wg-helper peer qr alice
docker exec wireguard wg-helper peer list
docker exec wireguard wg-helper peer remove alice --purge

# review, then apply
docker exec wireguard wgctl reload wg0
```

- `peer add` requires a server config (`--server`, default `wg0`) with a `/24`
  IPv4 `Address` and a `PrivateKey`. It allocates the first free `.2`-`.254`,
  generates a private/public key and PSK, writes
  `/config/peers/<name>/<name>.conf` plus a terminal QR code
  (`<name>.qr`, view it with `cat`), and appends a marked `[Peer]`
  block to the server config.
- Options: `--allowed-ips` (default `0.0.0.0/0, ::/0`), `--dns`, `--keepalive`,
  and `--server-allowed-ips` for extra server-side routes.
- `peer remove` removes the marked block from the server config and keeps peer
  files unless `--purge` is given.
- `peer qr <name|config>` prints the QR code for the current config to the
  terminal. It also accepts any arbitrary WireGuard config file.

### nftables

`/config/nftables.conf` is optional. It contains the **body** of `table inet
wgctl` (chains, maps, sets, rules), not a complete `table` declaration. `wgctl`
wraps it, validates it with `nft -c -f`, and replaces the table on `up`/`reload`.
Removing the file and running `reload` removes the table; `wgctl down` also removes
it. Override the table name with `WG_NFT_TABLE`.

Example:

```nft
chain postrouting {
  type nat hook postrouting priority srcnat; policy accept;
  ip saddr 10.13.13.0/24 oifname "eth0" masquerade
}
```

An `accept` in `inet wgctl` cannot override a `drop` in another
table: nftables evaluates every base chain on the hook. If the host firewall drops
forwarded traffic (Docker's iptables backend sets the `FORWARD` policy to `DROP`;
firewalld or your own tables may too), allow WireGuard forwarding in that
firewall. Docker's nftables backend only filters traffic to its own bridge
networks; reaching those from WireGuard peers needs published ports or Docker's
`--bridge-accept-fwmark`.

### Host networking safety

With `--net host`, `wg-quick` and nftables operate in the host network namespace.
The container logs every route command and the nft table it applies.

- Choose config addresses/subnets that do not overlap existing host routes.
- The main default route is never deleted or replaced. A config with
  `AllowedIPs = 0.0.0.0/0` or `::/0` adds a policy-routing default; `wgctl` logs a
  warning before starting it.
- `wgctl` refuses to write `net.ipv4.conf.all.src_valid_mark` from inside the
  container (the `/usr/local/bin/sysctl` guard). Set it on the host if
  default-route traffic needs it.
- IPv4 forwarding is never changed. Set `net.ipv4.ip_forward=1` on the host.
- Docker and Podman reject `--sysctl net.*` with host networking; it only works
  with a bridge network.
- DNS changes are confined to the container's `/etc/resolv.conf`; do not bind-mount
  the host's file if you do not want it modified.
- nftables changes are limited to `inet wgctl` (or `WG_NFT_TABLE`), but they apply
  to the host namespace when `--net host` is used. Use unique table names for
  multiple host-network instances.

The kernel must provide WireGuard. This image does not include `kmod` or compile
kernel modules; load `wireguard` on the host before starting the container.
