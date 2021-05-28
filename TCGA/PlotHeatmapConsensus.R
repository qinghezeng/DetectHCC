
# Load clusters generated from consensus clustering and draw heatmap.

# ****************************************************************************************
# Install libraries

# if (!requireNamespace("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")

# BiocManager::install("ComplexHeatmap") # don't install this version. There is no pheatmap function.
# To install the newest version instead

# library(devtools)
# install_github("jokergoo/ComplexHeatmap")
# 
# # install if necessary
# install.packages("dendextend")

# ***************************************************************************************
# Load libraries

library(ComplexHeatmap)
library(dendextend)
library(RColorBrewer)
library(stringr)
library(dendsort)
library(philentropy)

# ***************************************************************************************
# Paths

in_path <- "E:\\deeplearning\\Hepatocarcinomes\\TCGA\\processed"
out_path <- "E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap"

# ***************************************************************************************
# Load data

# data <- as.data.frame(read.csv('E:\\deeplearning\\Hepatocarcinomes\\TCGA\\processed_backup\\fpkm_final_log2-zscore_CCL3L1.csv', sep="\t", row.names = 1))
# data <- as.matrix(data[row.names(data) != "DEFB134", , drop = FALSE]) # remove all-0 row: DEFB134

datas = "full" # full, filtered-05, filtered-1, filtered-4, filtered-6, filtered-Sia
trans = "median" # median, zscore
sangro_filtered = TRUE

width = 17
height = 17
fontsize_row = 0.5

# Load new data
if (trans == "zscore") {
  if (datas == "full") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_log2-zscore_CCL3L1-noDEFB134.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-05") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-05_log2-zscore.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-1") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-1_log2-zscore.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-4") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-4_log2-zscore.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-6") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-6_log2-zscore.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-Sia") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-Sia_log2-zscore.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
    height = 5
  }
} else if (trans == "median") {
  if (datas == "full") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-05") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-05_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-1") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-1_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-4") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-4_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-6") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-6_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-Sia") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-Sia_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
    data <- data[,c(-1)]
    dnames <- dimnames(data)
    data <- as.matrix(sapply(as.data.frame(data), as.numeric)) # no idea why attribute dimnames not working
    dimnames(data) <- dnames
    height = 5
    fontsize_row = 8}
}

if (sangro_filtered) {
  sangro_genes <- read.csv(paste(in_path, "Sangro_Table2_GeneList.csv",sep = "\\"), sep="\t", row.names = NULL, header=FALSE)
  sangro_genes[1,] <- "CD274"
  sangro_genes <- sangro_genes[-6,] #drop "CCL3"
  
  data <- data[sangro_genes,]
  
  datas = "filtered-Sangro"
  height = 5
  fontsize_row = 8
}

# **************************************************************************************
# Load clusters

alg = "km" # km, hc
linkage = "ward.D2" # single, average, complete, ward.D2
dst = "euclidean" # euclidean, pearson, spearman (slow)

# Set cluster number
ncluster_row = 2 # 12, 14
ncluster_col = 3 # 3, 6

# Rename sample cluster according to heatmap
cluster01 <- "Cluster Median" # Cluster High, Cluster Median, Cluster Low
cluster02 <- "Cluster Low"
cluster03 <- "Cluster High"

# Load consensus clustering probabilities belonging to each cluster, for all the K
if (alg == "km") {
  cluster_row  <- as.data.frame(read.csv(paste(out_path,"\\",datas,"_",trans,"_","gene","_",alg,"_",dst,"_0.8_0.8_1200","\\","itemConsensus.csv",sep=""), sep=","))
  cluster_col  <- as.data.frame(read.csv(paste(out_path,"\\",datas,"_",trans,"_","sample","_",alg,"_",dst,"_0.8_0.8_1200","\\","itemConsensus.csv",sep=""), sep=","))
} else if (alg == "hc") {
  cluster_row  <- as.data.frame(read.csv(paste(out_path,"\\",datas,"_",trans,"_","gene","_",alg,"_",linkage,"_",dst,"_0.8_0.8_1200","\\","itemConsensus.csv",sep=""), sep=","))
  cluster_col  <- as.data.frame(read.csv(paste(out_path,"\\",datas,"_",trans,"_","sample","_",alg,"_",linkage,"_",dst,"_0.8_0.8_1200","\\","itemConsensus.csv",sep=""), sep=","))  
}

