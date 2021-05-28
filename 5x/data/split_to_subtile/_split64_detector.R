#This script is to split the 512x512 tiles exported by Visiopharm into 64x64 subtiles.
#split each 512 image individually, to save memory.

# library (EBImage) //EBImage will cause unexpectable error in Vis
# install.packages("tiff")
library(tiff) #use tiff package rather than rtiff
library (stringr) #for padding counter n with 0

######################################################
#edit train/test and slide name
slide_name="train\\HMNT0062"
######################################################

#read the names of 512x512 images
path=paste("E:\\deeplearning\\data\\5x\\detector\\",slide_name,"\\512_image",sep="")
limg=list.files(path, pattern = "\\.tif$")

#paths to save the 64x64 sutiles.
path_64=paste("E:\\deeplearning\\data\\5x\\detector\\",slide_name,"\\split64_image",sep="")

#Firstly split the tiles one by one into subtiles. 
img=array(dim=c(512,512,3))
img_subtile = array(dim=c(64,64,64,3))
every_64 = seq(1,449,64)

for (i in c(1:length(limg))){
  img[,,]=readTIFF(paste(path,"\\",limg[i],sep=""))
  num_sub = 0
  for(c in every_64)
  {
    c_63 = c+63
    for(r in every_64)
    {
      num_sub = num_sub + 1
      r_63 = r+63
      img_subtile[num_sub,,,] = img[r:r_63,c:c_63,]
      nsub=length(list.files(path_64, pattern = "\\.tif$"))
      nsub=str_pad(nsub,6,pad="0")
      writeTIFF(img_subtile[num_sub,,,],  paste(path_64, "\\", nsub, ".tif",sep=""))
    }
  }
}