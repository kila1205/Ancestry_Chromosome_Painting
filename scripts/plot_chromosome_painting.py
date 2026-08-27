#!/usr/bin/env python3

from pathlib import Path
import matplotlib.pyplot as plt
from matplotlib.patches import Patch

PROJECT = Path.home() / "Chromosome_Ancestry"
RFMIX_DIR = PROJECT / "results" / "07_rfmix"
OUTDIR = PROJECT / "results" / "08_chromosome_painting"
OUTDIR.mkdir(parents=True, exist_ok=True)

# RFMix ancestry codes
ANCESTRY = {
    -1: ("Unassigned", "#BDBDBD"),
     0: ("AFR", "#E41A1C"),
     1: ("AMR", "#FF7F00"),
     2: ("EAS", "#4DAF4A"),
     3: ("EUR", "#377EB8"),
     4: ("SAS", "#984EA3"),
}

fig, ax = plt.subplots(figsize=(16, 12))

bar_height = 0.28
hap_gap = 0.08
chr_gap = 1.0

yticks = []
yticklabels = []

for i, chrom in enumerate(range(1, 23)):

    path = (
        RFMIX_DIR
        / f"chr{chrom}"
        / f"HG002_chr{chrom}_fixed.msp.tsv"
    )

    y_base = (22 - i) * chr_gap

    hap0_y = y_base + hap_gap
    hap1_y = y_base - bar_height - hap_gap

    yticks.append(y_base - bar_height / 2)
    yticklabels.append(f"chr{chrom}")

    with open(path) as f:

        for line in f:

            if line.startswith("#"):
                continue

            fields = line.strip().split()

            if len(fields) < 8:
                continue

            start = int(fields[1])
            end = int(fields[2])

            hap0 = int(fields[-2])
            hap1 = int(fields[-1])

            width = end - start

            # Haplotype 1
            ax.broken_barh(
                [(start / 1e6, width / 1e6)],
                (hap0_y, bar_height),
                facecolors=ANCESTRY[hap0][1],
                edgecolors="none",
            )

            # Haplotype 2
            ax.broken_barh(
                [(start / 1e6, width / 1e6)],
                (hap1_y, bar_height),
                facecolors=ANCESTRY[hap1][1],
                edgecolors="none",
            )


ax.set_yticks(yticks)
ax.set_yticklabels(yticklabels)

ax.set_xlabel("Genomic position (Mb)")
ax.set_ylabel("Chromosome")

ax.set_title(
    "HG002 Local Ancestry Chromosome Painting (RFMix)\n"
    "Autosomes chr1–22"
)

ax.grid(axis="x", linestyle=":", alpha=0.25)

legend_handles = [
    Patch(facecolor=color, label=label)
    for code, (label, color) in ANCESTRY.items()
    if code != -1
]

ax.legend(
    handles=legend_handles,
    title="Ancestry",
    loc="upper right",
    frameon=True,
)

plt.tight_layout()

png = OUTDIR / "HG002_chr1_22_chromosome_painting.png"
pdf = OUTDIR / "HG002_chr1_22_chromosome_painting.pdf"

plt.savefig(png, dpi=300, bbox_inches="tight")
plt.savefig(pdf, bbox_inches="tight")

print(f"PNG written to: {png}")
print(f"PDF written to: {pdf}")
