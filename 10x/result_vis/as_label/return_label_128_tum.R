options(echo=FALSE)
options(warn=-1)
args<- commandArgs(trailingOnly=TRUE)

# install.packages("tiff")
library(tiff) # use tiff package rather than rtiff
library (stringr) #for padding counter n with 0
#library ("EBImage")

path="D:\\dl\\5x\\test\\HMNT0113\\results\\label"
# preds_classes1 <- c(t(read.table("D:\\qinghe\\results\\HMNT0001\\preds_classes", header = TRUE, sep = ",")))
prob <- c(t(read.table("Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\10x\\test\\HMNT0113\\results\\vgg_dense_bn_prob", header = TRUE, sep = ",")))

# vote for the label
label = array(dim=c(1024,1024))

n=length(list.files(path,pattern = "label"))
j = n*128+1
every_128 = seq(1,897,128)
for(c in every_128)
{
  c_127 = c+127
  for(r in every_128)
  {
    r_127 = r+127
    # if(prob[j+1]>= 0.86) { #set threshold of confidence to 0.8
    #   label[r:r_63,c:c_63] = 1/255
    #   j = j+2
    # } else if(prob[j] >= 0.6) {
    if(prob[j] >= 0.6) {
      label[r:r_127,c:c_127] = 2/255
      j = j+2
    } else{
      label[r:r_127,c:c_127] = 0/255
      j = j+2
    }
  }
}

n=str_pad(n,5,pad="0")
writeTIFF(label, paste(path,"\\label_",n,".tiff",sep=""))
# if(length(which(preds_classes[j:j_63]==1))>32) {
#   label[,] = 1/255
# } else {
#   label[,] = 2/255
# }

# Write resulting label back to arguments
writeTIFF(label, args[1])
#simply change the following line for inporting the results as roi:
#writeTIFF(label, args[2])
