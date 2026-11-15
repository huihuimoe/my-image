#!/bin/sh
set -e

config_file=${CONFIG_FILE:-/etc/ndppd.conf}

if [ -n "${CONFIG_FILE:-}" ]; then
  echo "Using configuration file: $CONFIG_FILE"
elif [ -n "${IPV6_SUBNET:-}" ]; then
  PROXY_IFACE=${PROXY_IFACE:-eth0}
  FWD_IFACE=${FWD_IFACE:-docker0}
  echo "Proxy interface: $PROXY_IFACE"
  echo "Forward interface: $FWD_IFACE"
  echo "IPv6 subnet: $IPV6_SUBNET"

  cat > "$config_file" <<EOF
proxy $PROXY_IFACE {
  router yes
  rule $IPV6_SUBNET {
    iface $FWD_IFACE
  }
}
EOF
elif [ -n "${CONFIG:-}" ]; then
  echo "Using configuration:"
  printf '%s\n' "$CONFIG"
  printf '%s\n' "$CONFIG" > "$config_file"
else
  echo "Using configuration file: $config_file"
fi

exec /usr/local/sbin/ndppd -c "$config_file"
