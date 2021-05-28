# READ ME ----------------------------------------------------------------------
#input: 64x64 tiles
#Founction:
#Predict the probability of tumoral class and save. 

# Library ----------------------------------------------------------------------
library(keras)
library(tiff) # use tiff package rather than rtiff

# Data preparation -------------------------------------------------------------

#######################################s###############
#edit train/test and slide name
slide_name="train\\HMNT0025_bis"
######################################################

path_img=paste("E:\\deeplearning\\data\\5x\\detector\\",slide_name,"\\split64_image\\",sep="")
path_result=paste("E:\\deeplearning\\data\\5x\\detector\\",slide_name,"\\results\\",sep="")

limg=list.files(path_img, pattern = "\\.tif$")

img=array(dim=c(length(limg),64,64,3))

for (i in c(1:length(limg))){
  img[i,,,]=readTIFF(paste(path_img,"\\",limg[i],sep=""))
}

#save workspace
# filename=paste(path_result,"data_detector_64.RData",sep="")
# save.image(file = filename)

# Load trained model ------------------------------------------------------------

# modified VGG16
model <- load_model_hdf5(filepath = "D:\\deeplearning\\Hepatocarcinomes\\models\\5x\\vgg16_dense_bn\\best_model", compile = TRUE)

# Prediction --------------------------------------------------------------------

#predict the class
# preds_classes <- model %>% predict_classes(img_subtile) 
# write.table(preds_classes, "D:\\qinghe\\results\\HMNT0001\\preds_classes", sep=",",row.names=FALSE)

#predict the probability
preds <- model %>% predict(img)
write.table(preds, 
            paste(path_result,"\\vgg_dense_bn_prob",sep=""),
            sep=",",
            row.names = FALSE,
            col.names = c("tum", "nor"))