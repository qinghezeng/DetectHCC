# ***************************************************************
# # Install package
# if (!requireNamespace("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")
# 
# BiocManager::install("DESeq2")

# ***************************************************************
# Load package
library("DESeq2")
### This package has its own normalization method to calculate for DEGs.
### So it takes un-normalized count reads as input.
# browseVignettes("DESeq2")

# ***************************************************************
# Path
in_path <- "E:\\deeplearning\\Hepatocarcinomes\\TCGA\\processed"
out_path <- "E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap"

datas = "filtered-6" # full, filtered-05, filtered-1, filtered-4, filtered-6 to load cluster
trans = "median" # median, zscore
alg = "km" # km, hc
linkage = "ward.D2" # single, average, complete, ward.D2
dst = "euclidean" # euclidean, pearson, spearman (slow)
consensus = FALSE

# Do Not set the both to TRUE at the same time
sangro_filtered = TRUE
sia_filtered = FALSE

# Set sample cluster
ncluster_col = 3 # 3, 6

# Load data. Always matrix for full gene list.
data <- as.matrix(as.data.frame(read.csv(paste(in_path, "count_matrix_filtered_full.csv",sep = "\\"), 
                                         sep="\t", row.names = 1)))
if (sangro_filtered) {
  lsangro <- read.csv(paste(in_path, "Sangro_Table2_GeneList.csv",sep = "\\"), sep="\t", row.names = NULL,
                      header = FALSE)
  lsangro$V1[1] = "CD274" # CD274(PDL1)
  lsangro <- lsangro[-c(6),] # CCL3
}
if (sia_filtered) {
  lsia <- read.csv2(paste(substr(in_path,1,37), "overlapping_genes_Sia.csv",sep = "\\"),
                    row.names = NULL, header = TRUE)[ ,c('Gene.name')]
}

if (consensus) {
  consensus = "consensus_"
} else {
  consensus = ""
}
if (alg == "km") {
  linkage = ""
} else if (alg == "hc") {
  linkage = paste(linkage, "_", sep="")
}

if (alg == "hc") {
  coldata  <- as.data.frame(read.csv(paste(out_path,"\\",consensus,"sample_clusters_",datas,"_",trans,"_",
                                           alg,"_",linkage,dst,"_",ncluster_col,"_reorder.csv",sep=""),
                                     sep=","))
} else if (alg == "km") {
  coldata  <- as.data.frame(read.csv(paste(out_path,"\\",consensus,"sample_clusters_",datas,"_",trans,"_",
                                           alg,"_",linkage,dst,"_",ncluster_col,".csv",sep=""), sep=","))
}
# coldata  <- as.data.frame(read.csv(paste(out_path,"\\sum_gene_clusters_filter-4.csv",sep=""), sep=","))
# ********************************************************************************
# *****************************************************************************
# # To modify for merging clusters
# coldata[coldata=="Cluster High"] <- "Cluster High + Median"
# coldata[coldata=="Cluster Median"] <- "Cluster High + Median"
# *****************************************************************************
# ********************************************************************************

coldata = coldata[match(colnames(data),coldata$Sample), , drop=FALSE] # same order as that of data
coldata$Cluster <- factor(coldata$Cluster) # categorize
levels(coldata$Cluster)

# ********************************************************************************
# *****************************************************************************
# To modify for merging clusters
levels(coldata$Cluster) <- c("Cluster.High","Cluster.Low","Cluster.Median") # rename levels with safe character
# levels(coldata$Cluster) <- c("Cluster.High.Median","Cluster.Low") # rename levels with safe character
# *****************************************************************************
# ********************************************************************************

levels(coldata$Cluster)

# Build an DESeqDataSet from the count matrix
dds <- DESeqDataSetFromMatrix(countData = data,
                              colData = coldata,
                              design = ~ Cluster)
dds

# Pre-filtering
dds <- dds[ rowSums(counts(dds)) > 1, ] # remains the same

# Differential expression analysis
dds <- DESeq(dds)

resultsNames(dds)

# ********************************************************************************
# *****************************************************************************
# To modify for merging clusters
res <-  results(dds, contrast = c("Cluster","Cluster.High", "Cluster.Low"))
# res <-  results(dds, contrast = c("Cluster","Cluster.High.Median", "Cluster.Low"))
# *****************************************************************************
# ********************************************************************************

res

summary(res, alpha=0.05)

if (sangro_filtered) {
  # Keep only the genes in Sangro's list
  res <- res[match(lsangro,rownames(res)),]
  
  datas <- paste0(datas,"-sangro")
  
} else if (sia_filtered) {
  res <- res[match(lsia,rownames(res)),]
  
  datas <- paste0(datas,"-sia")
}

resOrdered <- res[order(res$padj),]
resOrdered=as.data.frame(resOrdered)
head(resOrdered)

# Save results and summary
# ********************************************************************************
# *****************************************************************************
# To modify for merging clusters
if (alg == "hc") {
  write.csv(resOrdered, file= paste(out_path, "\\",consensus,"DEA_",datas,"_",trans,"_",alg,"_",linkage,
                                    dst,"_",ncluster_col,"_reorder_Cluster.High_vs_Cluster.Low",".csv",
                                    sep = ""),quote=F, row.names=TRUE)
  # write.csv(resOrdered, file= paste(out_path, "\\",consensus,"DEA_",datas,"_",trans,"_",alg,"_",linkage,
  #                                   dst,"_",ncluster_col,"_reorder_Cluster.High.Median_vs_Cluster.Low",
  #                                   ".csv", sep = ""), quote=F, row.names=TRUE)
  sink(paste(out_path, "\\",consensus,"DEA_",datas,"_",trans,"_",alg,"_",linkage, dst,"_",ncluster_col,
             "_reorder_Cluster.High_vs_Cluster.Low",".csv", sep = ""), append = TRUE)
  # sink(paste(out_path, "\\",consensus,"DEA_",datas,"_",trans,"_",alg,"_",linkage, dst,"_",ncluster_col,
  #            "_reorder_Cluster.High.Median_vs_Cluster.Low",".csv", sep = ""), append = TRUE)
  

} else if (alg == "km") {
  write.csv(resOrdered, file= paste(out_path, "\\",consensus,"DEA_",datas,"_",trans,"_",alg,"_",linkage,
                                    dst,"_",ncluster_col,"_Cluster.High_vs_Cluster.Low",".csv", sep = ""),
            quote=F, row.names=TRUE)
  # write.csv(resOrdered, file= paste(out_path, "\\",consensus,"DEA_",datas,"_",trans,"_",alg,"_",linkage,
  #                                   dst,"_",ncluster_col,"_Cluster.High.Median_vs_Cluster.Low",".csv",
  #                                   sep = ""), quote=F, row.names=TRUE)
  sink(paste(out_path, "\\",consensus,"DEA_",datas,"_",trans,"_",alg,"_",linkage, dst,"_",ncluster_col,
             "_Cluster.High_vs_Cluster.Low",".csv", sep = ""), append = TRUE)
  # sink(paste(out_path, "\\",consensus,"DEA_",datas,"_",trans,"_",alg,"_",linkage, dst,"_",ncluster_col,
  #            "_Cluster.High.Median_vs_Cluster.Low",".csv", sep = ""), append = TRUE)
}

# *****************************************************************************
# ********************************************************************************

summary(res, alpha=0.05)
sink()
