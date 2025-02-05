#!/usr/bin/env bash
#
#SBATCH -J gwas
#SBATCH -c 1
#SBATCH --mem-per-cpu=4G
#SBATCH -t 0-00:10
#SBATCH -p serial_requeue
#SBATCH -o logs/%x.%A.o
#SBATCH -e logs/%x.%A.e
set -e

source utils/init_env.sh

out_dir=results/gwas
if [ ! -d $out_dir ]; then
    mkdir -p $out_dir
fi

use_maf=${1:-"0.05"}
grp=${2:-"Qual_Int"} # Metadata column to use for phenotype

vcf_fn="results/snp_postproc/merged.drum.filt.lmiss_0.5.imiss_0.9.polarized.vcf.gz"
in_prefix="$out_dir/merged.drum.filt.lmiss_0.5.imiss_0.9.polarized.bi.$grp"
out_prefix=$(basename $in_prefix).gemma.relmat.maf_${use_maf}

if [ ! -s $in_prefix.bed ]; then
    # Make phenotype file if needed
    pheno_fn=$in_prefix.pheno
    i=$( awk -v grp=$grp 'NR == 1 {for(i=1; i <= NF; i++){if($i == grp){print i}}}' $DRUM_MET )

    bcftools query -l $vcf_fn | \
        xargs  -I % grep -m 1 ^%$'\t' $DRUM_MET | \
        awk -v i=$i -v OFS=" " '{print $1,$1,$i}' > $pheno_fn

    ./utils/vcf2plink.sh $vcf_fn $in_prefix $in_prefix.pheno
    ./utils/plink_recode.Atpose.sh $in_prefix $in_prefix.recode
fi

# Gemma dumps all the files in output. Not sure how to change this.
rm -rf output

gemma -bfile $in_prefix \
    -gk 1 \
    -maf ${use_maf} -miss 0.5 \
    -o $out_prefix

gemma -bfile $in_prefix \
    -lmm 1 \
    -maf ${use_maf} -miss 0.5 \
    -k output/$out_prefix.cXX.txt \
    -o $out_prefix.ulmm
mv -f output/* $out_dir
rmdir output



