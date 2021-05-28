library(tiff)
library (stringr)

path_256_nor = "Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\20x\\split256\\pos_nor"
path_256_tum = "Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\20x\\split256\\neg_tum"

for (i in c(1:length(lpos))){
  writeTIFF(pos[i,,,],  paste(path_256_nor,"\\nor_",str_pad(i-1,10,pad="0"),".tif",sep=""))
  writeTIFF(neg[i,,,],  paste(path_256_tum,"\\tum_",str_pad(i-1,10,pad="0"),".tif",sep=""))
}