# Extract the prob belonging to each cluster, for the K we want
cluster_row <- cluster_row[cluster_row$k == ncluster_row,]
cluster_col <- cluster_col[cluster_col$k == ncluster_col,]

# Only keep the highest prob row for each observation
for (i in 1:length(unique(cluster_row$item))){
  if (i == 1) {
    rclu <- cluster_row[cluster_row$item == unique(cluster_row$item)[i],][1,]
    rout_row <- rclu[rclu$itemConsensus==max(rclu$itemConsensus),]
  } else {
    rclu <- cluster_row[cluster_row$item == unique(cluster_row$item)[i],]
    rclu <- rclu[rclu$itemConsensus==max(rclu$itemConsensus),][1,]
    rout_row <- rbind(rout_row, rclu)
  }
}
for (i in 1:length(unique(cluster_col$item))){
  if (i == 1) {
    rclu <- cluster_col[cluster_col$item == unique(cluster_col$item)[i],]
    rout_col <- rclu[rclu$itemConsensus==max(rclu$itemConsensus),][1,]
  } else {
    rclu <- cluster_col[cluster_col$item == unique(cluster_col$item)[i],]
    rclu <- rclu[rclu$itemConsensus==max(rclu$itemConsensus),][1,]
    rout_col <- rbind(rout_col, rclu)
  }
}

# # Order the clusters
# rout_row <- rout_row[order(rout_row$cluster),]
# rout_col <- rout_col[order(rout_col$cluster),]

# Reconstruct clusters
for (i in 1:dim(rout_row)[1]){
  if (i == 1) {
    rclu <- rout_row$item[i]
    cluster_row <- cbind(rclu, paste("Cluster ", str_pad(rout_row$cluster[i], 2, "left", "0"), sep=""))
    colnames(cluster_row) <- c("Gene", "Cluster")
  } else {
    rclu <- rout_row$item[i]
    rclu <- cbind(rclu, paste("Cluster ", str_pad(rout_row$cluster[i], 2, "left", "0"), sep=""))
    cluster_row <- rbind(cluster_row, rclu)
  }
}
for (i in 1:dim(rout_col)[1]){
  if (i == 1) {
    rclu <- rout_col$item[i]
    cluster_col <- cbind(rclu, paste("Cluster ", str_pad(rout_col$cluster[i], 2, "left", "0"), sep=""))
    colnames(cluster_col) <- c("Sample", "Cluster")
  } else {
    rclu <- rout_col$item[i]
    rclu <- cbind(rclu, paste("Cluster ", str_pad(rout_col$cluster[i], 2, "left", "0"), sep=""))
    cluster_col <- rbind(cluster_col, rclu)
  }
}

cluster_row <- as.data.frame(cluster_row)
cluster_col <- as.data.frame(cluster_col)

# **************************************************************************************
# Rename and order clusters
if (ncluster_col == 3) {
  # rename sample clusters
  cluster_col[cluster_col=="Cluster 01"] <- cluster01
  cluster_col[cluster_col=="Cluster 02"] <- cluster02
  cluster_col[cluster_col=="Cluster 03"] <- cluster03
  
  # Rename and order clusters
  cluster_col[cluster_col=="Cluster Median"] <- "2Cluster Median"
  cluster_col[cluster_col=="Cluster Low"] <- "3Cluster Low"
  cluster_col[cluster_col=="Cluster High"] <- "1Cluster High"
  
  cluster_col <- cluster_col[order(cluster_col[,2],decreasing = FALSE),]
  cluster_row <- cluster_row[order(cluster_row[,2],decreasing = FALSE),]
  
  cluster_col[cluster_col=="1Cluster High"] <- "Cluster High"
  cluster_col[cluster_col=="2Cluster Median"] <- "Cluster Median"
  cluster_col[cluster_col=="3Cluster Low"] <- "Cluster Low"
}

# # The order of cluster_row should be the same as the data passed to the heatmap!
# # If enable clustering (cluster_cols != FALSE), BOTH will be reordered according to the dendrogram.
data <- data[match(cluster_row[,1],rownames(data)),match(cluster_col[,1],colnames(data))]

