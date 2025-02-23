#!/bin/bash

gene_path=$1 # the path to the gene list, where each gene is a row, without header
plink_file_path=$2 # the directory to the plink files for all genes, assuming each gene has its own directory, e.g. plink_file_path/ABT1/ABT1.bed
n_marker=$3 # number of genetic markers used to generate grm
out_file_path=$4 # the directory to the output grm files for all genes, assuming each gene has its own directory, e.g. out_file_path/ABT1/ABT1

echo "Start"

while read -r gene; do
    printf '%s\n' "Processing $gene" 

    conda activate saige
    echo "Sparse GRM ====================="
    createSparseGRM.R \
        --plinkFile=${plink_file_path}/${gene}/${gene} \
        --nThreads=4 \
        --outputPrefix=${out_file_path}/${gene}/${gene} \
        --numRandomMarkerforSparseKin=${n_marker} \
        --relatednessCutoff=0.125 


    conda activate r_env
    echo "Standardize GRM ================="
    Rscript trace.R \
        --grm_path=${out_file_path}/${gene}/${gene}_relatednessCutoff_0.125_${n_marker}_randomMarkersUsed.sparseGRM.mtx \
        --n_marker=${n_marker} \
        --out=${out_file_path}/${gene}/${gene} 

done < "$gene_path"
echo "Done!"
