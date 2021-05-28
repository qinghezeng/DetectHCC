#Saves ROIs as labels and split the whole WSI into 512x512 tiles (numbered tif files) for building a 5x test dataset.
#ROI and image from a sliding window are both Tiff images in byte format.

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

#path to save the 512x512 tiles
#path_512="E:\\deeplearning\\data\\5x\\test\\512_image_label"
path_512="V:\\deeplearning\\Hepatocarcinomes\\data\\5x\\test_zeiss"

#read the number of files already saved, and add new tiles to the end
n=length(list.files(path_512, pattern = "\\.tif$"))
n=str_pad(n,8,pad="0")
writeTIFF(img,  paste(path_512,"\\img_",n,".tif",sep=""))

#add the new ROIs to the end of labels
n=length(list.files(path_512, pattern = "\\.tiff$"))
n=str_pad(n,8,pad="0")
writeTIFF(roi,  paste(path_512,"\\label_",n,".tiff",sep=""))

#ensure there is enough time for writing the tiles
#Sys.sleep(2)


