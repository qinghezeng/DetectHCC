# **************************************************************************************
library(CancerSubtypes)

# Paths
in_path <- "/media/visiopharm5/WDGold/deeplearning/Hepatocarcinomes/TCGA/clust_res_final"

fname <-  "sample_clusters_filtered-Sangro_zscore_hc_ward.D2_euclidean_3_reorder"

 # Load label
label = as.matrix(as.data.frame(read.csv(paste0(in_path, "/", fname, ".csv"), sep=",", row.names = 1)))
label[label == "Cluster High"] = 2
label[label == "Cluster Median"] = 1
label[label == "Cluster Low"] = 0

#### Execute the script PlotHeatmapClustering till plotheatmap (for check): to get dist_col

# sil=silhouette(as.numeric(label[rownames(as.matrix(dist_col)),]), dist_col)
sil=silhouette(as.numeric(label), as.matrix(dist_col)[rownames(label),rownames(label)])
plot(sil, border=NA)

sil[which(sil[,3] < 0, arr.ind = TRUE),]

sigclustTest(data,as.numeric(label[rownames(as.matrix(dist_col)),]), nsim=500, nrep=1, icovest=3)

if (sum(!sil[,1] == label[,1]) != 0) {
  print("The order is wrong!")
}
  
res = data.frame(Sample = rownames(label), sil[,])
colnames(res)[2] = "Cluster"
res[res == 2] = "Cluster High"
res[res == 1] = "Cluster Median"
res[res == 0] = "Cluster Low"
res["core_sample"] = (res[,4] > 0)

write.table(res, file= paste(in_path, "/sample_clusters_",datas,"_",trans,"_",alg,"_",linkage, "_", dst,"_",ncluster_col,sreorder,".csv", sep = ""),
            sep=",", quote=F, row.names=FALSE)
