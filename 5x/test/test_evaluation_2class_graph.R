# READ ME ----------------------------------------------------------------------
#input: 512x512 tiles
#split to 64x64 subtiles without writing
#Predict the probability of each class and save.
#Calculate different kinds of performance and draw their curves.
#Precision, Recall, F1 score curves.
#Sensitivity, specificity, AUC, ROC curve, best threshold.

# Library ----------------------------------------------------------------------
library(keras)
library(tiff) # use tiff package rather than rtiff
# install.packages("ROCR")
library (ROCR)
# install.packages("caret")
library(caret)
# install.packages("e1071")
# install.packages("pROC")
library(pROC)

# Data preparation -------------------------------------------------------------
path="D:\\dl\\5x\\test\\HMNT0132_bis\\512_image_label"
limg=list.files(path, pattern = "\\.tif$")
lroi=list.files(path, pattern = "\\.tiff$")
img=array(dim=c(length(limg),512,512,3))
roi=array(dim=c(length(limg),512,512))

for (i in c(1:length(limg))){
  img[i,,,]=readTIFF(paste(path,"\\",limg[i],sep=""))
  roi[i,,]=readTIFF(paste(path,"\\",lroi[i],sep=""))
}

# subdivide the image into 64*64
img_subtile = array(dim=c(length(limg)*64,64,64,3))
roi_subtile = array(dim=c(length(lroi)*64,64,64))
every_64 = seq(1,449,64)
num_sub = 0
for(i in c(1:length(limg))) {
  for(c in every_64)
  {
    for(r in every_64)
    {
      num_sub = num_sub + 1
      r_63 = r+63
      c_63 = c+63
      img_subtile[num_sub,,,] = img[i,r:r_63,c:c_63,]
      roi_subtile[num_sub,,] = roi[i,r:r_63,c:c_63]
    }
  }
}

save.image(file = "D:\\dl\\5x\\test\\HMNT0132_bis\\data_512_64.RData")

# Labels for evalutaion --------------------------------------------------------
y_tum = c(dim=num_sub)
y_nor = c(dim=num_sub)
for(i in c(1:num_sub)) {
  if(sum(roi_subtile[i,,] == 2/255) > 3072) {
    y_tum[i] = 0 #1 for positive, 0 for negative
    y_nor[i] = 1
  } else if(sum(roi_subtile[i,,] == 3/255) > 3072){
    y_tum[i] = 1
    y_nor[i] = 0
  } else {
    y_tum[i] = 0
    y_nor[i] = 0}
}

# Load trained model ------------------------------------------------------------

# use a trained CNN model
model <- load_model_hdf5(filepath = "D:\\dl\\5x\\vgg16_dense_bn\\best_model", compile = TRUE)

# Prediction --------------------------------------------------------------------

#predict the class
# preds_classes <- model %>% predict_classes(img_subtile) 
# write.table(preds_classes, "D:\\qinghe\\results\\HMNT0001\\preds_classes", sep=",",row.names=FALSE)

#predict the probability
preds <- model %>% predict(img_subtile)
write.table(preds, "D:\\dl\\5x\\test\\HMNT0132_bis\\results\\vgg_dense_bn_prob", sep=",",
          row.names = FALSE, col.names = c("tum", "nor"))

#not completed yet, see the link below:
#https://keras.io/getting-started/faq/#how-can-i-obtain-the-output-of-an-intermediate-layer
# print(get_output_at(get_layer(model,"activation_2"), 1))

# Evaluation ---------------------------------------------------------------------

#package ROCR: Recall-Precision curve, F1-score curve, ROC curve, accuracy
pred_tum <- prediction(preds[,1], y_tum);
pred_nor <- prediction(preds[,2], y_nor);
# Recall-Precision curve             
RP.perf_tum <- performance(pred_tum, "prec", "rec");
RP.perf_nor <- performance(pred_nor, "prec", "rec");
plot (RP.perf_tum, col = "red", main= "Precision-Recall graphs");
plot (RP.perf_nor, col = "green", add = T);
# F1-score curve 
F1.perf_tum <- performance(pred_tum,"f")
F1.perf_nor <- performance(pred_nor,"f")
plot (F1.perf_tum, col = "red", main= "F1-score graphs");
plot (F1.perf_nor, col = "green", add = T);
# ROC curve
ROC.perf_tum <- performance(pred_tum, "tpr", "fpr");
ROC.perf_nor <- performance(pred_nor, "tpr", "fpr");
plot (ROC.perf_tum, col = "red", main= "ROC graphs");
plot (ROC.perf_nor, col = "green", add = T);
# ROC area under the curve
auc.tmp_tum <- performance(pred_tum,"auc");
print("accuracy of tumoral class:")
slot(auc.tmp_tum,"y.values")[[1]]

auc.tmp_nor <- performance(pred_nor,"auc");
print("accuracy of normal class:")
slot(auc.tmp_nor,"y.values")[[1]]

#package pROC: ROC curve, accuracy, the best threshold
roc_tum <- roc(y_tum, preds[,1])
roc_nor <- roc(y_nor, preds[,2])
plot(roc_tum, col="red", print.thres=TRUE, print.auc=TRUE)
plot.roc(roc_nor, add=TRUE, col="green", print.thres=TRUE)
roc_nor$auc

#package caret: At the BEST THRESHOLD, confusion matrix, accuracy, F1-score, sensitivity, specificity, etc
data_tum = c(dim=(num_sub))
for(i in c(1:num_sub)) {
  if(preds[i,1]>=0.436) { #set the best threshold printed above, for tumoral class
    data_tum[i] = 1
  } else {
    data_tum[i] = 0
  }
}
data_nor = c(dim=(num_sub))
for(i in c(1:num_sub)) {
  if(preds[i,2]>=0.86) { #set the best threshold printed above, for normal class
    data_nor[i] = 1
  } else {
    data_nor[i] = 0
  }
}

data_tum = factor(data_tum)
reference = factor(y_tum)
result_tum <- confusionMatrix(data = data_tum, reference = reference, positive = "1")
# View confusion matrix overall
result_tum 
# F1 value
result_tum$byClass[7] 

data_nor = factor(data_nor)
reference = factor(y_nor)
result_nor <- confusionMatrix(data = data_nor, reference = reference, positive = "1")
# View confusion matrix overall
result_nor 
# F1 value
result_nor$byClass[7]