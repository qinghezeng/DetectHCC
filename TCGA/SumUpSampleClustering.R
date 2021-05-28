# ***************************************************************************************
# Load libraries

library(ComplexHeatmap)
library(RColorBrewer)
library(stringr)

# ***************************************************************************************

# Paths
in_path <- "E:\\deeplearning\\Hepatocarcinomes\\TCGA\\processed"
out_path <- "E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap"

# Dataset
list_datas_sample <- c("full", "filtered-Sia","filtered-4", "filtered-4", "filtered-4", "filtered-4") # full, filtered-05, filtered-1, filtered-4, filtered-6, filtered-Sia
list_datas_gene <- c("full") # full, filtered-05, filtered-1, filtered-4, filtered-6, filtered-Sia
list_trans_sample <- c("zscore","zscore","zscore","zscore","median","median") # median, zscore
list_trans_gene <- c("zscore") # median, zscore
list_sangro_filtered_sample <- c(TRUE,FALSE,FALSE,FALSE,FALSE,FALSE) # TRUE, FALSE
list_sangro_filtered_gene <- c(TRUE) # TRUE, FALSE
list_consensus_sample <- c(FALSE,TRUE,FALSE,FALSE,FALSE,FALSE) # TRUE, FALSE
list_consensus_gene <- c(FALSE) # TRUE, FALSE

# list_sample_clusters <- c(TRUE) # TRUE, FALSE
# list_gene_clusters <- c(TRUE) # TRUE, FALSE

# Clustering
list_alg_sample <- c("hc","km","hc","km","hc","km") # km, hc
list_alg_gene <- c("hc") # km, hc
list_linkage_sample <- c("ward.D2","","ward.D2","","ward.D2","") # single, average, complete, ward.D2, ""
list_linkage_gene <- c("ward.D2") # single, average, complete, ward.D2, ""
list_dst_sample <- c("euclidean","euclidean","euclidean","euclidean","euclidean","euclidean") # euclidean, pearson, spearman (slow)
list_dst_gene <- c("euclidean") # euclidean, pearson, spearman (slow)

# Set cluster number
# list_ncluster_row <- c(3)
# list_ncluster_sample <- c(3)
list_ncluster_sample <- c(3,3,3,3,3,3)
list_ncluster_gene <- c(5)

# Exported figure size
width = 35
height = 35 # if list_datas[1]

# ***************************************************************************************

# Load data
if (list_trans_sample[1] == "zscore") {
  if (list_datas_sample[1] == "full") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_log2-zscore_CCL3L1-noDEFB134.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (list_datas_sample[1] == "filtered-05") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-05_log2-zscore.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (list_datas_sample[1] == "filtered-1") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-1_log2-zscore.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (list_datas_sample[1] == "filtered-4") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-4_log2-zscore.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (list_datas_sample[1] == "filtered-6") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-6_log2-zscore.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  }  else if (list_datas_sample[1] == "filtered-Sia") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-Sia_log2-zscore.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  }
} else if (list_trans_sample[1] == "median") {
  if (list_datas_sample[1] == "full") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (list_datas_sample[1] == "filtered-05") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-05_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (list_datas_sample[1] == "filtered-1") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-1_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (list_datas_sample[1] == "filtered-4") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-4_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (list_datas_sample[1] == "filtered-6") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-6_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (list_datas_sample[1] == "filtered-Sia") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-Sia_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
    data <- data[,c(-1)]
    dnames <- dimnames(data)
    data <- as.matrix(sapply(as.data.frame(data), as.numeric)) # no idea why attribute dimnames not working
    dimnames(data) <- dnames
    height = 10
  }
}

for (i in 1:length(list_sangro_filtered_sample)) {
  if (i == 1) {
    # if matrix is filtered-Sangro, subset the data, and change datas names for sample clusters
    if (list_sangro_filtered_sample[1]) {
      sangro_genes <- read.csv(paste(in_path, "Sangro_Table2_GeneList.csv",sep = "\\"), sep="\t", row.names = NULL, header=FALSE)
      sangro_genes[1,] <- "CD274"
      sangro_genes <- sangro_genes[-6,] #drop "CCL3"
      
      data <- data[sangro_genes,]
      
      list_datas_sample[1] = "filtered-Sangro"
      height = 10
    }
  } else {
    # only change datas names for sample clusters
    if (list_sangro_filtered_sample[i]) {
      list_datas_sample[i] = "filtered-Sangro"
    }
  }
}
# change datas names for gene clusters
for (i in 1:length(list_sangro_filtered_gene)) {
  if (list_sangro_filtered_gene[i]) {
    list_datas_gene[i] = "filtered-Sangro"
  }
}

# change datas names for sample clusters
for (i in 1:length(list_consensus_sample)) {
  if (list_consensus_sample[i]) {
    list_consensus_sample[i] = "consensus_"
  } else {
    list_consensus_sample[i] = ""
  }
}
# change datas names for sample clusters
for (i in 1:length(list_consensus_gene)) {
  if (list_consensus_gene[i]) {
    list_consensus_gene[i] = "consensus_"
  } else {
    list_consensus_gene[i] = ""
  }
}

