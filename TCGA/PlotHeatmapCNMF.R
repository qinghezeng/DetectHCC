# **************************************************************************************
library(CancerSubtypes)
library(RColorBrewer)
# devtools::install_github("jokergoo/ComplexHeatmap")
library(ComplexHeatmap)
library(stringr)

load("/media/visiopharm5/WDGold/deeplearning/Hepatocarcinomes/codes/TCGA/data_silouette.RData") # load a good CNMF result

# Paths
in_path <- "/media/visiopharm5/WDGold/deeplearning/Hepatocarcinomes/TCGA/processed"
out_path <- "/media/visiopharm5/WDGold/deeplearning/Hepatocarcinomes/TCGA/validation"

# # Dataset
datas = "full" # full, filtered-05, filtered-1, filtered-4, filtered-6, filtered-Sia
trans = "median" # median, zscore, raw
# sangro_filtered = FALSE
# 
# # Clustering
alg = "hc" # km, hc
dst = "euclidean" # euclidean, pearson, spearman (slow)
# Set cluster number
ncluster_row = 9 # 12, 14
ncluster_col = 3 # 3, 6

# Rename sample cluster according to heatmap
cluster01 <- "Cluster Median" # Cluster High, Cluster Median, Cluster Low
cluster02 <- "Cluster Low"
cluster03 <- "Cluster High"

# # *******************************
# # Hierachical clustering
linkage = "ward.D2" # single, average, complete, ward.D2
# sreorder = FALSE
# 
# 
# if (sangro_filtered) {
#   sangro_genes <- read.csv(paste(in_path, "Sangro_Table2_GeneList.csv",sep = "/"), sep="\t", row.names = NULL, header=FALSE)
#   sangro_genes[1,] <- "CD274"
#   sangro_genes <- sangro_genes[-6,] #drop "CCL3"
#   
#   data <- data[sangro_genes,]
#   
#   datas = "filtered-Sangro"
#   height = 5
# }
# 
# # **************************************************************************************
# # Clustering
# 
# if (alg == "km") {
#   set.seed(seed)
#   cluster_row <- kmeans(data, ncluster_row,iter.max=50)[["cluster"]] # 20-50 iterations
#   
#   set.seed(seed)
#   cluster_col <- kmeans(t(data), ncluster_col,iter.max=50)[["cluster"]] # 20-50 iterations
#   # The order of cluster_row should be the same as the data passed to the heatmap! Here is the same.
#   # If enable clustering (cluster_cols != FALSE), they will be reordered according to the dendrogram.
#   
#   # # Ordered by ascending clusters
#   # order_row <- order(cluster_row)
#   # order_col <- order(cluster_col)
#   # 
#   # cluster_row <- cluster_row[order_row]
#   # cluster_col <- cluster_col[order_col]
#   # 
#   # # cluster_row_ordered <- cluster_row
#   # # cluster_col_ordered <- cluster_col
#   # 
#   # data <- data[order_row, order_col]
#   
#   sreorder <- ""
#   
# } else if (alg == "hc"){
#   
#   # Perform HC
#   if (dst == "pearson" || dst == "spearman" || dst == "kendall") {
#     # # Handle missing distance with with use="pairwise.complete.obs"
#     # # the cases with missing values are only removed during the calculation of each pairwise correlation.
#     # row (gene)
#     distCor<-function (m) {
#       as.dist(1 - cor(t(m), use="pairwise.complete.obs", method = dst))
#     }
#     dist_row = distCor(data)
#     dist_col = distCor(t(data))
#     
#   } else {
#     
#     dist_row = dist(data, method = dst, upper=TRUE)
#     dist_col = dist(t(data), method = dst, upper=TRUE)
#     
#   }
#   
#   hc_row = hclust(dist_row, method = linkage)
#   hc_col = hclust(dist_col, method = linkage)
#   if (sreorder) {
#     hc_col = dendsort(hclust(dist(t(data), method = dst), method = linkage), isReverse = TRUE, type="average") # inverse the dendrogram
#     sreorder <- "_reorder"
#   } else {
#     sreorder <- ""
#   }
#   
#   # Cut trees for fixed number
#   # order_clusters_as_data = FALSE: to organize the clusters by the labels in the dendrogram
#   cluster_row <- cutree(tree = hc_row, k = ncluster_row)
#   cluster_col <- cutree(tree = hc_col, k = ncluster_col)
#   
# }
# 
# sil=silhouette(cluster_col, dist_col)
# plot(sil, col=1:3, border=NA) # border=NA fixed the problem with no contents but only border


