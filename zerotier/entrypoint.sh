#!/bin/sh
set -eu

if [ $# -eq 0 ]; then
  set -- zerotier-one -U
elif [ "${1#-}" != "$1" ]; then
  set -- zerotier-one "$@"
fi

DEFAULT_PRIMARY_PORT=9993
DEFAULT_PORT_MAPPING_ENABLED=true
DEFAULT_ALLOW_TCP_FALLBACK_RELAY=true
DEFAULT_DIRECT_DATA_ONLY=false

MANAGEMENT_NETWORKS=""
if [ -n "${ZT_ALLOW_MANAGEMENT_FROM:-}" ]; then
  OLD_IFS="$IFS"
  IFS=','
  for NETWORK in $ZT_ALLOW_MANAGEMENT_FROM; do
    [ -n "$NETWORK" ] || continue
    if [ -n "$MANAGEMENT_NETWORKS" ]; then
      MANAGEMENT_NETWORKS="${MANAGEMENT_NETWORKS},"
    fi
    MANAGEMENT_NETWORKS="${MANAGEMENT_NETWORKS}\"${NETWORK}\""
  done
  IFS="$OLD_IFS"
fi

if [ "${ZT_OVERRIDE_LOCAL_CONF:-false}" = "true" ] || [ ! -f /var/lib/zerotier-one/local.conf ]; then
  printf '{\n  "settings": {\n    "primaryPort": %s,\n    "portMappingEnabled": %s,\n    "softwareUpdate": "disable",\n    "allowManagementFrom": [%s],\n    "allowTcpFallbackRelay": %s,\n    "directDataOnly": %s\n  }\n}\n' \
    "${ZT_PRIMARY_PORT:-$DEFAULT_PRIMARY_PORT}" \
    "${ZT_PORT_MAPPING_ENABLED:-$DEFAULT_PORT_MAPPING_ENABLED}" \
    "${MANAGEMENT_NETWORKS}" \
    "${ZT_ALLOW_TCP_FALLBACK_RELAY:-$DEFAULT_ALLOW_TCP_FALLBACK_RELAY}" \
    "${ZT_DIRECT_DATA_ONLY:-$DEFAULT_DIRECT_DATA_ONLY}" \
    > /var/lib/zerotier-one/local.conf
fi

exec "$@"
