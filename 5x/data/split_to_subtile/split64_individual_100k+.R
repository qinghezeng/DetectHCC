#This script is to extract more than 100,000 64x64 subtiles for each class (2 classes) from the 512x512 tiles exported by Visiopharm.
#The number of tiles is too large to load all the tile at the same time, so this script splits them individually.

# library (EBImage) //EBImage will cause unexpectable error in Vis
# install.packages("tiff")
library(tiff) #use tiff package rather than rtiff
library (stringr) #for padding counter n with 0

#read the names of 512x512 images and labels
path="Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\5x\\512_"
limg=list.files(path, pattern = "\\.tif$")
lroi=list.files(path, pattern = "\\.tiff$")

#set the paths to save the 64x64 sutiles according to their labels.
path_64_pos="D:\\dl\\5x\\data\\split64\\nor_1m"
path_64_neg="D:\\dl\\5x\\data\\split64\\tum_1m"

#Firstly split the tiles one by one into subtiles. 
#Secondly distinguish the subtiles one by one according to their lables. If it belongs to tum/nor, save it.
img=array(dim=c(512,512,3))
roi=array(dim=c(512,512))
img_subtile = array(dim=c(3,64,64,3)) #sample 3 from 64
roi_subtile = array(dim=c(3,64,64))
every_64 = seq(1,449,64)
threshold <- 200/255

for (i in c(1:length(limg))){
  img[,,]=readTIFF(paste(path,"\\",limg[i],sep=""))
  roi[,]=readTIFF(paste(path,"\\",lroi[i],sep=""))
  num_sub = 0
  for(c in sample(every_64,size=3))
  {
    c_63 = c+63
    for(r in sample(every_64,size=1))
    {
      num_sub = num_sub + 1
      r_63 = r+63
      img_subtile[num_sub,,,] = img[r:r_63,c:c_63,]
      roi_subtile[num_sub,,] = roi[r:r_63,c:c_63]
    }
  }
  #if the subtile is not mostly white, save them corresponding to their class
  for(j in c(1:num_sub)) {
    m_sub=mean(img_subtile[j,,,])
    if(m_sub < threshold) {
      if(sum(roi_subtile[j,,] == 2/255) > 3072) { #set the theshold to 0.75
        npos=length(list.files(path_64_pos, pattern = "\\.tif$"))
        npos=str_pad(npos,10,pad="0")
        writeTIFF(img_subtile[j,,,],  paste(path_64_pos,"\\nor",npos,".tif",sep=""))
      } else if(sum(roi_subtile[j,,] == 3/255) > 3072){
        nneg=length(list.files(path_64_neg, pattern = "\\.tif$"))
        nneg=str_pad(nneg,10,pad="0")
        writeTIFF(img_subtile[j,,,],  paste(path_64_neg,"\\tum",nneg,".tif",sep=""))
      }
    }
  }
}