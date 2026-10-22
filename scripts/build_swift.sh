#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SWIFT_DIR=${SWIFT_DIR:-"$ROOT/dependencies/SWIFT"}
JOBS=${JOBS:-4}
CONFIGURE_FLAGS=(--enable-ipo --disable-mpi)
read -r -a EXTRA_CONFIGURE_FLAGS <<< "${SWIFT_CONFIGURE_FLAGS:-}"

[[ -x "$SWIFT_DIR/autogen.sh" ]] || {
  echo "Missing SWIFT submodule. Run: git submodule update --init --recursive" >&2
  exit 1
}

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
  ./autogen.sh
  ./configure "${CONFIGURE_FLAGS[@]}" "${EXTRA_CONFIGURE_FLAGS[@]}"
  make -j "$JOBS"
)

"$SWIFT_DIR/swift" --help | grep -q -- '--dump-zoom-geometry'
echo "SWIFT built at $SWIFT_DIR/swift"
