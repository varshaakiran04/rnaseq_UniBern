#!/bin/bash

#SBATCH --job-name=test_containers
#SBATCH --partition=pibu_el8
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:05:00
#SBATCH --output=/data/users/vkiran/rnaseq_UniBern/results/logs/test_%j.out
#SBATCH --error=/data/users/vkiran/rnaseq_UniBern/results/logs/test_%j.err

echo "=== Testing Containers on Compute Node ==="
echo "Node: $HOSTNAME"
echo "Date: $(date)"
echo ""

echo "1. Testing FastQC:"
apptainer exec /containers/apptainer/fastqc-0.12.1.sif fastqc --version
echo ""

echo "2. Testing Hisat2:"
apptainer exec /containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif hisat2 --version | head -1
echo ""

echo "3. Testing Samtools:"
apptainer exec /containers/apptainer/hisat2_samtools_408dfd02f175cd88.sif samtools --version | head -1
echo ""

echo "4. Testing featureCounts:"
apptainer exec /containers/apptainer/subread_2.0.6.sif featureCounts -v 2>&1 | head -1
echo ""

echo "=== All tests complete! ==="
