#This script is to split the 512x512 tiles into 64x64 subtiles by loading all the tiles at the same time.
#It is better to use this script everytime finishing a batch of slides (like 100 slides), or it may run out of memory------------

# library (EBImage) //EBImage will cause unexpectable error in Vis
# install.packages("tiff")
library(tiff) # use tiff package rather than rtiff
library (stringr) #for padding counter n with 0

#read the names of 512x512 images and labels
path="Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\5x\\512_img_label"
limg=list.files(path, pattern = "\\.tif$")
lroi=list.files(path, pattern = "\\.tiff$")

#read the 512x512 images and labels
img=array(dim=c(length(limg),512,512,3))
roi=array(dim=c(length(lroi),512,512))
for (i in c(1:length(limg))){
  img[i,,,]=readTIFF(paste(path,"\\",limg[i],sep=""))
  roi[i,,]=readTIFF(paste(path,"\\",lroi[i],sep=""))}
 
#The following code can be run while doing the batch processing of spliting slides to 512x512---------

#split the 512x512 tiles into 64x64 subtiles
img_subtile = array(dim=c(length(limg)*64,64,64,3))
roi_subtile = array(dim=c(length(lroi)*64,64,64))
every_64 = seq(1,449,64)
num_sub = 0
for (i in c(1:length(limg))){
  for(c in every_64)
  {
   for(r in every_64)
   {
     num_sub = num_sub + 1
     r_63 = r+63
     c_63 = c+63
     img_subtile[num_sub,,,] = img[i,r:r_63,c:c_63,]
     roi_subtile[num_sub,,] = roi[i,r:r_63,c:c_63]
   }
  }
}
  
#if the subtile is not mostly white, save them corresponding to their class
path_64_pos="Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\5x\\split64\\nor"
path_64_neg="Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\5x\\split64\\tum"
threshold <- 200/255
for(i in c(1:num_sub)) {
  m_sub=mean(img_subtile[i,,,])
  if(m_sub < threshold) {
    if(sum(roi_subtile[i,,] == 2/255) > 3072) {
      npos=length(list.files(path_64_pos, pattern = "\\.tif$"))
      npos=str_pad(npos,10,pad="0")
      writeTIFF(img_subtile[i,,,],  paste(path_64_pos,"\\nor_",npos,".tif",sep=""))
    } else if(sum(roi_subtile[i,,] == 3/255) > 3072){
      nneg=length(list.files(path_64_neg, pattern = "\\.tif$"))
      nneg=str_pad(nneg,10,pad="0")
      writeTIFF(img_subtile[i,,,],  paste(path_64_neg,"\\tum_",nneg,".tif",sep=""))
    }
  }
}