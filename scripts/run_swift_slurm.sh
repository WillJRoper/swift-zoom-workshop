#!/usr/bin/env bash
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=swift-zoom-%j.out

set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
RUN_ID=${RUN_ID:-"slurm-${SLURM_JOB_ID}"}
THREADS=${SLURM_CPUS_PER_TASK:-1}
STEPS=${STEPS:-16}

RUN_DIR="$ROOT/runs/$RUN_ID" "$ROOT/scripts/run_swift.sh" run "$THREADS" "$STEPS" "$@"
