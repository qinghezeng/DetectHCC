# Saves ROIs as labels and split the original WSI (only ROIs area) into 2048x2048 tiles (numbered tif files).
# ROI and image from a sliding window are both Tiff images in byte format.

options(echo=FALSE)
options(warn=-1)
args<- commandArgs(trailingOnly=TRUE)

# library (EBImage) //EBImage will cause unexpectable error in Vis
# install.packages("tiff")
library(tiff) # use tiff package rather than rtiff
library (stringr) #for padding counter n with 0

# Read ROI overlay from arguments
roi<-readTIFF(args[2])
# Read input image from arguments
img<-readTIFF(args[3])

#path to save the 2048x2048 tiles
path_2048="D:\\dl\\20x\\data\\2048"

#number of files allready saved
n=length(list.files(path_2048, pattern = "\\.tif$"))
n=str_pad(n,10,pad="0")

#compute the mean value of RGB channels of a tile
m=mean(img)

#set the threshold to 200 so as to pick out the white tiles
threshold <- 200/255
if(m < threshold) {
  writeTIFF(roi,  paste(path_2048,"\\label_",n,".tiff",sep=""))
  writeTIFF(img,  paste(path_2048,"\\img_",n,".tif",sep=""))
}

#ensure there is enough time for writing the tiles
Sys.sleep(2)
