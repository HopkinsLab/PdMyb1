#!/usr/bin/env bash
#
#SBATCH -J vcf2plink
#SBATCH -c 1
#SBATCH --mem-per-cpu=4G
#SBATCH -t 0-00:30
#SBATCH -p serial_requeue
#SBATCH -o logs/%x.%A.o
#SBATCH -e logs/%x.%A.e
set -e

source utils/init_env.sh


vcf_fn=$1 # VCF to use
out_prefix=${2:-plink} # Plink prefix to use
pheno=$3 # Phenotypes to annotate with

tmp_prefix=$TMPDIR/vcf2plink.$RANDOM


# plink1.9 really only understand biallelic sites, but we have a substantial number of 
# multiallelic sites. To deal with this, we will, for each multiallelic site,
# keep only the ALTernate allele with the largest MAF. If two or more ALT alleles 
# have the same MAF then we randomly select one.

if [ ! -s $out_prefix.seed ]; then
    rand_seed=$( echo $RANDOM )
    echo "$rand_seed" > $out_prefix.seed
else
    rand_seed=$( cat $out_prefix.seed )
fi


tmp_vcf=$tmp_prefix.vcf.gz
bcftools view -Oz -m 2 $vcf_fn > $tmp_vcf

./utils/vcf2plink.filter_multiallelic.R $tmp_vcf $rand_seed | \
    $PLINK_CMD --vcf /dev/stdin \
        --double-id --allow-extra-chr \
        --allow-no-sex \
        --set-missing-var-ids '@:#' \
        --missing \
        --make-bed --out $out_prefix

if [ -z "$pheno" ]; then
    echo "no phenotypes provided"
else
    echo "annotating phenotypes"
    # NB: --pheno in plink1.9 rounds the phenotype values so we do this manually instead to retain precision.
    ./utils/vcf2plink.annot_pheno.R $out_prefix $pheno
fi

rm -f $tmp_prefix.*
