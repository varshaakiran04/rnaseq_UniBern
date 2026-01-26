# load libraries
if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

BiocManager::install(c(
  "org.Mm.eg.db",
  "clusterProfiler",
  "enrichplot",
  "DOSE",
  "AnnotationDbi"
), ask = FALSE)

library(org.Mm.eg.db)
library(clusterProfiler)
library(enrichplot)
library(DESeq2)
library(ggplot2)

# Prepare gene lists

# sort by adjusted p-value
res_sorted <- res_DKO_adj[order(res_DKO_adj$padj), ]

# top 500 most significant genes
top_500_genes <- rownames(res_sorted)[1:500]

# upregulated genes
top_up <- rownames(
  DE_DKO_adj_upregulated[
    order(DE_DKO_adj_upregulated$padj),
  ][1:250, ]
)

# downregulated genes
top_down <- rownames(
  DE_DKO_adj_downregulated[
    order(DE_DKO_adj_downregulated$padj),
  ][1:250, ]
)

# universe = all genes tested
gene_universe <- rownames(dds)


# GO enrichment analysis

# A: all DE genes
ego_DKO_vs_WT <- enrichGO(
  gene = top_500_genes,
  universe = gene_universe,
  OrgDb = org.Mm.eg.db,
  keyType = "ENSEMBL",
  ont = "BP",
  pAdjustMethod = "BH",
  pvalueCutoff = 0.05,
  readable = TRUE
)

# B: up-regulated genes
ego_up <- enrichGO(
  gene = top_up,
  universe = gene_universe,
  OrgDb = org.Mm.eg.db,
  keyType = "ENSEMBL",
  ont = "BP",
  pAdjustMethod = "BH",
  pvalueCutoff = 0.05,
  readable = TRUE
)

# C: down-regulated genes
ego_down <- enrichGO(
  gene = top_down,
  universe = gene_universe,
  OrgDb = org.Mm.eg.db,
  keyType = "ENSEMBL",
  ont = "BP",
  pAdjustMethod = "BH",
  pvalueCutoff = 0.05,
  readable = TRUE
)


# Visualisation

# output directory
dir.create("results/GO", recursive = TRUE, showWarnings = FALSE)

# A: dotplot for all DE genes
all_dot <- dotplot(ego_DKO_vs_WT, showCategory = 12) +
  theme_minimal() +
  scale_color_gradient(low = "red", high = "blue",
                       name = "Adjusted p-value") +
  labs(title = "Top Enriched GO Terms in DKO vs WT Infection Response",
       subtitle = "Interaction term analysis",
       x = "Gene Ratio",
       y = NULL,
       caption = paste("Analysis based on", length(top_500_genes),
                       "most significant DE genes")) +
  theme(plot.title = element_text(face = "bold", size = 14),
        axis.text.y = element_text(size = 10))

# B: up-regulated genes
up_dot <- dotplot(ego_up, showCategory = 10) +
  theme_minimal() +
  scale_color_gradient(low = "red3", high = "darkred",
                       name = "Adjusted p-value") +
  labs(title = "GO Terms – Upregulated Genes in DKO",
       subtitle = "Stronger response in DKO vs WT",
       x = "Gene Ratio",
       y = NULL,
       caption = paste("Analysis based on", length(top_up),
                       "upregulated genes")) +
  theme(plot.title = element_text(color = "red3", face = "bold", size = 14),
        axis.text.y = element_text(size = 10))

# C: down-regulated genes
down_dot <- dotplot(ego_down, showCategory = 10) +
  theme_minimal() +
  scale_color_gradient(low = "blue3", high = "darkblue",
                       name = "Adjusted p-value") +
  labs(title = "GO Terms – Downregulated Genes in DKO",
       subtitle = "Weaker response in DKO vs WT",
       x = "Gene Ratio",
       y = NULL,
       caption = paste("Analysis based on", length(top_down),
                       "downregulated genes")) +
  theme(plot.title = element_text(color = "blue3", face = "bold", size = 14),
        axis.text.y = element_text(size = 10))

# D: network view
simple_network <- cnetplot(ego_DKO_vs_WT, showCategory = 5)

# E–G: barplots
bar_all <- barplot(ego_DKO_vs_WT, showCategory = 10,
                   title = "Top GO Terms (All DE Genes)",
                   color = "p.adjust") +
  theme_minimal()

bar_up <- barplot(ego_up, showCategory = 8,
                  title = "Top GO Terms – Upregulated",
                  color = "p.adjust") +
  theme_minimal()

bar_down <- barplot(ego_down, showCategory = 8,
                    title = "Top GO Terms – Downregulated",
                    color = "p.adjust") +
  theme_minimal()


# Save plots

pdf("results/GO/GO_ALL_PLOTS.pdf", width = 10, height = 8)
print(all_dot)
print(up_dot)
print(down_dot)
print(simple_network)
print(bar_all)
print(bar_up)
print(bar_down)
dev.off()

ggsave("results/GO/GO_dot_all.png", all_dot, width = 10, height = 7, dpi = 300)
ggsave("results/GO/GO_dot_up.png", up_dot, width = 10, height = 7, dpi = 300)
ggsave("results/GO/GO_dot_down.png", down_dot, width = 10, height = 7, dpi = 300)
ggsave("results/GO/GO_bar_all.png", bar_all, width = 10, height = 7, dpi = 300)
ggsave("results/GO/GO_bar_up.png", bar_up, width = 10, height = 7, dpi = 300)
ggsave("results/GO/GO_bar_down.png", bar_down, width = 10, height = 7, dpi = 300)

png("results/GO/GO_network.png", width = 10, height = 8, units = "in", res = 300)
print(simple_network)
dev.off()

cat("GO enrichment analysis complete\n")
