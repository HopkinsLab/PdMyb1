# README

## phenotype_code

All scripts were run using R/4.2.2

### Setup

Install R packages, as needed

```bash
source utils/init_env.sh # Loads conda environment and R module
install_packages.R
```

Make results directory
```bash
mkdir results/
```

### Run scripts

VIGS analyses

```bash
./VigsAnalysis.R
```


Myb expression

```bash
./Myb_expression.R
```

Spectra plots

```bash
./Natural_Color_Variation_Clustering_Reflectance_Spectra.R
```

Results can be found in the `results/` directory