if (alg == "km") {
  # order samples inside each cluster
  for (i in 1:length(unique(cluster_col$Cluster))) {
    cluster <- unique(cluster_col$Cluster)[i]
    index_cluster <- which(cluster_col$Cluster == cluster,arr.ind = TRUE)
    cluster_col_cluster <- cluster_col[index_cluster,] # subset
    # reorder by hc
    cluster_col_cluster <- cluster_col_cluster[hclust(dist(t(data[,index_cluster]), method = dst),
                                                      method = linkage)[["order"]],]
    if (i == 1) {
      tmp <- cluster_col_cluster
    } else {
      tmp <- rbind(tmp, cluster_col_cluster)
      rownames(tmp) <- NULL
    }
  }
  cluster_col <- tmp
  rm(tmp)
  data <- data[, match(cluster_col[,1],colnames(data))]
  
  # order genes inside each cluster
  for (i in 1:length(unique(cluster_row$Cluster))) {
    cluster <- unique(cluster_row$Cluster)[i]
    index_cluster <- which(cluster_row$Cluster == cluster,arr.ind = TRUE)
    cluster_row_cluster <- cluster_row[index_cluster,,drop=FALSE] # subset
    if (length(index_cluster)!=1) {
      # reorder by hc
      cluster_row_cluster <- cluster_row_cluster[hclust(dist(data[index_cluster,], method = dst),
                                                        method = linkage)[["order"]],]
    }
    
    if (i == 1) {
      tmp <- cluster_row_cluster
    } else {
      tmp <- rbind(tmp, cluster_row_cluster)
      rownames(tmp) <- NULL
    }
  }
  cluster_row <- tmp
  rm(tmp)
  data <- data[match(cluster_row[,1],rownames(data)), ]
}


cluster_row_ordered <- cluster_row
cluster_col_ordered <- cluster_col

cluster_row <- data.frame("Gene Clusters" = cluster_row$Cluster)
cluster_col <- data.frame("Sample Clusters" = cluster_col$Cluster)

# *********************************************************************************
# Generate distinctive color for cluster labeling
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
set.seed(695032) # 695105,695008,695014

if (ncluster_col == 3) {
  col_anno_colors <- c("#E41A1C","#FFD92F","#B3CDE3")
  names(col_anno_colors) <- c("Cluster High", "Cluster Median", "Cluster Low")
} else {
  col_anno_colors = sample(col_vector, ncluster_col)
  # col_anno_colors[c(1,2,3)] <- col_anno_colors[c(1,3,2)]
  # Expected a named list
  names(col_anno_colors) <- unique(cluster_col)[,1]}

# if (ncluster_row == 2) {
#   row_anno_colors <- brewer.pal(n = 3, name = "Set2")[1:2]
# } else {
#   row_anno_colors <- brewer.pal(n = ncluster_row, name = "Set2")
# }
row_anno_colors = sample(col_vector, ncluster_row)
names(row_anno_colors) <- unique(cluster_row)[,1]
# Visualization
par(mfrow=c(1,2)) 
pie(rep(1,length(row_anno_colors)), col=row_anno_colors, labels=names(row_anno_colors))
pie(rep(1,length(col_anno_colors)), col=col_anno_colors, labels=names(col_anno_colors))

# *************************************************************************************
# Plot heatmap

# Scale rows to range [-1, 1] for visualization: 
# ( x - min(x) ) / ( max(x)- min(x) ) ) * ( max(x) - min(x)) + min(x)
data_scaled <- t(apply(data, 1, function(x) (((x-min(x))/(max(x)-min(x)) * 2 - 1))))

# split <- factor(levels=c("Cluster 02","Cluster 01","Cluster 03"))

if (alg == "km") {
  title <- paste("Clustered heatmap: ", alg, " + ", dst)
} else if (alg == "hc") {
  title <- paste("Clustered heatmap: ", alg, " + ", linkage, " + ", dst)}

