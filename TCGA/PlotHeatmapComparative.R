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
list_datas_sample <- c("full","filtered-Sia", "filtered-6", "filtered-6", "filtered-6", "filtered-6") # full, filtered-05, filtered-1, filtered-4, filtered-6, filtered-Sia, filtered-2clusters, sum_filter-4
list_datas_gene <- c("full") # full, filtered-05, filtered-1, filtered-4, filtered-6, filtered-Sia
list_trans_sample <- c("zscore","zscore", "zscore","zscore","median", "median") # median, zscore
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
                                            list_linkage_sample[i], "_", 
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
      if (list_datas_sample[i] == 'sum_filter-4') {
        cluster_sample <- cbind(cluster_sample, read.csv(paste0(out_path,"\\sample_clusters_sum_filter-4.csv"), sep=",",
                                                         col.names=c(paste0("Sample",i),
                                                                     paste0(list_consensus_sample[i],
                                                                            list_datas_sample[i],"_",
                                                                            list_trans_sample[i],"_",
                                                                            list_alg_sample[i],"_",
                                                                            list_linkage_sample[i], "_", 
                                                                            list_dst_sample[i]))))
      } else {      
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
}

# Reorder clusters from High to Low by the cluster column 1 
cluster_sample[cluster_sample=="Cluster Low"] <- "1Cluster Low"
cluster_sample[cluster_sample=="Cluster Median"] <- "2Cluster Median"
cluster_sample[cluster_sample=="Cluster High"] <- "3Cluster High"

cluster_sample <- cluster_sample[order(cluster_sample[,2]),]

cluster_sample[cluster_sample=="1Cluster Low"] <- "Cluster Low"
cluster_sample[cluster_sample=="2Cluster Median"] <- "Cluster Median"
cluster_sample[cluster_sample=="3Cluster High"] <- "Cluster High"

# Save a copy for cluster column 1 and its sample names
cluster_sample_1 <- cluster_sample[,1:2]

# Match all the cluster columns (and sample names) to column 1 
tmp <-  NULL
for (i in 1:(dim(cluster_sample)[2]/2)) {
  cluster_sample[,i*2] <- cluster_sample[,i*2][match(cluster_sample$Sample1,cluster_sample[,i*2-1])] # matches first argument in its second.
  # Index of the columns of sample names
  tmp <- c(tmp, i*2-1)
}
# Delete the columns of sample names
cluster_sample = as.data.frame(cluster_sample[,-tmp], drop=FALSE)
# colnames(cluster_sample) <- gsub("clusters_", "clusters\n_",colnames(cluster_sample))

# Load gene clusters
for (i in 1:length(list_alg_gene)) {
  if (i == 1) {
    if (list_alg_gene[i] == 'km') {
      cluster_gene <- read.table(file= paste(out_path, "\\",list_consensus_gene[i],"gene_clusters_",
                                            list_datas_gene[i],"_",list_trans_gene[i],"_",list_alg_gene[i],
                                            "_",list_dst_gene[i],"_",list_ncluster_gene[i],".csv", sep = ""),
                                sep=",", header=TRUE, 
                                col.names=c(paste0("gene",i), 
                                            paste0(list_consensus_gene[i],list_datas_gene[i],"_",
                                                   list_trans_gene[i],"_",list_alg_gene[i],"_", 
                                                   list_dst_gene[i])))
    } else if (list_alg_gene[i] == 'hc') {
      cluster_gene <- read.table(file= paste(out_path, "\\",list_consensus_gene[i],"gene_clusters_",
                                            list_datas_gene[i],"_",list_trans_gene[i],"_",list_alg_gene[i],
                                            "_",list_linkage_gene[i], "_", list_dst_gene[i],"_",
                                            list_ncluster_gene[i],"_reorder.csv", sep = ""),
                                sep=",", header=TRUE, 
                                col.names=c(paste0("gene",i),
                                            paste0(list_consensus_gene[i],list_datas_gene[i],"_",
                                                   list_trans_gene[i],"_",list_alg_gene[i],"_", 
                                                   list_dst_gene[i])))
    }
  }
  else {
    if (list_alg_gene[i] == 'km') {
      cluster_gene <- cbind(cluster_gene, read.table(file= paste(out_path, "\\",list_consensus_gene[i],
                                                               "gene_clusters_",list_datas_gene[i],"_",
                                                               list_trans_gene[i],"_",list_alg_gene[i],"_",
                                                               list_dst_gene[i],"_",list_ncluster_gene[i],".csv",
                                                               sep = ""),
                                                   sep=",", header=TRUE, 
                                                   col.names=c(paste0("gene",i),
                                                               paste0(list_consensus_gene[i],list_datas_gene[i],
                                                                      "_",list_trans_gene[i],"_",list_alg_gene[i],
                                                                      "_", list_dst_gene[i]))))
    } else if (list_alg_gene[i] == 'hc') {
      cluster_gene <- cbind(cluster_gene, read.table(file= paste(out_path, "\\",list_consensus_gene[i],
                                                               "gene_clusters_",list_datas_gene[i],"_",
                                                               list_trans_gene[i],"_",list_alg_gene[i],"_",
                                                               list_linkage_gene[i], "_", list_dst_gene[i],"_",
                                                               list_ncluster_gene[i],"_reorder.csv", sep = ""),
                                                   sep=",", header=TRUE, 
                                                   col.names=c(paste0("gene",i),
                                                               paste0(list_consensus_gene[i],list_datas_gene[i],
                                                                      "_",list_trans_gene[i],"_",list_alg_gene[i],"_",
                                                                      list_linkage_gene[i], "_", 
                                                                      list_dst_gene[i]))))
    }
  }
}

