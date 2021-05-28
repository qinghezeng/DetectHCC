# To make a comparison with the clusters assigned by consensus clustering,
# run the beginning part of PlotHeatmapConsensus.R except the line 174-188.
# Then run this script.
# ! Caution about the color generation part. To choose which to run from the 2 files.
# For this script, 2 parts to modify, search "modify to compare".

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
# library(philentropy)

# ***************************************************************************************

# Paths
path <- "/media/visiopharm5/WDGold/deeplearning/Hepatocarcinomes/TCGA/heatmap_nanostring"

# Dataset
datas = "selected" # full, filtered-05, filtered-1, filtered-4, filtered-6, filtered-Sia, selected (the same genes in TCGA SD > 4)
trans = "zscore" # median, zscore
sangro_filtered = FALSE
twoclusters_filtered = FALSE

# Clustering
alg = "hc" # km, hc
seed = 55 # 55 for median_filter-6_km and both filter-Sia_km, 50 for zscore_filter-6_km and both filter-Sangro_km
dst = "euclidean" # euclidean, pearson, spearman (slow)
# Set cluster number
ncluster_row = 8 # 12, 14
ncluster_col = 3 # 3, 6

# Rename sample cluster according to heatmap
cluster01 <- "Cluster High" # Cluster High, Cluster Median, Cluster Low
cluster02 <- "Cluster Median"
cluster03 <- "Cluster Low"

# *******************************
# Hierachical clustering
linkage = "ward.D2" # single, average, complete, ward.D2
sreorder = TRUE

# Exported figure size
width = 17
height = 17

# ***************************************************************************************

