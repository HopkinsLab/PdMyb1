#!/usr/bin/env bash
#
#SBATCH -J pwise_ld
#SBATCH -c 1
#SBATCH --mem-per-cpu=14G
#SBATCH -t 0-00:30
#SBATCH -p serial_requeue
#SBATCH -o logs/%x.%A.o
#SBATCH -e logs/%x.%A.e
#
# Compute R2 pairwise across all SNPs as well as missingness and frequency data

set -e
source utils/init_env.sh

out_dir="results/pairwise_ld"
if [ ! -d $out_dir ]; then
    mkdir -p $out_dir
fi

vcf_fn="results/snp_postproc/merged.drum.filt.lmiss_0.5.imiss_0.9.polarized.vcf.gz"
in_prefix="$out_dir/merged.drum.filt.lmiss_0.5.imiss_0.9.polarized.bi"

out_prefix=${in_prefix}_ld

./utils/vcf2plink.sh $vcf_fn $in_prefix

$PLINK_CMD --bfile $in_prefix \
    --allow-extra-chr \
    --r2 square \
    --freq counts \
    --out $out_prefix

