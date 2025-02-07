# popgen_code

This directory contains code for sequence and populataion genetic analyses.

The `../seqproc_code/` pipeline should be run first to process the raw ONT sequence FASTAS and prepare them for alignment.

This pipeline should be executable as is using the commands in `MAIN_SCRIPT.sh` to produce Figures 3, 4, S6, and S7.

Note that these scripts were designed to run on a cluster with a SLURM scheduler. If you are using a different system some variables and execution commands (e.g., `sbatch`) may require adjustment.
