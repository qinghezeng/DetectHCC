# **************************************************************************************************
# This script only assign the names of "Cluster High / Median / Low", but doesn't order the samples.
# The samples are now in the original order of the data.

# **************************************************************************************
library(CancerSubtypes)
library(RColorBrewer)
# devtools::install_github("jokergoo/ComplexHeatmap")
library(ComplexHeatmap)
library(dendsort)
library(stringr)

# Paths
in_path <- "/media/visiopharm5/WDGold/deeplearning/Hepatocarcinomes/TCGA/heatmap_nanostring_139"
out_path <- "/media/visiopharm5/WDGold/deeplearning/Hepatocarcinomes/TCGA/heatmap_nanostring_139" # figures/pdf_black_fontsize_equalcell

# Dataset
datas = "full" # full, filtered-05, filtered-1, filtered-4, filtered-6, filtered-Sia
trans = "zscore" # median, zscore, raw
sangro_filtered = TRUE
gene_signature = "T-cell_Exhaustion" # Inflammatory, Gajewski_13G_Inflammatory, 6G_Interferon_Gamma, Interferon_Gamma_Biology, 
# T-cell_Exhaustion, Ribas_10G_Interferon_Gamma, 10G_preliminary_IFN-γ, Expanded_immune_gene

# Clustering
alg = "hc" # km, hc
dst = "euclidean" # euclidean, pearson, spearman (slow)
# Set cluster number
ncluster_row = 2 # 12, 14
ncluster_col = 3 # 3, 6

# Rename sample cluster according to heatmap
cluster01 <- "Cluster High" # Cluster High 
cluster02 <- "Cluster Median" # Cluster Median
cluster03 <- "Cluster Low" # Cluster Low

# # *******************************
# # Hierachical clustering
linkage = "ward.D2" # single, average, complete, ward.D2
sreorder = TRUE

# Exported figure size
width = 23
height = 10

# ***************************************************************************************

# Load data
if (trans == "zscore") {
  if (datas == "full") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "mondor_final_log2-zscore-centering.csv",
                                                   sep = "/"), sep="\t", row.names = 1)))
  }
} else if (trans == "median") {
  if (datas == "full") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_log2-median-centering.csv",
                                                   sep = "/"), sep="\t", row.names = 1)))
  }
}

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
if (sangro_filtered) {
  if (gene_signature == "Inflammatory") {
    geneS = c("CD274", "CD8A", "LAG3", "STAT1")
  } else if (gene_signature == "Gajewski_13G_Inflammatory")  {
    geneS = c("CCL2","CCL4","CD8A","CXCL10","CXCL9","GZMK","HLA-DMA","HLA-DMB","HLA-DOA","HLA-DOB","ICOS","IRF1")
  } else if (gene_signature == "6G_Interferon_Gamma")  { # exactly the same as the IFN-γ in Melanoma
    geneS = c("CXCL10","CXCL9","HLA-DRA","IDO1","IFNG","STAT1")
  } else if (gene_signature == "Interferon_Gamma_Biology")  {
    geneS = c("CCL5","CD27","CXCL9","CXCR6","IDO1","STAT1")
  } else if (gene_signature == "T-cell_Exhaustion")  {
    geneS = c("CD274","CD276","CD8A","LAG3","PDCD1LG2","TIGIT")
  } else if (gene_signature == "Ribas_10G_Interferon_Gamma")  {
    geneS = c("CCR5","CXCL10","CXCL11","CXCL9","GZMA","HLA-DRA","IDO1","IFNG","PRF1","STAT1")
  } else if (gene_signature == "10G_preliminary_IFN-γ")  {
    geneS = c("IFNG","STAT1","CCR5","CXCL9","CXCL10","CXCL11","IDO1","PRF1","GZMA","HLA-DRA")
  } else if (gene_signature == "Expanded_immune_gene")  {
    geneS = c("CD3D","IL2RG","IDO1","NKG7","HLA-E","CD3E","CXCR6","CCL5","LAG3","GZMK","CD2","CXCL10","HLA-DRA","STAT1",
              "CXCL13","GZMB") # 'CIITA', 'TAGAP' not found in the NanoString panel
  }
  
  data <- data[geneS,]
  datas = gene_signature
}

# **************************************************************************************
# Clustering

if (alg == "hc"){
  
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
    
    dist_row = dist(data, method = dst, upper=TRUE)
    dist_col = dist(t(data), method = dst, upper=TRUE)
    
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
  # order_clusters_as_data = FALSE: to organize the clusters by the labels in the dendrogram
  ### function "stats::cutree" may not return the same order as the tree, will cause problem when using "column_order(ht)"
  ### So be sure to use dendextend::cutree with "order_clusters_as_data = FALSE"
  cluster_row <- dendextend::cutree(tree = hc_row, k = ncluster_row, order_clusters_as_data = FALSE) 
  cluster_col <- dendextend::cutree(tree = hc_col, k = ncluster_col, order_clusters_as_data = FALSE)
  
  # Make the order same as that of data (necessary following the dendextend::cutree)
  cluster_row = cluster_row[rownames(data)]
  cluster_col = cluster_col[colnames(data)]
  
}

png(paste(out_path, "/silhouette_sample_",datas,"_",trans,"_",alg,"_",linkage,"_",dst,"_",ncluster_col,".png",
          sep = ""))

