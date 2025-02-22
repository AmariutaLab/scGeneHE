#!/bin/bash

plink_file=$1
n_marker=$2
out=$3

echo "Start"

conda activate saige

echo "Sparse GRM ====================="

createSparseGRM.R \
    --plinkFile=${plink_file} \
    --nThreads=4 \
    --outputPrefix=${out} \
    --numRandomMarkerforSparseKin=${n_marker} \
    --relatednessCutoff=0.125 


conda activate r_env

echo "Standardize GRM ================="
Rscript trace.R \
    --grm_path=${out}_relatednessCutoff_0.125_${n_marker}_randomMarkersUsed.sparseGRM.mtx \
    --n_marker=${n_marker} \
    --out=${out} 

echo "Done!"
