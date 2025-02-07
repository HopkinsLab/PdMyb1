#!/bin/bash
#SBATCH -p test # Partition to submit to
#SBATCH -c 1
#SBATCH -t 0-4:00               # Runtime in days-hours:minutes
#SBATCH --mem 5000              # Memory in MB
#SBATCH -J qcfilt           # job name
#SBATCH -o logs/%x.%A_%a.out        # File to which standard out will be written
#SBATCH -e logs/%x.%A_%a.err        # File to which standard err will be written
set -e 

source utils/init_env.sh

i=${SLURM_ARRAY_TASK_ID:-1}
samp=$(awk -v i=$i 'NR == i {print $1}' $POPMAP)

prefix=Samplix.$samp.R2R3Myb.Guppyv.5.0.1

fn=seqs/$prefix.fastq.gz

out_dir=results/filt
if [ ! -d $out_dir ]; then
    mkdir -p $out_dir
fi

# nanoQC
conda activate nanoQC

qc_fn=$out_dir/$prefix.nanoQC.html

tmpdir=$(mktemp -d )
nanoQC -o $tmpdir $fn
mv -f $tmpdir/nanoQC.html $qc_fn


# nanofilt
conda deactivate
conda activate nanofilt

filt_fn=$out_dir/${prefix}.NF_L500_Q10.fastq.gz
zcat  $fn | NanoFilt --headcrop 10 --tailcrop 10 --length 500 --quality 10 | gzip -c > $filt_fn
