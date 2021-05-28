# ***************************************************************************************
# Load libraries

library(ComplexHeatmap)
library(RColorBrewer)
library(stringr)

library(dendextend) # No idea why cutree() didn't work here without this function


# ***************************************************************************************

# Paths
in_path <- "E:\\deeplearning\\Hepatocarcinomes\\TCGA\\processed"
out_path <- "E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap"

# Gene clustering
alg = "hc" # km, hc
linkage = "ward.D2" # single, average, complete, ward.D2
dst = "euclidean" # euclidean, pearson, spearman (slow)
# Set cluster number
ncluster_row = 5 # 12, 14

# Exported figure size
width = 35
height = 10
fontsize_row = 8

# Load data
data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_log2-zscore_CCL3L1-noDEFB134.csv",
                                               sep = "\\"), sep="\t", row.names = 1)))

sangro_genes <- read.csv(paste(in_path, "Sangro_Table2_GeneList.csv",sep = "\\"), sep="\t", row.names = NULL, header=FALSE)
sangro_genes[1,] <- "CD274"
sangro_genes <- sangro_genes[-6,] #drop "CCL3"

data_sangro <- data[sangro_genes,]


data_sia <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-Sia_log2-zscore.csv",
                                               sep = "\\"), sep="\t", row.names = 1)))

duplicate_index <- match(rownames(data_sangro), rownames(data_sia))
duplicate_index <- duplicate_index[!is.na(match(rownames(data_sangro), rownames(data_sia)))]
data <- rbind(data_sangro, data_sia[-duplicate_index,])

# Load sample clusters
# cluster_col  <- as.data.frame(read.csv(paste0(out_path,"\\sample_clusters_filtered-4_zscore_hc_ward.D2_euclidean_3_reorder.csv"), sep=","))
cluster_col  <- as.data.frame(read.csv(paste0(out_path,"\\sample_clusters_sum_filter-4.csv"), sep=","))

# **************************************************************
# **********************************************************
# # order samples inside each cluster
# # To try, sometimes it is better without instra clustering, for example, sum up version of filtered-4
# for (i in 1:length(unique(cluster_col$Cluster))) {
#   cluster <- unique(cluster_col$Cluster)[i]
#   index_cluster <- which(cluster_col$Cluster == cluster,arr.ind = TRUE)
#   cluster_col_cluster <- cluster_col[index_cluster,] # subset
#   if (length(index_cluster)!=1) {
#     # reorder by hc
#     cluster_col_cluster <- cluster_col_cluster[hclust(dist(t(data[,index_cluster]), method = dst),
#                                                       method = linkage)[["order"]],]
#   }
#   if (i == 1) {
#     tmp <- cluster_col_cluster
#   } else {
#     tmp <- rbind(tmp, cluster_col_cluster)
#     rownames(tmp) <- NULL
#   }
# }
# cluster_col <- tmp
# rm(tmp)
# **********************************************************
# **************************************************************

# The order of cluster_row should be the same as the data passed to the heatmap!
# If enable clustering (cluster_cols != FALSE), BOTH will be reordered according to the dendrogram.
data <- data[,match(cluster_col[,1],colnames(data))]

# Gene clustering
hc_row <- hclust(dist(data, method = dst),method = linkage)
cluster_row <- cutree(tree = as.dendrogram(hc_row), k = ncluster_row, order_clusters_as_data = FALSE)

# Make the order same as that of data
cluster_row = cluster_row[rownames(data)]

# Reconstruct clusters
cluster_row <- data.frame("Gene" = as.character(stack(cluster_row)[,2]), "Cluster" = paste('Cluster', str_pad(stack(cluster_row)[,1], 2, "left", "0")))

cluster_row_named <- cluster_row
cluster_col_named <- cluster_col

cluster_row <- data.frame("Gene Clusters" = cluster_row$Cluster)
cluster_col <- data.frame("Sample Clusters" = cluster_col$Cluster)

# **************************************************************************************
# Generate distinctive color for cluster labeling
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))

col_anno_colors <- c("#E41A1C","#FFD92F","#B3CDE3")
names(col_anno_colors) <- c("Cluster High", "Cluster Median", "Cluster Low")

row_anno_colors <- brewer.pal(n = ncluster_row, name = "Set2")
names(row_anno_colors) <- unique(cluster_row)[,1]

data_scaled <- t(apply(data, 1, function(x) (((x-min(x))/(max(x)-min(x)) * 2 - 1))))

# No idea why the color setting do not work
my_heatmap <- function(bottom_annotation = NULL) {
  pheatmap(data_scaled,
           # main = paste("Sample Clusters from SD<4 Z-Score Hierarchical Clustering"),
           main = paste("Sample Cluster from Sum Up Filtered-4"),
           fontsize = 20,
           name = "Normalized FPKM Matrix",
           color = rev(brewer.pal(n = 11, name = "RdYlBu")),
           border_color = NA, 
           # cellwidth = 1, cellheight = 1,
           show_rownames = FALSE, show_colnames = FALSE,
           cluster_rows = hc_row, 
           cluster_cols = FALSE,
           cutree_rows = ncluster_row,
           cutree_cols = NA,
           gaps_row = NULL,
           gaps_col = which(!duplicated(cluster_col[1]))[-1]-1,
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

# png(paste(out_path, "\\snapshots\\clustermap_",datas,"_",trans,"_",linkage,"_",dst,"_",
# ncluster_row,"_",ncluster_col,sreorder,".png", sep = ""), width = 962, height = 542)
ht = draw(my_heatmap()) # Plot heatmap

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

q <- my_heatmap(bottom_annotation = b) + rowAnnotation(foo = anno_text(rownames(data), gp = gpar(fontsize = 8, col = row_label_colors)))

# Export heatmap
# pdf(paste(out_path, "\\Expression_Sangro_Sia_",datas,"_",trans,"_",alg,"_",dst,"_",ncluster_row,"_",ncluster_col,sreorder,".pdf", sep = ""),
#     compress=FALSE, width=width, height=height)
pdf(paste0(out_path, "\\Expression_Sangro_Sia_filtered-4_sum.pdf"),
      compress=FALSE, width=width, height=height)

draw(q, row_title = "Sangro's and Sia's Genes", row_title_gp = gpar(fontsize = 20, fontface = "bold"))

# Close heatmap
dev.off()
dev.off()
# dev.off()


# # ***********************************************************************************
# # Retrieve and export gene clusters
# for (i in 1:length(row_order(ht))){ # to loop the clusters
#   rclu <- row.names(data)[row_order(ht)[[i]]] # genes belonging to this cluster
#   if (i == 1) {
#     rout <- cbind(rclu, paste("Cluster ", str_pad(i, 2, "left", "0"), sep=""))
#     colnames(rout) <- c("Gene", "Cluster")
#   } else {
#     rclu <- cbind(rclu, paste("Cluster ", str_pad(i, 2, "left", "0"), sep=""))
#     rout <- rbind(rout, rclu)
#   }
# }
# 
# write.table(rout, file= paste(out_path, "\\gene_clusters_sum_filter-4.csv", sep = ""),
#             sep=",", quote=F, row.names=FALSE)

