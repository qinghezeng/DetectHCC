options(echo=FALSE)
options(warn=-1)
args<- commandArgs(trailingOnly=TRUE)

# install.packages("tiff")
library(tiff) # use tiff package rather than rtiff
library (stringr) #for padding counter n with 0
#library ("EBImage")
library(reticulate)
np <- import("numpy")

######################################################
#edit slide name
slide_name="R10_004_2 - 2017-08-23"

#nrow and ncol in Visiopharm (for 512x512 patches)
nrow=17
ncol=33
######################################################

# path1=paste("E:\\deeplearning\\Hepatocarcinomes\\data\\5x\\biopsy_HCC\\",slide_name,sep="")
# path=paste(path1,"\\results\\",sep="")
# prob <- c(t(read.table(paste(path1,"\\results\\vgg_dense_bn_prob",sep=""), header = TRUE, sep = ",")))

path1=paste("E:\\deeplearning\\Hepatocarcinomes\\BiopsiesClassification")
file=paste(path1, '\\', strsplit(slide_name, ' ')[[1]][1], "_pb_stride16p.npy",sep="")
path=paste("E:\\deeplearning\\Hepatocarcinomes\\data\\5x\\biopsy_HCC\\",slide_name,"\\results\\",sep="")

pb <- np$load(file)

record=paste(path,"record.txt",sep="")

n = as.numeric(scan(record, quiet=TRUE))

# vote for the label
label = array(dim=c(512,512))

# n=length(list.files(path,pattern = "label"))

icol <- n%%ncol #col index in vis
irow <- n%/%ncol #row index in vis

if(irow%%2==1) {
  irow = irow*32+1 #in pb
  icol = icol*32+1 
} else {
  irow = irow*32+1
  icol = (ncol-1-icol)*32+1
}

every_16 = seq(1,497,16)
for(c in every_16)
{
  c_16 = c+15
  for(r in every_16)
  {
    r_16 = r+15
    # if(prob[j+1]>= 0.86) { #set threshold of confidence to 0.8
    #   label[r:r_63,c:c_63] = 1/255
    #   j = j+2
    # } else if(prob[j] >= 0.6) {
    
    if(irow>=520) {
      irow <- 520
    }
    if(icol>=1054) {
      icol <- 1054
    }
    
    if(pb[icol, irow, 1] >= 0.5) {#default 0.9
      label[c:c_16,r:r_16] = 3/255
    } else{
      label[c:c_16,r:r_16] = 0/255
    }
    irow = irow+1
  }
  icol = icol+1
}

# n=str_pad(n,5,pad="0")
# writeTIFF(label, paste(path,"\\label_",n,".tiff",sep=""))
# if(length(which(preds_classes[j:j_63]==1))>32) {
#   label[,] = 1/255
# } else {
#   label[,] = 2/255
# }
n = n +1
write.table(n, record, row.names = FALSE, col.names = FALSE)

# Write resulting label back to arguments
writeTIFF(label, args[1])
#simply change the following line for inporting the results as roi:
#writeTIFF(label, args[2])






