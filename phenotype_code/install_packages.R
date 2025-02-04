#!/usr/bin/env Rscript

# Install packages
req_pkgs <- readLines("utils/required_pkgs.txt")
for(pkg in req_pkgs){
    if(!require(pkg, character.only=TRUE)){install.packages(pkg, repos="https://cloud.r-project.org/")}
}

# reticulate::py_install("plotly")
# reticulate::py_install("conda-forge::python-kaleido")
