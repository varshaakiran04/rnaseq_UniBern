#!/bin/bash
#SBATCH --job-name=fastqc_bam
#SBATCH --output=/data/users/vkiran/rnaseq_UniBern/results/logs/fastqc_bam_%A_%a.out
#SBATCH --error=/data/users/vkiran/rnaseq_UniBern/results/logs/fastqc_bam_%A_%a.err
#SBATCH --time=02:00:00
#SBATCH --mem=1G
#SBATCH --array=0-14
#SBATCH --cpus-per-task=1
#SBATCH --partition=pibu_el8
#SBATCH --mail-type=END,FAIL
#SBATCH --mail-user=varshaa.kiran@students.unibe.ch

# Paths

CONTAINER="/containers/apptainer/fastqc-0.12.1.sif"
INPUT_DIR="/data/users/vkiran/rnaseq_UniBern/results/bam"
OUTPUT_DIR="/data/users/vkiran/rnaseq_UniBern/results/fastqc_bam"

mkdir -p "$OUTPUT_DIR"


# Sample IDs
samples=(
    SRR7821949
    SRR7821950
    SRR7821951
    SRR7821952
    SRR7821953
    SRR7821968
    SRR7821969
    SRR7821970
    SRR7821954
    SRR7821955
    SRR7821956
    SRR7821957
    SRR7821971
    SRR7821972
    SRR7821973
)

sample=${samples[$SLURM_ARRAY_TASK_ID]}


# Run FastQC on BAM

apptainer exec --bind /data:/data "$CONTAINER" fastqc \
    "$INPUT_DIR/${sample}.sorted.bam" \
    -o "$OUTPUT_DIR" \
    -t $SLURM_CPUS_PER_TASK

