#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
MUSIC_DIR=${MUSIC_DIR:-"$ROOT/dependencies/MUSIC2"}
JOBS=${JOBS:-4}

[[ -f "$MUSIC_DIR/CMakeLists.txt" ]] || {
  echo "Missing MUSIC-2 submodule. Run: git submodule update --init --recursive" >&2
  exit 1
}

# MUSIC-2 needs OpenMP, so macOS uses Homebrew GCC instead of Apple Clang.
if [[ $(uname -s) == Darwin ]]; then
  GCC_BIN=$(brew --prefix gcc)/bin
  GCC_CANDIDATES=("$GCC_BIN"/gcc-[0-9]*)
  GXX_CANDIDATES=("$GCC_BIN"/g++-[0-9]*)
  [[ -x ${GCC_CANDIDATES[0]} && -x ${GXX_CANDIDATES[0]} ]] || {
    echo "Missing Homebrew GCC. Run scripts/install_dependencies_macos.sh first." >&2
    exit 1
  }
  export CC="${CC:-${GCC_CANDIDATES[0]}}"
  export CXX="${CXX:-${GXX_CANDIDATES[0]}}"
  export FC="${FC:-$GCC_BIN/gfortran}"
fi

(
  cd "$MUSIC_DIR"
  # Configure an out-of-source release build, then compile in parallel.
  cmake -B build -DCMAKE_BUILD_TYPE=Release
  cmake --build build -j "$JOBS"
)

echo "MUSIC-2 built at $MUSIC_DIR/build/MUSIC"
