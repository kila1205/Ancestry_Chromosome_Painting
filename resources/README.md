# Reference Data

Reference datasets are not included in this repository because of their size. The sources used for this analysis are listed below.

## HG002 Ultima Genomics data

The pipeline was tested using the Genome in a Bottle (GIAB) HG002 sample sequenced on the Ultima Genomics platform.

```text
Sample: HG002
CRAM sample ID: L7386
CRAM: 414004-L7386-Z0114-CAACATACATCAGAT.cram
Reference: GRCh38 / hg38
```

GIAB:
https://www.nist.gov/programs-projects/genome-bottle

Ultima Genomics:
https://www.ultimagenomics.com/

The CRAM and CRAI files are not included in this repository.

## GRCh38 reference genome

Variant calling was performed using GRCh38/hg38.

Reference FASTA used during development:

```text
Homo_sapiens_assembly38.fasta
```

GIAB reference resources:
https://ftp-trace.ncbi.nlm.nih.gov/ReferenceSamples/giab/release/references/

## 1000 Genomes Project reference panel

Local ancestry inference was performed using the high-coverage 1000 Genomes Project (1KGP) reference panel on GRCh38.

Dataset information:
https://www.internationalgenome.org/announcements/3202-samples-at-high-coverage-from-NYGC/

Phased GRCh38 chromosome VCFs:
https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/working/20220422_3202_phased_SNV_INDEL_SV/

Example:

```text
1kGP_high_coverage_Illumina.chr1.filtered.SNV_INDEL_SV_phased_panel.vcf.gz
```

VCF and index files are required for chromosomes 1-22.

## Population labels

The 1KGP reference samples were grouped into five superpopulations:

| Code | Superpopulation |
|------|-----------------|
| AFR | African |
| AMR | Admixed American |
| EAS | East Asian |
| EUR | European |
| SAS | South Asian |

The population metadata were converted to the RFMix input files:

```text
1kg_superpop.map
1kg_rfmix_samples.txt
```

## GRCh38 genetic maps

GRCh38 PLINK genetic maps were used for Beagle and RFMix.

Download:
https://bochet.gcc.biostat.washington.edu/beagle/genetic_maps/plink.GRCh38.map.zip

The maps should be available for chromosomes 1-22 and use chromosome naming compatible with the VCF files.

## Files not stored in this repository

Large input, reference, and intermediate files should remain in local or HPC storage, including:

```text
CRAM / CRAI
VCF / VCF.GZ
VCF indexes
GRCh38 FASTA
1KGP reference VCFs
Beagle JAR
Ultima ONNX model
RFMix outputs
```
