# Build a clean zeiss test set
# remove background and blurred, using conv filter

library (EBImage)
# install.packages("tiff")
library(tiff) # use tiff package rather than rtiff
library (stringr) #for padding counter n with 0

#read the names of 512x512 images and labels
rootpath="E:\\deeplearning\\Hepatocarcinomes\\data\\5x\\test_zeiss"
#set the paths to save the 64x64 sutiles according to their labels.
path_64_pos="E:\\deeplearning\\Hepatocarcinomes\\data\\5x\\test_zeiss\\testset\\nor"
path_64_neg="E:\\deeplearning\\Hepatocarcinomes\\data\\5x\\test_zeiss\\testset\\tum"

#Firstly split the tiles one by one into subtiles. 
#Secondly distinguish the subtiles one by one according to their lables. If it belongs to tum/nor, save it.
img=array(dim=c(512,512,3))
label=array(dim=c(512,512))
img_subtile = array(dim=c(64,64,64,3))
label_subtile = array(dim=c(64,64,64))
every_64 = seq(1,449,64)
threshold <- 200/255
#EBImage Edge Detection filter
la <- matrix(-1, nc=3, nr=3)
la[2,2] <- 8
la
# threshold_filter <- 35/255
threshold_filter <- 15/255

dirs=dir(path = rootpath, full.names = FALSE, recursive = FALSE, pattern = "HMNT")
for (dir in dirs[2:18]) {
  path=paste(rootpath,"\\",dir,"\\512_image_label",sep="")
  
  limg=list.files(path, pattern = "\\.tif$")
  llabel=list.files(path, pattern = "\\.tiff$")
  
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
    
    #if the subtile is not mostly context nor mostly blurred nor mostly over-colored, save them corresponding to their class
    for(j in c(1:num_sub)) {
      m_sub=mean(img_subtile[j,,,])
      y <- filter2(img_subtile[j,,,], la)
      for (a in c(1:64)){
        for (b in c(1:64)){
          for (c in c(1:3)){
            if(y[a,b,c]<0) {
              y[a,b,c]=0
            }
            if(y[a,b,c]>1) {
              y[a,b,c]=1
            }
          }
        }
      }
      m_filtered_sub=mean(y) #difference of value compared to ImageJ is ignorable
      if(m_sub < threshold & m_filtered_sub > threshold_filter) {
        if(sum(label_subtile[j,,] == 3/255) > 2048){ #if more than a half of the surface is labeled as tum
          nneg=length(list.files(path_64_neg, pattern = "\\.tif$"))
          nneg=str_pad(nneg,10,pad="0")
          writeTIFF(img_subtile[j,,,],  paste(path_64_neg,"\\tum_",nneg,".tif",sep=""))
        } else {
          npos=length(list.files(path_64_pos, pattern = "\\.tif$"))
          npos=str_pad(npos,10,pad="0")
          writeTIFF(img_subtile[j,,,],  paste(path_64_pos,"\\non_",npos,".tif",sep=""))
        }
      }
    }
  }
}
