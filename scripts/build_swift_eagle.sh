#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SWIFT_DIR=${SWIFT_DIR:-"$ROOT/dependencies/SWIFT"}
JOBS=${JOBS:-4}
CONFIGURE_FLAGS=(
  --with-subgrid=EAGLE-XL
  --with-hydro=sphenix
  --with-kernel=wendland-C2
  --enable-ipo
  --disable-mpi
)
# Add site-specific configure options with SWIFT_CONFIGURE_FLAGS if needed.
read -r -a EXTRA_CONFIGURE_FLAGS <<< "${SWIFT_CONFIGURE_FLAGS:-}"

[[ -x "$SWIFT_DIR/autogen.sh" ]] || {
  echo "Missing SWIFT submodule. Run: git submodule update --init --recursive" >&2
  exit 1
}

# Homebrew libraries are not on SWIFT's default search path on macOS.
if [[ $(uname -s) == Darwin ]]; then
  CONFIGURE_FLAGS+=(
    --disable-hand-vec
    --enable-compiler-warnings
    "--with-fftw=$(brew --prefix fftw)"
    "--with-gsl=$(brew --prefix gsl)"
    "--with-hdf5=$(brew --prefix hdf5@1.10)/bin/h5cc"
    "--with-tbbmalloc=$(brew --prefix tbb)/lib"
  )
else
  CONFIGURE_FLAGS+=(--with-tbbmalloc)
fi

(
  cd "$SWIFT_DIR"
  # Generate configure, select EAGLE-XL above, then compile with JOBS workers.
  ./autogen.sh
  ./configure "${CONFIGURE_FLAGS[@]}" "${EXTRA_CONFIGURE_FLAGS[@]}"
  make -j "$JOBS"
)

echo "SWIFT-EAGLE built at $SWIFT_DIR/swift"