cluster_gene_1 <- cluster_gene[,1:2]

tmp <-  NULL
for (i in 1:(dim(cluster_gene)[2]/2)) {
  cluster_gene[,i*2] <- cluster_gene[,i*2][match(cluster_gene$gene1,cluster_gene[,i*2-1])] # matches first argument in its second.
  tmp <- c(tmp, i*2-1)
}
cluster_gene = cluster_gene[,-tmp, drop=FALSE]
rm(tmp)
# colnames(cluster_gene) <- gsub("clusters_", "clusters_\n",colnames(cluster_gene))


# Generate distinctive color for cluster labeling
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
set.seed(695032) # 695002
col_anno_colors = sample(col_vector, max(list_ncluster_sample))
col_anno_colors[c(1,2)] <- col_anno_colors[c(2, 1)]
for (i in 1:length(list_ncluster_sample)) {
  names(col_anno_colors)[1:list_ncluster_sample[i]] <- unique(cluster_sample[,1]) # unique(cluster_sample[,1])
  tmp1 <- list( "1" = col_anno_colors[1:list_ncluster_sample[i]])
  names(tmp1) <- colnames(cluster_sample)[i]
  if (i==1) {
    tmp2 <- c(tmp1)
  } else {
    tmp2 <- c(tmp2, tmp1)
  }
}
col_anno_colors <- tmp2
rm(tmp1, tmp2)
# names(row_anno_colors) <- unique(cluster_sample[,1])
# Expected a named list
set.seed(695032) # 695002
row_anno_colors = sample(col_vector, max(list_ncluster_gene))
for (i in 1:length(list_ncluster_gene)) {
  # if (list_ncluster_gene[i] == 2) {
  #   row_anno_colors <- brewer.pal(n = 3, name = "Set2")[1:2]
  # } else {
  #   row_anno_colors <- brewer.pal(n = max(list_ncluster_gene), name = "Set2")
  # }
  names(row_anno_colors)[1:list_ncluster_gene[i]] <- unique(cluster_gene[,i])
  tmp1 <- list( "1" = row_anno_colors[1:list_ncluster_gene[i]])
  names(tmp1) <- colnames(cluster_gene)[i]
  if (i==1) {
    tmp2 <- c(tmp1)
  } else {
    tmp2 <- c(tmp2, tmp1)
  }
}
row_anno_colors <- tmp2
rm(tmp1, tmp2)
# if (max(list_ncluster_gene) == 2) {
# } else {
#   col_anno_colors <- brewer.pal(n = max(list_ncluster_gene), name = "Set3")
# }
# names(col_anno_colors) <- unique(cluster_gene[,1])
# Visualization
par(mfrow=c(1,length(list_ncluster_sample)+length(list_ncluster_gene))) 
for (i in 1:length(list_ncluster_sample)) {
  pie(rep(1,list_ncluster_sample[i]), col=col_anno_colors[[i]], labels=names(col_anno_colors[[i]]))}
for (i in 1:length(list_ncluster_gene)) {
  pie(rep(1,list_ncluster_gene[i]), col=row_anno_colors[[i]], labels=names(row_anno_colors[[i]]))}

dev.off()

data <- data[,match(cluster_sample_1[,1],colnames(data))]
data_scaled <- t(apply(data, 1, function(x) (((x-min(x))/(max(x)-min(x)) * 2 - 1))))

# split <- factor(levels=c("Cluster 02","Cluster 01","Cluster 03"))

# if (alg == "km") {
#   title <- paste("Clustered heatmap: ", alg, " + ", dst)
# } else if (alg == "hc") {
#   title <- paste("Clustered heatmap: ", alg, " + ", linkage, " + ", dst)}

my_heatmap <- function(bottom_annotation = NULL) {
  pheatmap(data_scaled,
           # annotation_col = "Sample Cluster",
           main = "Sample Clusters",
           name = "Normalized FPKM Matrix",
           fontsize = 11.5, 
           color = rev(brewer.pal(n = 11, name = "RdYlBu")),
           border_color = NA, 
           gaps_row = which(!duplicated(cluster_gene[1]))[-1]-1,
           gaps_col = which(!duplicated(cluster_sample[1]))[-1]-1,
           # cellwidth = 5, cellheight = 5,
           show_rownames = FALSE, show_colnames = FALSE,
           # row_title_gp = gpar(font = 1), # not working
           cluster_rows = FALSE, cluster_cols = FALSE,
           # cluster_row_slices = FALSE,
           # row_split = split,
           # annotation_row = cluster_row, annotation_col = cluster_col,
           left_annotation = rowAnnotation(df = cluster_gene,
                                           show_annotation_name = FALSE,
                                           col = row_anno_colors, 
                                           annotation_name_side = "top",
                                           annotation_name_rot = 90),
           top_annotation = HeatmapAnnotation(df = cluster_sample,
                                              col = col_anno_colors,
                                              border = TRUE,
                                              gap = unit(1.5, "mm")),
           bottom_annotation = bottom_annotation,
           # row_split = cluster_row[,1],
           annotation_legend = TRUE, 
           scale = 'none')
}

