#!/bin/bash
#SBATCH --job-name=multiqc_fastqc
#SBATCH --output=/data/users/vkiran/rnaseq_UniBern/results/logs/multiqc_%j.out
#SBATCH --error=/data/users/vkiran/rnaseq_UniBern/results/logs/multiqc_%j.err
#SBATCH --time=01:00:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --partition=pibu_el8

# Set paths
CONTAINER="/containers/apptainer/multiqc-1.19.sif"
INPUT_DIR="/data/users/vkiran/rnaseq_UniBern/results/fastqc"
OUTPUT_DIR="/data/users/vkiran/rnaseq_UniBern/results/multiqc/fastqc"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Run MultiQC
apptainer exec --bind /data:/data "$CONTAINER" multiqc \
    "$INPUT_DIR" \
    -o "$OUTPUT_DIR"

echo "MultiQC FastQC analysis complete!"
