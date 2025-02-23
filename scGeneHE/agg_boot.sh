#!/bin/bash

boot_out_path=$1 # the output directory of bootstrap estimates, assuming each gene has its own directory, e.g. boot_out_path/gene/boot...
boot_out_str=$2 # the bootstrap output file name, e.g. h2_estimate
agg_out_path=$3 # the output direcotry of aggregated bootstrap results, assuming each gene has its own directory, e.g. output_path/gene/...
n_boot=$4 # number of bootstrap conducted
gene_path=$5 # path to a list of genes, each gene is a row, without header
agg_out_str=$6 # the output file name of aggregated bootstrap results, e.g. _boot_res

conda activate r_env

echo "Start"

while read -r gene; do
	printf '%s\n' " Processing $gene"

	Rscript agg_boot.R \
		--boot_path=${boot_out_path}/${gene} \
		--boot_out_str=${boot_out_str} \
		--n_boot=${n_boot} \
		--gene=$gene \
		--out_path=${output_path}/${gene}/ \
		--out_str=${agg_out_str}

done < "$gene_path"

echo "Done!"


