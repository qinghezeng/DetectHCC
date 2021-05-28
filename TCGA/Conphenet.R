library(philentropy)

# ***************************************************************************************
# Paths

in_path <- "E:\\deeplearning\\Hepatocarcinomes\\TCGA\\processed"
out_path <- "E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap"

# ***************************************************************************************
# Load data

# data <- as.data.frame(read.csv('E:\\deeplearning\\Hepatocarcinomes\\TCGA\\processed_backup\\fpkm_final_log2-zscore_CCL3L1.csv', sep="\t", row.names = 1))
# data <- as.matrix(data[row.names(data) != "DEFB134", , drop = FALSE]) # remove all-0 row: DEFB134

# Load new data
data <- as.data.frame(read.csv(paste(in_path, "fpkm_final_log2-zscore_CCL3L1-noDEFB134.csv", sep = "\\"), 
                               sep="\t", row.names = 1))



dst = "chebyshev" # euclidean, pearson, spearman (slow), manhattan, minkowski, kendall
linkage = "average" # single, average, complete, ward.D2

if (dst == "pearson" || dst == "spearman" || dst == "kendall") {
  
  # row (gene)
  distCor<-function (m) {
    as.dist(1 - cor(t(m), use="pairwise.complete.obs", method = dst))
  }
  dist_row = distCor(data)
  dist_col = distCor(t(data))
  
} else if (dst == "chebyshev") {
  
  # Attention that pearson and cosine didn't work. Only euclidean, chebyshev, manhattan.
  dist_row = as.dist(distance(data, method = dst))
  # dist_col = as.dist(distance(t(data), method = dst))
  
} else {
  
  dist_row = dist(data, method = dst)
  dist_col = dist(t(data), method = dst)
  
}

# sum(is.na(dist_row))
# sum(is.na(dist_col))

hc_row = hclust(dist_row, method = linkage)
# hc_col = hclust(dist_col, method = linkage)

cdist_row <- cophenetic(hc_row)
# cdist_col <- cophenetic(hc_col)

cophnt_row <- cor(dist_row, cdist_row)
# cophnt_col <- cor(dist_col, cdist_col)

print(cophnt_row)
# print(cophnt_col)
