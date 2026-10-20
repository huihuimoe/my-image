#!/bin/sh
set -eu

log() { printf '[entrypoint] %s\n' "$*" >&2; }

usage() {
  cat <<'EOF'
Usage: entrypoint.sh [supervise | command...]

  supervise   Apply configs (wgctl reload) and wait for signals (default)
  command...  Execute a command instead (for example: wgctl reload)

Signals:
  TERM/INT    Exit; interfaces keep running unless WG_DOWN_ON_STOP=1
  HUP         Apply changed/new/removed configs (wgctl reload)
EOF
}

if [ "$#" -gt 0 ]; then
  case $1 in
    -h|--help)
      usage
      exit 0
      ;;
    supervise)
      shift
      ;;
    *)
      exec "$@"
      ;;
  esac
fi

child=""

shutdown() {
  trap - TERM INT HUP
  if [ -n "$child" ]; then
    kill "$child" 2>/dev/null || true
  fi
  if [ "${WG_DOWN_ON_STOP:-0}" = 1 ]; then
    /usr/local/bin/wgctl down || true
  fi
  exit 0
}

reload() {
  /usr/local/bin/wgctl reload || log "reload reported errors; keeping current state"
}

trap shutdown TERM INT
trap reload HUP

log "manage WireGuard configs with:"
log "  docker exec -it <container> wgctl reload [iface...]  # apply changed configs"
log "  docker exec -it <container> wgctl up|down|status"
log "  docker exec -it <container> wg-helper peer add|remove|qr|list"
log "configs: /config/wg_confs/*.conf  nft: /config/nftables.conf"

if ! /usr/local/bin/wgctl reload; then
  log "startup reported errors; staying up so the config can be fixed from the CLI"
fi

# Kernel WireGuard has no daemon to supervise. Keep the shell as PID 1 so the
# TERM/HUP traps still run; wait on a background sleep instead of exec'ing it.
sleep infinity &
child=$!
while :; do
  wait "$child" || true
  if kill -0 "$child" 2>/dev/null; then
    continue
  fi
  sleep infinity &
  child=$!
done