# **************************************************************************************
# Reconstruct cluster

cluster_row <- data.frame(Gene = rownames(data), Cluster = paste('Cluster', str_pad(result_gene$group, 2, "left", "0")))
cluster_col <- data.frame(Sample = colnames(data), Cluster = paste('Cluster', str_pad(result$group, 2, "left", "0")))

# Ordered by ascending clusters
order_row <- order(cluster_row$Cluster)
order_col <- order(cluster_col$Cluster)

cluster_row <- cluster_row[order_row,]
cluster_col <- cluster_col[order_col,]

data_scaled <- data2[order_row, order_col]

# Reconstruct cluster
if (ncluster_col == 3) {
  # rename sample clusters
  cluster_col[cluster_col=="Cluster 01"] <- cluster01
  cluster_col[cluster_col=="Cluster 02"] <- cluster02
  cluster_col[cluster_col=="Cluster 03"] <- cluster03
  
  cluster_col[cluster_col=="Cluster Median"] <- "2Cluster Median"
  cluster_col[cluster_col=="Cluster Low"] <- "3Cluster Low"
  cluster_col[cluster_col=="Cluster High"] <- "1Cluster High"
  
  cluster_col <- cluster_col[order(cluster_col[,2],decreasing = FALSE),]
  cluster_row <- cluster_row[order(cluster_row[,2],decreasing = FALSE),]
  
  cluster_col[cluster_col=="1Cluster High"] <- "Cluster High"
  cluster_col[cluster_col=="2Cluster Median"] <- "Cluster Median"
  cluster_col[cluster_col=="3Cluster Low"] <- "Cluster Low"
}

# **************************************************************************************
# Generate distinctive color for cluster labeling
qual_col_pals = brewer.pal.info[brewer.pal.info$category == 'qual',]
col_vector = unlist(mapply(brewer.pal, qual_col_pals$maxcolors, rownames(qual_col_pals)))
set.seed(695032) # 695105,695008,695014

