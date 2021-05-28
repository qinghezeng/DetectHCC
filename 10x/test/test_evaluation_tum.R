# READ ME ----------------------------------------------------------------------
#input: 512x512 tiles
#split to 64x64 subtiles without writing
#Founction:
#Predict the probability of tumoral class and save. 
#Calculate the ROC curve, accuracy, the best threshold.
#Calculate the confusion matrix and other performance on a fixed threshold.

# Library ----------------------------------------------------------------------
library(keras)
library(tiff) # use tiff package rather than rtiff
library(pROC)
# install.packages("caret")
library(caret)

# Data preparation -------------------------------------------------------------

# memory.size()
memory.limit(750000) #Size in Mb (1048576 bytes), rounded to 0.01 Mb

path="E:\\deeplearning\\Hepatocarcinomes\\10x\\test\\HMNT0113\\1024_image_label"
limg=list.files(path, pattern = "\\.tif$")
lroi=list.files(path, pattern = "\\.tiff$")
img=array(dim=c(length(limg),1024,1024,3))
roi=array(dim=c(length(limg),1024,1024))

for (i in c(1:length(limg))){
  img[i,,,]=readTIFF(paste(path,"\\",limg[i],sep=""))
  roi[i,,]=readTIFF(paste(path,"\\",lroi[i],sep=""))
}

# subdivide the image into 64*64
img_subtile = array(dim=c(length(limg)*64,128,128,3))
roi_subtile = array(dim=c(length(lroi)*64,128,128))
every_128 = seq(1,897,128)
num_sub = 0
for(i in c(1:length(limg))) {
  for(c in every_128)
  {
    for(r in every_128)
    {
      num_sub = num_sub + 1
      r_127 = r+127
      c_127 = c+127
      img_subtile[num_sub,,,] = img[i,r:r_127,c:c_127,]
      roi_subtile[num_sub,,] = roi[i,r:r_127,c:c_127]
    }
  }
}

# save.image(file = "Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\10x\\test\\HMNT0113\\data_1024_128.RData")

# Labels for evalutaion --------------------------------------------------------
y_tum = c(dim=num_sub)
for(i in c(1:num_sub)) {
  if(sum(roi_subtile[i,,] == 3/255) > 2048){ #3072 is 75% threshold, 2048 is 50%
    y_tum[i] = 1
  } else {
    y_tum[i] = 0}
}

# Load trained model ------------------------------------------------------------

# use a trained CNN model
model <- load_model_hdf5(filepath = "E:\\deeplearning\\Hepatocarcinomes\\models\\10x\\vgg16_dense_bn\\adam_64_lr3_best_model.hdf5", compile = TRUE)

# Prediction --------------------------------------------------------------------

#predict the class
# preds_classes <- model %>% predict_classes(img_subtile) 
# write.table(preds_classes, "D:\\qinghe\\results\\HMNT0001\\preds_classes", sep=",",row.names=FALSE)

#predict the probability
preds <- model %>% predict(img_subtile)
write.table(preds, "E:\\deeplearning\\Hepatocarcinomes\\10x\\test\\HMNT0113\\results\\vgg_dense_bn_prob", sep=",",
          row.names = FALSE, col.names = c("tum", "nor"))

#not completed yet, see the link below:
#https://keras.io/getting-started/faq/#how-can-i-obtain-the-output-of-an-intermediate-layer
# print(get_output_at(get_layer(model,"activation_2"), 1))

# Evaluation ---------------------------------------------------------------------

#package pROC: ROC curve, accuracy, the best threshold
roc_tum <- roc(y_tum, preds[,1])
plot(roc_tum, col="red", print.thres=TRUE, print.auc=TRUE)

#package caret: confusion matrix, accuracy, F1-score, sensitivity, specificity, etc
#                      Reference
# 
#                    non_tum  tum      
# 
# Prediction  non_tum     TN   FN
# 
#                 tum     FP   TP
#Precision = TP/ (TP + FP)
#   Recall = TP/ (TP + FN)
# F1-score = 2 * Precision * Recall / (Precision + Recall)
data_tum = c(dim=(num_sub))
for(i in c(1:num_sub)) {
  if(preds[i,1]>=0.6) { #set the best threshold printed above, for tumoral class
    data_tum[i] = 1
  } else {
    data_tum[i] = 0
  }
}

data_tum = factor(data_tum)
reference = factor(y_tum)
result_tum <- confusionMatrix(data = data_tum, reference = reference, positive = "1")
# View confusion matrix overall
result_tum 
# F1 value
result_tum$byClass[7] 
