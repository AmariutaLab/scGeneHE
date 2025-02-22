#!/bin/bash
#SBATCH --job-name="grm gen"
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=5
#SBATCH --mem=10G
#SBATCH --account=csd832
#SBATCH --export=ALL
#SBATCH -t 4:00:00

module reset
module load cpu/0.15.4
module unload anaconda3/2020.11 
source ~/.bashrc

sim_path=$1
n_sim=$2
n_marker=$3

echo "Start"

conda activate saige

echo "Sparse GRM ====================="
for ((i=0;i<n_sim;i++)); do
    echo "SIM $i"
    plink_file="${sim_path}sim_${i}/HM_chr1_1MB_sim${i}"

    createSparseGRM.R \
        --plinkFile=${plink_file} \
        --nThreads=4 \
        --outputPrefix=${plink_file} \
        --numRandomMarkerforSparseKin=${n_marker} \
        --relatednessCutoff=0.125 
done

conda activate r_env

echo "Standardize GRM ================="
for ((i=0;i<n_sim;i++)); do
    echo "SIM $i"
    plink_file="${sim_path}sim_${i}/HM_chr1_1MB_sim${i}"
    Rscript trace.R \
        --grm_path=${plink_file}_relatednessCutoff_0.125_${n_marker}_randomMarkersUsed.sparseGRM.mtx \
        --n_marker=${n_marker} \
        --out=${plink_file} 
done


echo "Done!"

# sbatch --output="sim_grm.log" generate_grm.sh /expanse/lustre/projects/ddp412/zix016/permut_sim/50_indiv/ 100 245 


