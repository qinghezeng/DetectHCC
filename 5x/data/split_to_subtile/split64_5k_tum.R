library(tiff) #use tiff package rather than rtiff
library (stringr) #for padding counter n with 0
library (EBImage)

#read the names of 64x64 image
path="E:\\deeplearning\\Hepatocarcinomes\\data\\5x\\training\\split64_image"
limg=list.files(paste(path,"\\tum_100k+",sep=""), pattern = "\\.tif$")

img = array(dim=c(64,64,3))
sub = 0
ssub = "00"

threshold <- 200/255
#EBImage Edge Detection filter
la <- matrix(-1, nc=3, nr=3)
la[2,2] <- 8
la
threshold_filter <- 35/255

for (i in c(1:length(limg))){
  img[,,]=readTIFF(paste(path,"\\tum_100k+\\",limg[i],sep=""))
  
  #if the subtile is not mostly context nor mostly blurred nor mostly over-colored, save them corresponding to their class
  m_sub=mean(img[,,])
  y <- filter2(img[,,], la)
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
  m_filtered_sub=mean(y)
  
  if(m_sub < threshold & m_filtered_sub > threshold_filter) {
      nsub=length(list.files((paste(path,"\\tum_5k\\sub",ssub,sep="")),pattern = "\\.tif$"))
      if(nsub == 5000) {
        sub = sub + 1
        nsub=0
      } 
      nsub=str_pad(nsub,4,pad="0")
      ssub=str_pad(sub,2,pad="0")
      writeTIFF(img[,,], (paste(path,"\\tum_5k\\sub",ssub,"\\",ssub,"_",nsub,".tif",sep="")))
  }
}
