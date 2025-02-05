#!/usr/bin/env bash
#
#SBATCH -J align
#SBATCH -c 8
#SBATCH -N 1
#SBATCH --mem-per-cpu=4G
#SBATCH -t 0-03:00
#SBATCH -p shared
#SBATCH -o logs/%x.%A_%a.o
#SBATCH -e logs/%x.%A_%a.e
set -e
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

source utils/init_env.sh

i=${SLURM_ARRAY_TASK_ID:-1}

samp=$( cat $DRUM_LIST $CUSP_LIST | awk -v i=$i 'NR == i' )

in_fn=seq/fastas/${samp}.fasta.gz
bam_sort=seq/bams/${samp}.sorted.bam
bam_prim=${bam_sort%.*}.primary.bam

tmpscript=$TMPDIR/align.$i.$RANDOM.sh
echo "Running $tmpscript"

# echo "zcat $in_fn | $MINIMAP_CMD -z 600,200 -a -t 8 -x map-ont ${REF_FASTA}.mmi /dev/stdin | "'\' > $tmpscript
# echo "    samtools addreplacerg -r ID:$samp -r SM:$samp /dev/stdin | "'\' >> $tmpscript
# echo "    samtools sort -O BAM -T $TMPDIR -@ 4 /dev/stdin > $bam_sort" >> $tmpscript

# srun -c $SLURM_CPUS_PER_TASK bash $tmpscript
zcat $in_fn | $MINIMAP_CMD -I 30G -K 1G -z 600,200 -a -t 8 -x map-ont ${REF_FASTA} /dev/stdin | \
    samtools addreplacerg -r "ID:$samp" -r "SM:$samp" /dev/stdin | \
    samtools sort -O BAM -T $TMPDIR -@ 4 /dev/stdin > $bam_sort

samtools index -c $bam_sort

samtools view -b -F 2304 $bam_sort > $bam_prim
samtools index -c $bam_prim

rm -f $tmpscript
