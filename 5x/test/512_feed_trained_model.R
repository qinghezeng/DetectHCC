#input: 512x512 tiles
#split to 64x64 subtiles without writing
#predict the probability of each class and save

library(keras)
library(tiff) # use tiff package rather than rtiff

path="D:\\vis_db\\img\\HMNT0001\\test"
names=list.files(path, pattern = "\\.tif$")
img=array(dim=c(length(names),512,512,3))

for (i in c(1:length(names))){
  img[i,,,]=readTIFF(paste(path,"\\",names[i],sep=""))
}

# subdivide the image into 64*64
img_subtile = array(dim=c(length(names)*64,64,64,3))
every_64 = seq(1,449,64)
num_sub = 0
for(i in c(1:length(names))) {
  for(c in every_64)
  {
    for(r in every_64)
    {
      num_sub = num_sub + 1
      r_63 = r+63
      c_63 = c+63
      img_subtile[num_sub,,,] = img[i,r:r_63,c:c_63,]
    }
  }
}

# use a trained CNN model
model <- load_model_hdf5(filepath = "Y:\\IMAGES\\CK\JulienCalderaro\\Hepatocarcinomes\\5x\\models\\vgg16_512dense\\bedt_model", compile = TRUE)

# preds_classes <- model %>% predict_classes(img_subtile) 
# write.table(preds_classes, "D:\\qinghe\\results\\HMNT0001\\preds_classes", sep=",",row.names=FALSE)

preds <- model %>% predict(img_subtile)
write.csv(preds, "D:\\vis_db\\dl\\prob", sep="," ,row.names=FALSE)

get_output_at(get_layer(model,"activation_4"), 1)

#Sys.sleep(2)
