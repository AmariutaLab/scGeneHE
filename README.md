# scGeneHE (single cell Gene expression Heritability Estimation)
[![DOI](https://zenodo.org/badge/936882217.svg)](https://doi.org/10.5281/zenodo.14920579)

scGeneHE is a method that aims to increase the power of cis-heritability estimates by leveraging intra- and inter-individual correlation in scRNA-seq data. It uses a **`Poisson`** mixed-effects model to quantify the cis-genetic component of gene expression using **`individual cellular profiles`** and supports **`bootstrapping`** for standard error estimation.

## Environment Setup

The recommended interface is the Snakemake workflow in `workflow/Snakefile`. The shell wrappers in `scGeneHE/` remain available for manual or advanced usage. Separate conda environments are required for SAIGE, SAIGE-QTL, Python, R, and optionally Snakemake.

scGeneHE uses four isolated environments: SAIGE, SAIGE-QTL, Python, and R. The default environment names used by the wrapper scripts are `saige`, `saigeqtl`, `pythn`, and `r_env`.

1. Install [SAIGE](https://github.com/weizhouUMICH/SAIGE) using the [bioconda recipe](https://github.com/weizhouUMICH/SAIGE/issues/272)
```sh
    conda create -n saige -c conda-forge -c bioconda "r-base>=4.0" r-saige
    conda activate saige
```

2. Install [SAIGE-QTL](https://github.com/weizhou0/SAIGEQTL). SAIGE-QTL is still under development and the upstream YAML environment has not been reliable for scGeneHE. The tested conda route is to build/install `r-saigeqtl` from the recipe in [`ziqixu091/aryarm-conda`](https://github.com/ziqixu091/aryarm-conda). The current scGeneHE configuration records recipe commit `891e0944282d48cecafd4f2a8d5ba9643c931a89` and upstream SAIGE-QTL commit `0d1f1ebcc2898eef8c3c6d0a372ee24612ec8ceb`.
```sh
    git clone https://github.com/ziqixu091/aryarm-conda.git
    cd aryarm-conda
    conda create -y -n biobuild -c conda-forge -c bioconda bioconda-utils
    conda activate biobuild
    bioconda-utils build --packages r-saigeqtl
    conda create -y -n saigeqtl -c "file://${CONDA_PREFIX}/conda-bld" -c conda-forge -c bioconda r-saigeqtl
    conda activate saigeqtl
```

When updating SAIGE-QTL, update `vcommit` and `sha256` in the recipe, rebuild
`r-saigeqtl`, then update the provenance fields in
`workflow/config/config.example.yaml`.

3. Set up Python environment for bootstrapping
```sh
    git clone https://github.com/AmariutaLab/scGeneHE.git
    conda env create --file=./envs/pythn.yaml
    conda activate pythn
```

4. Set up R environment for h2 estimation and processing results
```sh
    conda env create --file=./envs/r_env.yaml
    conda activate r_env
```

5. Grant execution permission to files
```sh
    chmod +x ./scGeneHE/*.sh
    chmod +x ./scripts/*.sh ./tests/*.sh
```

6. Optional: set up Snakemake to run the workflow scaffold
```sh
    conda env create --file=./envs/snakemake.yaml
    conda activate scgenehe-snakemake
```

The shell wrappers source conda's shell hook before calling `conda activate`.
If your local environment names differ from the defaults, set environment
variables before running the wrappers instead of editing the scripts:

```sh
    export SCGENEHE_SAIGE_ENV=saige
    export SCGENEHE_SAIGEQTL_ENV=saigeqtl
    export SCGENEHE_PY_ENV=qq
    export SCGENEHE_R_ENV=r_env
    export SCGENEHE_SNAKEMAKE_ENV=scgenehe-snakemake
```

## Commands

scGeneHE includes five sequential stages to conduct cis-heritability estimation: generating the cell-level sparse GRM (genetic relationship matrix), fitting the point estimate, creating bootstrap phenotype files, fitting bootstrap estimates, and aggregating bootstrap results. Each stage takes explicit input/output paths so users can organize data by project, cell type, or gene without editing hardcoded paths in the scripts.

Detailed wrapper arguments are documented in [`docs/usage.md`](docs/usage.md). Snakemake configuration fields are documented in [`docs/snakemake_config.md`](docs/snakemake_config.md).

1. Cell-level sparse GRM
    * ```generate_grm``` function takes in a list of genes and genotype data to generate row-expanded genetic relationship matrix in the dimension of number of cells. We enforce the trace of GRM matix to be M (total number of cells) to constrain h2 estimate within the range of [0, 1]. 
    * Input: list of gene, plink files, n_markers used for GRM
    * Output: sparse GRM and GRM id files

2. cis-heritability point estimate
    * ```estimate_point``` function takes in gene expression, covariates data, and GRM to estimate variances of genetic and cell environment components by fitting a Poisson linear mixed model. 
    * Input: gene expression and covariates text file, GRM generated in ```Step 1```
    * Output: variance parameter estimates files

3. Bootstrapping samples
    * ```bootstrap_real``` function takes in all sample gene expression and covariates data to generate bootstrap gene expression and covariates files. We conduct random sampling with replacement across cells.
    * Input: all sample gene expression and covariates text file, number of bootstrap conducted
    * Output: bootstrap gene expression and covariates text files in separate directories

4. cis-heritability estimates of bootstrap samples
    * ```estimate_boot``` function takes in bootstrap gene expression and covariates files to estimate cis-h2 of bootstrap samples.
    * Input: bootstrapped gene expression and covariates text files, GRM generated in ```Step 1```
    * Output: variance parameter estimates files

5. Aggregate bootstrap results
    * ```agg_boot``` function takes in bootstrap estimate results and aggregate them into a result file.
    * Input: variance parameter estimates files generated in ```Step 4```
    * Output: bootstrap estimate result

## Example Usage

We generate sample data to illustrate the usage of scGeneHE. We use publicly available genotype data from [1000 Genome Project](https://www.internationalgenome.org/category/genotypes/) and publicly available single-cell gene expression data from [OneK1K](https://onek1k.org/). We truncate 1MB region from chromosome 1 of 100 randomly sampled European individuals from `1000GP`, combined with 100 random individual's single-cell expression (50 cells per donor) of gene CDC37 in CD4+ T effector memory cells in `OneK1K` data. 

Run these commands from the repository root after completing environment setup.

```sh
    ./scGeneHE/generate_grm.sh \
        ./example/gene_list.txt \
        ./example/HM_chr1_1MB_100_indiv \
        245 \
        ./example

    ./scGeneHE/estimate_point.sh \
        ./example \
        ./example/HM_chr1_1MB_100_indiv \
        ./example \
        _sample_expression \
        ./example \
        245 \
        ./example/gene_list.txt \
        1,0.1,0.1 \
        PC1,PC2,PC3,PC4,PC5,PC6,percent.mt \
        PC1,PC2,PC3,PC4,PC5,PC6 \
        iid count _h2_estimate CDC37

    ./scGeneHE/bootstrap_real.sh \
        1.0 1 ./example/gene_list.txt \
        ./example _sample_expression \
        ./example/HM_chr1_1MB_100_indiv \
        PC1,PC2,PC3,PC4,PC5,PC6,percent.mt \
        ./example 1.0_sample_boot \
        CDC37 iid 20250301

    ./scGeneHE/estimate_boot.sh \
        ./example ./example \
        ./example/gene_list.txt \
        ./example 1.0_sample_boot 1 \
        1,0.1,0.1 PC1,PC2,PC3,PC4,PC5,PC6,percent.mt \
        PC1,PC2,PC3,PC4,PC5,PC6 iid count \
        ./example 1.0_sample_boot 245 \
        ./example/HM_chr1_1MB_100_indiv CDC37 keep

    ./scGeneHE/agg_boot.sh \
        ./example 1.0_sample_boot \
        ./example/result 1 \
        ./example/gene_list.txt \
        _boot_res 
```
All example input and output files could be found under `./example/`. The expected run time for 1 gene in 1 cell type is within 3 minutes, depending on the degree of correlation between individuals in your dataset (less correlated, more time).

## Bootstrap Storage

`estimate_boot.sh` keeps all bootstrap phenotype intermediates by default. This
matches the original workflow and is useful when checking bootstrap input files
or comparing bootstrap distributions.

For large datasets, pass `cleanup` as the final `estimate_boot.sh` argument to
remove bootstrap phenotype intermediates after each matching SAIGE-QTL bootstrap
result is successfully written:

```sh
    ./scGeneHE/estimate_boot.sh ... CDC37 cleanup
```

Cleanup mode removes only `boot{i}/${boot_file_prefix}_{i}.txt` and
`boot{i}/${boot_file_prefix}_id.txt` after `boot{i}/${boot_out_prefix}.rda`
exists and is non-empty. Bootstrap result files are kept for aggregation.

When using Snakemake, bootstrap phenotype intermediates can also be marked as
Snakemake `temp()` files by setting:

```yaml
bootstrap:
  snakemake_temp_intermediates: true
```

Snakemake then deletes those bootstrap phenotype/ID files only after downstream
rules no longer need them. To place these intermediates on scratch or `/tmp`,
set `outputs.bootstrap_dir` in the config to that location. Keep
`outputs.bootstrap_estimate_dir` on persistent storage if you need to preserve
bootstrap `.rda` files for aggregation or later inspection. Set
`runtime.tmpdir` to expose a scratch or `/tmp` directory as `TMPDIR` inside
Snakemake shell jobs; this is separate from where declared output files are
written.

## Snakemake Workflow

The Snakemake scaffold is a workflow wrapper around the existing shell scripts.
It does not build SAIGE-QTL automatically. Install a working named `saigeqtl`
environment first using the recipe workflow above, then set environment names
and paths in `workflow/config/config.example.yaml`.

Dry-run the example workflow from the repository root:

```sh
    conda activate scgenehe-snakemake
    snakemake \
        --snakefile workflow/Snakefile \
        --configfile workflow/config/config.example.yaml \
        --cores 1 \
        --dry-run \
        --printshellcmds
```

Run the workflow by removing `--dry-run`. No Snakemake account or online login
is required.

For new analyses, copy `workflow/config/config.example.yaml`, edit paths and
parameters for your cohort/cell type, and keep the original example config as a
working reference.

## Testing

The repository includes a lightweight smoke-test suite for the example data,
bootstrap file generation, bootstrap aggregation, accidental local-path
hardcoding, shell syntax, and Snakemake dry-run validation. Run it locally with:

```sh
    SCGENEHE_PY_ENV=qq \
    SCGENEHE_R_ENV=r_env \
    SCGENEHE_SNAKEMAKE_ENV=scgenehe-snakemake \
    bash scripts/run_smoke_tests.sh
```

If your conda environments use the default repository names, use
`SCGENEHE_PY_ENV=pythn` and `SCGENEHE_R_ENV=r_env`. GitHub Actions runs the
same smoke tests on every push and pull request.

## Support
Please contact zix020@ucsd.edu 