# No idea why the color setting do not work
my_heatmap <- function(bottom_annotation = NULL) {
  pheatmap(data_scaled,
           main = title,
           name = "Normalized FPKM Matrix",
           color = rev(brewer.pal(n = 11, name = "RdYlBu")),
           border_color = NA, 
           gaps_row = which(!duplicated(cluster_row[1]))[-1]-1,
           gaps_col = which(!duplicated(cluster_col[1]))[-1]-1,
           # cellwidth = 1, cellheight = 1,
           show_rownames = FALSE, show_colnames = FALSE,
           cluster_rows = FALSE, cluster_cols = FALSE,
           # cluster_row_slices = FALSE,
           # row_split = split,
           # annotation_row = cluster_row, annotation_col = cluster_col,
           left_annotation = rowAnnotation(df = cluster_row,
                                           col = list('Gene.Clusters' = row_anno_colors),
                                           annotation_name_side = "top",
                                           annotation_name_rot = 90),
           top_annotation = HeatmapAnnotation(df = cluster_col,
                                              col = list('Sample.Clusters' = col_anno_colors)),
           bottom_annotation = bottom_annotation,
           # row_split = cluster_row[,1],
           annotation_legend = TRUE, 
           scale = 'none')
}

# if (alg == "km") {
#   png(paste(out_path, "\\snapshots\\clustermap_",datas,"_",trans,"_",alg,"_",dst,"_",
#             ncluster_row,"_",ncluster_col,".png", sep = ""), width = 962, height = 542)
# } else if (alg == "hc") {
#   png(paste(out_path, "\\snapshots\\clustermap_",datas,"_",trans,"_",alg,"_",linkage,"_",dst,"_",
#           ncluster_row,"_",ncluster_col,".png", sep = ""), width = 962, height = 542)
# }
ht = draw(my_heatmap()) # Plot heatmap

# ***********************************************************************************
# Export clusters

if (alg == "km") {
  write.table(cluster_row_ordered, file= paste(out_path, "\\consensus_gene_clusters_",datas,"_",trans,"_",alg,"_",dst,"_",ncluster_row,".csv", sep = ""),
              sep=",", quote=F, row.names=FALSE)
  
  write.table(cluster_col_ordered, file= paste(out_path, "\\consensus_sample_clusters_",datas,"_",trans,"_",alg, "_", dst,"_",ncluster_col,".csv", sep = ""),
              sep=",", quote=F, row.names=FALSE)
} else if (alg == "hc") {
  write.table(cluster_row_ordered, file= paste(out_path, "\\consensus_gene_clusters_",datas,"_",trans,"_",alg,"_",linkage,"_",dst,"_",ncluster_row,".csv", sep = ""),
              sep=",", quote=F, row.names=FALSE)
  
  write.table(cluster_col_ordered, file= paste(out_path, "\\consensus_sample_clusters_",datas,"_",trans,"_",alg,"_",linkage, "_", dst,"_",ncluster_col,".csv", sep = ""),
              sep=",", quote=F, row.names=FALSE)
}

# *********************************************************************************************
# Color gene labels by clusters

for (i in 1:dim(cluster_row_ordered)[1]){
  if (i == 1) {
    tmp <- cluster_row_ordered[i,1]
    row_label_colors <- cbind(tmp, paste(row_anno_colors[cluster_row_ordered[i,2]]))
  } else {
    tmp <- cluster_row_ordered[i,1]
    tmp <- cbind(tmp, paste(row_anno_colors[cluster_row_ordered[i,2]]))
    row_label_colors <- rbind(row_label_colors, tmp)
  }
}
rm(tmp)
row_label_colors = row_label_colors[, 2]

# ***********************
# Color sample labels by clusters