# png(paste(out_path, "\\snapshots\\clustermap_",datas,"_",trans,"_",linkage,"_",dst,"_",
# ncluster_row,"_",ncluster_sample,sreorder,".png", sep = ""), width = 962, height = 542)
ht = draw(my_heatmap()) # Plot heatmap
dev.off()

# *********************************************************************************************
# Color gene labels by clusters

for (i in 1:dim(cluster_gene_1)[1]){
  if (i == 1) {
    tmp <- cluster_gene_1[i,1]
    row_label_colors <- cbind(tmp, paste(row_anno_colors[[1]][cluster_gene_1[i,2]]))
  } else {
    tmp <- cluster_gene_1[i,1]
    tmp <- cbind(tmp, paste(row_anno_colors[[1]][cluster_gene_1[i,2]]))
    row_label_colors <- rbind(row_label_colors, tmp)
  }
}
rm(tmp)
row_label_colors = row_label_colors[, 2]

# ***********************
# Color sample labels by clusters

for (i in 1:dim(cluster_sample_1)[1]){
  if (i == 1) {
    tmp <- cluster_sample_1[i,1]
    col_label_colors <- cbind(tmp, paste(col_anno_colors[[1]][cluster_sample_1[i,2]]))
  } else {
    tmp <- cluster_sample[i,1]
    tmp <- cbind(tmp, paste(col_anno_colors[[1]][cluster_sample_1[i,2]]))
    col_label_colors <- rbind(col_label_colors, tmp)
  }
}
rm(tmp)
col_label_colors = col_label_colors[, 2]

# ************************************************************************************
# Plot final heatmap

# No idea why these ways did not work
# col_ann <- HeatmapAnnotation(goo = anno_text(colnames(data), gp = gpar(fontsize = 0.5, col = col_label_colors)))
# q <- p + rowAnnotation(foo = anno_text(rownames(data), gp = gpar(fontsize = 0.5, col = row_label_colors)))
# q <- c(q, col_ann)

# Reconstruct heatmap
b <- HeatmapAnnotation(goo = anno_text(colnames(data), gp = gpar(fontsize = 2.5, col = col_label_colors)))

# fontsize = 10
q <- my_heatmap(bottom_annotation = b) + rowAnnotation(foo = anno_text(rownames(data), gp = gpar(fontsize = 10, col = row_label_colors)))

# Export heatmap
for (i in 1:max(length(list_datas_sample), length(list_datas_gene))) {
  if (i <= length(list_datas_sample)) {
    if (i==1) {
      fname <- paste0(out_path, "\\Comparative_Clustermap_")
    } else {
      fname <- paste0(fname, "_VS_")
    }
    if (list_alg_sample[i] == "km") {
      fname <- paste0(fname,list_consensus_sample[i],list_datas_sample[i],"_",list_trans_sample[i],"_",list_alg_sample[i],"_",list_dst_sample[i],"_",list_ncluster_sample[i])
    } else if (list_alg_sample[i] == "hc") {
      fname <- paste0(fname,list_consensus_sample[i],list_datas_sample[i],"_",list_trans_sample[i],"_",list_alg_sample[i],"_",list_linkage_sample[i],"_",list_dst_sample[i],"_",list_ncluster_sample[i])
    }
  }
  if (i <= length(list_datas_gene)) {
    if (list_alg_gene[i] == "km") {
      fname <- paste0(fname,"_",list_consensus_gene[i],list_datas_gene[i],"_",list_trans_gene[i],"_",list_alg_gene[i],"_",list_dst_gene[i],"_",list_ncluster_gene[i])
    } else if (list_alg_gene[i] == "hc") {
      fname <- paste0(fname,"_",list_consensus_gene[i],list_datas_gene[i],"_",list_trans_gene[i],"_",list_alg_gene[i],"_",list_linkage_gene[i],"_",list_dst_gene[i],"_",list_ncluster_gene[i])
    }
  }
}

if (nchar(fname)>180) {
  fname <- substr(fname, 1, 180)
}
fname
fname <- paste0(fname, ".pdf")
pdf(fname, compress=FALSE, width=width, height=height)

draw(q, row_title = paste("Gene Clusters",names(row_anno_colors),sep="\n"), 
     column_title = "Comparative clustered heatmap", column_title_gp = gpar(fontsize = 30, fontface = "bold"))

# Close heatmap
dev.off()
# dev.off()
