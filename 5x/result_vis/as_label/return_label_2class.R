#This script is to return labels to Visiopharm,
#every of which is a 512x512 image coded 0 or 1 by majority voting of the 64 subtiles (64x64).

options(echo=FALSE)
options(warn=-1)
args<- commandArgs(trailingOnly=TRUE)

# install.packages("tiff")
library(tiff) # use tiff package rather than rtiff
library (stringr) #for padding counter n with 0
#library ("EBImage")

path="D:\\vis_db\\img\\HMNT0001\\test"
# preds_classes1 <- c(t(read.table("D:\\qinghe\\results\\HMNT0001\\preds_classes", header = TRUE, sep = ",")))
prob <- read.csv2("D:\\qinghe\\results\\HMNT0001\\prob", header = TRUE, sep = ",") #if read.table, it will mix all the columns.

# vote for the label
label = array(dim=c(512,512))

#use the number of labels to send back the labels in the correct order, so we can't use a ROI layer when testing.
n=length(list.files(path,pattern = "label"))
# j = n*64+1
# j_63 = j+63
# if(length(which(preds_classes1[j:j_63]==1))>51) { #confidence threshold 0.8
#   label[,] = 1/255
# } else if(length(which(preds_classes1[j:j_63]==0))>51) {
#   label[,] = 2/255
# }
j = n*64+1
j_63 = j+63
if(sum(as.numeric(as.character(prob$V2[j:j_63])) >= 0.8)>20) { #set threshold of confidence to 0.8
  label[,] = 1/255
  n=str_pad(n,5,pad="0")
  writeTIFF(label, args[1])
  writeTIFF(label, paste(path,"\\label_",n,".tiff",sep=""))
  } else if(sum(as.numeric(as.character(prob$V1[j:j_63])) >= 0.8)>20) {
    label[,] = 2/255
    n=str_pad(n,5,pad="0")
    writeTIFF(label, paste(path,"\\label_",n,".tiff",sep=""))
    writeTIFF(label, args[1])
  } else {
    label[,] = 0/255
    n=str_pad(n,5,pad="0")
    writeTIFF(label, paste(path,"\\label_",n,".tiff",sep=""))
  }
