#!/usr/bin/env bash
#
#SBATCH -J recode_Atpose
#SBATCH -c 1
#SBATCH --mem-per-cpu=4G
#SBATCH -t 0-00:30
#SBATCH -p serial_requeue
#SBATCH -o logs/%x.%A.o
#SBATCH -e logs/%x.%A.e
set -e

# Plink recode to A-transpose (usually for R use)

source utils/init_env.sh

in_prefix=$1 # Plink prefix to use
out_prefix=$2

$PLINK_CMD --bfile $in_prefix \
    --allow-extra-chr \
    --recode A-transpose \
    --out $out_prefix
