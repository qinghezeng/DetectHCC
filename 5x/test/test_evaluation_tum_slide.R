# READ ME ----------------------------------------------------------------------
#input: 512x512 tiles
#split to 64x64 subtiles without writing (no removing white)
#Founction:
#Predict the probability of tumoral class and save. 
#Calculate the ROC curve, accuracy, the best threshold.
#Calculate the confusion matrix and other performance on a fixed threshold.

# Library ----------------------------------------------------------------------
library(keras)
library(tiff) # use tiff package rather than rtiff
library(pROC)
# install.packages("caret")
# library(caret)

######################################################
#edit slide name
slide_name="HMNT0001_bis"
######################################################

# Data preparation -------------------------------------------------------------
path="E:\\deeplearning\\Hepatocarcinomes\\data\\5x\\test_ndpi\\"
path1=paste(path,slide_name,sep="")
path=paste(path1,"\\512_image_label",sep="")

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
    c_63 = c+63
    for(r in every_64)
    {
      num_sub = num_sub + 1
      r_63 = r+63
      img_subtile[num_sub,,,] = img[i,r:r_63,c:c_63,]
      roi_subtile[num_sub,,] = roi[i,r:r_63,c:c_63]
    }
  }
}

filename=paste(path1,"\\data_512_64.RData",sep="")
#save.image(file = "D:\\dl\\5x\\test\\HMNT0132_bis\\data_512_64.RData")
# save.image(file = filename)

# Labels for evalutaion --------------------------------------------------------
y_tum = c(dim=num_sub)
y_nor = c(dim=num_sub)
for(i in c(1:num_sub)) {
  if(sum(roi_subtile[i,,] == 3/255) > 2048){ #3072 is 75% threshold, 2048 is 50%
    y_tum[i] = 1
  } else {
    y_tum[i] = 0}
  if(sum(roi_subtile[i,,] == 2/255) > 2048){ #3072 is 75% threshold, 2048 is 50%
    y_nor[i] = 1
  } else {
    y_nor[i] = 0}
}


# Load trained model ------------------------------------------------------------

# use a trained CNN model
#model <- load_model_hdf5(filepath = "D:\\dl\\5x\\vgg16_dense_bn\\best_model", compile = TRUE)
model <- load_model_hdf5(filepath = "E:\\deeplearning\\Hepatocarcinomes\\models\\5x\\vgg16_dense_bn\\best_model", compile = TRUE)
# Prediction --------------------------------------------------------------------

#predict the class
# preds_classes <- model %>% predict_classes(img_subtile) 
# write.table(preds_classes, "D:\\qinghe\\results\\HMNT0001\\preds_classes", sep=",",row.names=FALSE)

#predict the probability
preds <- model %>% predict(img_subtile)
write.table(preds, 
            #"D:\\dl\\5x\\test\\HMNT1500\\results\\vgg_dense_bn_prob",
            paste(path1,"\\results\\vgg_dense_bn_prob.csv",sep=""),
            sep=",",
            row.names = FALSE,
            col.names = c("tum", "nor"))

#not completed yet, see the link below:
#https://keras.io/getting-started/faq/#how-can-i-obtain-the-output-of-an-intermediate-layer
# print(get_output_at(get_layer(model,"activation_2"), 1))

# Evaluation ---------------------------------------------------------------------

#package pROC: ROC curve, accuracy, the best threshold
roc_tum <- roc(y_tum, preds[,1])
png(file=paste(path1,"\\results\\ROC.png",sep=""))
plot(roc_tum, col="red", 
     print.thres=TRUE, 
     print.thres.adj=0,
     print.auc=TRUE,
     print.auc.adj=1,
     main=paste(slide_name,"ROC curve",sep=" "),
     xlim=c(1,0),
     ylim=c(0,1),
     asp=1)

roc_tum <- roc(y_nor, preds[,2])
plot(roc_tum, col="green", 
     print.thres=TRUE, 
     print.thres.adj=0,
     print.auc=TRUE,
     print.auc.adj=0,
     main=paste(slide_name,"ROC curve",sep=" "),
     xlim=c(1,0),
     ylim=c(0,1),
     asp=1,
     add=TRUE)
dev.off()


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
# data_tum = c(dim=(num_sub))
# for(i in c(1:num_sub)) {
#   if(preds[i,1]>=0.585) { #set the best threshold printed above, for tumoral class
#     data_tum[i] = 1
#   } else {
#     data_tum[i] = 0
#   }
# }
# 
# data_tum = factor(data_tum)
# reference = factor(y_tum)
# result_tum <- confusionMatrix(data = data_tum, reference = reference, positive = "1", mode='everything')
# # View confusion matrix overall
# result_tum 
# # F1 value
# result_tum$byClass[7] 
