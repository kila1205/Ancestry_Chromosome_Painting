#!/usr/bin/env bash

set -euo pipefail

# Local ancestry pipeline for chromosomes 1-22.
#
# Steps:
#   1. Filter HG002 to biallelic PASS SNPs
#   2. Filter 1KGP reference to biallelic SNPs
#   3. Retain shared variants
#   4. Select ancestry-labelled 1KGP samples
#   5. Phase HG002 with Beagle
#   6. Prepare genetic map for RFMix
#   7. Run RFMix
#
# Required directory structure and resources can be changed
# using the environment variables below.

PROJECT="${PROJECT:-$PWD}"

SAMPLE="${SAMPLE:-HG002}"

STUDY_DIR="${STUDY_DIR:-$PROJECT/results/02_variant_vcfs}"

REF_DIR="${REF_DIR:-$PROJECT/resources/1kg_grch38/20220422_3202_phased_SNV_INDEL_SV}"

LABELS="${LABELS:-$PROJECT/resources/rfmix/1kg_superpop.map}"

SAMPLES="${SAMPLES:-$PROJECT/resources/rfmix/1kg_rfmix_samples.txt}"

BEAGLE="${BEAGLE:-$PROJECT/tools/beagle/beagle.jar}"

RFMIX="${RFMIX:-$PROJECT/tools/rfmix/rfmix}"

BEAGLE_MAP_DIR="${BEAGLE_MAP_DIR:-$PROJECT/resources/genetic_maps/chr_in_chrom_field}"

RFMIX_MAP_DIR="${RFMIX_MAP_DIR:-$PROJECT/resources/rfmix/genetic_maps}"

mkdir -p "$RFMIX_MAP_DIR"