# Load data
if (trans == "zscore") {
  if (datas == "full") {
    data <- as.matrix(as.data.frame(read.csv(paste(path, "mondor_final_log2-zscore-centering.csv",
                                                   sep = "/"), sep="\t", row.names = 1)))
  } else if (datas == "selected") {
    data <- as.matrix(as.data.frame(read.csv(paste(path, "mondor_final_selected_log2-zscore-centering.csv",
                                                   sep = "/"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-05") {
    data <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_final_filtered-05_log2-zscore.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-1") {
    data <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_final_filtered-1_log2-zscore.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-4") {
    data <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_final_filtered-4_log2-zscore.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-6") {
    data <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_final_filtered-6_log2-zscore.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-Sia") {
    data <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_final_filtered-Sia_log2-zscore.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
    height = 5
  }
} else if (trans == "median") {
  if (datas == "full") {
    data <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_final_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-05") {
    data <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_final_filtered-05_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-1") {
    data <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_final_filtered-1_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-4") {
    data <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_final_filtered-4_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-6") {
    data <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_final_filtered-6_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
  } else if (datas == "filtered-Sia") {
    data <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_final_filtered-Sia_log2-median-centering.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
    data <- data[,c(-1)]
    dnames <- dimnames(data)
    data <- as.matrix(sapply(as.data.frame(data), as.numeric)) # no idea why attribute dimnames not working
    dimnames(data) <- dnames
    height = 5
  }
}

if (sangro_filtered) {
  sangro_genes <- read.csv(paste(path, "Sangro_Table2_GeneList.csv",sep = "\\"), sep="\t", row.names = NULL, header=FALSE)
  sangro_genes[1,] <- "CD274"
  sangro_genes <- sangro_genes[-6,] #drop "CCL3"
  
  data <- data[sangro_genes,]
  
  datas = "filtered-Sangro"
  height = 5
}

if (twoclusters_filtered) {
  # Subset data to only keep genes of the selected 2 clusters
  gene_2clusters  <- as.data.frame(read.csv(paste0(path,"\\gene_clusters_sum_filter-4.csv"), sep=","))
  gene_2clusters <- gene_2clusters[is.element(gene_2clusters$Cluster,c("Cluster 01","Cluster 02")),"Gene"]
  data <- data[gene_2clusters,]
  
  datas = "filtered-2clusters"
  height = 5
}

# **************************************************************************************
# Clustering

if (alg == "km") {
  set.seed(seed)
  cluster_row <- kmeans(data, ncluster_row,iter.max=50)[["cluster"]] # 20-50 iterations
  
  set.seed(seed)
  cluster_col <- kmeans(t(data), ncluster_col,iter.max=50)[["cluster"]] # 20-50 iterations
  # The order of cluster_row should be the same as the data passed to the heatmap! Here is the same.
  # If enable clustering (cluster_cols != FALSE), they will be reordered according to the dendrogram.
  
  # # Ordered by ascending clusters
  # order_row <- order(cluster_row)
  # order_col <- order(cluster_col)
  # 
  # cluster_row <- cluster_row[order_row]
  # cluster_col <- cluster_col[order_col]
  # 
  # # cluster_row_ordered <- cluster_row
  # # cluster_col_ordered <- cluster_col
  # 
  # data <- data[order_row, order_col]
  
  sreorder <- ""
  
} else if (alg == "hc"){
  
  # Perform HC
  if (dst == "pearson" || dst == "spearman" || dst == "kendall") {
    # # Handle missing distance with with use="pairwise.complete.obs"
    # # the cases with missing values are only removed during the calculation of each pairwise correlation.
    # row (gene)
    distCor<-function (m) {
      as.dist(1 - cor(t(m), use="pairwise.complete.obs", method = dst))
    }
    dist_row = distCor(data)
    dist_col = distCor(t(data))
    
  } else {
    
    dist_row = dist(data, method = dst)
    dist_col = dist(t(data), method = dst)
    
  }
  
  hc_row = hclust(dist_row, method = linkage)
  hc_col = hclust(dist_col, method = linkage)
  if (sreorder) {
    hc_col = dendsort(hclust(dist(t(data), method = dst), method = linkage), isReverse = FALSE, type="average") # inverse the dendrogram
    sreorder <- "_reorder"
  } else {
    sreorder <- ""
  }
  
  # Cut trees for fixed number
  # Here using cutree from package dendextend: order_clusters_as_data = FALSE: to organize the clusters by the labels in the dendrogram
  cluster_row <- cutree(tree = as.dendrogram(hc_row), k = ncluster_row, order_clusters_as_data = FALSE)
  cluster_col <- cutree(tree = as.dendrogram(hc_col), k = ncluster_col, order_clusters_as_data = FALSE)
  
  # Make the order same as that of data (necessary following the dendextend::cutree)
  cluster_row = cluster_row[rownames(data)]
  cluster_col = cluster_col[colnames(data)]
  
}

# Reconstruct clusters
cluster_row <- data.frame("Gene" = as.character(stack(cluster_row)[,2]), "Cluster" = paste('Cluster', str_pad(stack(cluster_row)[,1], 2, "left", "0")))
cluster_col <- data.frame("Sample" = as.character(stack(cluster_col)[,2]), "Cluster" = paste('Cluster', str_pad(stack(cluster_col)[,1], 2, "left", "0")))

# **************************************************************************************

if (ncluster_col == 3) {
  # rename sample clusters
  cluster_col[cluster_col=="Cluster 01"] <- cluster01
  cluster_col[cluster_col=="Cluster 02"] <- cluster02
  cluster_col[cluster_col=="Cluster 03"] <- cluster03
}

# Rename and order clusters
if (alg == "km") {
  
  if (ncluster_col == 3) {
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
  
  # order samples inside each cluster
  for (i in 1:length(unique(cluster_col$Cluster))) {
    cluster <- unique(cluster_col$Cluster)[i]
    index_cluster <- which(cluster_col$Cluster == cluster,arr.ind = TRUE)
    cluster_col_cluster <- cluster_col[index_cluster,] # subset
    if (length(index_cluster)!=1) {
      # reorder by hc
      cluster_col_cluster <- cluster_col_cluster[hclust(dist(t(data[,index_cluster]), method = dst),
                                                        method = linkage)[["order"]],]
    }
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

# **************************************************************************************
# Reconstruct clusters for heatmap

cluster_row_named <- cluster_row
cluster_col_named <- cluster_col

cluster_row <- data.frame("Gene Clusters" = cluster_row$Cluster)
cluster_col <- data.frame("Sample Clusters" = cluster_col$Cluster)

# **************************************************************************************
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

if (alg == "km") {
  title <- paste("Clustered heatmap: ", alg, " + ", dst)
  cluster_rows = FALSE
  cluster_cols = FALSE
  cutree_rows = NA
  cutree_cols = NA
  gaps_row = which(!duplicated(cluster_row[1]))[-1]-1
  gaps_col = which(!duplicated(cluster_col[1]))[-1]-1
} else if (alg == "hc") {
  title <- paste("Clustered heatmap: ", alg, " + ", linkage, " + ", dst)
  cluster_rows = hc_row
  cluster_cols = hc_col
  cutree_rows = ncluster_row
  cutree_cols = ncluster_col
  gaps_row = NULL
  gaps_col = NULL
}

# No idea why the color setting do not work
my_heatmap <- function(bottom_annotation = NULL) {
  pheatmap(data_scaled,
           main = title,
           name = "Normalized FPKM Matrix",
           color = rev(brewer.pal(n = 11, name = "RdYlBu")),
           border_color = NA, 
           # cellwidth = 1, cellheight = 1,
           show_rownames = FALSE, show_colnames = FALSE,
           cluster_rows = cluster_rows, 
           cluster_cols = cluster_cols,
           cutree_rows = cutree_rows,
           cutree_cols = cutree_cols,
           gaps_row = gaps_row,
           gaps_col = gaps_col,
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

# png(paste(path, "\\snapshots\\clustermap_",datas,"_",trans,"_",linkage,"_",dst,"_",
# ncluster_row,"_",ncluster_col,sreorder,".png", sep = ""), width = 962, height = 542)
ht = draw(my_heatmap()) # Plot heatmap

# ***********************************************************************************
# Retrieve and export gene clusters

if (alg == "km") {
  
  # # Loop to extract genes for each cluster.
  # for (i in 1:length(unique(cluster_row_named))){ # to loop the clusters
  #   rclu <- names(cluster_row_named[cluster_row_named==i]) # genes belonging to this cluster
  #   if (i == 1) {
  #     rout <- cbind(rclu, paste("Cluster ", str_pad(i, 2, "left", "0"), sep=""))
  #     colnames(rout) <- c("Gene", "Cluster")
  #   } else {
  #     rclu <- cbind(rclu, paste("Cluster ", str_pad(i, 2, "left", "0"), sep=""))
  #     rout <- rbind(rout, rclu)
  #   }
  # }
  
  # # check
  # rout
  
  # export
  write.table(cluster_row_named, file= paste(path, "/gene_clusters_",datas,"_",trans,"_",alg, "_", dst,"_",ncluster_row,sreorder,".csv", sep = ""),
              sep=",", quote=F, row.names=FALSE)
  
} else if (alg == "hc") {
  
  rcl.list <- row_order(ht) # Extract clusters (output is a list)
  
  lapply(rcl.list, function(x) length(x))  #check/confirm size clusters
  
  # Loop to extract genes for each cluster.
  for (i in 1:length(row_order(ht))){ # to loop the clusters
    rclu <- row.names(data)[row_order(ht)[[i]]] # genes belonging to this cluster
    if (i == 1) {
      rout <- cbind(rclu, paste("Cluster ", str_pad(i, 2, "left", "0"), sep=""))
      colnames(rout) <- c("Gene", "Cluster")
    } else {
      rclu <- cbind(rclu, paste("Cluster ", str_pad(i, 2, "left", "0"), sep=""))
      rout <- rbind(rout, rclu)
    }
  }
  
  # # check
  # rout
  
  # export
  write.table(rout, file= paste(path, "/gene_clusters_",datas,"_",trans,"_",alg,"_",linkage, "_", dst,"_",ncluster_row,sreorder,".csv", sep = ""),
              sep=",", quote=F, row.names=FALSE)
}

# ******************
# Retrieve and export sample clusters

if (alg == "km") {
  
  # # Loop to extract genes for each cluster.
  # for (i in 1:length(unique(cluster_col_named))){ # to loop the clusters
  #   cclu <- names(cluster_col_named[cluster_col_named==i]) # genes belonging to this cluster
  #   if (i == 1) {
  #     cout <- cbind(cclu, paste("Cluster ", str_pad(i, 2, "left", "0"), sep=""))
  #     colnames(cout) <- c("Sample", "Cluster")
  #   } else {
  #     cclu <- cbind(cclu, paste("Cluster ", str_pad(i, 2, "left", "0"), sep=""))
  #     cout <- rbind(cout, cclu)
  #   }
  # }
  
  # # check
  # rout
  
  # export
  write.table(cluster_col_named, file= paste(path, "/sample_clusters_",datas,"_",trans,"_",alg, "_", dst,"_",ncluster_col,sreorder,".csv", sep = ""),
              sep=",", quote=F, row.names=FALSE)
  
} else if (alg == "hc") {
  
  ccl.list <- column_order(ht) # Extract clusters (output is a list)
  
  lapply(ccl.list, function(x) length(x))  # check/confirm size clusters
  
  # Loop to extract samples for each cluster.
  for (i in 1:length(column_order(ht))){ # to loop the clusters
    # samples belonging to this cluster
    # drop=FALSE to keep as matrix when only 1 column
    cclu <- colnames(data[, column_order(ht)[[i]], drop = FALSE]) 
    if (i == 1) {
      cout <- cbind(cclu, paste("Cluster ", str_pad(i, 2, "left", "0"), sep=""))
      colnames(cout) <- c("Sample", "Cluster")
    } else {
      cclu <- cbind(cclu, paste("Cluster ", str_pad(i, 2, "left", "0"), sep=""))
      cout <- rbind(cout, cclu)
    }
  }
  
  cout[cout=="Cluster 01"] <- cluster01
  cout[cout=="Cluster 02"] <- cluster02
  cout[cout=="Cluster 03"] <- cluster03
  
  # # check
  # cout
  
  # export
  write.table(cout, file= paste(path, "/sample_clusters_",datas,"_",trans,"_",alg,"_",linkage, "_", dst,"_",ncluster_col,sreorder,".csv", sep = ""),
              sep=",", quote=F, row.names=FALSE)
}

# *********************************************************************************************
# Color gene labels by clusters

for (i in 1:dim(cluster_row)[1]){
  if (i == 1) {
    tmp <- cluster_row[i,1]
    row_label_colors <- cbind(tmp, paste(row_anno_colors[cluster_row[i,1]]))
  } else {
    tmp <- cluster_row[i,1]
    tmp <- cbind(tmp, paste(row_anno_colors[cluster_row[i,1]]))
    row_label_colors <- rbind(row_label_colors, tmp)
  }
}
rm(tmp)
row_label_colors = row_label_colors[, 2]

# ***********************
# Color sample labels by clusters

for (i in 1:dim(cluster_col)[1]){
  if (i == 1) {
    tmp <- cluster_col[i,1]
    col_label_colors <- cbind(tmp, paste(col_anno_colors[cluster_col[i,1]]))
  } else {
    tmp <- cluster_col[i,1]
    tmp <- cbind(tmp, paste(col_anno_colors[cluster_col[i,1]]))
    col_label_colors <- rbind(col_label_colors, tmp)
  }
}
rm(tmp)
col_label_colors = col_label_colors[, 2]

# # modify to compare
# # To color the labels by the refered clusters
# for (i in 1:dim(cluster_col)[1]){
#   if (i == 1) {
#     tmp <- cluster_col[i,1]
#     col_label_colors <- cbind(tmp, paste(col_anno_colors[cluster_col[i,1]]))
#   } else {
#     tmp <- cluster_col[i,1]
#     tmp <- cbind(tmp, paste(col_anno_colors[cluster_col[i,1]]))
#     col_label_colors <- rbind(col_label_colors, tmp)
#   }
# }
# rm(tmp)
# col_label_colors = col_label_colors[, 2]

# ************************************************************************************
# Plot final heatmap

# No idea why these ways did not work
# col_ann <- HeatmapAnnotation(goo = anno_text(colnames(data), gp = gpar(fontsize = 0.5, col = col_label_colors)))
# q <- p + rowAnnotation(foo = anno_text(rownames(data), gp = gpar(fontsize = 0.5, col = row_label_colors)))
# q <- c(q, col_ann)

# Reconstruct heatmap
b <- HeatmapAnnotation(goo = anno_text(colnames(data), gp = gpar(fontsize = 0.5, col = col_label_colors)))

q <- my_heatmap(bottom_annotation = b) + rowAnnotation(foo = anno_text(rownames(data), gp = gpar(fontsize = 0.5, col = row_label_colors)))

# Export heatmap
if (alg == "km") {
  pdf(paste(path, "/clustermap_",datas,"_",trans,"_",alg,"_",dst,"_",ncluster_row,"_",ncluster_col,sreorder,".pdf", sep = ""),
      compress=FALSE, width=width, height=height)
} else if (alg == "hc") {
  pdf(paste(path, "/clustermap_",datas,"_",trans,"_",alg,"_",linkage,"_",dst,"_",ncluster_row,"_",ncluster_col,sreorder,".pdf", sep = ""),
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
#     data_removed <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_removed-05_log2-zscore.csv.csv",
#                                                    sep = "\\"), sep="\t", row.names = 1)))
#   } else if (datas == "filtered_1") {
#     data_removed <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_removed-1_log2-zscore.csv.csv",
#                                                    sep = "\\"), sep="\t", row.names = 1)))
#   } else if (datas == "filtered_4") {
#     data_removed <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_removed-4_log2-zscore.csv.csv",
#                                                    sep = "\\"), sep="\t", row.names = 1)))
#   } else if (datas == "filtered_6") {
#     data_removed <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_removed-6_log2-zscore.csv",
#                                                    sep = "\\"), sep="\t", row.names = 1)))
#   }
# } else if (trans == "median") {
#   if (datas == "filtered_05") {
#     data_removed <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_removed-05_log2-median-centering.csv",
#                                                    sep = "\\"), sep="\t", row.names = 1)))
#   } else if (datas == "filtered_1") {
#     data_removed <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_removed-1_log2-median-centering.csv",
#                                                    sep = "\\"), sep="\t", row.names = 1)))
#   } else if (datas == "filtered_4") {
#     data_removed <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_removed-4_log2-median-centering.csv",
#                                                    sep = "\\"), sep="\t", row.names = 1)))
#   } else if (datas == "filtered_6") {
#     data_removed <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_removed-6_log2-median-centering.csv",
#                                                    sep = "\\"), sep="\t", row.names = 1)))
#   }
# }
# data_removed <- as.matrix(as.data.frame(read.csv(paste(path, "fpkm_removed_log2-zscore.csv", sep = "\\"),
#                                          sep="\t", row.names = 1)))
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
# if (alg == "km") {
#   pdf(paste(path, "\\removed_genes_std_descending_",datas,"_",trans,"_",alg,"_",dst,"_",ncluster_col,
#             sreorder,".pdf", sep = ""), compress=FALSE, width=width, height=height)
# } else if (alg == "hc") {
#   pdf(paste(path, "\\removed_genes_std_descending_",datas,"_",trans,"_",alg,"_",linkage,"_",dst,"_",
#             ncluster_col,sreorder,".pdf", sep = ""), compress=FALSE, width=width, height=height)
# }
# draw(r)
# dev.off()






# km = kmeans(data, 3) # gene / row
# m2 <- cbind(m,km$cluster)
# o <- order(m2[, 6])
# m2 <- m2[o, ]
#
# # create heatmap using pheatmap
# pheatmap(data, kmeans_k=3)
#
# d=matrix(c(1,2,3, 11,12,13), nrow = 2, ncol = 3)
# d1 = sweep(d,1, apply(d,1,median,na.rm=T))
# as.matrix([as.matrix(1:10)],[as.matrix(1:10)])
#
#
# draw(rowAnnotation(df = cluster_row, annotation_colors = list('test' = row_anno_colors)))

