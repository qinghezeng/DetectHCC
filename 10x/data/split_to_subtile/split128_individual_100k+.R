#This script is to extract more than 100,000 128x128 subtiles for each class (2 classes) from the 1024x1024 tiles exported by Visiopharm.
#The number of tiles is too large to load all the tile at the same time, so this script splits them individually.

# library (EBImage) //EBImage will cause unexpectable error in Vis
# install.packages("tiff")
library(tiff) #use tiff package rather than rtiff
library (stringr) #for padding counter n with 0

#read the names of 1024x1024 images and labels
path="Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\10x\\1024"
limg=list.files(path, pattern = "\\.tif$")
lroi=list.files(path, pattern = "\\.tiff$")

#set the paths to save the 64x64 sutiles according to their labels.
path_128_pos="Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\10x\\split128\\nor"
path_128_neg="Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\10x\\split128\\tum"

#Firstly split the tiles one by one into subtiles. 
#Secondly distinguish the subtiles one by one according to their lables. If it belongs to tum/nor, save it.
img=array(dim=c(1024,1024,3))
roi=array(dim=c(1024,1024))
img_subtile = array(dim=c(4,128,128,3))
roi_subtile = array(dim=c(4,128,128))
every_128 = seq(1,897,128)

threshold <- 200/255

for (i in c(1:length(limg))){
  img[,,]=readTIFF(paste(path,"\\",limg[i],sep=""))
  roi[,]=readTIFF(paste(path,"\\",lroi[i],sep=""))
  num_sub = 0
  for(c in sample(every_128,size=2))
  {
    c_127 = c+127
    for(r in sample(every_128,size=2))
    {
      num_sub = num_sub + 1
      r_127 = r+127
      img_subtile[num_sub,,,] = img[r:r_127,c:c_127,]
      roi_subtile[num_sub,,] = roi[r:r_127,c:c_127]
    }
  }
  #if the subtile is not mostly white, save them corresponding to their class
  for(j in c(1:num_sub)) {
    m_sub=mean(img_subtile[j,,,])
    if(m_sub < threshold) {
      if(sum(roi_subtile[j,,] == 2/255) > 3072) { #set the theshold to 0.75
        npos=length(list.files(path_128_pos, pattern = "\\.tif$"))
        npos=str_pad(npos,10,pad="0")
        writeTIFF(img_subtile[j,,,],  paste(path_128_pos,"\\nor_",npos,".tif",sep=""))
      } else if(sum(roi_subtile[j,,] == 3/255) > 3072){
        nneg=length(list.files(path_128_neg, pattern = "\\.tif$"))
        nneg=str_pad(nneg,10,pad="0")
        writeTIFF(img_subtile[j,,,],  paste(path_128_neg,"\\tum_",nneg,".tif",sep=""))
      }
    }
  }
}