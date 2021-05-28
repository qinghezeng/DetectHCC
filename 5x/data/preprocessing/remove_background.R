#This script is to create a new dataset without the tiles whose roi valeurs are all 0.
#This script treats the tiles one by one, so the target folder shouldn't be occupied.
#The advantage is that it doesn't need a huge space to realize the function.

library(tiff) # use tiff package rather than rtiff
library (stringr) #for padding counter n with 0

path="Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\5x\\512_img_label"
limage=list.files(path, pattern = "\\.tif$") #only return the file end with ".tif". 
img=array(dim=c(512,512,3))

llabel=list.files(path, pattern = "\\.tiff$")
label=array(dim=c(512,512))

path_out="Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\5x\\512"

for (i in c(1:length(llabel))){
  img[,,]=readTIFF(paste(path,"\\",limage[i],sep=""))
  label[,]=readTIFF(paste(path,"\\",llabel[i], sep=""))
  if(sum(label[,]==0)==262144) {}
  else {
    nimg=length(list.files(path_out, pattern = "\\.tif$"))
    nimg=str_pad(nimg,12,pad="0")
    writeTIFF(img[,,],  paste(path_out,"\\img_",nimg,".tif",sep=""))
    writeTIFF(label[,],  paste(path_out,"\\label_",nimg,".tiff",sep=""))
  }
}