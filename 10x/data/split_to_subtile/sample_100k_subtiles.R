library(tiff)
library (stringr)

load("Y:/IMAGES/CK/JulienCalderaro/Hepatocarcinomes/10x/-x_train.RData")

path_128_nor = "Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\10x\\split128\\nor"
path_128_tum = "Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\10x\\split128\\tum"

for (i in c(1:length(lpos))){
  writeTIFF(pos[i,,,],  paste(path_128_nor,"\\nor_",str_pad(i-1,10,pad="0"),".tif",sep=""))
  writeTIFF(neg[i,,,],  paste(path_128_tum,"\\tum_",str_pad(i-1,10,pad="0"),".tif",sep=""))
}

