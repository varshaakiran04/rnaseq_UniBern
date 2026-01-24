#!/bin/bash
#SBATCH --job-name=hisat2_map                  # Job name
#SBATCH --time=08:00:00                        # Runtime limit
#SBATCH --mem=32G                              # Memory per task
#SBATCH --cpus-per-task=8                     # Threads per task
#SBATCH --partition=pibu_el8
#SBATCH --array=0-14                           # One task per sample
#SBATCH --output=/data/users/vkiran/rnaseq_UniBern/results/logs/hisat2_%A_%a.out
#SBATCH --error=/data/users/vkiran/rnaseq_UniBern/results/logs/hisat2_%A_%a.err
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=varshaa.kiran@students.unibe.ch


# Container with HISAT2 + Samtools

CONTAINER="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"


# Define input and output paths

INDEX_PREFIX="/data/users/vkiran/rnaseq_UniBern/reference/hisat2_index/genome"
READS_DIR="/data/users/vkiran/rnaseq_UniBern/results/fastp"
OUT_DIR="/data/users/vkiran/rnaseq_UniBern/results/bam"

# Ensure output directory exists
mkdir -p "$OUT_DIR"


# Sample IDs 

samples=(
  SRR7821949 SRR7821950 SRR7821951 SRR7821952 SRR7821953
  SRR7821968 SRR7821969 SRR7821970 SRR7821954 SRR7821955
  SRR7821956 SRR7821957 SRR7821971 SRR7821972 SRR7821973
)

# Select sample corresponding to this array task
SAMPLE=${samples[$SLURM_ARRAY_TASK_ID]}

# Define paired-end read files
R1="${READS_DIR}/${SAMPLE}_1_trimmed.fastq.gz"
R2="${READS_DIR}/${SAMPLE}_2_trimmed.fastq.gz"


# HISAT2 alignment + BAM creation

# Align reads to genome and pipe directly into samtools sort
apptainer exec --bind /data:/data "$CONTAINER" hisat2 \
    -p $SLURM_CPUS_PER_TASK \
    --rna-strandness RF \
    -x "$INDEX_PREFIX" \
    -1 "$R1" \
    -2 "$R2" \
| apptainer exec --bind /data:/data "$CONTAINER" samtools sort \
    -@ $SLURM_CPUS_PER_TASK \
    -o "$OUT_DIR/${SAMPLE}.sorted.bam"


# Index the sorted BAM file

apptainer exec --bind /data:/data "$CONTAINER" samtools index \
    "$OUT_DIR/${SAMPLE}.sorted.bam"







