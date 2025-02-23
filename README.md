# scGeneHE (single cell Gene expression Heritability Estimation)

scGeneHE is a method that aim to increase the power of cis-heritaiblity estimates by leveraging the intra- and inter- individual correlation using scRNA-seq data. 

## Environment Setup

Note: This pipeline is still under development. Please wait for our release of a reproducible Snakemake workflow. For now, to run the source code, separate environments of R and Python are required.

scGeneHE requires 4 isolated environments: saige, saigeqtl, r, and python. 

1. Install [SAIGE](https://github.com/weizhouUMICH/SAIGE) using the [bioconda recipe](https://github.com/weizhouUMICH/SAIGE/issues/272).
```sh
    conda create -n saige -c conda-forge -c bioconda "r-base>=4.0" r-saige
    conda activate saige
```

2. Install [SAIGE-QTL](https://github.com/weizhou0/qtl) using the [bioconda recipe](https://github.com/weizhou0/qtl/issues/5). This is a recipe that we created based on the environment needed for SAIGE-QTL. It's now updated to commit [0d1f1eb](https://github.com/weizhou0/qtl/commit/0d1f1ebcc2898eef8c3c6d0a372ee24612ec8ceb) which is sufficient to run scGeneHE. Since SAIGE-QTL is still under development, we will add it to bioconda after it's ready. 
```sh
    conda install -c conda-forge -c bioconda 'aryarm::r-saigeqtl'
    conda activate saigeqtl
```


3. Set up Python environment for bootstrapping.
```sh
    git clone https://github.com/AmariutaLab/scGeneHE.git
    conda env create --file=./envs/pythn.yaml
    conda activate pythn
```

4. Set up R environment for h2 estimation and processing results.
```sh
    conda env create --file=./envs/r_env.yaml
    conda activate r_env
```

## Commands

scGeneHE includes three sequential steps to conduct cis-heritability estimation: generating GRM (genetic relationshipe matrix), point estimate, bootstrap estimate. Each step depends on the previous step's output. 



## Example Usage

