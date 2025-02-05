#!/usr/bin/env bash
#
#SBATCH -J polarize
#SBATCH -c 1
#SBATCH --mem-per-cpu=4G
#SBATCH -t 0-00:30
#SBATCH -p serial_requeue
#SBATCH -o logs/%x.%A.o
#SBATCH -e logs/%x.%A.e
set -e

source utils/init_env.sh

cusp_vcf=results/bcf_pipe/call/merged.cusp.filt.vcf.gz
cusp_prefix=$(basename $cusp_vcf)
cusp_prefix=${cusp_prefix%.vcf*}

drum_vcf=results/bcf_pipe/call/merged.drum.filt.lmiss_0.5.imiss_0.9.vcf.gz
drum_prefix=$(basename $drum_vcf)
drum_prefix=${drum_prefix%.vcf*}

out_dir=results/snp_postproc
if [ ! -d $out_dir ]; then
    mkdir -p $out_dir
fi

# Use fixed sites in cusp individuals to determine ancestral allele state
anc_bed=$out_dir/$cusp_prefix.ANC.bed
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\t%AN\t%AC\n' $cusp_vcf | \
    awk -v OFS="\t" '
        $5 > 0 && ($6 == "." || $6 == 0) {print $1,$2-1,$2,$3}
        $5 > 0 && $6 != "." && $6 !~ /,/ && $5 == $6 {print $1,$2-1,$2,$4}
        ' > $anc_bed 

# bcftools annotate requires a tabix indexed tsv file
anc_annot=$out_dir/$drum_prefix.ANC.annot.tab.gz
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\n' $drum_vcf | \
    awk -v OFS="\t" '{print $1,$2-1,$2,$3,$4}' | \
    bedtools intersect -loj -a - -b $anc_bed | \
    awk -v OFS="\t" '{print $1,$3,$4,$5,$9}' | \
    bgzip -c > $anc_annot
tabix -s1 -b2 -e2 $anc_annot

# Create an INFO file line for the new vcf file
hdr_fn=$out_dir/$drum_prefix.new.hdr
echo '##INFO=<ID=AA,Number=1,Type=Character,Description="Ancestral allele">' > $hdr_fn

# Annotate
out_vcf=$out_dir/$drum_prefix.polarized.vcf.gz
bcftools annotate -Oz -a $anc_annot \
    -c CHROM,POS,REF,ALT,INFO/AA -h $hdr_fn -Oz \
    $drum_vcf > $out_vcf

tabix $out_vcf
