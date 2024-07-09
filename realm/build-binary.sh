#!/bin/bash
set -e

cd $(dirname $0)

if [[ -z $1 ]]; then
  echo "Usage: $0 <VERSION>"
  exit 1
fi
VERSION=$1

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
else
  git clone https://github.com/zhboner/realm -b v$VERSION --depth=1 realm-src
  cd realm-src
fi

cp ../Cross.toml Cross.toml

TARGET=(
  x86_64
  aarch64
)

mkdir -p ../dist

for short_target in ${TARGET[@]}; do
  target="${short_target}-unknown-linux-gnu"
  cross build --release --target $target --features 'jemalloc'

  if [[ $short_target == "x86_64" ]]; then
    cp target/$target/release/realm ../dist/realm-amd64
  elif [[ $short_target == "aarch64" ]]; then
    cp target/$target/release/realm ../dist/realm-arm64
  else
    echo "Unknown target: $short_target"
    exit 1
  fi
done
