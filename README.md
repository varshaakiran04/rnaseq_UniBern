 The analysis follows a standard RNA-seq pipeline

The following were executed as BASH scripts:
1. Trim Reads: Fastp
2. Quality Control: FastQC and MultiQC
3. Alignmnet: HISAT2
4. BAM Processing: samtools (view, sort and index)
5. Gene Quantification: featureCounts (subread)

The second part of the analysis was done on R and involved the following:
1. Differential Expression (DESeq2)
2. Downstream analysis: PCA, Heatmaps, Volcano plots, GO enrichment

Folder Structure
Scripts/
R_scripts/ differential_expression_analysis + exploratory_data_analysis + heatmap + volcano_plot
Slurm/ fastp + fastqc + multiqc + fastqc_bam + multiqc_bam + hisat2_indexing + hisat2_mapping + featureCounts
GO_analysis/ GO_analysis_and_plots
.gitignore
README.md

