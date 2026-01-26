# Volcano plot
library(ggplot2)

# convert results to data frame
volcano_data <- as.data.frame(res_DKO_adj)

# colour for non-significant
volcano_data$color <- "gray"

# colour for significant genes
# up-regulated
volcano_data$color[!is.na(volcano_data$padj) & 
                     volcano_data$padj < 0.05 & 
                     volcano_data$log2FoldChange > 1] <- "red"
# down-regulated
volcano_data$color[!is.na(volcano_data$padj) & 
                     volcano_data$padj < 0.05 & 
                     volcano_data$log2FoldChange < -1] <- "blue"

# count of upregulated and downregulated
num_red <- sum(volcano_data$color == "red")
num_blue <- sum(volcano_data$color == "blue")

# print count
cat("Up-regulated (red):", num_red, "\n")
cat("Down-regulated (blue):", num_blue, "\n")

simple_volcano <- ggplot(volcano_data, aes(x = log2FoldChange, y = -log10(padj))) +
  
  # add points along with colours
  geom_point(color = volcano_data$color, alpha = 0.6, size = 1) +
  
  # add threshold
  geom_vline(xintercept = c(-1, 1), linetype = "dashed", alpha = 0.5) +
  geom_hline(yintercept = -log10(0.05), linetype = "dashed", alpha = 0.5) +
  
  # add labels
  labs(title = "Differential Response: DKO vs WT",
       x = "log2 Fold Change",
       y = "-log10(p-value)",
       caption = paste("Red =", num_red, "up | Blue =", num_blue, "down")) +
  
  theme_bw()

print(simple_volcano)

# create output directory if needed
dir.create("results/deseq", recursive = TRUE, showWarnings = FALSE)

# save as PDF
pdf("results/deseq/simple_volcano.pdf", width = 8, height = 6)
print(simple_volcano)
dev.off()

# save as PNG
png("results/deseq/simple_volcano.png", width = 8, height = 6, units = "in", res = 300)
print(simple_volcano)
dev.off()