for chr in {1..22}; do

    echo
    echo "================================================"
    echo "Starting chr${chr}"
    echo "================================================"
    echo

    HARM="$PROJECT/results/05_harmonized/chr${chr}"
    PHASE="$PROJECT/results/06_phasing/chr${chr}"
    LOCAL="$PROJECT/results/07_rfmix/chr${chr}"

    mkdir -p "$HARM" "$PHASE" "$LOCAL"

    STUDY="$STUDY_DIR/${SAMPLE}_chr${chr}.annotated.filt.vcf.gz"

    REF="$REF_DIR/1kGP_high_coverage_Illumina.chr${chr}.filtered.SNV_INDEL_SV_phased_panel.vcf.gz"

    BEAGLE_MAP="$BEAGLE_MAP_DIR/plink.chrchr${chr}.GRCh38.map"

    RFMIX_MAP="$RFMIX_MAP_DIR/chr${chr}.GRCh38.rfmix.map"

    FINAL="$LOCAL/${SAMPLE}_chr${chr}_fixed.msp.tsv"


    # --------------------------------------------------------
    # Resume support
    # --------------------------------------------------------

    if [[ -s "$FINAL" ]]; then
        echo "chr${chr}: already completed. Skipping."
        continue
    fi


    # --------------------------------------------------------
    # Check required inputs
    # --------------------------------------------------------

    if [[ ! -f "$STUDY" ]]; then
        echo "ERROR: Study VCF not found:"
        echo "$STUDY"
        exit 1
    fi

    if [[ ! -f "$REF" ]]; then
        echo "ERROR: 1KGP reference VCF not found:"
        echo "$REF"
        exit 1
    fi

    if [[ ! -f "$BEAGLE_MAP" ]]; then
        echo "ERROR: Genetic map not found:"
        echo "$BEAGLE_MAP"
        exit 1
    fi


    # --------------------------------------------------------
    # 1. Filter study sample to biallelic PASS SNPs
    # --------------------------------------------------------

    if [[ ! -s "$HARM/${SAMPLE}_chr${chr}.snps.vcf.gz" ]]; then

        echo "[chr${chr}] Filtering ${SAMPLE} SNPs..."

        bcftools view \
            -f PASS \
            -m2 -M2 \
            -v snps \
            "$STUDY" \
            -Oz \
            -o "$HARM/${SAMPLE}_chr${chr}.snps.vcf.gz"

        bcftools index -t \
            "$HARM/${SAMPLE}_chr${chr}.snps.vcf.gz"

    else
        echo "[chr${chr}] Study SNP file already exists."
    fi


    # --------------------------------------------------------
    # 2. Filter 1KGP reference to biallelic SNPs
    # --------------------------------------------------------

    if [[ ! -s "$HARM/1KG_chr${chr}.snps.vcf.gz" ]]; then

        echo "[chr${chr}] Filtering 1KGP SNPs..."

        bcftools view \
            -m2 -M2 \
            -v snps \
            "$REF" \
            -Oz \
            -o "$HARM/1KG_chr${chr}.snps.vcf.gz"

        bcftools index -t \
            "$HARM/1KG_chr${chr}.snps.vcf.gz"

    else
        echo "[chr${chr}] 1KGP SNP file already exists."
    fi


    # --------------------------------------------------------
    # 3. Find shared study SNPs
    # --------------------------------------------------------

    if [[ ! -s "$HARM/${SAMPLE}_chr${chr}.shared.vcf.gz" ]]; then

        echo "[chr${chr}] Finding shared ${SAMPLE} SNPs..."

        bcftools isec \
            -c none \
            -n=2 \
            -w1 \
            "$HARM/${SAMPLE}_chr${chr}.snps.vcf.gz" \
            "$HARM/1KG_chr${chr}.snps.vcf.gz" \
            -Oz \
            -o "$HARM/${SAMPLE}_chr${chr}.shared.vcf.gz"

        bcftools index -t \
            "$HARM/${SAMPLE}_chr${chr}.shared.vcf.gz"
    fi


    # --------------------------------------------------------
    # 4. Find shared 1KGP SNPs
    # --------------------------------------------------------

    if [[ ! -s "$HARM/1KG_chr${chr}.shared.vcf.gz" ]]; then

        echo "[chr${chr}] Finding shared 1KGP SNPs..."

        bcftools isec \
            -c none \
            -n=2 \
            -w2 \
            "$HARM/${SAMPLE}_chr${chr}.snps.vcf.gz" \
            "$HARM/1KG_chr${chr}.snps.vcf.gz" \
            -Oz \
            -o "$HARM/1KG_chr${chr}.shared.vcf.gz"

        bcftools index -t \
            "$HARM/1KG_chr${chr}.shared.vcf.gz"
    fi


    # --------------------------------------------------------
    # 5. Select ancestry-labelled 1KGP reference samples
    # --------------------------------------------------------

    if [[ ! -s "$HARM/1KG_chr${chr}.rfmix_reference.vcf.gz" ]]; then

        echo "[chr${chr}] Preparing RFMix reference..."

        bcftools view \
            -S "$SAMPLES" \
            "$HARM/1KG_chr${chr}.shared.vcf.gz" \
            -Oz \
            -o "$HARM/1KG_chr${chr}.rfmix_reference.vcf.gz"

        bcftools index -t \
            "$HARM/1KG_chr${chr}.rfmix_reference.vcf.gz"
    fi


    # --------------------------------------------------------
    # 6. Phase study sample with Beagle
    # --------------------------------------------------------

    if [[ ! -s "$PHASE/${SAMPLE}_chr${chr}.phased.vcf.gz" ]]; then

        echo "[chr${chr}] Running Beagle..."

        java -Xmx32g \
            -jar "$BEAGLE" \
            gt="$HARM/${SAMPLE}_chr${chr}.shared.vcf.gz" \
            ref="$HARM/1KG_chr${chr}.rfmix_reference.vcf.gz" \
            map="$BEAGLE_MAP" \
            out="$PHASE/${SAMPLE}_chr${chr}.phased" \
            nthreads=16

    else
        echo "[chr${chr}] Beagle result already exists."
    fi


    # --------------------------------------------------------
    # 7. Convert genetic map for RFMix
    # --------------------------------------------------------

    if [[ ! -s "$RFMIX_MAP" ]]; then

        echo "[chr${chr}] Creating RFMix genetic map..."

        awk 'BEGIN{OFS="\t"} {print $1,$4,$3}' \
            "$BEAGLE_MAP" \
            > "$RFMIX_MAP"
    fi


    # --------------------------------------------------------
    # 8. Run RFMix
    # --------------------------------------------------------

    echo "[chr${chr}] Running RFMix..."

    "$RFMIX" \
        -f "$PHASE/${SAMPLE}_chr${chr}.phased.vcf.gz" \
        -r "$HARM/1KG_chr${chr}.rfmix_reference.vcf.gz" \
        -m "$LABELS" \
        -g "$RFMIX_MAP" \
        -o "$LOCAL/${SAMPLE}_chr${chr}_fixed" \
        --chromosome="chr${chr}" \
        --n-threads=16 \
        -w 1

    echo
    echo "chr${chr} finished."
    echo

done


echo
echo "================================================"
echo "Local ancestry analysis chr1-chr22 finished."
echo "================================================"
