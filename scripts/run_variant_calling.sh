#!/usr/bin/env bash

set -euo pipefail

# Run EfficientDV chromosome-level variant calling for chr1-chr22.
#
# Usage:
#   WDL=/path/to/efficient_dv.wdl \
#   bash scripts/run_variant_calling.sh
#
# Optional environment variables:
#   SAMPLE=HG002
#   CONFIG_DIR=configs/generated
#   OUTDIR=results/01_variant_calling

SAMPLE="${SAMPLE:-HG002}"
CONFIG_DIR="${CONFIG_DIR:-configs/generated}"
OUTDIR="${OUTDIR:-results/01_variant_calling}"

if [[ -z "${WDL:-}" ]]; then
    echo "ERROR: WDL is not set."
    echo
    echo "Example:"
    echo "WDL=/path/to/efficient_dv.wdl bash scripts/run_variant_calling.sh"
    exit 1
fi

if ! command -v miniwdl >/dev/null 2>&1; then
    echo "ERROR: miniwdl was not found in PATH."
    exit 1
fi

mkdir -p "$OUTDIR"

for chr in {1..22}; do

    CHROM="chr${chr}"
    CONFIG="${CONFIG_DIR}/${SAMPLE}_${CHROM}.json"
    CHR_OUT="${OUTDIR}/${SAMPLE}_${CHROM}"

    echo
    echo "========================================"
    echo "Starting ${CHROM}"
    echo "========================================"

    if [[ ! -f "$CONFIG" ]]; then
        echo "ERROR: Config not found: $CONFIG"
        exit 1
    fi

    # Skip chromosomes that already have a completed run directory.
    if [[ -d "$CHR_OUT" ]]; then
        echo "${CHROM}: output directory already exists. Skipping."
        continue
    fi

    miniwdl run \
        "$WDL" \
        -i "$CONFIG" \
        --dir "$CHR_OUT"

    echo "${CHROM} finished."
done

echo
echo "========================================"
echo "Variant calling chr1-chr22 finished."
echo "========================================"
