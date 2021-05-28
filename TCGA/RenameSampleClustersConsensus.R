
# ***********************************************************************************
# To use after scripts PlotHeatmap* 
# (do not remove the variables)

# ***********************************************************************************
# Set Sample cluster names according from the heatmap
Cluster01 <- "Cluster Median" # Cluster Median, Cluster High, Cluster Low
Cluster02 <- "Cluster Low"
Cluster03 <- "Cluster High"

# ***********************************************************************************
# Rename sample clusters

cluster_col <- sub("Cluster 01", Cluster01, as.matrix(cluster_col))
cluster_col <- sub("Cluster 02", Cluster02, cluster_col)
cluster_col <- as.data.frame(sub("Cluster 03", Cluster03, cluster_col))

names(col_anno_colors)[1] <- Cluster01 # Cluster 01
names(col_anno_colors)[2] <- Cluster02 # Cluster 01
names(col_anno_colors)[3] <- Cluster03 # Cluster 01

cluster_col_ordered <- sub("Cluster 01", Cluster01, as.matrix(cluster_col_ordered))
cluster_col_ordered <- sub("Cluster 02", Cluster02, cluster_col_ordered)
cluster_col_ordered <- as.data.frame(sub("Cluster 03", Cluster03, cluster_col_ordered))

# ***********************************************************************************
# Re-save results
if (alg == "km") {
  
  # re-export sample clusters
  write.table(cluster_col_ordered, file= paste(out_path, "\\consensus_sample_clusters_",datas,"_",trans,"_",alg, "_", dst,"_",ncluster_col,".csv", sep = ""),
              sep=",", quote=F, row.names=FALSE)
  # Re-export heatmap
  pdf(paste(out_path, "\\consensus_clustermap_",datas,"_",trans,"_",alg,"_",dst,"_",ncluster_row,"_",ncluster_col,".pdf", sep = ""),
      compress=FALSE, width=width, height=height)
  
} else if (alg == "hc") {
  # re-export sample clusters
  write.table(cluster_col_ordered, file= paste(out_path, "\\consensus_sample_clusters_",datas,"_",trans,"_",alg,"_",linkage, "_", dst,"_",ncluster_col,".csv", sep = ""),
              sep=",", quote=F, row.names=FALSE)
  # Re-export heatmap
  pdf(paste(out_path, "\\consensus_clustermap_",datas,"_",trans,"_",alg,"_",linkage,"_",dst,"_",ncluster_row,"_",ncluster_col,".pdf", sep = ""),
      compress=FALSE, width=width, height=height)
}

# ***********************************************************************************
# Plot heatmap

q <- my_heatmap(bottom_annotation = b) + rowAnnotation(foo = anno_text(rownames(data), gp = gpar(fontsize = 0.5, col = row_label_colors)))

draw(q)

# Close heatmap
dev.off()
