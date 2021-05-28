# BiocManager::install("limma")
# install.packages("statmod")

library("limma")
library("statmod")

# Path
in_path <- "E:\\deeplearning\\Hepatocarcinomes\\TCGA\\processed"
out_path <- "E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap"

# Load data
data <- as.data.frame(as.matrix(as.data.frame(read.csv(paste(out_path, "data_counts_clusters_survival_filtered-sangro_median_consensus_km_euclidean_3.csv",sep = "\\"), 
                                         sep="\t", row.names = 1))))
data <- as.data.frame(data[!is.na(data$"OS_MONTHS"),2:738])
data <- as.matrix(sapply(data, as.numeric))

design <- as.matrix(data[,"OS_MONTHS"])

index1 <- c("CXCL10","CXCL9","HLA-DRA","IDO1","IFNG","STAT1") # 6-Gene Interferon
index2 <- c("CCL5","CD27","CXCL9","CXCR6","IDO1","STAT1") # Interferon
index3 <- c("CD274","CD276","CD8A","LAG3","PDCD1LG2","TIGIT") # T-cell Exhaustion

# roast(log2(t(data[,5:737])+1),index=,design,contrast=1)
mroast(log2(t(data[,5:737])+1),list(set1=index1,set2=index2,set3=index3),design,contrast=1)

fry(log2(t(data[,5:737])+1),list(set1=index1,set2=index2,set3=index3),design,contrast=1)
