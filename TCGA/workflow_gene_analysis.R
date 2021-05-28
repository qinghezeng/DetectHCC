# **************************************************************************************
# devtools::install_github(repo = "renozao/NMF", ref = "master", force=TRUE) # update this package will solve the error "- run #1: non-conformable arrays"
# install.packages("https://cran.r-project.org/src/contrib/Archive/NMF/NMF_0.20.6.tar.gz", repos=NULL, type="source")
library(CancerSubtypes)

# Paths
in_path <- "/media/visiopharm5/WDGold/deeplearning/Hepatocarcinomes/TCGA/processed_backup"
out_path <- "/media/visiopharm5/WDGold/deeplearning/Hepatocarcinomes/TCGA/validation"

data = as.matrix(as.data.frame(read.csv(paste(in_path, "fpkm_final_raw_CCL3L1.csv", sep = "/"), sep="\t", row.names = 1)))
data = data[!rownames(data) %in% c("DEFB134"),]

###To observe the mean, variance and Median Absolute Deviation distribution of the dataset, it helps users to get the distribution characteristics of the data, e.g. To evaluate whether the dataset fits a normal distribution or not.
data.checkDistribution(data)


# check missing values
index=which(is.na(data))
print(index)

# Feature selection based on the most variance
data1=FSbyVar(data, cut.type="topk",value=100)

# Feature selection based on the most variant Median Absolute Deviation (MAD).
data1=FSbyMAD(mRNA, cut.type="topk",value=1000)
data2=FSbyMAD(mRNA, cut.type="cutoff",value=0.5)

# Feature dimension reduction and extraction based on Principal Component Analysis.
data1=FSbyPCA(data, PC_percent=0.9,scale = TRUE)

# Feature selection based on Cox regression model.
data1=FSbyCox(GeneExp,time,status,cutoff=0.05)

# Data normalization
data1 = as.matrix(data.normalization(data,type="feature_zscore",log2=TRUE))
data.checkDistribution(data1)
data2 = data.normalization(data,type="feature_Median",log2=TRUE)
data.checkDistribution(data2)

### CC
result1=ExecuteCC(clusterNum=3,d=data,maxK=10,clusterAlg="hc",distance="pearson",title="GBM")
sil1=silhouette_SimilarityMatrix(result1$group, result1$distanceMatrix)
plot(sil1, border=NA)

### CNMF
seed = 126
result=ExecuteCNMF(data2,clusterNum=3,nrun=30) # result2: data, result: data2
sil=silhouette_SimilarityMatrix(result$group, result$distanceMatrix)
plot(sil, col=1:3, border=NA)

sigclustTest(data2,result$group, nsim=500, nrep=1, icovest=3) # no idea why the results slightly differ each time

result_gene=ExecuteCNMF(t(data),clusterNum=9,nrun=30)
sil_gene=silhouette_SimilarityMatrix(result_gene$group, result_gene$distanceMatrix)
plot(sil_gene, col=1:9, border=NA)

### Reconstruct results
sample_clusters = data.frame(Sample = colnames(data), Cluster = result2$group)
write.csv(sample_clusters, paste(out_path, "sample_clusters_full_cnmf_3.csv", sep = "/"), row.names = FALSE)

sil[which(sil[,3] < 0, arr.ind = TRUE),]

colnames(data2)[which(sil[,3] < 0, arr.ind = TRUE)]
