# scGeneHE (single cell Gene expression Heritability Estimation)

scGeneHE is a method that aim to increase the power of cis-heritaiblity estimates by leveraging the intra- and inter- individual correlation using scRNA-seq data. We employed a **Poisson** mixed-effects model that quantifies the cis-genetic component of gene expression using **individual cellular profiles**. scGeneHE is **robust** enough to conduct **bootstrapping** for standard error estimation of cis-heritability. 

## Environment Setup

Note: This pipeline is still under development. Please wait for our release of a reproducible Snakemake workflow. For now, to run the source code, separate environments of R and Python are required. The typical install time on a desktop computer/server is estimated to be 

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

scGeneHE includes three sequential steps to conduct cis-heritability estimation: generating cell-level sparse GRM (genetic relationship matrix), point estimate, bootstrap estimate. Each step depends on the previous step's output. Here is a brief introduction of the commands, detailed description are included in ```./scGeneHE/```.

1. Cell-level sparse GRM
    * ```generate_grm``` function takes in a list of genes and genotype data to generate row-expanded genetic relationship matrix in the dimension of number of cells. We enforce the trace of GRM matix to be M (total number of cells) to constrain h2 estimate within the range of [0, 1]. 
    * Input: list of gene, plink files, n_markers used for GRM
    * Output: sparse GRM and GRM id files

2. cis-heritability point estimate
    * ```estimate_point``` function takes in gene expression, covariates data, and GRM to estimate variances of genetic and cell environment components by fitting a Poisson linear mixed model. 
    * Input: gene expression and covariates text file, GRM generated in ```Step 1```
    * Output: variance parameter estimates files

3. Bootstrapping samples
    * ```bootsrap_real``` function takes in all sample gene expression and covariates data to generate bootstrap gene expression and covariates files. We conduct random sampling with replacement across cells.
    * Input: all sample gene expression and covariates text file, number of bootstrap conducted
    * Output: bootstrap gene expression and covariates text files in separate directories

4. cis-heritability estimates of bootstrap samples
    * ```estimate_boot``` function takes in bootstrap gene expression and covariates files to estimate cis-h2 of bootstrap samples.
    * Input: gene expression and covariates text file, GRM generated in ```Step 3```
    * Output: variance parameter estimates files

5. Aggregate bootstrap results
    *```agg_boot``` function takes in bootstrap estimate results and aggregate them into a result file.
    * Input: variance parameter estimates files generated in ```Step 4```
    * Output: bootstrap estimate result

## Example Usage

