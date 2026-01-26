# check for package, if not available then load
if (!require("BiocManager", quietly = TRUE)) # checking and installing BiocManager
  install.packages("BiocManager")

# Load required packages
BiocManager::install("DESeq2") # main package for differential expression
install.packages("pheatmap")
library(DESeq2)
library(ggplot2)
library(pheatmap)
library(biomaRt)

# Load count data
counts_file <- read.table(
  "counts/gene_counts.txt",
  header = TRUE,
  row.names = 1,
  comment.char = "#",
  sep = "\t"
)

# featureCounts output (keep only count columns)
raw_counts_df <- counts_file[, 7:ncol(counts_file)]

# clean column names (extract SRR IDs from full BAM paths)
colnames(raw_counts_df) <- sub(
  ".*(SRR[0-9]+).*",
  "\\1",
  colnames(raw_counts_df)
)


# Load sample metadata

coldata <- read.table(
  "metadata/samplenames.txt",
  header = TRUE,
  sep = "\t",
  stringsAsFactors = FALSE
)

# set Sample column as rownames
rownames(coldata) <- coldata$Sample

# derive genotype (WT / DKO) from Group
coldata$type <- sub("_.*", "", sub("Blood_", "", coldata$Group))

# derive condition (Case / Control) from Group
coldata$condition <- sub(".*_", "", coldata$Group)

# keep only needed columns
coldata <- coldata[, c("type", "condition")]

# convert to factors
coldata$type <- factor(coldata$type)
coldata$condition <- factor(coldata$condition)

# set reference levels
coldata$type <- relevel(coldata$type, ref = "WT")
coldata$condition <- relevel(coldata$condition, ref = "Control")

# reorder metadata to match counts
coldata <- coldata[colnames(raw_counts_df), ]

# safety check
stopifnot(all(colnames(raw_counts_df) == rownames(coldata)))




# DESeq2 analysis
dds <- DESeqDataSetFromMatrix(
  countData = raw_counts_df,
  colData = coldata,
  design = ~ type + condition + type:condition
)

dds <- DESeq(dds)


# Exploratory analysis: VST + PCA

dir.create("results/deseq", recursive = TRUE, showWarnings = FALSE)

vsd <- vst(dds, blind = TRUE)

pca_plot <- plotPCA(vsd, intgroup = c("type", "condition")) +
  ggtitle("PCA of DESeq2 VST-transformed counts")

ggsave(
  filename = "results/deseq/PCA_plot.png",
  plot = pca_plot,
  width = 8,
  height = 6,
  dpi = 300
)

# Differential expression results
res_WT <- results(dds, name = "condition_Case_vs_Control")

res_DKO <- results(
  dds,
  contrast = list(c("condition_Case_vs_Control", "typeDKO.conditionCase"))
)

res_DKO_adj <- results(dds, name = "typeDKO.conditionCase")

# Filter significant genes
DE_DKO_adj <- res_DKO_adj[
  !is.na(res_DKO_adj$padj) &
    res_DKO_adj$padj < 0.05 &
    abs(res_DKO_adj$log2FoldChange) > 1,
]

write.table(
  as.data.frame(DE_DKO_adj),
  file = "results/deseq/DE_DKO_adj_significant.tsv",
  sep = "\t",
  quote = FALSE
)

cat("DESeq2 exploratory analysis complete\n")
cat("Significant DKO genes:", nrow(DE_DKO_adj), "\n")
