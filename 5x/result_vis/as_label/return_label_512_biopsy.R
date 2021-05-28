options(echo=FALSE)
options(warn=-1)
args<- commandArgs(trailingOnly=TRUE)

# install.packages("tiff")
library(tiff) # use tiff package rather than rtiff
library(stringr) #for padding counter n with 0

######################################################
#edit train/test and slide name
slide_name="R10_004_2 - 2017-08-23"
######################################################

path=paste("E:\\deeplearning\\Hepatocarcinomes\\data\\5x\\biopsy_HCC\\",slide_name, "\\results\\", sep="")
record=paste(path,"record.txt",sep="")

num = as.numeric(scan(record, quiet=TRUE))

label = readTIFF(paste(path, "label_overlap_fcn\\", str_pad(num,5,pad="0"), ".tiff",sep=""))
label[which(label < 150/255)] = 1/255
label[which(150/255 <= label & label < 200/255)] = 2/255
label[which(200/255 <= label )] = 3/255
writeTIFF(label, args[1])

num = num +1
write.table(num, record, row.names = FALSE, col.names = FALSE)



