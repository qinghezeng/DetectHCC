#Unused script
#To individually split the 512x512 tiles exported by Visiopharm into 64x64 subtiles for building the test set.
#To select subtile (no white but with blurred) to 2 classes. For each slide.

# library (EBImage) //EBImage will cause unexpectable error in Vis
# install.packages("tiff")
library(tiff) # use tiff package rather than rtiff
library (stringr) #for padding counter n with 0

#read the names of 512x512 images and labels
path="D:\\dl\\5x\\test\\HMNT0786\\512_image_label"
limg=list.files(path, pattern = "\\.tif$")
llabel=list.files(path, pattern = "\\.tiff$")

#set the paths to save the 64x64 sutiles according to their labels.
path_64_pos="D:\\dl\5x\\test\\HMNT0783_bis\\split64\\nor"
path_64_neg="D:\dl\\5x\\test\\HMNT0783_bis\\split64\\tum"

#Firstly split the tiles one by one into subtiles. 
#Secondly distinguish the subtiles one by one according to their lables. If it belongs to tum/nor, save it.
img=array(dim=c(512,512,3))
label=array(dim=c(512,512))
img_subtile = array(dim=c(64,64,64,3))
label_subtile = array(dim=c(64,64,64))
every_64 = seq(1,449,64)
threshold <- 200/255

for (i in c(1:length(limg))){
  img[,,]=readTIFF(paste(path,"\\",limg[i],sep=""))
  label[,]=readTIFF(paste(path,"\\",llabel[i],sep=""))
  num_sub = 0
  for(c in every_64)
  {
    c_63 = c+63
    for(r in every_64)
    {
      num_sub = num_sub + 1
      r_63 = r+63
      img_subtile[num_sub,,,] = img[r:r_63,c:c_63,]
      label_subtile[num_sub,,] = label[r:r_63,c:c_63]
    }
  }
  
  #if the subtile is not mostly white, save them corresponding to their class
  for(i in c(1:num_sub)) {
    m_sub=mean(img_subtile[i,,,])
    if(m_sub < threshold) {
      if(sum(label_subtile[i,,] == 2/255) > 3072) { #set the theshold to 0.75
        npos=length(list.files(path_64_pos, pattern = "\\.tif$"))
        npos=str_pad(npos,10,pad="0")
        writeTIFF(img_subtile[i,,,],  paste(path_64_pos,"\\nor_",npos,".tif",sep=""))
      } else if(sum(label_subtile[i,,] == 3/255) > 3072){
        nneg=length(list.files(path_64_neg, pattern = "\\.tif$"))
        nneg=str_pad(nneg,10,pad="0")
        writeTIFF(img_subtile[i,,,],  paste(path_64_neg,"\\tum_",nneg,".tif",sep=""))
      }
    }
  }
}