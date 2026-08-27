import pandas as pd
import matplotlib.pyplot as plt
import sys

input_file = sys.argv[1]
output_file = sys.argv[2]

df = pd.read_csv(input_file, sep="\t")

# Remove # from Somalier's first column name
df.columns = [c.lstrip("#") for c in df.columns]

query_id = "L7386"

# Reference samples have known/given ancestry
reference = df[df["given_ancestry"].notna()].copy()

# Our Ultima query sample
query = df[df["sample_id"] == query_id].copy()

plt.figure(figsize=(10, 8))

for ancestry in ["AFR", "EUR", "EAS", "AMR", "SAS"]:
    group = reference[reference["given_ancestry"] == ancestry]

    plt.scatter(
        group["PC1"],
        group["PC2"],
        s=15,
        alpha=0.5,
        label=ancestry
    )

if not query.empty:
    plt.scatter(
        query["PC1"],
        query["PC2"],
        s=180,
        marker="*",
        edgecolors="black",
        linewidths=1.2,
        label="Ultima HG002 (L7386)"
    )

    x = query.iloc[0]["PC1"]
    y = query.iloc[0]["PC2"]

    plt.annotate(
        "Ultima HG002\nL7386",
        (x, y),
        xytext=(10, 10),
        textcoords="offset points",
        fontsize=10,
        fontweight="bold"
    )

plt.xlabel("PC1")
plt.ylabel("PC2")

plt.title(
    "PCA of Ultima HG002 Against 1000 Genomes Reference Populations"
)

plt.legend(title="Ancestry")
plt.tight_layout()

plt.savefig(output_file, dpi=300)
plt.close()

print(f"PCA plot saved to: {output_file}")
