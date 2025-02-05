#!/usr/bin/env bash
#
#SBATCH -J render_Rmd
#SBATCH -t 0-01:00
#SBATCH -p serial_requeue
#SBATCH -o logs/%x.%A.o
#SBATCH -e logs/%x.%A.e
set -e

source utils/init_env.sh

if [ -z $1 ]; then
    echo "No Rmd file provided."
    exit 1
fi

utils/render_rmd.R $1
