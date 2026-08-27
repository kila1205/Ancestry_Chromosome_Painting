# Ancestry Analysis and Chromosome Painting

This repository contains global and chromosome-level ancestry analysis workflows tested using the GIAB HG002 sample sequenced with Ultima Genomics.

The analysis is divided into two parts:

1. **Global ancestry** using Somalier
2. **Chromosome-level ancestry and chromosome painting** using Beagle and RFMix

Both analyses use GRCh38/hg38 and population references from the 1000 Genomes Project (1KGP).

## Workflow

### 1. Global ancestry

The global ancestry workflow is located in [`global_ancestry/`](global_ancestry/).

Somalier is used to extract ancestry-informative variants from the study CRAM and compare the sample with 1KGP reference individuals.

The ancestry output includes:

- predicted ancestry
- AFR probability
- AMR probability
- EAS probability
- EUR probability
- SAS probability
- PC1-PC10 coordinates

The PCA coordinates can then be used to visualize the study sample together with the 1KGP reference populations.

### 2. Chromosome-level ancestry

The chromosome-level analysis starts from the same HG002 CRAM.

The main steps are:

1. Chromosome-level variant calling with EfficientDV
2. Filtering to biallelic SNPs
3. Selection of SNPs shared between the study sample and 1KGP
4. Phasing with Beagle
5. Local ancestry inference with RFMix
6. Chromosome painting across chr1-chr22

## Dataset used

The workflow was tested using the GIAB HG002 dataset generated on the Ultima Genomics platform.

| Field | Value |
|---|---|
| Sample | HG002 |
| CRAM sample ID | L7386 |
| Platform | Ultima Genomics |
| CRAM | `414004-L7386-Z0114-CAACATACATCAGAT.cram` |
| Genome reference | GRCh38 / hg38 |

Genome in a Bottle (GIAB):

https://www.nist.gov/programs-projects/genome-bottle

Additional information about the reference files and datasets used in the analysis is available in [`resources/README.md`](resources/README.md).

## Reference data

### GRCh38

Variant calling and ancestry analysis were performed using GRCh38/hg38.

Reference FASTA used during testing:

```text
Homo_sapiens_assembly38.fasta
```

GIAB reference resources:

https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/references/

### 1000 Genomes Project

The 1000 Genomes Project was used as the population reference for both global and chromosome-level ancestry analysis.

For chromosome-level ancestry, the phased high-coverage GRCh38 panel was used:

https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20220422_3202_phased_SNV_INDEL_SV/

The five ancestry superpopulations used in the analysis are:

- AFR - African
- AMR - Admixed American
- EAS - East Asian
- EUR - European
- SAS - South Asian

### Genetic maps

GRCh38 genetic maps used for Beagle and RFMix:

https://bochet.gcc.biostat.washington.edu/beagle/genetic_maps/plink.GRCh38.map.zip

## Requirements

### Global ancestry

- Nextflow
- Somalier
- bcftools
- Python 3
- pandas
- matplotlib

### Chromosome-level ancestry

- miniwdl
- Ultima HealthOmics EfficientDV workflow
- bcftools
- Java
- Beagle
- RFMix
- Python 3
- matplotlib

## Running global ancestry

The global ancestry pipeline is available in:

```text
global_ancestry/
```

Example:

```bash
cd global_ancestry

nextflow run main.nf \
  --input samplesheets/example.csv \
  --sites /path/to/sites.hg38.vcf.gz \
  --sites_index /path/to/sites.hg38.vcf.gz.tbi \
  --fasta /path/to/Homo_sapiens_assembly38.fasta \
  --reference /path/to/1kg-somalier \
  --labels /path/to/ancestry-labels-1kg.tsv \
  --outdir results \
  -with-conda
```

More information is available in [`global_ancestry/README.md`](global_ancestry/README.md).

## Running chromosome-level ancestry

### 1. Generate chromosome configs

```bash
python3 scripts/generate_chr_configs.py \
  --cram /path/to/sample.cram \
  --crai /path/to/sample.cram.crai \
  --model /path/to/ultima-germline-model.onnx \
  --sample HG002
```

### 2. Run chromosome variant calling

```bash
WDL=/path/to/efficient_dv.wdl \
bash scripts/run_variant_calling.sh
```

### 3. Run local ancestry inference

```bash
bash scripts/run_ancestry_chr1_22.sh
```

This performs SNP filtering, shared-marker selection, Beagle phasing and RFMix ancestry inference for chr1-chr22.

### 4. Generate chromosome painting

Combined chromosome painting:

```bash
python3 scripts/plot_chromosome_painting.py
```

Individual chromosome figures:

```bash
python3 scripts/plot_each_chromosome.py
```

## Example results

### Global ancestry PCA

Example PCA generated from the HG002 Somalier ancestry analysis:

![HG002 global ancestry PCA](global_ancestry/docs/figures/HG002_global_ancestry_PCA.png)

### Chromosome painting

Chromosome painting generated from the HG002 local ancestry analysis across chr1-chr22:

![HG002 chromosome painting](docs/figures/chromosome_painting_example.png)

## Repository structure

```text
Ancestry_Chromosome_Painting/
├── global_ancestry/
│   ├── README.md
│   ├── main.nf
│   ├── nextflow.config
│   ├── modules/
│   │   ├── validate_input.nf
│   │   ├── somalier_extract.nf
│   │   └── somalier_ancestry.nf
│   ├── envs/
│   │   └── somalier.yml
│   ├── samplesheets/
│   │   └── example.csv
│   ├── scripts/
│   │   └── plot_pca.py
│   └── docs/
│       └── figures/
│           └── HG002_global_ancestry_PCA.png
├── configs/
│   └── example_chr.json
├── scripts/
│   ├── generate_chr_configs.py
│   ├── run_variant_calling.sh
│   ├── run_ancestry_chr1_22.sh
│   ├── plot_chromosome_painting.py
│   └── plot_each_chromosome.py
├── resources/
│   └── README.md
├── docs/
│   └── figures/
│       └── chromosome_painting_example.png
├── .gitignore
└── README.md
```

## Main outputs

The global ancestry workflow produces:

- Somalier extraction output
- predicted global ancestry
- AFR, AMR, EAS, EUR and SAS ancestry probabilities
- PCA coordinates
- PCA visualization

The chromosome-level workflow produces:

- chromosome-specific study VCFs
- study and 1KGP VCFs containing shared SNPs
- phased study VCFs
- RFMix local ancestry results
- combined chr1-chr22 chromosome painting
- individual chromosome painting figures