# Load sample clusters
for (i in 1:length(list_alg_sample)) {
  if (i == 1) {
    if (list_alg_sample[i] == 'km') {
      cluster_sample <- read.table(file= paste(out_path, "\\",list_consensus_sample[i],"sample_clusters_",
                                               list_datas_sample[i],"_",list_trans_sample[i],"_",list_alg_sample[i],
                                               "_",list_dst_sample[i],"_",list_ncluster_sample[i],".csv", sep = ""),
                                   sep=",", header=TRUE, 
                                   col.names=c(paste0("Sample",i), 
                                               paste0(list_consensus_sample[i],list_datas_sample[i],"_",
                                                      list_trans_sample[i],"_",list_alg_sample[i],"_", 
                                                      list_dst_sample[i])))
    } else if (list_alg_sample[i] == 'hc') {
      cluster_sample <- read.table(file= paste(out_path, "\\",list_consensus_sample[i],"sample_clusters_",
                                               list_datas_sample[i],"_",list_trans_sample[i],"_",list_alg_sample[i],
                                               "_",list_linkage_sample[i], "_", list_dst_sample[i],"_",
                                               list_ncluster_sample[i],"_reorder.csv", sep = ""),
                                   sep=",", header=TRUE, 
                                   col.names=c(paste0("Sample",i),
                                               paste0(list_consensus_sample[i],list_datas_sample[i],"_",
                                                      list_trans_sample[i],"_",list_alg_sample[i],"_", 
                                                      list_dst_sample[i])))
    }
  }
  else {
    if (list_alg_sample[i] == 'km') {
      cluster_sample <- cbind(cluster_sample, read.table(file= paste(out_path, "\\",list_consensus_sample[i],
                                                                     "sample_clusters_",list_datas_sample[i],"_",
                                                                     list_trans_sample[i],"_",list_alg_sample[i],"_",
                                                                     list_dst_sample[i],"_",list_ncluster_sample[i],".csv",
                                                                     sep = ""),
                                                         sep=",", header=TRUE, 
                                                         col.names=c(paste0("Sample",i),
                                                                     paste0(list_consensus_sample[i],list_datas_sample[i],"_",
                                                                            list_trans_sample[i],"_",list_alg_sample[i], "_", 
                                                                            list_dst_sample[i]))))
    } else if (list_alg_sample[i] == 'hc') {
      cluster_sample <- cbind(cluster_sample, read.table(file= paste(out_path, "\\",list_consensus_sample[i],
                                                                     "sample_clusters_",list_datas_sample[i],"_",
                                                                     list_trans_sample[i],"_",list_alg_sample[i],"_",
                                                                     list_linkage_sample[i], "_", list_dst_sample[i],"_",
                                                                     list_ncluster_sample[i],"_reorder.csv", sep = ""),
                                                         sep=",", header=TRUE, 
                                                         col.names=c(paste0("Sample",i),
                                                                     paste0(list_consensus_sample[i],list_datas_sample[i],"_",
                                                                            list_trans_sample[i],"_",list_alg_sample[i],"_",
                                                                            list_linkage_sample[i], "_", list_dst_sample[i]))))
    }
  }
}

# Match all the cluster columns (and sample names) to column 1 
tmp <-  NULL
for (i in 1:(dim(cluster_sample)[2]/2)) {
  cluster_sample[,i*2] <- cluster_sample[,i*2][match(cluster_sample$Sample1,cluster_sample[,i*2-1])] # matches first argument in its second.
  # Index of the columns of sample names
  tmp <- c(tmp, i*2-1)
}
# Keep only the first column of sample names
cluster_sample <- as.data.frame(cluster_sample[,-tmp[c(-1)]], drop=FALSE)

# New df to save the consensus results
cluster_sample_sum <- cluster_sample[,1,drop=FALSE]
# Add an empty col
cluster_sample_sum[,2] <- 0
colnames(cluster_sample_sum) <- c("Sample", "Cluster")

# Extract Cluster High
# Cond 1: filtered.Sangro_zscore_hc_euclidean != "Cluster Low"
# Cond 2: Clustered as "Cluster High" in no less than 4 results
for (i in 1:dim(cluster_sample)[1]) {
  if (cluster_sample[i,2] != "Cluster Low") {
    if (sum(cluster_sample[i,-1]=="Cluster High") >= 4) {
      cluster_sample_sum[i,2] <- "Cluster High"
    }
  }
}
sum(cluster_sample_sum[,2]=="Cluster High")

# Extract Cluster Low
# Cond: Clustered as "Cluster Low" in for no less than 5 results
for (i in 1:dim(cluster_sample)[1]) {
  if (sum(cluster_sample[i,-1]=="Cluster Low") >= 5) {
    cluster_sample_sum[i,2] <- "Cluster Low"
  }
}
sum(cluster_sample_sum[,2]=="Cluster Low")

# Set the rest as "Cluster Median"
cluster_sample_sum[which(cluster_sample_sum[,2]==0),2] <- "Cluster Median"
sum(cluster_sample_sum[,2]=="Cluster Median")

# Reorder clusters from High to Low
cluster_sample_sum[cluster_sample_sum=="Cluster Median"] <- "2Cluster Median"
cluster_sample_sum[cluster_sample_sum=="Cluster Low"] <- "3Cluster Low"
cluster_sample_sum[cluster_sample_sum=="Cluster High"] <- "1Cluster High"

cluster_sample_sum <- cluster_sample_sum[order(cluster_sample_sum[,2],decreasing = FALSE),]

cluster_sample_sum[cluster_sample_sum=="1Cluster High"] <- "Cluster High"
cluster_sample_sum[cluster_sample_sum=="2Cluster Median"] <- "Cluster Median"
cluster_sample_sum[cluster_sample_sum=="3Cluster Low"] <- "Cluster Low"

# Export
write.table(cluster_sample_sum, file= paste(out_path, "\\sample_clusters_sum_filter-4.csv", sep = ""),
            sep=",", quote=F, row.names=FALSE)