sil=silhouette(cluster_col, dist_col)
plot(sil, col=1:3, border=NA) # border=NA fixed the problem with no contents but only border

dev.off()

sigclustTest(data, cluster_col, nsim=500, nrep=1, icovest=3) # Cluster High and Median no significant difference

# **************************************************************************************

# Reconstruct clusters
cluster_row <- data.frame("Gene" = as.character(stack(cluster_row)[,2]), "Cluster" = paste('Cluster', str_pad(stack(cluster_row)[,1], 2, "left", "0")))
cluster_col <- data.frame("Sample" = as.character(stack(cluster_col)[,2]), "Cluster" = paste('Cluster', str_pad(stack(cluster_col)[,1], 2, "left", "0")))

# rename and reorder sample clusters
if (ncluster_col == 3) {
  cluster_col[cluster_col=="Cluster 01"] <- cluster01
  cluster_col[cluster_col=="Cluster 02"] <- cluster02
  cluster_col[cluster_col=="Cluster 03"] <- cluster03
  
}

# **************************************************************************************
# Reconstruct clusters for heatmap

cluster_row_named <- cluster_row
cluster_col_named <- cluster_col

cluster_row <- data.frame("Gene" = cluster_row$Cluster) # Gene Clusters
cluster_col <- data.frame("Sample" = cluster_col$Cluster) # Sample Clusters

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

if (alg == "hc") {
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
           cellwidth = 3, cellheight = 40,
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
                                           col = list('Gene' = row_anno_colors), # Gene.Clusters
                                           annotation_name_side = "top", show_annotation_name = FALSE,
                                           annotation_name_rot = 90),
           top_annotation = HeatmapAnnotation(df = cluster_col,
                                              col = list('Sample' = col_anno_colors), # Sample.Clusters
                                              show_annotation_name = FALSE),
           bottom_annotation = bottom_annotation,
           # row_split = cluster_row[,1],
           annotation_legend = TRUE, 
           scale = 'none')
}

# png(paste(out_path, "\\snapshots\\clustermap_",datas,"_",trans,"_",linkage,"_",dst,"_",
# ncluster_row,"_",ncluster_col,sreorder,".png", sep = ""), width = 962, height = 542)
ht = draw(my_heatmap()) # Plot heatmap

# ***********************************************************************************
# Retrieve and export sample clusters

if (alg == "hc") {
  
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
  write.table(cout, file= paste(out_path, "/sample_clusters_",datas,"_",trans,"_",alg,"_",linkage, "_", dst,"_",ncluster_col,sreorder,".csv", sep = ""),
              sep=",", quote=F, row.names=FALSE)
}

# *********************************************************************************************
# # Color gene labels by clusters
# 
# for (i in 1:dim(cluster_row)[1]){
#   if (i == 1) {
#     tmp <- cluster_row[i,1]
#     row_label_colors <- cbind(tmp, paste(row_anno_colors[cluster_row[i,1]]))
#   } else {
#     tmp <- cluster_row[i,1]
#     tmp <- cbind(tmp, paste(row_anno_colors[cluster_row[i,1]]))
#     row_label_colors <- rbind(row_label_colors, tmp)
#   }
# }
# rm(tmp)
# row_label_colors = row_label_colors[, 2]

# Set all gene names to black
row_label_colors = rep("#000000", dim(cluster_row)[1])

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

# ************************************************************************************
# Plot final heatmap

# No idea why these ways did not work
# col_ann <- HeatmapAnnotation(goo = anno_text(colnames(data), gp = gpar(fontsize = 0.5, col = col_label_colors)))
# q <- p + rowAnnotation(foo = anno_text(rownames(data), gp = gpar(fontsize = 0.5, col = row_label_colors)))
# q <- c(q, col_ann)

# Reconstruct heatmap
b <- HeatmapAnnotation(goo = anno_text(colnames(data), gp = gpar(fontsize = 0.5, col = col_label_colors)))

q <- my_heatmap(bottom_annotation = b) + rowAnnotation(foo = anno_text(rownames(data), rot = 16,  # rotation
                                                                       gp = gpar(fontsize = 28, col = row_label_colors)))


# Export heatmap
if (alg == "hc") {
  pdf(paste(out_path, "/clustermap_",datas,"_",trans,"_",alg,"_",linkage,"_",dst,"_",ncluster_row,"_",ncluster_col,sreorder,".pdf", sep = ""),
      compress=FALSE, width=width, height=height)
}

draw(q)

# Close heatmap
dev.off()
dev.off()
# dev.off()

# ************************************************************************************
# Export clusters, silhouette values and core samples

sil[which(sil[,3] < 0, arr.ind = TRUE),]

res = sil[match(cout[,1], cluster_col_named[,1]),]

res = data.frame(Sample = cout[,1], res[,])
colnames(res)[2] = "Cluster"
res[res == 1] = cluster01
res[res == 2] = cluster02
res[res == 3] = cluster03
res["core_sample"] = (res[,4] > 0)

write.table(res, file= paste("/media/visiopharm5/WDGold/deeplearning/Hepatocarcinomes/TCGA/clust_res_final",
                             "/mondor_sample_clusters_",datas,"_",trans,"_",alg,"_",linkage, "_", dst,"_",ncluster_col,sreorder,".csv", sep = ""),
            sep=",", quote=F, row.names=FALSE)
