# ***************************************************************************************
# Install libraries

# if (!requireNamespace("BiocManager", quietly = TRUE))
#   install.packages("BiocManager")

# BiocManager::install("ConsensusClusterPlus")

# ***************************************************************************************
# Load libraries

library(ConsensusClusterPlus)

# ***************************************************************************************

# Paths
in_path <- "E:\\deeplearning\\Hepatocarcinomes\\TCGA\\processed"
out_path <- "E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap"

# Dataset
datas = "full" # full, filtered-05, filtered-1, filtered-4, filtered-6, filtered-Sia
trans = "median" # median, zscore

# Clustering algo
clusterAlg = "km" # hc, km
dst = "euclidean" # euclidean, pearson, spearman. Kmeans and ward's only supports euclidean
reps = 1200 # 1200
pItem = 0.8
pFeature = 0.8

sangro_filtered = TRUE

# ***************************************************************************************

# Load data
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
  }  else if (datas == "filtered-Sia") {
    data <- as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_filtered-Sia_log2-zscore.csv",
                                                   sep = "\\"), sep="\t", row.names = 1)))
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
  }
} 

if (sangro_filtered) {
  sangro_genes <- read.csv(paste(in_path, "Sangro_Table2_GeneList.csv",sep = "\\"), sep="\t", row.names = NULL, header=FALSE)
  sangro_genes[1,] <- "CD274"
  sangro_genes <- sangro_genes[-6,] #drop "CCL3"
  
  data <- data[sangro_genes,]
  datas = "filtered-Sangro"
}

# **************************************************************************************
# Consensus clustering
if (clusterAlg == "hc") {
  
  linkage = "ward.D2" # ward.D2, ward.D, average, complete
  
  results = ConsensusClusterPlus(data, maxK=15, reps=reps, pItem=pItem, pFeature=pFeature, innerLinkage=linkage, finalLinkage=linkage, 
                       title=paste(out_path,paste(datas,trans,"sample",clusterAlg,linkage,dst,pItem,pFeature,reps,sep='_'),sep="\\"), 
                       clusterAlg=clusterAlg, distance=dst, seed=1262118388.71279, plot="png")
  icl_sample = calcICL(results,title=paste(out_path,paste(datas,trans,"sample",clusterAlg,linkage,dst,pItem,pFeature,reps,sep='_'),sep="\\"), 
                plot="png")
  write.table(icl_sample[["clusterConsensus"]], file= paste(out_path,paste(datas,trans,"sample",clusterAlg,linkage,dst,pItem,pFeature,reps,sep='_'),"clusterConsensus.csv",sep="\\"),
              sep=",", quote=F, row.names=FALSE)
  write.table(icl_sample[["itemConsensus"]], file= paste(out_path,paste(datas,trans,"sample",clusterAlg,linkage,dst,pItem,pFeature,reps,sep='_'),"itemConsensus.csv",sep="\\"),
              sep=",", quote=F, row.names=FALSE)
  
  results = ConsensusClusterPlus(t(data), maxK=20, reps=reps, pItem=pItem, pFeature=pFeature, innerLinkage=linkage, finalLinkage=linkage,
                       title=paste(out_path,paste(datas,trans,"gene",clusterAlg,linkage,dst,pItem,pFeature,reps,sep='_'),sep="\\"),
                       clusterAlg=clusterAlg, distance=dst, seed=1262118388.71279, plot="png")
  icl_gene = calcICL(results,title=paste(out_path,paste(datas,trans,"gene",clusterAlg,linkage,dst,pItem,pFeature,reps,sep='_'),sep="\\"), 
                plot="png")
  write.table(icl_gene[["clusterConsensus"]], file= paste(out_path,paste(datas,trans,"gene",clusterAlg,linkage,dst,pItem,pFeature,reps,sep='_'),"clusterConsensus.csv",sep="\\"),
              sep=",", quote=F, row.names=FALSE)
  write.table(icl_gene[["itemConsensus"]], file= paste(out_path,paste(datas,trans,"gene",clusterAlg,linkage,dst,pItem,pFeature,reps,sep='_'),"itemConsensus.csv",sep="\\"),
              sep=",", quote=F, row.names=FALSE)
  
} else {
  
  kmeansAlg = function(x,k){assignment=kmeans(x,k,iter.max=50) # 20-50 iterations
                            return(assignment[["cluster"]])}
  
  results = ConsensusClusterPlus(data, maxK=15, reps=reps, pItem=pItem, pFeature=pFeature, 
                       title=paste(out_path,paste(datas,trans,"sample",clusterAlg,dst,pItem,pFeature,reps,sep='_'),sep="\\"),
                       clusterAlg="kmeansAlg", distance=dst, seed=1262118388.71279, plot="png")
  icl_sample = calcICL(results,title=paste(out_path,paste(datas,trans,"sample",clusterAlg,dst,pItem,pFeature,reps,sep='_'),sep="\\"), 
                plot="png")
  write.table(icl_sample[["clusterConsensus"]], file= paste(out_path,paste(datas,trans,"sample",clusterAlg,dst,pItem,pFeature,reps,sep='_'),"clusterConsensus.csv",sep="\\"),
              sep=",", quote=F, row.names=FALSE)
  write.table(icl_sample[["itemConsensus"]], file= paste(out_path,paste(datas,trans,"sample",clusterAlg,dst,pItem,pFeature,reps,sep='_'),"itemConsensus.csv",sep="\\"),
              sep=",", quote=F, row.names=FALSE)
  
  results = ConsensusClusterPlus(t(data), maxK=20, reps=reps, pItem=pItem, pFeature=pFeature, 
                       title=paste(out_path,paste(datas,trans,"gene",clusterAlg,dst,pItem,pFeature,reps,sep='_'),sep="\\"),
                       clusterAlg="kmeansAlg", distance=dst, seed=1262118388.71279, plot="png")
  icl_gene = calcICL(results,title=paste(out_path,paste(datas,trans,"gene",clusterAlg,dst,pItem,pFeature,reps,sep='_'),sep="\\"), 
                plot="png")
  
  write.table(icl_gene[["clusterConsensus"]], file= paste(out_path,paste(datas,trans,"gene",clusterAlg,dst,pItem,pFeature,reps,sep='_'),"clusterConsensus.csv",sep="\\"),
              sep=",", quote=F, row.names=FALSE)
  write.table(icl_gene[["itemConsensus"]], file= paste(out_path,paste(datas,trans,"gene",clusterAlg,dst,pItem,pFeature,reps,sep='_'),"itemConsensus.csv",sep="\\"),
              sep=",", quote=F, row.names=FALSE)
  
}


