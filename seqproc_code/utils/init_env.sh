#!/usr/bin/env bash
# Activate conda environment
# Initiate paths to be used by all scripts

conda_setup="$('conda' 'shell.bash' 'hook' 2> /dev/null)"
eval "$conda_setup"

POPMAP="../all.samples.popmap.tsv"

CANU="/n/holylfs05/LABS/hopkins_lab/Lab/software/canu-2.2/bin/canu"
export PATH="$PATH:/n/holylfs05/LABS/hopkins_lab/Lab/software/SACRA/scripts/"
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^
# Edit to your own canu and SACRA paths
