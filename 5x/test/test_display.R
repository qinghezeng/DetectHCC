#save workspace
path="E:\\deeplearning\\data\\5x\\test\\split64_image\\"
filename=paste(path,"data_testset_25k2_64.RData",sep="")
load(file = filename)

Model_path <-"D:\\deeplearning\\Hepatocarcinomes\\models\\5x\\vgg16_dense_bn\\best_model"
model <- load_model_hdf5(filepath = Model_path, compile = TRUE)
preds <- model %>% predict(img_test)

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

fp_pred=preds[(data_tum[]==1&reference[]==0),]
fn_pred=preds[(data_tum[]==0&reference[]==1),]
tp_pred=preds[(data_tum[]==1&reference[]==1),]
tn_pred=preds[(data_tum[]==0&reference[]==0),]

fp=img_test[(data_tum[]==1&reference[]==0),,,]
fn=img_test[(data_tum[]==0&reference[]==1),,,]
tp=img_test[(data_tum[]==1&reference[]==1),,,]
tn=img_test[(data_tum[]==0&reference[]==0),,,]

for(i in 1:10){
  
  #true neg
  img=rgbImage(tn[i,,,1],tn[i,,,2],tn[i,,,3])
  display(img,"raster")
  title(main=paste(c("P(T)  =","P(NT)="),sprintf("%0.3f",tn_pred[i,])))

  #true pos
  img=rgbImage(tp[i,,,1],tp[i,,,2],tp[i,,,3])
  display(img,"raster")
  title(main=paste(c("P(T)  =","P(NT)="),sprintf("%0.3f",tp_pred[i,])))
  
  #false neg
  # img=rgbImage(fn[i,,,1],fn[i,,,2],fn[i,,,3])
  # display(img,"raster")
  # title(main=paste(c("P(T)  =","P(NT)="),sprintf("%0.3f",fn_pred[i,])))
  
}

tp_ordered=order(tp_pred[,1],decreasing=TRUE)
tn_ordered=order(tn_pred[,1])
fp_ordered=order(fp_pred[,1],decreasing=FALSE)
fn_ordered=order(fn_pred[,1],decreasing=TRUE)



#TP with highest probability p(tum)
for (i in tp_ordered[1:250]){
  #true pos
  img=rgbImage(tp[i,,,1],tp[i,,,2],tp[i,,,3])
  display(img,"raster")
  title(main=paste(c("P(T)  =","P(NT)="),sprintf("%0.3f",tp_pred[i,])))
  writeImage(img,paste("H:\\00_DeepLearning\\00_HepatoCarcinomes\\01_Documents\\Presentations&résumés\\QBIconference\\Fig\\TP\\tp",i),"png")
}

#TN with lowest probability p(tum)
for (i in tn_ordered[1:250]){
  #true pos
  img=rgbImage(tn[i,,,1],tn[i,,,2],tn[i,,,3])
  display(img,"raster")
  title(main=paste(c("P(T)  =","P(NT)="),sprintf("%0.3f",tn_pred[i,])))
  writeImage(img,paste("H:\\00_DeepLearning\\00_HepatoCarcinomes\\01_Documents\\Presentations&résumés\\QBIconference\\Fig\\TN\\tn",i),"png")
}

#FP with lowest probability p(tum)
for (i in fp_ordered[1:250]){
  #true pos
  img=rgbImage(fp[i,,,1],fp[i,,,2],fp[i,,,3])
  display(img,"raster")
  title(main=paste(c("P(T)  =","P(NT)="),sprintf("%0.3f",fp_pred[i,])))
  writeImage(img,paste("H:\\00_DeepLearning\\00_HepatoCarcinomes\\01_Documents\\Presentations&résumés\\QBIconference\\Fig\\FP\\fp",i),"png")
}

#FN with highest probability p(tum)
for (i in fn_ordered[1:100]){
  #true pos
  img=rgbImage(fn[i,,,1],fn[i,,,2],fn[i,,,3])
  display(img,"raster")
  title(main=paste(c("P(T)  =","P(NT)="),sprintf("%0.3f",fn_pred[i,])))
  writeImage(img,paste("H:\\00_DeepLearning\\00_HepatoCarcinomes\\01_Documents\\Presentations&résumés\\QBIconference\\Fig\\FN\\fn",i),"png")
}
