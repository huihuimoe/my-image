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

## [sing-box](https://github.com/SagerNet/sing-box)

- Package: <https://github.com/users/huihuimoe/packages/container/package/my-image%2Fsing-box>
- Size: ~40MB(Base on Alpine)
- Run: `podman run --rm ghcr.io/huihuimoe/my-image/sing-box:v1.10.6 --help`
- Modification:
  1. Provide linux-amd64v3 OCI image due the official do not provide since v1.9.7 .

## [linuxserver-wireguard](https://github.com/linuxserver/docker-wireguard)

- Package: <https://github.com/huihuimoe/my-image/pkgs/container/my-image%2Fwireguard>
- Size: ~38MB(Base on [Alpine modified by linuxserver](https://github.com/linuxserver/docker-baseimage-alpine))
- Run: See [linuxserver's docs](https://github.com/linuxserver/docker-wireguard?tab=readme-ov-file#usage) `podman pull ghcr.io/huihuimoe/my-image/wireguard`
- Modification:
  1. Remove useless coredns server. (-60MB)
  2. Use iptables-nft instead of iptables-legacy.
  3. Add nftables package. So that more modern `nft` can be used.