if (ncluster_col == 3) {
  col_anno_colors <- c("#E41A1C","#FFD92F","#B3CDE3")
  names(col_anno_colors) <- c("Cluster High", "Cluster Median", "Cluster Low")
  # names(col_anno_colors) <- c("1", "2", "3")
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
names(row_anno_colors) <- unique(cluster_row[,2])
# names(row_anno_colors) <- unique(result_gene$group)
# Visualization
par(mfrow=c(1,2)) 
pie(rep(1,length(row_anno_colors)), col=row_anno_colors, labels=names(row_anno_colors))
pie(rep(1,length(col_anno_colors)), col=col_anno_colors, labels=names(col_anno_colors))

dev.off()

# **************************************************************************************
# order samples inside each cluster
for (i in 1:length(unique(cluster_col$Cluster))) {
  cluster <- unique(cluster_col$Cluster)[i]
  index_cluster <- which(cluster_col$Cluster == cluster,arr.ind = TRUE)
  cluster_col_cluster <- cluster_col[index_cluster,] # subset
  if (length(index_cluster)!=1) {
    # reorder by hc
    cluster_col_cluster <- cluster_col_cluster[hclust(dist(t(data_scaled[,index_cluster]), method = dst),
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
data_scaled <- data_scaled[, match(cluster_col[,1],colnames(data_scaled))]

# order genes inside each cluster
for (i in 1:length(unique(cluster_row$Cluster))) {
  cluster <- unique(cluster_row$Cluster)[i]
  index_cluster <- which(cluster_row$Cluster == cluster,arr.ind = TRUE)
  cluster_row_cluster <- cluster_row[index_cluster,,drop=FALSE] # subset
  if (length(index_cluster)!=1) {
    # reorder by hc
    cluster_row_cluster <- cluster_row_cluster[hclust(dist(data_scaled[index_cluster,], method = dst),
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
data_scaled <- data_scaled[match(cluster_row[,1],rownames(data_scaled)), ]

# Data scaling before visualization
data_scaled <- t(apply(data_scaled, 1, function(x) (((x-min(x))/(max(x)-min(x)) * 2 - 1))))

# Reconstruct cluster

cluster_row_named <- cluster_row
cluster_col_named <- cluster_col

cluster_row <- data.frame("Gene Clusters" = cluster_row$Cluster)
cluster_col <- data.frame("Sample Clusters" = cluster_col$Cluster)

# **************************************************************************************
# Plot heatmap
my_heatmap <- function(bottom_annotation = NULL) {
  pheatmap(data_scaled,
           main = "Sample Clusters",
           name = "Normalized FPKM Matrix",
           color = rev(brewer.pal(n = 11, name = "RdYlBu")),
           border_color = NA, 
           # cellwidth = 1, cellheight = 1,
           show_rownames = FALSE, show_colnames = FALSE,
           cluster_rows = FALSE, 
           cluster_cols = FALSE,
           cutree_rows = NA,
           cutree_cols = NA,
           gaps_row = which(!duplicated(cluster_row[1]))[-1]-1,
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

png(paste(out_path, "/clustermap_",datas,"_",trans,"_cnmf_ordered_",alg,"_",linkage,"_",dst,"_",ncluster_row,"_",ncluster_col,".png", 
          sep = ""), width = 800, height = 600)
ht = draw(my_heatmap()) # Plot heatmap
dev.off()

# ***********************************************************************************
# Retrieve and export gene clusters
write.table(cluster_row_named, file= paste(out_path, "/gene_clusters_",datas,"_",trans,"_cnmf_ordered_",alg, "_", dst,"_",ncluster_row,".csv", sep = ""),
            sep=",", quote=F, row.names=FALSE)
write.table(cluster_col_named, file= paste(out_path, "/sample_clusters_",datas,"_",trans,"_cnmf_ordered",alg, "_", dst,"_",ncluster_col,".csv", sep = ""),
            sep=",", quote=F, row.names=FALSE)

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
b <- HeatmapAnnotation(goo = anno_text(colnames(data_scaled), gp = gpar(fontsize = 0.5, col = col_label_colors)))

q <- my_heatmap(bottom_annotation = b) + rowAnnotation(foo = anno_text(rownames(data_scaled), gp = gpar(fontsize = 0.5, col = row_label_colors)))

pdf(paste(out_path, "/clustermap_",datas,"_",trans,"_cnmf_ordered_",alg,"_",linkage,"_",dst,"_",ncluster_row,"_",ncluster_col,".pdf", sep = ""),
    compress=FALSE, width = 17, height = 17)

draw(q)

# Close heatmap
dev.off()

# ************************************************************************************
# Export clusters, silhouette values and core samples

sil=silhouette_SimilarityMatrix(result$group, result$distanceMatrix) # result2: data, result: data2
plot(sil, col=1:3, border=NA)
res = sil[match(cluster_col_named[,1], colnames(data2)),]

sil[which(sil[,3] < 0, arr.ind = TRUE),]

sigclustTest(data2, result$group, nsim=500, nrep=1, icovest=3) # Cluster High and Median no significant difference

res = data.frame(Sample = cluster_col_named[,1], res[,])
colnames(res)[2] = "Cluster"
res[res == 3] = "Cluster High"
res[res == 1] = "Cluster Median"
res[res == 2] = "Cluster Low"
res["core_sample"] = (res[,4] > 0)

write.table(res, file= paste("/media/visiopharm5/WDGold/deeplearning/Hepatocarcinomes/TCGA/clust_res_final",
                             "/sample_clusters_",datas,"_",trans,"_cnmf_ordered_",alg,"_",linkage, "_", dst,"_",ncluster_col,".csv", sep = ""),
            sep=",", quote=F, row.names=FALSE)

dev.off()
