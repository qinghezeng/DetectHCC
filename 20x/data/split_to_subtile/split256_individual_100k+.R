#This script is to split the 2048x2048 tiles exported by Visiopharm into 256x256 subtiles.
#The number of tiles is too large to load all the tile at the same time, so this script splits them individually.

# library (EBImage) //EBImage will cause unexpectable error in Vis
# install.packages("tiff")
library(tiff) #use tiff package rather than rtiff
library (stringr) #for padding counter n with 0

#read the names of 2048x2048 images and labels
path="Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\20x\\2048"
limg=list.files(path, pattern = "\\.tif$")
lroi=list.files(path, pattern = "\\.tiff$")

#set the paths to save the 64x64 sutiles according to their labels.
path_256_pos="Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\20x\\split256\\nor"
path_256_neg="Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\20x\\split256\\tum"

#Firstly split the tiles one by one into subtiles. 
#Secondly distinguish the subtiles one by one according to their lables. If it belongs to tum/nor, save it.
img=array(dim=c(2048,2048,3))
roi=array(dim=c(2048,2048))
img_subtile = array(dim=c(64,256,256,3))
roi_subtile = array(dim=c(64,256,256))
every_256 = seq(1,1793,256)
threshold <- 200/255

for (i in c(3414:length(limg))){
  img[,,]=readTIFF(paste(path,"\\",limg[i],sep=""))
  roi[,]=readTIFF(paste(path,"\\",lroi[i],sep=""))
  num_sub = 0
  for(c in sample(every_256,size=3))
  {
    c_255 = c+255
    for(r in sample(every_256,size=1))
    {
      num_sub = num_sub + 1
      r_255 = r+255
      img_subtile[num_sub,,,] = img[r:r_255,c:c_255,]
      roi_subtile[num_sub,,] = roi[r:r_255,c:c_255]
    }
  }
  #if the subtile is not mostly white, save them corresponding to their class
  for(j in c(1:num_sub)) {
    m_sub=mean(img_subtile[j,,,])
    if(m_sub < threshold) {
      if(sum(roi_subtile[j,,] == 2/255) > 3072) { #set the theshold to 0.75
        npos=length(list.files(path_256_pos, pattern = "\\.tif$"))
        npos=str_pad(npos,10,pad="0")
        writeTIFF(img_subtile[j,,,],  paste(path_256_pos,"\\nor_",npos,".tif",sep=""))
      } else if(sum(roi_subtile[j,,] == 3/255) > 3072){
        nneg=length(list.files(path_256_neg, pattern = "\\.tif$"))
        nneg=str_pad(nneg,10,pad="0")
        writeTIFF(img_subtile[j,,,],  paste(path_256_neg,"\\tum_",nneg,".tif",sep=""))
      }
    }
  }
}