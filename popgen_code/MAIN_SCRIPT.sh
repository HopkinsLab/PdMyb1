#!/usr/bin/env bash

### SETUP ###

# !!! Manual step: confirm/update paths in `utils/init_envs.sh`


# Make directories
dirlist=( logs ref results )
for newdir in ${dirlist[@]}; do
    if [ ! -d $newdir ]; then
        mkdir -p $newdir
    fi
done

### DOWNLOAD REF, SEQUENCE FASTAS ###

#!!! TBD depending on where sequences are being hosted !!!
# Will go in seq/fastas



### ALIGNMENT ###

# FW: Austin used minimap2-v2.9 to do alignment which produces more alignments
# than minimap2-v2.28 (the most recent version). Also, Austin modified the X-drop
# parameter (argument: `-z 600,200`). After investigating it appears the *new* version of 
# minimap2 might yield slightly more homozygous REF sites (0/0); the two versions disagree 
# on snp calls ~5% of the time based on spot-checking sample 01_01_06.

sbatch -a 1-112 ./align.sh


### SNP CALLING, FILTERING ###

sbatch -a 1-112 ./mpileup_and_call.sh # Call genotypes (bcftools)
sbatch ./merge_vcfs.sh drum # Merge drummondii vcfs
sbatch ./merge_vcfs.sh cusp # Merge cuspidata vcfs

# Determine depth in region using DP field
sbatch -c 1 --mem-per-cpu=4G ./render_rmd.sh assess_depth.Rmd
# See assess_depth.html for rendered notebook
# Outputs figureS6.pdf as well


# Filter vcfs and narrow down to high depth window.
sbatch ./filter_vcfs.sh

### SNP POLARIZING, PHASING ###
# Annotate the snps with an AA (ancestral allele) info field
# This allows us to use the rehh R package for Extended Haplotype Homozygosity (EHH)
# analyses downstream.
sbatch ./polarize_snps.sh
sbatch ./phase_snps.sh

### ANALYSES ###

## Pairwise LD
sbatch ./pairwise_ld.sh

## GWAS
sbatch gwas.sh 0.025 Qual_Int
sbatch gwas.sh 0.025 Quant_Chroma
sbatch gwas.sh 0.025 Quant_Int_Bright
sbatch -c 1 --mem-per-cpu=4G ./render_rmd.sh gwas_plot.Rmd

## Pi, dxy, and Fst (computed using pixy)
sbatch pixy.sh region

## Figure 3: 
## GWAS
sbatch -c 1 --mem-per-cpu=8G ./render_rmd.sh figure3.Rmd

## Figure 4: 
## Selection scans, haplotype homozygosity (EHH, XP-EHH), 
## Fst, pi
sbatch -c 1 --mem-per-cpu=16G ./render_rmd.sh figure4.Rmd



