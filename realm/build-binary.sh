#!/bin/bash
set -ex

cd $(dirname $0)

if [[ -z $1 ]]; then
  echo "Usage: $0 <VERSION>"
  exit 1
fi
VERSION=$1
# TINI_VERSION=0.19.0

# Install cross if not installed
if [[ ! -x $(which cross) ]]; then
  cargo install cross --git https://github.com/cross-rs/cross
fi

# get source code
if [[ -d realm-src ]]; then
  cd realm-src
  git fetch --unshallow || true
  git fetch --all
  git reset --hard v$VERSION
  patch -p1 < ../01.dns-retry-once.patch
  patch -p1 < ../02.mptcp.patch
  patch -p1 < ../03.timeout_float.patch
  patch -p1 < ../04.tcp_conn_retry.patch
  patch -p1 < ../05.graceful_reload.patch
else
  git clone https://github.com/zhboner/realm -b v$VERSION --depth=1 realm-src
  cd realm-src
  patch -p1 < ../01.dns-retry-once.patch
  patch -p1 < ../02.mptcp.patch
  patch -p1 < ../03.timeout_float.patch
  patch -p1 < ../04.tcp_conn_retry.patch
  patch -p1 < ../05.graceful_reload.patch
fi

cp ../Cross.toml Cross.toml

TARGET=(
  x86_64
  aarch64
)

# https://rust-lang.github.io/packed_simd/perf-guide/target-feature/rustflags.html
# build for x64-v3 and armv8-a
# export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUSTFLAGS='-C target-cpu=x86-64-v3'
# export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_RUSTFLAGS='-C target-cpu=cortex-a53'
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUSTFLAGS='-C target-feature=+crt-static'
export CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_RUSTFLAGS='-C target-feature=+crt-static'

for short_target in ${TARGET[@]}; do
  case "$short_target" in
    "x86_64")
      arch=amd64 ;;
    "aarch64")
      arch=arm64 ;;
    *)
      echo "Unknown target: $short_target"
      exit 1 ;;
  esac

  target="${short_target}-unknown-linux-gnu"
  cross build --release --target $target --features 'mi-malloc'

  mkdir -p ../dist/$arch
  cp target/$target/release/realm ../dist/$arch/realm
  # wget https://github.com/krallin/tini/releases/download/v$TINI_VERSION/tini-$arch \
  #   -O ../dist/$arch/tini
  # chmod +x ../dist/$arch/tini
done
