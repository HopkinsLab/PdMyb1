#!/bin/bash
#SBATCH -p serial_requeue # Partition to submit to
#SBATCH -c 12                  # Number of cores
#SBATCH -N 1                   # Ensure that all cores are on one machine
#SBATCH -t 0-01:00               # Runtime in days-hours:minutes
#SBATCH --mem-per-cpu=1G              # Memory in MB
#SBATCH -J SACRA          # job name
#SBATCH -o logs/%x.%A_%a.out        # File to which standard out will be written
#SBATCH -e logs/%x.%A_%a.err        # File to which standard err will be written
set -e

source utils/init_env.sh
conda activate sacra

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

i=${SLURM_ARRAY_TASK_ID:-1}
samp=$(awk -v i=$i 'NR == i {print $1}' $POPMAP)

prefix=Samplix.$samp.correctedReads
fn=results/canu/$samp/$prefix.fasta.gz

out_dir=results/sacra/$samp
if [ ! -d $out_dir ]; then
    mkdir -p $out_dir
fi
out_fn=$out_dir/$prefix.merged.fasta

fasta=$out_dir/$prefix.fasta
gunzip -c $fn > $fasta

tmpfn=$(mktemp)
echo "bash SACRA.sh \\" > $tmpfn
echo "    -i $fasta \\" >> $tmpfn
echo "    -p $out_fn \\" >> $tmpfn
echo "    -t $SLURM_CPUS_PER_TASK \\" >> $tmpfn
echo "    -c config.yml" >> $tmpfn

srun -c $SLURM_CPUS_PER_TASK bash $tmpfn

gzip ${fasta%.*}.split.fasta
gzip ${fasta%.*}.non_chimera.fasta
gzip $out_fn

rm -f $fasta $fasta.bck $fasta.blasttab* $fasta.des $fasta.prj $fasta.sds $fasta.ssp $fasta.suf $fasta.tis
