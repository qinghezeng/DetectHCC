options(echo=FALSE)
options(warn=-1)
args<- commandArgs(trailingOnly=TRUE)

# install.packages("tiff")
library(tiff) # use tiff package rather than rtiff
library (stringr) #for padding counter n with 0
#library ("EBImage")

######################################################
#edit slide name
slide_name="R10_004_2 - 2017-08-23"
######################################################

path1=paste("E:\\deeplearning\\Hepatocarcinomes\\data\\5x\\biopsy_HCC\\",slide_name,sep="")
path=paste(path1,"\\results\\",sep="")
prob <- c(t(read.table(paste(path1,"\\results\\vgg_dense_bn_prob",sep=""), header = TRUE, sep = ",")))

record=paste(path,"record.txt",sep="")

n = as.numeric(scan(record, quiet=TRUE))

# vote for the label
label = array(dim=c(512,512))

# n=length(list.files(path,pattern = "label"))

j = n*128+1
every_64 = seq(1,449,64)
for(c in every_64)
{
  c_63 = c+63
  for(r in every_64)
  {
    r_63 = r+63
    # if(prob[j+1]>= 0.86) { #set threshold of confidence to 0.8
    #   label[r:r_63,c:c_63] = 1/255
    #   j = j+2
    # } else if(prob[j] >= 0.6) {
    if(prob[j] >= 0.75) {#default 0.9
      label[r:r_63,c:c_63] = 3/255
      j = j+2
    } else{
      label[r:r_63,c:c_63] = 0/255
      j = j+2
    }
  }
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
