#!/usr/bin/env bash
set -euo pipefail

[[ $(uname -s) == Darwin ]] || {
  echo "This script is for macOS." >&2
  exit 1
}

xcode-select -p >/dev/null 2>&1 || {
  echo "Install Apple's command-line tools first: xcode-select --install" >&2
  exit 1
}

command -v brew >/dev/null || {
  echo "Install Homebrew first: https://brew.sh" >&2
  exit 1
}

brew install \
  autoconf \
  automake \
  cmake \
  fftw \
  gcc \
  git \
  gsl \
  hdf5 \
  libtool \
  pkg-config \
  python

echo "Workshop build dependencies installed."
