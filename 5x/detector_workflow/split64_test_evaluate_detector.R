#Fonction:
#1 Split 512 tiles from Visiopharm, to 64x64 subtiles.
#  Save 64x64 image as tiff, save 64x64 label (GT) as table of tumoral pixels.
#2 Predict the probability of tumoral class and save. 
#3 Calculate the ROC curve, accuracy, the best threshold and save them.

start_time <- Sys.time()

# library (EBImage) //EBImage will cause unexpectable error in Vis
# install.packages("tiff")
library(tiff) #use tiff package rather than rtiff
library (stringr) #for padding counter n with 0
library(keras)
library(pROC)

######################################################
#edit train/test and slide name
slide_name="test\\HMNT0932"
######################################################

#read the names of 512x512 images and labels
path_512=paste("E:\\deeplearning\\data\\5x\\detector\\",slide_name,"\\512_image_label",sep="")
limg=list.files(path_512, pattern = "\\.tif$")
lroi=list.files(path_512, pattern = "\\.tiff$")

#paths to save the 64x64 sutiles.
path_64=paste("E:\\deeplearning\\data\\5x\\detector\\",slide_name,"\\split64_image_label",sep="")

#paths to save prediction.
path_result=paste("E:\\deeplearning\\data\\5x\\detector\\",slide_name,"\\results\\",sep="")

#Firstly split the tiles one by one into subtiles. 
img=array(dim=c(512,512,3))
roi=array(dim=c(512,512))
#should be activated, when: already saved split64 image but not yet test ----
img_subtile = array(dim=c(length(lroi)*64,64,64,3))
###########################--------------------------------------------------
roi_subtile = array(dim=c(64,64,64))
roi_sub_npixel = array(dim=(c(length(lroi))*64))
nroi = 0
every_64 = seq(1,449,64)

for (i in c(1:length(lroi))){
  img[,,]=readTIFF(paste(path_512,"\\",limg[i],sep=""))
  roi[,]=readTIFF(paste(path_512,"\\",lroi[i],sep=""))
  num_sub = 0
  for(c in every_64)
  {
    c_63 = c+63
    for(r in every_64)
    {
      num_sub = num_sub + 1
      r_63 = r+63
      nroi = nroi+1
      img_subtile[nroi,,,] = img[r:r_63,c:c_63,]
      # nsub=length(list.files(path_64, pattern = "\\.tif$"))
      # nsub=str_pad(nsub,6,pad="0")
      # writeTIFF(img_subtile[nroi,,,],  paste(path_64, "\\", nsub, ".tif",sep=""))
      roi_subtile[num_sub,,] = roi[r:r_63,c:c_63]
      roi_sub_npixel[nroi] = sum(roi_subtile[num_sub,,]==3/255)
    }
  }
}

write.table(roi_sub_npixel, 
            paste(path_64,"\\label_tum_npixel",sep=""),
            sep=",",
            row.names = FALSE,
            col.names = FALSE)

# roi_sub_npixel <- c(t(read.table(paste(path_64,"\\label_tum_npixel",sep=""), header = FALSE, sep = ",")))

# Load trained model ------------------------------------------------------------

# modified VGG16
model <- load_model_hdf5(filepath = "E:\\deeplearning\\Hepatocarcinomes\\models\\5x\\vgg16_dense_bn\\best_model", compile = TRUE)

# Prediction --------------------------------------------------------------------

###should be activated, when: already saved split64 image but not yet test ----
# limg=list.files(path_64, pattern = "\\.tif$")
# for (i in c(1:length(limg))){
#   img_subtile[i,,,]=readTIFF(paste(path_64,"\\",limg[i],sep=""))
# }
#########################------------------------------------------------------

#predict the probability
preds <- model %>% predict(img_subtile)
write.table(preds,
            paste(path_result,"\\vgg_dense_bn_prob",sep=""),
            sep=",",
            row.names = FALSE,
            col.names = c("tum", "nor"))

# prob <- c(t(read.table(paste(path_result,"\\vgg_dense_bn_prob",sep=""), header = TRUE, sep = ",", 
#                        colClasses = c("numeric", "NULL")))) #set col2 to "NULL", to skip this col

# Labels for evalutaion --------------------------------------------------------
y_tum = c(dim=(c(length(lroi))*64))
for(i in c(1:nroi)) {
  if(roi_sub_npixel[i] > 2048){ #3072 is 75% threshold, 2048 is 50%
    y_tum[i] = 1
  } else {
    y_tum[i] = 0}
}

# Evaluation ---------------------------------------------------------------------

#package pROC: ROC curve, accuracy, the best threshold
roc_tum <- roc(y_tum, preds[,1])
# roc_tum <- roc(y_tum, prob)
png(file=paste(path_result,"\\ROC.png",sep=""))
plot(roc_tum, col="red", 
     print.thres=TRUE, 
     print.auc=TRUE,
     main=paste(slide_name,"ROC curve",sep=" "),
     xlim=c(1,0),
     ylim=c(0,1),
     asp=1)
dev.off()

end_time <- Sys.time()
end_time - start_time