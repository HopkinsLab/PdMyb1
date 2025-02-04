#!/usr/bin/env bash
# Activate conda environment
# Initiate paths to be used by all scripts

conda_setup="$('conda' 'shell.bash' 'hook' 2> /dev/null)"
eval "$conda_setup"
conda activate myb

# Load R
module load R/4.2.2-fasrc01
