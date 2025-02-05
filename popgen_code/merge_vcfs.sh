#!/usr/bin/env bash
#
#SBATCH -J merge
#SBATCH -c 1
#SBATCH --mem-per-cpu=4G
#SBATCH -t 0-00:30
#SBATCH -p serial_requeue
#SBATCH -o logs/%x.%A.o
#SBATCH -e logs/%x.%A.e
set -e

source utils/init_env.sh

species=${1:-drum}

# Get sample list
if [ $species == "drum" ]; then
    samp_fn=$DRUM_LIST
elif [ $species == "cusp" ]; then
    samp_fn=$CUSP_LIST
else
    echo "Species $species not recognized"
    exit 1
fi


# Collect vcf paths
call_dir=results/bcf_pipe/call
tmp_fn=$TMPDIR/tmp.merge_vcf.$species.$RANDOM.list
> $tmp_fn
for samp in $(cat $samp_fn); do
    call_vcf=$call_dir/${samp}.call.vcf.gz
    echo "$call_vcf" >> $tmp_fn
done

# Merge
merge_vcf="$call_dir/merged.$species.vcf.gz"
bcftools merge -Oz -l $tmp_fn > $merge_vcf
tabix -fC $merge_vcf

rm -f $tmp_fn
