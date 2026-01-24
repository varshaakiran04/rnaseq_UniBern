#!/bin/bash

# Project paths
PROJECT_DIR="/data/users/vkiran/rnaseq_UniBern"
SCRIPTS_DIR="${PROJECT_DIR}/scripts"
RESULTS_DIR="${PROJECT_DIR}/results"
REFERENCE_DIR="${PROJECT_DIR}/reference"
ANALYSIS_DIR="${PROJECT_DIR}/analysis"

# Data source
DATA_DIR="/data/courses/rnaseq_course/toxoplasma_de/reads_Blood"

# Container paths
FASTQC_CONTAINER="/containers/apptainer/fastqc-0.12.1.sif"
HISAT2_CONTAINER="/containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif"
SUBREAD_CONTAINER="/containers/apptainer/subread_2.0.6.sif"

# Slurm partition
PARTITION="pibu_el8"

# Resource settings (from assignment)
# FastQC: 1 CPU, 1000 MB, 1 hour
# Hisat2 indexing: 1 CPU, 8000 MB, 3 hours
# Hisat2 mapping: 4 CPU, 8000 MB, 2 hours
# Samtools view: 1 CPU, 4000 MB, 1 hour
# Samtools sort: 4 CPU, 25000 MB, 1 hour
# Samtools index: 1 CPU, 4000 MB, 1 hour
# featureCounts: 4 CPU, 1000 MB, 2 hours
