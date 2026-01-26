# Heatmap of top 50 variable genes

library(DESeq2)
library(pheatmap)

# use VST-normalized data 
vsd <- vst(dds, blind = TRUE)

# extract expression matrix
mat <- assay(vsd)

# calculate variance for each gene
gene_vars <- apply(mat, 1, var)

# select top 50 most variable genes
top_genes <- names(sort(gene_vars, decreasing = TRUE))[1:50]
mat_top <- mat[top_genes, ]

# build annotation dataframe (columns = samples)
annotation_df <- as.data.frame(colData(dds)[, c("type", "condition")])

# ensure rownames match sample names
rownames(annotation_df) <- colnames(mat_top)

# create output directory
dir.create("results/deseq", recursive = TRUE, showWarnings = FALSE)

# generate heatmap object
heatmap_obj <- pheatmap(
  mat_top,
  annotation_col = annotation_df,
  scale = "row",
  clustering_distance_rows = "euclidean",
  clustering_distance_cols = "euclidean",
  clustering_method = "complete",
  show_rownames = FALSE,
  fontsize_col = 8
)


# Save heatmap

# PDF
pdf("results/deseq/heatmap_top50_genes.pdf", width = 10, height = 8)
print(heatmap_obj)
dev.off()

# PNG
png(
  "results/deseq/heatmap_top50_genes.png",
  width = 10,
  height = 8,
  units = "in",
  res = 300
)
print(heatmap_obj)
dev.off()

cat("Heatmap (top 50 variable genes) saved to results/deseq/\n")
