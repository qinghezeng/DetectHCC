###################################################################################################################
#It is not recommended to use this script to directly split the WSI both into 512x512 and into 64x64.
#Because of the delay of the network to connect the server, we have to set the waiting time to very large,
#which will cause the whole process too slow.
#It is better to split them into 64x64 subtiles directly in RStudio without setting the waiting time.
#Moreover, it is necessary to force the number of parallel tasks equal to 1 when doing a batch processing in VIS.
###################################################################################################################

# Saves ROIs as labels and split the original WSI (only ROIs area) 
#into subtiles of two sizes, 512x512 and 64x64 (numbered tif files).
# ROI and image from a sliding window are both Tiff images in byte format.

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

#path to save the 2 kinds of tiles
path_512="Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\5x\\512_img_label"
path_64_pos="D:\\5x\\split64\\nor"
path_64_neg="D:\\5x\\split64\\tum"

#number of files allready saved
n=length(list.files(path_512, pattern = "\\.tif$"))
n=str_pad(n,10,pad="0")

#Firstly split the tiles one by one into subtiles. 
img_subtile = array(dim=c(64,64,64,3))
roi_subtile = array(dim=c(64,64,64))
every_64 = seq(1,449,64)

#compute mean intensity
m=mean(img)

#set the threshold to 200 so as to pick out the white tiles
threshold <- 200/255
if(m < threshold) {
  num_sub = 0
  for(c in every_64)
  {
    for(r in every_64)
     {
      num_sub = num_sub + 1
      r_63 = r+63
      c_63 = c+63
      img_subtile[num_sub,,,] = img[r:r_63,c:c_63,]
      roi_subtile[num_sub,,] = roi[r:r_63,c:c_63]
    }
  }

  #Secondly distinguish the subtiles one by one according to their lables. If it belongs to tum/nor, save it.
  for(i in c(1:64)) {
    m_sub=mean(img_subtile[i,,,])
    if(m_sub < threshold) {
      if(sum(roi_subtile[i,,] == 1/255) > 3072) {
        npos=length(list.files(path_64_pos, pattern = "\\.tif$"))
        npos=str_pad(npos,12,pad="0")
        writeTIFF(img_subtile[i,,,],  paste(path_64_pos,"\\nor_",npos,".tif",sep=""))
      } else if(sum(roi_subtile[i,,] == 2/255) > 3072){
        nneg=length(list.files(path_64_neg, pattern = "\\.tif$"))
        nneg=str_pad(nneg,12,pad="0")
        writeTIFF(img_subtile[i,,,],  paste(path_64_neg,"\\tum_",nneg,".tif",sep=""))
      }
    }
  }

  #save the 512x512 images and labels
  writeTIFF(img,  paste(path_512,"\\img_",n,".tif",sep=""))
  writeTIFF(roi,  paste(path_512,"\\label_",n,".tiff",sep=""))
}

Sys.sleep(20)