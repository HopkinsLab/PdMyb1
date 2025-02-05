#!/usr/bin/env bash
#
#SBATCH -J filter
#SBATCH -c 1
#SBATCH --mem-per-cpu=4G
#SBATCH -t 0-00:05
#SBATCH -p serial_requeue
#SBATCH -o logs/%x.%A.o
#SBATCH -e logs/%x.%A.e
set -e

source utils/init_env.sh

species=${1:-drum}

call_dir=results/bcf_pipe/call
drum_vcf="$call_dir/merged.drum.vcf.gz"
cusp_vcf="$call_dir/merged.cusp.vcf.gz"

# High depth window
bed_fn=results/bcf_pipe/call/drum.hi_dep_region.bed

tmp_prefix=$TMPDIR/filter.$RANDOM

drum_filt=${drum_vcf%.vcf*}.filt.vcf.gz

bcftools view -R $bed_fn -M2 $drum_vcf | \
    bcftools filter --set-GTs . -e '(FMT/DP < 10) | ((INFO/AC > 0) & (GQ < 20))'  > $tmp_prefix.bi.vcf
        
bcftools view -R $bed_fn -m3 $drum_vcf | \
    bcftools filter --set-GTs . -e '(FMT/DP < 10) | (GQ < 20)' | \
    bcftools norm --multiallelics '-' | \
    bcftools view -e 'AC == 0' | \
    bcftools norm --multiallelics '+' > $tmp_prefix.multi.vcf

bcftools concat $tmp_prefix.bi.vcf $tmp_prefix.multi.vcf | \
    bcftools sort -Oz > $drum_filt
tabix $drum_filt

rm -f $tmp_prefix.bi.vcf $tmp_prefix.multi.vcf
##################
# Filter sites based on snp missingness ...
drum_lmiss=${drum_filt%.vcf*}.lmiss_0.5.vcf.gz
bcftools view -Oz -e 'F_MISSING > 0.5' $drum_filt > $drum_lmiss
tabix $drum_lmiss

# ... and on sample missingness
drum_imiss=${drum_lmiss%.vcf*}.imiss_0.9.vcf.gz
samp_remove=${drum_imiss%.vcf*}.rm_samps.list
bcftools view -m 2 $drum_lmiss | bcftools stats -s - | \
    grep ^PSC | \
    awk '{if($14 / ($4+$5+$6+$14) > 0.9){print $3}}' > $samp_remove
bcftools view -Oz -S "^$samp_remove" $drum_lmiss > $drum_imiss
tabix $drum_imiss

##################
# Cusp filtering
cusp_filt=${cusp_vcf%.vcf*}.filt.vcf.gz
bcftools view -R $bed_fn $cusp_vcf | \
    bcftools filter --set-GTs . -e '(FMT/DP < 10) | ((INFO/AC > 0) & (GQ < 20))' | \
    bcftools view -Oz -i 'COUNT(GT="./.") < 3' > $cusp_filt
tabix $cusp_filt

# Merge drum and cusp data
cusp_merge=${cusp_vcf%.vcf*}.filt.MERGED.$(basename $drum_imiss)
if [ ! -s $cusp_merge ]; then
    bcftools merge -Oz $drum_imiss $cusp_filt > $cusp_merge
    tabix $cusp_merge
fi
