 Differential expression analysis

library(DESeq2)
library(biomaRt)


# Extract DESeq2 results

# list available model coefficients
resultsNames(dds)

# Comparison 1: Case vs Control in WT
res_WT <- results(
  dds,
  name = "condition_Case_vs_Control"
)

# Comparison 2: Case vs Control in DKO
res_DKO <- results(
  dds,
  contrast = list(
    c("condition_Case_vs_Control", "typeDKO.conditionCase")
  )
)

# Comparison 3: DKO-specific (interaction term)
res_DKO_adj <- results(
  dds,
  name = "typeDKO.conditionCase"
)


# Filter significant genes

DE_WT <- res_WT[
  !is.na(res_WT$padj) &
    res_WT$padj < 0.05 &
    abs(res_WT$log2FoldChange) > 1,
]

DE_DKO <- res_DKO[
  !is.na(res_DKO$padj) &
    res_DKO$padj < 0.05 &
    abs(res_DKO$log2FoldChange) > 1,
]

DE_DKO_adj <- res_DKO_adj[
  !is.na(res_DKO_adj$padj) &
    res_DKO_adj$padj < 0.05 &
    abs(res_DKO_adj$log2FoldChange) > 1,
]


# Split by direction

DE_DKO_adj_upregulated <- DE_DKO_adj[
  DE_DKO_adj$log2FoldChange > 1,
]

DE_DKO_adj_downregulated <- DE_DKO_adj[
  DE_DKO_adj$log2FoldChange < -1,
]

# add direction column
res_DKO_adj$direction <- "Not significant"
res_DKO_adj$direction[
  rownames(res_DKO_adj) %in% rownames(DE_DKO_adj_upregulated)
] <- "Upregulated"
res_DKO_adj$direction[
  rownames(res_DKO_adj) %in% rownames(DE_DKO_adj_downregulated)
] <- "Downregulated"

DE_DKO_adj$direction <- res_DKO_adj$direction[
  rownames(DE_DKO_adj)
]

# report counts
cat("Up-regulated in DKO:", nrow(DE_DKO_adj_upregulated), "\n")
cat("Down-regulated in DKO:", nrow(DE_DKO_adj_downregulated), "\n")


# Gene ID mapping

ensembl <- useEnsembl(
  biomart = "genes",
  dataset = "mmusculus_gene_ensembl"
)

gene_ids <- rownames(res_DKO_adj)

annot <- getBM(
  attributes = c("ensembl_gene_id", "mgi_symbol"),
  filters = "ensembl_gene_id",
  values = gene_ids,
  mart = ensembl
)

gene_symbols <- annot$mgi_symbol
names(gene_symbols) <- annot$ensembl_gene_id

# replace rownames with gene symbols where available
DE_DKO_adj_renamed <- DE_DKO_adj
mapped_symbols <- gene_symbols[rownames(DE_DKO_adj)]

rownames(DE_DKO_adj_renamed) <- ifelse(
  is.na(mapped_symbols),
  rownames(DE_DKO_adj),
  mapped_symbols
)

# Save results
dir.create("results/deseq", recursive = TRUE, showWarnings = FALSE)

write.table(
  as.data.frame(DE_DKO_adj_renamed),
  file = "results/deseq/DE_DKO_adj_with_symbols.tsv",
  sep = "\t",
  quote = FALSE
)

cat("Differential expression analysis complete\n")
