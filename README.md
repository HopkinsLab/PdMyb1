# PdMyb1

Repository for initial PdMyb1 gene characterization paper.

## Overview

This repo contains the population genetic analyses from Garner et al. 2024 __DOI HERE__.

VIGS, expression data, and phenotyping figures can be found in `phenotype_code/`

SNP calling, association data, and population genetic analyses can be found in `popgen_code/` 

## Dependencies

- conda/mamba (https://conda.io/projects/conda/en/latest/user-guide/install/index.html)
- plink v1.9 (https://www.cog-genomics.org/plink/)
- All R code was tested using R/4.2.2

Install conda environments:

```bash
conda env create -f envs/myb.yaml
conda env create -f envs/pixy.yaml
```

Install plink and edit corresponding variable in `popgen_code/utils/init_env.sh`


