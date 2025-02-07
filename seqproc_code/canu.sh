#!/bin/bash
#SBATCH -p shared # Partition to submit to
#SBATCH -c 12                   # Number of cores
#SBATCH -N 1                   # Ensure that all cores are on one machine
#SBATCH -t 0-04:00               # Runtime in days-hours:minutes
#SBATCH --mem-per-cpu=2G              # Memory in MB
#SBATCH -J Canu_correction           # job name
#SBATCH -o logs/%x.%A_%a.out        # File to which standard out will be written
#SBATCH -e logs/%x.%A_%a.err        # File to which standard err will be written
set -e

source utils/init_env.sh

export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

i=${SLURM_ARRAY_TASK_ID:-1}
samp=$(awk -v i=$i 'NR == i {print $1}' $POPMAP)

fn=results/filt/Samplix.$samp.R2R3Myb.Guppyv.5.0.1.NF_L500_Q10.fastq.gz

out_dir=results/canu/$samp
if [ ! -d $out_dir ]; then
    mkdir -p $out_dir
fi

tmpfn=$(mktemp)

echo "$CANU -p Samplix.$samp -d $out_dir \\" > $tmpfn
echo "    genomeSize=1m \\" >> $tmpfn
echo "    -nanopore-raw $fn \\" >> $tmpfn
echo "    useGrid=false \\" >> $tmpfn
echo "    -corOutCoverage=10000 \\" >> $tmpfn
echo "    -corMinCoverage=0 -correct" >> $tmpfn

srun -c $SLURM_CPUS_PER_TASK bash $tmpfn
