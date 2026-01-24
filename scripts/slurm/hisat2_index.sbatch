#!/bin/bash
#SBATCH --job-name=hisat2_index                
#SBATCH --time=12:00:00                        
#SBATCH --mem=32G                              
#SBATCH --cpus-per-task=8                     
#SBATCH --partition=pibu_el8                  
#SBATCH --output=/data/users/vkiran/rnaseq_UniBern/results/logs/hisat2_index.out
#SBATCH --error=/data/users/vkiran/rnaseq_UniBern/results/logs/hisat2_index.err


# Loading HISAT2 via Apptainer

CONTAINER="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"


# Defining reference genome paths

GENOME_FA="/data/users/vkiran/rnaseq_UniBern/reference/Mus_musculus.GRCm39.dna.primary_assembly.fa"
INDEX_DIR="/data/users/vkiran/rnaseq_UniBern/reference/hisat2_index"
INDEX_PREFIX="${INDEX_DIR}/genome"

# Create index directory if it does not exist
mkdir -p "$INDEX_DIR"


# Build HISAT2 genome index


apptainer exec --bind /data:/data "$CONTAINER" hisat2-build \
    -p $SLURM_CPUS_PER_TASK \
    "$GENOME_FA" \
    "$INDEX_PREFIX"

