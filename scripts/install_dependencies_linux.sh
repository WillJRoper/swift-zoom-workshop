#!/usr/bin/env bash
set -euo pipefail

[[ $(uname -s) == Linux ]] || {
  echo "This script is for Linux." >&2
  exit 1
}

command -v apt-get >/dev/null || {
  echo "This script supports Debian and Ubuntu systems using apt." >&2
  exit 1
}

SUDO=()
if (( EUID != 0 )); then
  command -v sudo >/dev/null || {
    echo "Run as root or install sudo." >&2
    exit 1
  }
  SUDO=(sudo)
fi

"${SUDO[@]}" apt-get update
"${SUDO[@]}" apt-get install -y \
  autoconf \
  automake \
  build-essential \
  cmake \
  gfortran \
  git \
  libfftw3-dev \
  libgsl-dev \
  libhdf5-dev \
  libtbb-dev \
  libtool \
  pkg-config \
  python3 \
  python3-pip \
  python3-venv

echo "Workshop build dependencies installed."
