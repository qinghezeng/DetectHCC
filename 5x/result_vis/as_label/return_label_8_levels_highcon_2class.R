options(echo=FALSE)
options(warn=-1)
args<- commandArgs(trailingOnly=TRUE)

# install.packages("tiff")
library(tiff) # use tiff package rather than rtiff
library (stringr) #for padding counter n with 0
#library ("EBImage")

path="D:\\vis_db\\img\\HMNT0001\\test"
# preds_classes1 <- c(t(read.table("D:\\qinghe\\results\\HMNT0001\\preds_classes", header = TRUE, sep = ",")))
prob <- c(t(read.table("D:\\qinghe\\results\\HMNT0001\\prob", header = TRUE, sep = ",")))

# vote for the label
label = array(dim=c(512,512))

n=length(list.files(path,pattern = "label"))
j = n*128+1
every_64 = seq(1,449,64)
for(c in every_64)
{
  c_63 = c+63
  for(r in every_64)
  {
    r_63 = r+63
    if(prob[j] >= 0.95) { #set threshold of confidence to 0.8
      label[r:r_63,c:c_63] = 1/255
      j = j+2
    } else if(prob[j] >= 0.9) {
      label[r:r_63,c:c_63] = 2/255
      j = j+2
    } else if(prob[j] >= 0.85) {
      label[r:r_63,c:c_63] = 3/255
      j = j+2
    } else if(prob[j] >= 0.8) {
      label[r:r_63,c:c_63] = 4/255
      j = j+2
    } else if(0.8 <= prob[j+1] & prob[j+1] <= 0.85) {
      label[r:r_63,c:c_63] = 5/255
      j = j+2
    } else if(0.85 < prob[j+1] & prob[j+1] <= 0.9) {
      label[r:r_63,c:c_63] = 6/255
      j = j+2
    } else if(0.9 < prob[j+1] & prob[j+1] <= 0.95) {
      label[r:r_63,c:c_63] = 7/255
      j = j+2
    } else if(0.95 < prob[j+1] & prob[j+1] <= 1) {
      label[r:r_63,c:c_63] = 8/255
      j = j+2
    } else {
      label[r:r_63,c:c_63] = 11/255 #it is better not to use the label 0. Although it is set default to be invisible, 
      j = j+2                       #but the result will be very strange, which means to lost most part of it, 
    }                               #so does the roi "default".
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
