# pkgs <- c('lme4')
# pkgs <- c('pbkrtest')
# pkgs <- c('car')
# pkgs <- c('FactoMineR')
# pkgs <- c('cowplot')
# pkgs <- c('bindrcpp')
# pkgs <- c('ggpubr', "factoextra")
# pkgs <- c("factoextra",  "NbClust")
# install.packages(pkgs)

library(factoextra)
library(NbClust)

# transform = 'log2-zscore'
clusterAlg = "hc" # hc, kmeans
linkage = "average" # ward.D2, average, complete
distance = "euclidean" # euclidean, manhattan, pearson, spearman

# df <- read.csv(file = paste('E:\\deeplearning\\Hepatocarcinomes\\TCGA\\processed\\firebrowse_', 
#                             transform, '_filtered_nohousekeeping_HCC.csv', sep=''), sep='\t')
df <- read.csv('E:\\deeplearning\\Hepatocarcinomes\\TCGA\\processed_backup\\fpkm_final_log2-zscore_CCL3L1.csv', sep="\t", row.names = 1)
head(df)

function_hc<-function(x,k){hcut(x,k, hc_method =linkage , hc_metric=distance)}
png(file=paste('E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap\\test', clusterAlg, linkage, distance, 'elbow_sample_clusters.png', sep='_'))
fviz_nbclust(as.matrix(t(df)), function_hc, method = "wss", k.max = 20) +
  # geom_vline(xintercept = 4, linetype = 2)+
  labs(subtitle = "Elbow method")
dev.off()

#Need to define function
function_hc<-function(x,k){hcut(x,k, hc_method =linkage , hc_metric=distance)}
# function_hc<-function(x,k){kmeans(x,k)}

# Elbow method
# png(file=paste('E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap\\log2-zscore', clusterAlg, distance, 'elbow_gene_clusters.png', sep='_'))
# fviz_nbclust(df, kmeans, method = "wss", k.max = 30) +
png(file=paste('E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap\\log2-zscore', clusterAlg, linkage, distance, 'elbow_gene_clusters.png', sep='_'))
fviz_nbclust(df, function_hc, method = "wss", k.max = 30) +
  # geom_vline(xintercept = 10, linetype = 2)+
  labs(subtitle = "Elbow method")
dev.off()

# Silhouette method
# png(file=paste('E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap\\log2-zscore', clusterAlg, distance, 'silhouette_gene_clusters.png', sep='_'))
# fviz_nbclust(df, kmeans, method = "silhouette", k.max = 30) +
png(file=paste('E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap\\log2-zscore', clusterAlg, linkage, distance, 'silhouette_gene_clusters.png', sep='_'))
fviz_nbclust(df, function_hc, method = "silhouette", k.max = 30)+
  labs(subtitle = "Silhouette method")
dev.off()

# # Gap statistic (much more time-consuming than the other 2)
# # nboot = 50 to keep the function speedy. 
# # recommended value: nboot= 500 for your analysis.
# # Use verbose = FALSE to hide computing progression.
# png(file=paste('E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap\\log2-zscore', transform, '_', funcluster, '_gap-stat_gene_clusters.png', sep='_'))
# set.seed(123)
# fviz_nbclust(df, funcluster, nstart = 25,  method = "gap_stat", nboot = 500, k.max = 30)+
#   labs(subtitle = "Gap statistic method")
# dev.off()

# Elbow method
# png(file=paste('E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap\\log2-zscore', clusterAlg, distance, 'elbow_sample_clusters.png', sep='_'))
# fviz_nbclust(as.matrix(t(df)), kmeans, method = "wss", k.max = 20) +
png(file=paste('E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap\\log2-zscore', clusterAlg, linkage, distance, 'elbow_sample_clusters.png', sep='_'))
fviz_nbclust(as.matrix(t(df)), function_hc, method = "wss", k.max = 20) +
  # geom_vline(xintercept = 4, linetype = 2)+
  labs(subtitle = "Elbow method")
dev.off()

# Silhouette method
# png(file=paste('E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap\\log2-zscore', clusterAlg, distance, 'silhouette_sample_clusters.png', sep='_'))
# fviz_nbclust(as.matrix(t(df)), kmeans, method = "silhouette", k.max = 20)+
png(file=paste('E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap\\log2-zscore', clusterAlg, linkage, distance, 'silhouette_sample_clusters.png', sep='_'))
fviz_nbclust(as.matrix(t(df)), function_hc, method = "silhouette", k.max = 20)+
  labs(subtitle = "Silhouette method")
dev.off()

# # Gap statistic (much more time-consuming than the other 2)
# # nboot = 50 to keep the function speedy. 
# # recommended value: nboot= 500 for your analysis.
# # Use verbose = FALSE to hide computing progression.
# png(file=paste('E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap\\log2-zscore', transform, '_', funcluster, '_gap-stat_sample_clusters.png', sep='_'))
# set.seed(123)
# fviz_nbclust(t(df), funcluster, nstart = 25,  method = "gap_stat", nboot = 500, k.max = 20)+
#   labs(subtitle = "Gap statistic method")
# dev.off()