#!/usr/bin/env bash
#
#SBATCH -J pixy
#SBATCH -c 1
#SBATCH --mem-per-cpu=4G
#SBATCH -t 0-00:20
#SBATCH -p serial_requeue
#SBATCH -o logs/%x.%A.o
#SBATCH -e logs/%x.%A.e
set -e

source utils/init_env.sh

# Which groupings to use for comparison
grp=${1:-region}

tmp_prefix=$TMPDIR/pixy.$RANDOM
vcf_fn=$tmp_prefix.vcf.gz

echo "Using tmp_prefix:"
echo "$tmp_prefix"

# Make bed of overlapping windows
window_bed="results/bcf_pipe/call/drum.hi_dep_region.bed"
wsize=100
ssize=$(echo "$wsize / 2" | bc) # Step size is half of window size
bedtools makewindows -b $window_bed -w $wsize -s $ssize > $tmp_prefix.bed

# Make population file
if [ $grp == "region" ]; then
    # If using region then include cuspidata data
    merge_vcf="results/bcf_pipe/call/merged.cusp.filt.MERGED.merged.drum.filt.lmiss_0.5.imiss_0.9.vcf.gz"

    # Get column number of metadata to use
    i=$( awk -v grp=$grp 'NR == 1 {for(i=1; i <= NF; i++){if($i == grp){print i}}}' $DRUM_MET )
    
    bcftools query -l $merge_vcf | \
        xargs  -I % grep -m 1 ^%$'\t' $DRUM_MET |
        awk -v i=$i -v OFS="\t" '{print $1,$i}' > $tmp_prefix.pop
    awk -v OFS="\t" '{print $1,"cusp"}' $CUSP_LIST >> $tmp_prefix.pop

    cut -f 1 $tmp_prefix.pop > $tmp_prefix.samps
    
    # Subset vcf
    bcftools view -Oz -S $tmp_prefix.samps $merge_vcf | \
        bcftools +fill-tags -Oz /dev/stdin -- -t NS -S $tmp_prefix.pop > $vcf_fn
    tabix $vcf_fn
else
    merge_vcf="results/snp_postproc/merged.drum.filt.lmiss_0.5.imiss_0.9.polarized.vcf.gz"
    # Get column number of metadata to use
    i=$( awk -v grp=$grp 'NR == 1 {for(i=1; i <= NF; i++){if($i == grp){print i}}}' $DRUM_MET )
   
    bcftools query -l $merge_vcf | \
        xargs  -I % grep -m 1 ^%$'\t' $DRUM_MET | \
        awk -v i=$i -v OFS="\t" '{print $1,$i}' > $tmp_prefix.pop

    bcftools +fill-tags -Oz $merge_vcf -- -t NS -S $tmp_prefix.pop > $vcf_fn
    tabix $vcf_fn
 fi



out_dir="results/pixy"
if [ ! -d $out_dir ]; then
    mkdir -p $out_dir
fi
out_prefix="pixy.${grp}"

# Pixy doesn't do a good job of telling us where missing data is so we
# compile that here ourselves.
for pop in $( cut -f 2 $tmp_prefix.pop | sort | uniq ) ; do
    echo "Checking missingness in $pop"
    # INFO/NS        Number:1  Type:Integer  ..  Number of samples with data

    bcftools query -f '%CHROM\t%POS\t%NS_'"$pop"'\n' $vcf_fn | awk -v OFS="\t" '{print $1,$2-1,$2,"-",$3}' > $tmp_prefix.map.bed

    bedmap --echo --sum --delim '\t' $tmp_prefix.bed $tmp_prefix.map.bed > ${out_dir}/${out_prefix}.NS_${pop}.bed
done


# Activate pixy environment
conda deactivate
conda activate pixy

# Run pixy
pixy --stats pi fst dxy \
    --vcf $vcf_fn \
    --populations $tmp_prefix.pop \
    --bed_file $tmp_prefix.bed \
    --output_folder $out_dir \
    --output_prefix $out_prefix

rm -f $tmp_prefix.*
