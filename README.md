# SWIFT Zoom Workshop

This repository contains a hands-on introduction to running zoom simulations
with MUSIC-2 and SWIFT. We will make a small set of zoom initial conditions,
choose a SWIFT cell geometry, run the simulation for a fixed number of steps,
and have a look at what came out.

The workshop has three notebooks:

1. `notebooks/01_ics.ipynb` - make and inspect the initial conditions.
2. `notebooks/02_zoom_run.ipynb` - choose the geometry and run SWIFT.
3. `notebooks/03_zoom_analysis.ipynb` - load the snapshots and make images.

The example uses the Lagrangian region from TESSERA zoom `P00000/R0000`. We
reduce its finest level from 13 to 10 so that it remains a teaching run rather
than a production resimulation.

## Getting started

Clone the workshop and its MUSIC-2 and SWIFT dependencies:

```bash
git clone --recurse-submodules <workshop-repository-url>
cd SWIFTZoomWorkshop
```

If you already cloned without the dependencies, fetch them with:

```bash
git submodule update --init --recursive
```

SWIFT is pinned from the `zoom-swiftcon` branch in `dependencies/SWIFT`.
MUSIC-2 is in `dependencies/MUSIC2`.

Install the native build dependencies on Debian/Ubuntu Linux with:

```bash
scripts/install_dependencies_linux.sh
```

On macOS, install Apple's command-line tools and Homebrew first, then run:

```bash
scripts/install_dependencies_macos.sh
```

These install C, C++, and Fortran compilers plus CMake, autotools, HDF5, FFTW,
GSL, pkg-config, Git, and Python. The macOS script installs GNU GCC because
MUSIC-2 requires OpenMP.

Create a Python environment and start Jupyter:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
jupyter lab
```

Then open `notebooks/01_ics.ipynb` and work through the notebooks in order.

## MUSIC-2 and SWIFT

The notebooks use these scripts to build the required versions:

```bash
scripts/build_music2.sh
scripts/build_swift.sh
```

The build scripts use the bundled Git submodules. MUSIC-2 needs CMake, Fortran,
OpenMP, FFTW3, GSL, and HDF5. SWIFT needs autotools, FFTW3, GSL, and HDF5.
Set MUSIC-2's runtime thread count with `NumThreads` under `[execution]` in
`configs/music.conf`.

We will provide `data/zoom_ics.hdf5` before the workshop. This lets you move on
to the SWIFT notebooks if MUSIC-2 cannot be built on your machine.

## Running on an HPC

The main exercise uses one threaded SWIFT process, both locally and on an HPC.
The notebook gives the local command. A simple one-node Slurm script is also
provided:

```bash
sbatch --cpus-per-task=32 --mem=64G --time=00:30:00 \
  scripts/run_swift_slurm.sh
```

Add your site's account and partition options when submitting.

## SWIFT-EAGLE extension

The optional extension has its own build script and parameter file:

```bash
scripts/build_swift_eagle.sh
scripts/download_eagle_tables.sh
configs/swift_eagle.yml
```

The download script runs SWIFT's own table scripts and puts the PS2020 cooling,
EAGLE yield, and photometry tables in `runs/eagle`, where the parameter file
expects them when that directory is used for the extension run.
