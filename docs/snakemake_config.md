# Snakemake Configuration

The example configuration is `workflow/config/config.example.yaml`. Copy it for
new analyses and edit paths, model parameters, and environment names.

Run a dry-run after editing:

```sh
snakemake \
  --snakefile workflow/Snakefile \
  --configfile workflow/config/config.example.yaml \
  --cores 1 \
  --dry-run \
  --printshellcmds
```

After creating and activating the Snakemake environment, users can also run the
bundled setup check:

```sh
bash scripts/check_snakemake_setup.sh
```

This verifies that Snakemake is available, checks shell wrapper syntax, validates
the example schema, scans for accidental local hardcoded paths, and dry-runs the
example workflow. It is intended as a lightweight setup test before running
SAIGE or SAIGE-QTL jobs.

## inputs

- `gene_list`: text file with one gene per line and no header.
- `plink_prefix`: PLINK prefix or directory containing per-gene PLINK prefixes.
- `phenotype_dir`: directory containing phenotype files.
- `phenotype_suffix`: suffix appended to each gene prefix to find phenotype files.

## outputs

- `grm_dir`: output directory for sparse GRM files.
- `point_dir`: output directory for point-estimate files.
- `point_suffix`: point-estimate output suffix.
- `bootstrap_dir`: directory for bootstrap phenotype intermediates.
- `bootstrap_estimate_dir`: directory for bootstrap SAIGE-QTL estimate outputs.
- `aggregate_dir`: directory for aggregated bootstrap CSV files.

For large analyses, `bootstrap_dir` can point to scratch or `/tmp` while
`bootstrap_estimate_dir` remains on persistent storage.

## model

- `n_marker`: number of genetic markers used for sparse GRM generation.
- `tau_init`: comma-separated SAIGE-QTL initial variance parameters.
- `covariates`: comma-separated covariates used by SAIGE-QTL.
- `sample_covariates`: comma-separated donor-level covariates.
- `sample_id_col`: donor/sample ID column in phenotype files.
- `trait_type`: SAIGE-QTL trait type, usually `count`.
- `pheno_col`: phenotype column name. If omitted in wrapper mode, defaults to the current gene name.

## bootstrap

- `boot_rate`: fraction of cells sampled with replacement.
- `n_boot`: number of bootstrap replicates.
- `input_prefix`: bootstrap phenotype file prefix.
- `estimate_prefix`: bootstrap estimate output prefix.
- `aggregate_suffix`: suffix for aggregated bootstrap CSV files.
- `seed`: optional random seed for deterministic bootstrap sampling.
- `storage_policy`: `keep` or `cleanup`, passed to `estimate_boot.sh`.
- `snakemake_temp_intermediates`: when `true`, Snakemake marks bootstrap phenotype and ID files as `temp()` outputs.
- `snakemake_temp_bootstrap_estimates`: when `true`, Snakemake marks bootstrap `.rda` and variance-ratio estimate outputs as `temp()` outputs.
- `post_aggregate_cleanup`: `keep` or `cleanup`, passed to `agg_boot.sh`.

Use only one cleanup strategy at first unless you have tested your workflow:

- `storage_policy: keep` and `snakemake_temp_intermediates: false`: keep all intermediates.
- `storage_policy: cleanup`: wrapper deletes bootstrap phenotype files after each successful bootstrap estimate.
- `snakemake_temp_intermediates: true`: Snakemake deletes bootstrap phenotype files after downstream rules no longer need them.
- `snakemake_temp_bootstrap_estimates: true`: Snakemake deletes bootstrap estimate files after aggregation no longer needs them.
- `post_aggregate_cleanup: cleanup`: wrapper removes per-bootstrap directories after each gene's aggregate CSV exists.

Bootstrap `.rda` estimate files are not marked as temp by default because
aggregation depends on them and users may want to inspect or reuse them. Set
`snakemake_temp_bootstrap_estimates: true` only when the aggregate CSV is the
final bootstrap artifact you need to keep.

## runtime

- `tmpdir`: optional scratch or `/tmp` path exposed as Snakemake's `tmpdir` resource.

This does not move declared output files. To move bootstrap phenotype files,
set `outputs.bootstrap_dir`.

## envs

Named conda environments used by the wrapper scripts:

- `saige`
- `saigeqtl`
- `python`
- `r`

The Snakemake scaffold does not create or manage these analysis environments.
Install them before running the workflow. SAIGE-QTL should be installed through
the tested conda recipe workflow, not the upstream YAML route.

## saigeqtl_recipe

Provenance fields for the tested SAIGE-QTL recipe:

- `recipe_repo`
- `recipe_commit`
- `upstream_repo`
- `upstream_commit`
- `note`

Update these fields whenever the SAIGE-QTL recipe or upstream source commit is
changed.
