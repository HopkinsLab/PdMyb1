#!/usr/bin/env bash
#
#SBATCH -J mpileup
#SBATCH -c 1
#SBATCH --mem-per-cpu=4G
#SBATCH -t 0-00:15
#SBATCH -p serial_requeue
#SBATCH -o logs/%x.%A_%a.o
#SBATCH -e logs/%x.%A_%a.e
set -e

source utils/init_env.sh

i=${SLURM_ARRAY_TASK_ID:-1}

# Get sample name
samp=$( cat $DRUM_LIST $CUSP_LIST | awk -v i=$i 'NR == i' )

in_bam=seq/bams/${samp}.sorted.primary.bam

# Focus on calling genotypes in gene region +/- 100kb for now.
# Later, we will narrow the window based on depth
padding=100000
region=$(awk -v p=$padding '{print $1":"$2-p+1"-"$3+p}' $MYB_WINDOW_BED)

# MPILEUP
mpile_dir=results/bcf_pipe/mpileup
if [ ! -d $mpile_dir ]; then
    mkdir -p $mpile_dir
fi

mpile_vcf=$mpile_dir/${samp}.mpileup.vcf.gz
samtools view -b $in_bam $region | \
    bcftools mpileup -Oz -X ont -f $REF_FASTA -a AD,DP /dev/stdin > $mpile_vcf
tabix -fC $mpile_vcf

# CALL
call_dir=results/bcf_pipe/call
if [ ! -d $call_dir ]; then
    mkdir -p $call_dir
fi

call_vcf=$call_dir/${samp}.call.vcf.gz
bcftools view $mpile_vcf $region | \
    bcftools call -a GQ -Oz -m > $call_vcf
tabix -fC $call_vcf
