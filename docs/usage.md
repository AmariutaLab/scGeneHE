# scGeneHE Wrapper Usage

Run wrapper commands from the repository root. All wrappers accept either a
project-level directory containing per-gene subdirectories, or a single
gene-level directory, where supported by the argument description.

The wrappers activate conda environments internally. Override default
environment names with:

```sh
export SCGENEHE_SAIGE_ENV=saige
export SCGENEHE_SAIGEQTL_ENV=saigeqtl
export SCGENEHE_PY_ENV=pythn
export SCGENEHE_R_ENV=r_env
```

## File Layout Rules

For gene `GENE`, output-producing wrappers write to:

```text
<out_dir>/GENE/GENE...
```

If `<out_dir>` already ends in `GENE`, wrappers write to:

```text
<out_dir>/GENE...
```

PLINK inputs may be passed as a direct prefix, for example
`example/HM_chr1_1MB_100_indiv`, or as a directory containing per-gene PLINK
prefixes.

## generate_grm.sh

```sh
./scGeneHE/generate_grm.sh \
  <gene_list> \
  <plink_prefix_or_dir> \
  <n_marker> \
  <out_dir>
```

Arguments:

- `gene_list`: text file with one gene per line and no header.
- `plink_prefix_or_dir`: PLINK prefix, or directory containing per-gene PLINK prefixes.
- `n_marker`: number of markers used by SAIGE sparse GRM generation.
- `out_dir`: output directory for per-gene GRM files.

Main outputs per gene:

- `GENE_relatednessCutoff_0.125_<n_marker>_randomMarkersUsed.sparseGRM.mtx`
- `GENE_relatednessCutoff_0.125_<n_marker>_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt`
- `GENE_standard_relatednessCutoff_0.125_<n_marker>_randomMarkersUsed.sparseGRM.mtx`

## estimate_point.sh

```sh
./scGeneHE/estimate_point.sh \
  <grm_dir> \
  <plink_prefix_or_dir> \
  <pheno_dir> \
  <pheno_suffix> \
  <out_dir> \
  <n_marker> \
  <gene_list> \
  <tau_init> \
  <covars> \
  <sample_covars> \
  <sample_id_col> \
  <trait_type> \
  <out_suffix> \
  [pheno_col]
```

Arguments:

- `grm_dir`: directory containing per-gene sparse GRM files.
- `plink_prefix_or_dir`: PLINK prefix or directory.
- `pheno_dir`: directory containing per-gene phenotype files.
- `pheno_suffix`: phenotype suffix with or without `.txt`.
- `out_dir`: output directory for point-estimate files.
- `n_marker`: marker count used for GRM generation.
- `gene_list`: one gene per line, no header.
- `tau_init`: comma-separated SAIGE-QTL initial variance parameters, for example `1,0.1,0.1`.
- `covars`: comma-separated covariates for SAIGE-QTL.
- `sample_covars`: comma-separated donor-level covariates.
- `sample_id_col`: donor/sample ID column in the phenotype file.
- `trait_type`: SAIGE-QTL trait type, usually `count`.
- `out_suffix`: output suffix, for example `_h2_estimate`.
- `pheno_col`: optional phenotype column. Defaults to the current gene name.

## bootstrap_real.sh

```sh
./scGeneHE/bootstrap_real.sh \
  <boot_rate> \
  <n_boot> \
  <gene_list> \
  <pheno_dir> \
  <pheno_suffix> \
  <plink_prefix_or_dir> \
  <covars> \
  <bootstrap_dir> \
  <boot_out_prefix> \
  [pheno_col] \
  [sample_id_col] \
  [seed]
```

Arguments:

- `boot_rate`: fraction of cells sampled with replacement for each bootstrap.
- `n_boot`: number of bootstrap replicates.
- `gene_list`: one gene per line, no header.
- `pheno_dir`: directory containing per-gene phenotype files.
- `pheno_suffix`: phenotype suffix with or without `.txt`.
- `plink_prefix_or_dir`: PLINK prefix or directory.
- `covars`: comma-separated covariates to retain in bootstrap phenotype files.
- `bootstrap_dir`: directory for bootstrap phenotype outputs.
- `boot_out_prefix`: bootstrap phenotype file prefix.
- `pheno_col`: optional phenotype column. Defaults to the current gene name.
- `sample_id_col`: optional sample ID column. Defaults to `iid`.
- `seed`: optional random seed.

Outputs per bootstrap:

- `boot{i}/<boot_out_prefix>_{i}.txt`
- `boot{i}/<boot_out_prefix>_id.txt`

## estimate_boot.sh

```sh
./scGeneHE/estimate_boot.sh \
  <grm_dir> \
  <grm_id_dir> \
  <gene_list> \
  <bootstrap_dir> \
  <boot_file_prefix> \
  <n_boot> \
  <tau_init> \
  <covars> \
  <sample_covars> \
  <sample_id_col> \
  <trait_type> \
  <boot_out_dir> \
  <boot_out_prefix> \
  <n_marker> \
  <plink_prefix_or_dir> \
  [pheno_col] \
  [bootstrap_storage_policy]
```

Arguments:

- `grm_dir`: directory containing standardized sparse GRM files.
- `grm_id_dir`: directory containing sparse GRM sample ID files.
- `gene_list`: one gene per line, no header.
- `bootstrap_dir`: directory containing bootstrap phenotype files.
- `boot_file_prefix`: bootstrap phenotype input prefix.
- `n_boot`: number of bootstrap replicates.
- `tau_init`: comma-separated SAIGE-QTL initial variance parameters.
- `covars`: comma-separated covariates.
- `sample_covars`: comma-separated donor-level covariates.
- `sample_id_col`: donor/sample ID column in bootstrap phenotype files.
- `trait_type`: SAIGE-QTL trait type, usually `count`.
- `boot_out_dir`: output directory for bootstrap estimates.
- `boot_out_prefix`: bootstrap estimate output prefix.
- `n_marker`: marker count used for GRM generation.
- `plink_prefix_or_dir`: PLINK prefix or directory.
- `pheno_col`: optional phenotype column. Defaults to current gene name.
- `bootstrap_storage_policy`: optional `keep` or `cleanup`. Defaults to `keep`.

`cleanup` removes bootstrap phenotype and ID files only after the corresponding
bootstrap `.rda` result exists and is non-empty.

## agg_boot.sh

```sh
./scGeneHE/agg_boot.sh \
  <boot_out_dir> \
  <boot_out_prefix> \
  <agg_out_dir> \
  <n_boot> \
  <gene_list> \
  <agg_out_suffix>
```

Arguments:

- `boot_out_dir`: directory containing bootstrap estimate outputs.
- `boot_out_prefix`: bootstrap estimate output prefix.
- `agg_out_dir`: directory for aggregated bootstrap CSV files.
- `n_boot`: number of bootstrap replicates.
- `gene_list`: one gene per line, no header.
- `agg_out_suffix`: aggregate output suffix, for example `_boot_res`.

Output per gene:

- `<agg_out_dir>/GENE<agg_out_suffix>.csv`
