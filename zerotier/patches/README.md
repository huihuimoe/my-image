# Direct-Only Data Plane Patchset (ZeroTier 1.16.2)

This patchset adds a node-level `directDataOnly` transport policy to ZeroTier `1.16.2` (`fc5c3ec22090b5b2a0f274e863651fe9ca489bf4`). When enabled, virtual network data traffic is restricted to direct peer-to-peer paths while control-plane traffic, peer discovery, and NAT traversal remain operational through upstream roots/relays.

## Patch List

1. `0001-Add-direct-only-data-plane-policy.patch`
   Enforces direct-only routing and reception for data verbs (`FRAME`, `EXT_FRAME`, `MULTICAST_FRAME`, `USER_MESSAGE`), triggers direct-path rendezvous probing via relayed `HELLO` when no direct path is active, and disables designated multicast replication for `directDataOnly` nodes.
2. `0002-Configure-direct-only-data-plane-on-Linux.patch`
   Reads `settings.directDataOnly` from `local.conf` (with hot-reload support), overrides `allowTcpFallbackRelay` and `forceTcpRelay`, closes active or pending outgoing TCP fallback tunnels when enabled, and documents the setting.

## Building

From a clean checkout of ZeroTier `1.16.2`:

```sh
git checkout 1.16.2
git apply 0001-Add-direct-only-data-plane-policy.patch \
  0002-Configure-direct-only-data-plane-on-Linux.patch
make -j"$(nproc)"
```

Adjust `make` flags to match your target build environment.

## Configuration

Enable `settings.directDataOnly` in each participating node's `local.conf`:

```json
{
  "settings": {
    "directDataOnly": true
  }
}
```

`directDataOnly` defaults to `false`, applies to all networks joined by the node, and supports runtime reload via `local.conf`.

### Behavior When Enabled

- **Unicast and multicast data (`FRAME`, `EXT_FRAME`, `MULTICAST_FRAME`, `USER_MESSAGE`)**:
  - Outbound packets are sent only over direct peer paths. If no direct path is available, data packets are dropped (not queued for relay fallback) while `WHOIS` lookup and rate-limited relayed `HELLO` probes continue to trigger upstream `RENDEZVOUS` and UDP hole punching.
  - Inbound data packets are rejected after authentication if the packet head or any reassembled fragment traversed a ZeroTier relay (`hops > 0`).
  - Sender-side multicast replication is used exclusively; the node neither sends multicast frames to a designated `MULTICAST_REPLICATOR` nor replicates multicast frames on behalf of other peers.
- **Control plane**:
  - Identity lookup (`WHOIS`), network configuration, credentials (`NETWORK_CREDENTIALS`), multicast membership (`MULTICAST_LIKE`, `MULTICAST_GATHER`), and path negotiation (`HELLO`, `ECHO`, `RENDEZVOUS`, `PUSH_DIRECT_PATHS`) can still traverse upstream relays.
- **TCP fallback**:
  - TCP fallback relay is disabled and existing outgoing TCP fallback tunnels are closed.
  - `directDataOnly` overrides `forceTcpRelay` and `allowTcpFallbackRelay` (logging a warning if either is explicitly enabled) so UDP sockets remain bound and active. Nodes that can reach upstream roots only over TCP will lose control-plane connectivity when `directDataOnly` is enabled.

Disabling `directDataOnly` restores the behavior configured by `allowTcpFallbackRelay`, `forceTcpRelay`, and bonding policies. Packets already in flight during a policy toggle may complete under the previous policy.

## Limitations and Notes

- `directDataOnly` is a local transport policy, not a cryptographic proof against lower-layer proxies or malicious relays modifying unauthenticated hop counts. Enable it on all participating nodes.
- Ensure `multicastLimit` on the network controller is high enough to cover all intended multicast recipients, since sender-side replication is bounded by `multicastLimit`.
- Unpatched peers using TCP fallback, authorized bridges re-encapsulating multicast frames, or controller `TEE` / `REDIRECT` rules can appear as zero-hop traffic.
- When bootstrapping against a fresh isolated root that does not yet know a node's identity, keep `encryptedHelloEnabled` set to `false` until root connectivity is established.
