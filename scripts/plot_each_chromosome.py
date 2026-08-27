#!/usr/bin/env python3

from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.patches import Patch

PROJECT = Path.home() / "Chromosome_Ancestry"
RFMIX_DIR = PROJECT / "results" / "07_rfmix"
OUTDIR = PROJECT / "results" / "08_chromosome_painting" / "individual_chromosomes"
OUTDIR.mkdir(parents=True, exist_ok=True)

ANCESTRY = {
    -1: ("Unassigned", "#BDBDBD"),
     0: ("AFR", "#E41A1C"),
     1: ("AMR", "#FF7F00"),
     2: ("EAS", "#4DAF4A"),
     3: ("EUR", "#377EB8"),
     4: ("SAS", "#984EA3"),
}

for chrom in range(1, 23):

    msp = (
        RFMIX_DIR
        / f"chr{chrom}"
        / f"HG002_chr{chrom}_fixed.msp.tsv"
    )

    fig, ax = plt.subplots(figsize=(14, 3.2))

    hap1_y = 1.0
    hap2_y = 0.25
    bar_height = 0.45

    with open(msp) as f:
        for line in f:

            if line.startswith("#"):
                continue

            fields = line.strip().split()

            if len(fields) < 8:
                continue

            start = int(fields[1])
            end = int(fields[2])

            hap1 = int(fields[-2])
            hap2 = int(fields[-1])

            start_mb = start / 1e6
            width_mb = (end - start) / 1e6

            ax.broken_barh(
                [(start_mb, width_mb)],
                (hap1_y, bar_height),
                facecolors=ANCESTRY[hap1][1],
                edgecolors="none",
            )

            ax.broken_barh(
                [(start_mb, width_mb)],
                (hap2_y, bar_height),
                facecolors=ANCESTRY[hap2][1],
                edgecolors="none",
            )

    ax.set_yticks([
        hap1_y + bar_height / 2,
        hap2_y + bar_height / 2
    ])
    ax.set_yticklabels([
        "Haplotype 1",
        "Haplotype 2"
    ])

    ax.set_xlabel("Genomic position (Mb)")
    ax.set_title(
        f"HG002 Local Ancestry — Chromosome {chrom}"
    )

    ax.grid(
        axis="x",
        linestyle=":",
        alpha=0.25
    )

    legend_handles = [
        Patch(facecolor=color, label=label)
        for code, (label, color) in ANCESTRY.items()
        if code != -1
    ]

    ax.legend(
        handles=legend_handles,
        title="Ancestry",
        bbox_to_anchor=(1.01, 1),
        loc="upper left"
    )

    plt.tight_layout()

    outfile = OUTDIR / f"HG002_chr{chrom}_chromosome_painting.png"

    plt.savefig(
        outfile,
        dpi=300,
        bbox_inches="tight"
    )

    plt.close()

    print(f"Written: {outfile}")

print("All chromosome plots finished.")
