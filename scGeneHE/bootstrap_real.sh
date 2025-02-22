#!/bin/bash
#SBATCH --job-name="real bootstrap"
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=5
#SBATCH --mem=25G
#SBATCH --account=csd832
#SBATCH --export=ALL
#SBATCH -t 48:00:00

module reset
module load cpu/0.15.4
module unload anaconda3/2020.11 
source ~/.bashrc


boot_rate=$1
n_boot=$2
gene_path=$3
ct_path=$4
plink_path=$5
cell_type=$6
n_ge_pc=$7
n_geno_pc=$8
res_path=$9

conda activate qq

python3 bootstrap_real.py \
    --boot_rate=${boot_rate} \
    --n_boot=${n_boot} \
    --gene_path=${gene_path} \
    --ct_path=${ct_path} \
    --plink_path=${plink_path} \
    --cell_type=${cell_type} \
    --n_ge_pc=${n_ge_pc} \
    --n_geno_pc=${n_geno_pc} \
    --res_path=${res_path}

# sbatch bootstrap_real.sh 1.0 100 /expanse/lustre/projects/ddp412/zix016/1k1k_h2/gwas_gene/RA_genes/gwas_1k1k_gene_inter.csv /expanse/lustre/projects/ddp412/zix016/saige_h2/real_data/CD4_CTL/ /expanse/lustre/projects/ddp412/kakamatsu/plink2 CD4_CTL 2 6 



