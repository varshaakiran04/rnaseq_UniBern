library(ggplot2)
library(pheatmap)
library(RColorBrewer)

# choose gene of interest
genes_of_interest <- c("Stat1", "Oas1g", "Cxcl2")

# get ENSEMBL ID of the gene of interest
gene_info <- getBM(
  attributes = c('ensembl_gene_id', 'mgi_symbol'),
  filters = 'mgi_symbol',
  values = genes_of_interest,
  mart = ensembl
)

# check for significance of gene of interest in DE result
for(i in 1:nrow(gene_info)) {
  gene_symbol <- gene_info$mgi_symbol[i]
  ensembl_id <- gene_info$ensembl_gene_id[i]
  
  if(ensembl_id %in% rownames(res_DKO_adj)) {
    res <- res_DKO_adj[ensembl_id, ]
    sig <- !is.na(res$padj) & res$padj < 0.05 & abs(res$log2FoldChange) > 1
    
    cat(sprintf("%-6s: padj = %7.2e, log2FC = %6.2f, Significant = %s\n",
                gene_symbol,
                res$padj,
                res$log2FoldChange,
                sig))
  } else {
    cat(gene_symbol, ": Not found in DE results\n")
  }
}

# get normalised values
vsd <- vst(dds, blind = FALSE)
norm_counts_vst <- assay(vsd)

# extract only required genes
ensembl_ids <- gene_info$ensembl_gene_id
expr_matrix <- norm_counts_vst[ensembl_ids, ]

# replace row names with gene symbols
rownames(expr_matrix) <- gene_info$mgi_symbol[match(rownames(expr_matrix), gene_info$ensembl_gene_id)]

# creating a heatmap for the genes of interest

# create sample annotation
annotation_col <- data.frame(
  Genotype = dds$type,
  Condition = dds$condition,
  row.names = colnames(dds)
)

# create gene annotation with log2FC values
log2fc_values <- res_DKO_adj[ensembl_ids, "log2FoldChange"]
names(log2fc_values) <- gene_info$mgi_symbol

annotation_row <- data.frame(
  log2FoldChange = log2fc_values,
  row.names = names(log2fc_values)
)

# define column gaps to separate groups
col_gaps <- c(
  sum(dds$type == "WT" & dds$condition == "Control"),    # after WT Control
  sum(dds$type == "WT"),                                 # after all WT
  sum(dds$type == "WT") + sum(dds$type == "DKO" & dds$condition == "Control")  # after DKO Control
)

# print heatmap and save
heatmap <- pheatmap(expr_matrix,
                    annotation_col = annotation_col,
                    annotation_row = annotation_row,
                    color = colorRampPalette(rev(brewer.pal(n = 7, name = "RdBu")))(100),
                    main = "Expression of Key Genes: Gbp5, Gbp2, Cxcl2",
                    show_rownames = TRUE,
                    show_colnames = FALSE,
                    cluster_cols = FALSE,
                    cluster_rows = FALSE,
                    gaps_col = col_gaps,
                    fontsize_row = 12,
                    fontsize_col = 10,
                    angle_col = 45)

# save as pdf
pdf("heatmap_selected_genes.pdf", width = 10, height = 8)
print(heatmap)
dev.off()

# save as png
png("heatmap_selected_genes.png", width = 10, height = 8, units = "in", res = 300)
print(heatmap)
dev.off()
