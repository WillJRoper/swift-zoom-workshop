# SWIFT Zoom Workshop

This repository contains a hands-on introduction to running zoom simulations
with MUSIC-2 and SWIFT.

The included notebooks will walk you through the process of making initial conditions, setting up and running a zoom simulation, and breifly analyzing the results.

You can either run things on your laptop (but I offer 0 warranty that it will work) or on a cluster (where I offer a tiny bit more warranty, but still very little, your environment is your own responsibility).

The workshop has three notebooks:

1. `notebooks/01_ics.ipynb` - make and inspect the initial conditions.
2. `notebooks/02_zoom_run.ipynb` - choose the geometry and run SWIFT.
3. `notebooks/03_zoom_analysis.ipynb` - load the snapshots and make images.

The example uses the Lagrangian region from TESSERA zoom `P00000/R0000`. We
reduce its finest level from 13 to 10 so that it runs in a reasonable time on a laptop.

## Getting started

Clone the workshop and its MUSIC-2 and SWIFT dependencies:

```bash
git clone --recurse-submodules <workshop-repository-url>
cd SWIFTZoomWorkshop
```

SWIFT is pinned from the `zoom-swiftcon` branch in `dependencies/SWIFT`.
MUSIC-2 is in `dependencies/MUSIC2`.

If using your laptop you will need to install the native build dependencies.

Install on Debian/Ubuntu Linux with:

```bash
scripts/install_dependencies_linux.sh
```

Or on macOS, install Apple's command-line tools and Homebrew first, then run:

```bash
scripts/install_dependencies_macos.sh
```

These install C, C++, and Fortran compilers plus CMake, autotools, HDF5, FFTW,
GSL, TBB, pkg-config, Git, and Python. The macOS script installs GNU GCC because
MUSIC-2 requires OpenMP, and HDF5 1.10 for the known-good SWIFT build.

Create a Python environment.

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
```

Then open `notebooks/01_ics.ipynb` and begin the workshop in your notebook software of choice (or follow the notebook in the browser if on a HPC).

## MUSIC-2 and SWIFT

To build MUSIC-2 and SWIFT you can run the following scripts. The build scripts will use the bundled Git submodules. All these do is run the build commands, but if you're curious, you can look inside the scripts to see what they do.

```bash
scripts/build_music2.sh
scripts/build_swift.sh
```

## Running on an HPC

If you are running on a cluster, you can load the modules for your environment, clone the repo and submodules, and then run the build scripts. Then instead of running the run scripts directly, you can submit the job scripts in `submission_scripts/` to your scheduler. The job scripts in here assume you are using cosma8 and default to the serial partition.

## SWIFT-EAGLE extension

If you want to prove full physics runs work you can also later rerun the zoom with the SWIFT-EAGLE model. To do so you will need the EAGLE-XL configuration and various input files. There are scripts contained within the repository to build SWIFT-EAGLE and download the necessary tables:

```bash
scripts/build_swift_eagle.sh
scripts/download_eagle_tables.sh
configs/swift_eagle.yml
```
