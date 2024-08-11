#!/bin/bash
set -e

cd $(dirname $0)

# if CI
if [[ -n $CI ]]; then
  rustup toolchain install nightly
  rustup default nightly
fi

if [[ -z $1 || -z $2 ]]; then
  echo "Usage: $0 <SS_VERSION> <KAMINARI_VERSION>"
  exit 1
fi
SS_VERSION=$1
KAMINARI_VERSION=$2

# Install cross if not installed
if [[ ! -x $(which cross) ]]; then
  cargo install cross --git https://github.com/cross-rs/cross
fi

TARGET=(
  x86_64
  aarch64
)

# shadowsocks-rust
if [[ -d shadowsocks-rust-src ]]; then
  rm -rf shadowsocks-rust-src
fi
git clone https://github.com/shadowsocks/shadowsocks-rust -b v$SS_VERSION --depth=1 shadowsocks-rust-src
pushd shadowsocks-rust-src
for short_target in ${TARGET[@]}; do
  target="${short_target}-unknown-linux-gnu"
  cross build --target $target \
              --no-default-features \
              --features 'basic, mimalloc, local-tunnel, aead-cipher-2022, local-online-config' \
              --release
  if [[ $short_target == "x86_64" ]]; then
    arch=amd64
  elif [[ $short_target == "aarch64" ]]; then
    arch=arm64
  fi
  mkdir -p ../dist/$arch
  cp target/$target/release/{sslocal,ssserver} ../dist/$arch
done
popd

# kaminari
if [[ -d kaminari-src ]]; then
  rm -rf kaminari-src
fi
git clone https://github.com/zephyrchien/kaminari -b v$KAMINARI_VERSION --depth=1 kaminari-src
pushd kaminari-src
cargo update --breaking -Z unstable-options \
  kaminari realm_io webpki-roots
cargo update
# fix impl_trait_in_assoc_type
sed -i '1s|^|#![feature(impl_trait_in_assoc_type)]\n|' kaminari/src/lib.rs
# fix breaking realm_io
sed -i 's|-> std::io::Result<()>|-> std::io::Result<(u64, u64)>|' \
  cmd/src/client.rs cmd/src/server.rs
for short_target in ${TARGET[@]}; do
  target="${short_target}-unknown-linux-gnu"
  cross build --target $target \
              -p kaminari-cmd \
              --release
  if [[ $short_target == "x86_64" ]]; then
    arch=amd64
  elif [[ $short_target == "aarch64" ]]; then
    arch=arm64
  fi
  mkdir -p ../dist/$arch
  cp target/$target/release/{kaminaric,kaminaris} ../dist/$arch

done
popd
