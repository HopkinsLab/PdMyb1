# PdMyb1

Repository for initial PdMyb1 gene characterization paper.

## Overview

This repo contains the population genetic analyses from Garner et al. 2024 __DOI HERE__.

VIGS, expression data, and phenotyping figures can be found in `phenotype_code/`

ONT sequence processing can be found in `seqproc_code`

SNP calling, association data, and population genetic analyses can be found in `popgen_code/` 

## Dependencies

- conda/mamba (https://conda.io/projects/conda/en/latest/user-guide/install/index.html)
- canu v2.2 (https://github.com/marbl/canu/releases/download/v2.2/canu-2.2.Linux-amd64.tar.xz)
- SACRA (https://github.com/hattori-lab/SACRA)
- plink v1.9 (https://www.cog-genomics.org/plink/)
- All R code was tested using R/4.2.2

Install conda environments:

```bash
conda env create -f envs/myb.yaml
conda env create -f envs/pixy.yaml
conda env create -f envs/nanoQC.yaml
conda env create -f envs/nanofilt.yaml
conda env create -f envs/sacra.yaml
```

In each subdirectory there exists a `utils/init_env.sh` file in which
tool/binary paths are specified. Please edit as needed.


