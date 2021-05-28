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
library(caret)

# Data preparation -------------------------------------------------------------
path="E:\\deeplearning\\data\\5x\\test\\split64_image\\"
path_tum=paste(path,"tum",sep="")
path_non=paste(path,"non",sep="")

ltum_=list.files(path_tum, pattern = "\\.tif$")
lnon_=list.files(path_non, pattern = "\\.tif$")
sam_25000_tum=sample(seq(1:length(ltum_)),size=25000)
ltum=ltum_[sam_25000_tum]
sam_25000_non=sample(seq(1:length(lnon_)),size=25000)
lnon=lnon_[sam_25000_non]
img_tum=array(dim=c(length(ltum),64,64,3))
img_non=array(dim=c(length(lnon),64,64,3))

for (i in c(1:length(ltum))){
  img_tum[i,,,]=readTIFF(paste(path_tum,"\\",ltum[i],sep=""))
  img_non[i,,,]=readTIFF(paste(path_non,"\\",lnon[i],sep=""))
}

#bind tum and non_tum exemples for test sets
library(abind)
img_test=abind(img_tum, img_non, along=1)

# Labels for evalutaion --------------------------------------------------------
y_tum = c(1)
for(i in c(1:(length(ltum)*2))) {
  if(i <= 25000){
    y_tum[i] = 1 #tum
  } else {
    y_tum[i] = 0} #non
}

# #create label vectors
# tumlabels=rep(1,length(ltum))
# #print(poslabels)
# nonlabels=rep(0,length(lnon))

#save workspace
filename=paste(path,"data_testset_25k2_64.RData",sep="")
save.image(file = filename)

#models--------------------------------------------------------------------------
Model = 3 #1 - simple one with 2 conv layers
#2 - VGG16 provided by Keras
#3 - VGG16 optimized

Model <- switch(Model, "simple_2conv", "svgg16_no_drop", "vgg16_dense_bn") 

Model_path <- switch(Model, "simple_2conv" = "Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\5x\\models\\simple_2conv\\best_model",
                     "svgg16_no_drop" = "Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\5x\\models\\vgg16_no_drop\\best_model",
                     "vgg16_dense_bn" = "D:\\deeplearning\\Hepatocarcinomes\\models\\5x\\vgg16_dense_bn\\best_model")

# Load trained model ------------------------------------------------------------

# use a trained CNN model
#model <- load_model_hdf5(filepath = "D:\\dl\\5x\\vgg16_dense_bn\\best_model", compile = TRUE)
model <- load_model_hdf5(filepath = Model_path, compile = TRUE)

# Prediction --------------------------------------------------------------------

#predict the class
# preds_classes <- model %>% predict_classes(img_subtile) 
# write.table(preds_classes, "D:\\qinghe\\results\\HMNT0001\\preds_classes", sep=",",row.names=FALSE)

#predict the probability
preds <- model %>% predict(img_test)
write.table(preds, 
            #"D:\\dl\\5x\\test\\HMNT0264\\results\\vgg_dense_bn_prob",
            paste("D:\\deeplearning\\Hepatocarcinomes\\results\\", Model, "\\vgg_dense_bn_prob",sep=""),
            sep=",",
            row.names = FALSE,
            col.names = c("tum", "nor"))

#not completed yet, see the link below:
#https://keras.io/getting-started/faq/#how-can-i-obtain-the-output-of-an-intermediate-layer
# print(get_output_at(get_layer(model,"activation_2"), 1))

# Evaluation ---------------------------------------------------------------------

#package pROC: ROC curve, accuracy, the best threshold
roc_tum <- roc(y_tum, preds[,1])
plot(roc_tum, col="red", 
     print.thres=TRUE, 
     print.auc=TRUE,
     #main=paste("test set","ROC curve",sep=" "),
     main="ROC curve for model 3",
     xlim=c(1,0),
     ylim=c(0,1),
     asp=1) 


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
data_tum = c(1)
for(i in  c(1:(length(ltum)*2))) {
  if(preds[i,1]>=0.585) { #set the best threshold printed above, for tumoral class
    data_tum[i] = 1
  } else {
    data_tum[i] = 0
  }
}

data_tum = factor(data_tum)
reference = factor(y_tum)
result_tum <- confusionMatrix(data = data_tum, reference = reference, positive = "1", mode="everything")
# View confusion matrix overall
result_tum 
# F1 value
result_tum$byClass[7] 
