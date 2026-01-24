#!/bin/bash
#SBATCH --job-name=featureCounts
#SBATCH --time=4:00:00
#SBATCH --mem=16G
#SBATCH --cpus-per-task=8
#SBATCH --partition=pibu_el8
#SBATCH --output=/data/users/vkiran/rnaseq_UniBern/results/logs/featureCounts_%j.out
#SBATCH --error=/data/users/vkiran/rnaseq_UniBern/results/logs/featureCounts_%j.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=varshaa.kiran@students.unibe.ch

# Container
CONTAINER="/containers/apptainer/subread_2.0.6.sif"

# Paths (FIXED)
ANNOTATION_GTF="/data/users/vkiran/rnaseq_UniBern/reference/Mus_musculus.GRCm39.115.gtf"
BAM_DIR="/data/users/vkiran/rnaseq_UniBern/results/bam"
OUTPUT_DIR="/data/users/vkiran/rnaseq_UniBern/results/counts"
OUTPUT_FILE="${OUTPUT_DIR}/gene_counts.txt"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Run featureCounts
apptainer exec --bind /data:/data "$CONTAINER" featureCounts \
  -p \
  -s 2 \
  -T ${SLURM_CPUS_PER_TASK} \
  -a "$ANNOTATION_GTF" \
  -o "$OUTPUT_FILE" \
  ${BAM_DIR}/*.sorted.bam