# library(philentropy) # conflict with ConsensusClusterPlus, Error in get(distance)(t(d)) when using euclidean
# 
# # sample / cols
# dist_col = as.dist(distance(t(data), method = "chebyshev"))
# linkage = "average" # ward.D2, ward.D, average, complete
# results = ConsensusClusterPlus(dist_col, maxK=15, reps=reps, pItem=pItem, pFeature=pFeature, innerLinkage=linkage, finalLinkage=linkage, 
#                      title=paste(out_path,paste(datas,trans,"sample",clusterAlg,linkage,"chebyshev",pItem,pFeature,reps,sep='_'),sep="\\"),
#                      clusterAlg=clusterAlg, distance="chebyshev", seed=1262118388.71279, plot="png")
# icl_sample = calcICL(results,title=paste(out_path,paste(datas,trans,"sample",clusterAlg,linkage,dst,pItem,pFeature,reps,sep='_'),sep="\\"), 
#               plot="png")
# write.table(icl_sample[["clusterConsensus"]], file= paste(out_path,paste(datas,trans,"sample",clusterAlg,linkage,dst,pItem,pFeature,reps,sep='_'),"clusterConsensus.csv",sep="\\"),
#             sep=",", quote=F, row.names=FALSE)
# write.table(icl_sample[["itemConsensus"]], file= paste(out_path,paste(datas,trans,"sample",clusterAlg,linkage,dst,pItem,pFeature,reps,sep='_'),"itemConsensus.csv",sep="\\"),
#             sep=",", quote=F, row.names=FALSE)
# 
# 
# # gene / rows
# dist_row = as.dist(distance(data, method = "chebyshev"))
# linkage = "average" # ward.D2, ward.D, average, complete
# results = ConsensusClusterPlus(dist_row, maxK=15, reps=reps, pItem=pItem, pFeature=pFeature, innerLinkage=linkage, finalLinkage=linkage, 
#                      title=paste(out_path,paste(datas,trans,"gene",clusterAlg,linkage,"chebyshev",pItem,pFeature,reps,sep='_'),sep="\\"),
#                      clusterAlg=clusterAlg, distance="chebyshev", seed=1262118388.71279, plot="png")
# icl_gene = calcICL(results,title=paste(out_path,paste(datas,trans,"gene",clusterAlg,linkage,dst,pItem,pFeature,reps,sep='_'),sep="\\"), 
#               plot="png")
# write.table(icl_gene[["clusterConsensus"]], file= paste(out_path,paste(datas,trans,"gene",clusterAlg,linkage,dst,pItem,pFeature,reps,sep='_'),"clusterConsensus.csv",sep="\\"),
#             sep=",", quote=F, row.names=FALSE)
# write.table(icl_gene[["itemConsensus"]], file= paste(out_path,paste(datas,trans,"gene",clusterAlg,linkage,dst,pItem,pFeature,reps,sep='_'),"itemConsensus.csv",sep="\\"),
#             sep=",", quote=F, row.names=FALSE)
# 
# 
# 
# 
# 
#
# 
# 
# library(cluster)
# dianaHook = function(this_dist,k){
#  tmp = diana(this_dist,diss=TRUE)
#  assignment = cutree(tmp,k)
#  return(assignment)
# }
# rcc6 = ConsensusClusterPlus(data,maxK=6,reps=25,pItem=0.8,pFeature=1,title="example",clusterAlg="cclusterAlg")





