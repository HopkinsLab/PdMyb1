#!/usr/bin/env bash
#
#SBATCH -J phase
#SBATCH -c 12
#SBATCH --mem-per-cpu=2G
#SBATCH -t 0-00:20
#SBATCH -p shared
#SBATCH -o logs/%x.%A.o
#SBATCH -e logs/%x.%A.e
set -e

source utils/init_env.sh

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

in_vcf=results/snp_postproc/merged.drum.filt.lmiss_0.5.imiss_0.9.polarized.vcf.gz
phased_vcf=${in_vcf%.vcf*}.phased.vcf.gz

tmp_prefix=$TMPDIR/phase.$RANDOM
bcftools query -l $in_vcf > $tmp_prefix.samps

cat $tmp_prefix.samps | \
    parallel \
        bcftools view -s {} $in_vcf '>' $tmp_prefix.{}.vcf

cat $tmp_prefix.samps | \
    parallel \
        whatshap phase -o $tmp_prefix.{}.phased.vcf --reference=$REF_FASTA --ignore-read-groups $tmp_prefix.{}.vcf seq/bams/{}.sorted.primary.bam

cat $tmp_prefix.samps | \
    parallel bgzip $tmp_prefix.{}.phased.vcf

cat $tmp_prefix.samps | \
    parallel tabix $tmp_prefix.{}.phased.vcf.gz


> $tmp_prefix.list
for samp in $(bcftools query -l $in_vcf); do
    echo "$tmp_prefix.$samp.phased.vcf.gz" >> $tmp_prefix.list
done

bcftools merge -Oz -l $tmp_prefix.list > $phased_vcf
tabix $phased_vcf

rm -f $tmp_prefix.*
