#!/usr/bin/env bash

### SETUP ###

# !!! Manual step: confirm/update paths in `utils/init_envs.sh`


# Make directories
dirlist=( logs results seqs )
for newdir in ${dirlist[@]}; do
    if [ ! -d $newdir ]; then
        mkdir -p $newdir
    fi
done

### SEQUENCE FASTQS ###

#!!! TBD depending on where sequences are being hosted !!!

### FILTER ###
sbatch -a 1-115 qcfilt.sh

### CANU ###
sbatch -a 1-115 canu.sh

### SACRA ###
sbatch -a 1-115 sacra.sh
