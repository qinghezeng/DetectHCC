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

#add the new ROIs to the end of labels
n=length(list.files("D:\\dl\\5x\\test\\HMNT0113\\better_label", pattern = "\\.tiff$"))
n=str_pad(n,5,pad="0")
writeTIFF(roi,  paste("D:\\dl\\5x\\test\\HMNT0113\\better_label","\\label_",n,".tiff",sep=""))

#ensure there is enough time for writing the tiles
Sys.sleep(2)