for (i in 1:dim(cluster_col_ordered)[1]){
  if (i == 1) {
    tmp <- cluster_col_ordered[i,1]
    col_label_colors <- cbind(tmp, paste(col_anno_colors[cluster_col_ordered[i,2]]))
  } else {
    tmp <- cluster_col_ordered[i,1]
    tmp <- cbind(tmp, paste(col_anno_colors[cluster_col_ordered[i,2]]))
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

q <- my_heatmap(bottom_annotation = b) + rowAnnotation(foo = anno_text(rownames(data), gp = gpar(fontsize = fontsize_row, col = row_label_colors)))

# Export heatmap
if (alg == "km") {
  pdf(paste(out_path, "\\consensus_clustermap_",datas,"_",trans,"_",alg,"_",dst,"_",ncluster_row,"_",ncluster_col,".pdf", sep = ""),
      compress=FALSE, width=width, height=height)
} else if (alg == "hc") {
  pdf(paste(out_path, "\\consensus_clustermap_",datas,"_",trans,"_",alg,"_",linkage,"_",dst,"_",ncluster_row,"_",ncluster_col,".pdf", sep = ""),
      compress=FALSE, width=width, height=height)
}

draw(q)

# Close heatmap
dev.off()
dev.off()
# dev.off()

# # ************************************************************************************
# # Plot heatmap for removed genes by descending std
# 
# # Load data
# if (trans == "zscore") {
#   if (datas == "filtered_05") {
#     data_removed <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_removed-05_log2-zscore.csv.csv",
#                                                    sep = "\\"), sep="\t", row.names = 1)))
#   } else if (datas == "filtered_1") {
#     data_removed <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_removed-1_log2-zscore.csv.csv",
#                                                    sep = "\\"), sep="\t", row.names = 1)))
#   } else if (datas == "filtered_4") {
#     data_removed <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_removed-4_log2-zscore.csv.csv",
#                                                    sep = "\\"), sep="\t", row.names = 1)))
#   } else if (datas == "filtered_6") {
#     data_removed <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_removed-6_log2-zscore.csv",
#                                                    sep = "\\"), sep="\t", row.names = 1)))
#   }
# } else if (trans == "median") {
#   if (datas == "filtered_05") {
#     data_removed <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_removed-05_log2-median-centering.csv",
#                                                    sep = "\\"), sep="\t", row.names = 1)))
#   } else if (datas == "filtered_1") {
#     data_removed <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_removed-1_log2-median-centering.csv",
#                                                    sep = "\\"), sep="\t", row.names = 1)))
#   } else if (datas == "filtered_4") {
#     data_removed <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_removed-4_log2-median-centering.csv",
#                                                    sep = "\\"), sep="\t", row.names = 1)))
#   } else if (datas == "filtered_6") {
#     data_removed <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_removed-6_log2-median-centering.csv",
#                                                    sep = "\\"), sep="\t", row.names = 1)))
#   }
# }
# # data_removed <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_removed_log2-zscore.csv", sep = "\\"),
# #                                          sep="\t", row.names = 1)))
# 
# data_removed_scaled <- t(apply(data_removed, 1, function(x) (((x-min(x))/(max(x)-min(x)) * 2 - 1))))
# 
# r <- pheatmap(data_removed_scaled,
#          main = "Removed low-variance gene",
#          color = rev(brewer.pal(n = 11, name = "RdYlBu")),
#          border_color = NA,
#          show_rownames = FALSE, show_colnames = FALSE,
#          cluster_rows = FALSE, cluster_cols = hc_col,
#          cutree_cols = ncluster_col,
#          # annotation_row = cluster_row, annotation_col = cluster_col,
#          # row_split = cluster_row[,1],
#          right_annotation = rowAnnotation(foo = anno_text(rownames(data_removed), gp = gpar(fontsize = 0.5))),
#          top_annotation = HeatmapAnnotation(df = cluster_col,
#                                             col = list('Sample.Clusters' = col_anno_colors)),
#          bottom_annotation = b,
#          annotation_legend = TRUE,
#          scale = 'none')
# 
# pdf(paste(out_path,"\\removed_genes_std_descending_",datas,"_",trans,".pdf", sep = ""), compress=FALSE, width=17, height=17)
# draw(r)
# dev.off()
# 
# 
# 
# 
# 
# 
# # km = kmeans(data, 3) # gene / row
# # m2 <- cbind(m,km$cluster)
# # o <- order(m2[, 6])
# # m2 <- m2[o, ]
# #
# # # create heatmap using pheatmap
# # pheatmap(data, kmeans_k=3)
# #
# # d=matrix(c(1,2,3, 11,12,13), nrow = 2, ncol = 3)
# # d1 = sweep(d,1, apply(d,1,median,na.rm=T))
# # as.matrix([as.matrix(1:10)],[as.matrix(1:10)])
# #
# #
# # draw(rowAnnotation(df = cluster_row, annotation_colors = list('test' = row_anno_colors)))
# 
