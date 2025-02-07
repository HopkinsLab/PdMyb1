#!/usr/bin/env bash
# Activate conda environment
# Initiate paths to be used by all scripts

conda_setup="$('conda' 'shell.bash' 'hook' 2> /dev/null)"
eval "$conda_setup"
conda activate myb

# Load some specific packages (R, GNU parallel)
module load R/4.2.2-fasrc01
module load ncf/1.0.0-fasrc01 parallel/20230422-rocky8_x64-ncf


# Paths

# TMPDIR must be absolute path
if [ -d /scratch ]; then
    TMPDIR=/scratch
fi

DRUM_LIST="config/drum.samples.list"
CUSP_LIST="config/cusp.samples.list"

DRUM_MET="config/drum.metadata.tsv"

REF_FASTA=ref/phlox_flye.v1.0.FINAL.lg_split.fasta

MYB_WINDOW_BED=annot/PdMyb1.gene_window.bed
MYB_ANNOT_BED=annot/PdMyb1.gene.bed

# Software
MINIMAP_CMD="minimap2"
PLINK_CMD="/n/holylfs05/LABS/hopkins_lab/Lab/software/plink_linux/plink"
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Edit to your own plink path
# Minimap2 should be part of myb conda environment


