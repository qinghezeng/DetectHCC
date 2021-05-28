options(echo=FALSE)
options(warn=-1)
args<- commandArgs(trailingOnly=TRUE)

# install.packages("tiff")
library(tiff) # use tiff package rather than rtiff
library (stringr) #for padding counter n with 0

######################################################
#edit train/test and slide name
slide_name="test\\HMNT0932"

#best threshold
threshold=0.272
######################################################

path1=paste("E:\\deeplearning\\data\\5x\\detector\\",slide_name,sep="")
path=paste(path1,"\\results\\label",sep="")
prob <- c(t(read.table(paste(path1,"\\results\\vgg_dense_bn_prob",sep=""), header = TRUE, sep = ",")))

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
    if(prob[j] >= threshold) {
      label[r:r_63,c:c_63] = 3/255
      j = j+2
    } else{
      label[r:r_63,c:c_63] = 0/255
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
