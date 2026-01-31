#!/bin/bash
#SBATCH --job-name=multiqc_bam
#SBATCH --time=01:00:00
#SBATCH --mem=1G
#SBATCH --cpus-per-task=1
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/vkiran/rnaseq_UniBern/results/logs/multiqc_bam_%j.out
#SBATCH --error=/data/users/vkiran/rnaseq_UniBern/results/logs/multiqc_bam_%j.err


# Paths

CONTAINER="/containers/apptainer/multiqc-1.19.sif"
INPUT_DIR="/data/users/vkiran/rnaseq_UniBern/results/fastqc_bam"
OUTPUT_DIR="/data/users/vkiran/rnaseq_UniBern/results/multiqc/bam"

# Create output directory
mkdir -p "$OUTPUT_DIR"


# Run MultiQC

apptainer exec --bind /data:/data "$CONTAINER" multiqc \
    "$INPUT_DIR" \
    -o "$OUTPUT_DIR"

echo "MultiQC for BAM FastQC complete"


