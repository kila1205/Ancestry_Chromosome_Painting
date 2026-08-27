#!/usr/bin/env python3

import argparse
import json
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(
        description="Generate EfficientDV configs for chromosomes 1-22."
    )

    parser.add_argument("--cram", required=True, help="Input CRAM file")
    parser.add_argument("--crai", required=True, help="Input CRAI file")
    parser.add_argument("--model", required=True, help="Ultima germline ONNX model")
    parser.add_argument("--sample", default="HG002", help="Sample name")
    parser.add_argument(
        "--outdir",
        default="configs/generated",
        help="Directory for generated configs",
    )

    args = parser.parse_args()

    outdir = Path(args.outdir)
    outdir.mkdir(parents=True, exist_ok=True)

    for chrom in range(1, 23):
        chromosome = f"chr{chrom}"

        config = {
            "EfficientDV.base_file_name": f"{args.sample}_{chromosome}",
            "EfficientDV.cram_files": [args.cram],
            "EfficientDV.cram_index_files": [args.crai],
            "EfficientDV.reference_genome": "hg38",
            "EfficientDV.intervals_string": chromosome,
            "EfficientDV.num_shards": 2,
            "EfficientDV.make_gvcf": True,
            "EfficientDV.recalibrate_vaf": False,
            "EfficientDV.is_somatic": False,
            "EfficientDV.normalize_strand_bias": False,
            "EfficientDV.single_strand": False,
            "EfficientDV.model_onnx": args.model,
        }

        outfile = outdir / f"{args.sample}_{chromosome}.json"

        with outfile.open("w") as handle:
            json.dump(config, handle, indent=2)

        print(f"Created {outfile}")


if __name__ == "__main__":
    main()
