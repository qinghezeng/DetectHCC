#This script is to evaluate a trained model.
#Input: labeled 64x64 subtiles

#Include the libraries
library(keras)
library(tiff)

#Load images
path="D:\\dl\\5x\\test\\HMNT0783_bis\\split64\\nor"
lpos=list.files(path, pattern = "\\.tif$") #only return the file end with ".tif". 
pos=array(dim=c(length(lpos),64,64,3))
for (i in c(1:length(lpos))){
  pos[i,,,]=readTIFF(paste(path,"\\",lpos[i],sep=""))
}

path="D:\\dl\\5x\\test\\HMNT0932\\split64\\tum"
lneg=list.files(path, pattern = "\\.tif$")
neg=array(dim=c(length(lneg),64,64,3))
for (i in c(1:length(lneg))){
  neg[i,,,]=readTIFF(paste(path,"\\",lneg[i], sep=""))
}

#create label vectors
poslabels=rep(1,length(lpos))
#print(poslabels)
poslabels=rep(0,length(lneg))

#bind pos and negative exemples for training and test sets
library(abind)
x_test=abind(pos,neg, along=1)

#bind pos and negative labels for training and test sets
y_test=c(poslabels,neglabels)

#bind pos and negative names for only test sets
l_test=c(lpos,lneg)

#randomize test set
rand_test=sample(seq(1:length(y_test)))
y_test=y_test[rand_test]
x_test=x_test[rand_test, , ,]
l_test=l_test[rand_test]

#labels to categorical
y_test <- to_categorical(y_test, num_classes = 2)

#remove unused data
rm(i,neglabels,poslabels,rand_test)

#load a trained CNN model
model <- load_model_hdf5(filepath = "D:\\dl\\5x\\models\\best_model", compile = TRUE)

#save the probability of each class in a csv file
preds <- model %>% predict(x_test)
write.csv(preds, "D:\\dl\\5x\\test\\HMNT0783_bis\\results\\prob", sep="," ,row.names=FALSE)

#predict the class
preds_classes <- model %>% predict_classes(x_test)

#save the names, probabilities of each class, most likely class, verification of prediction in a csv file
predictions=array(dim=c(length(l_test),5))
n_false=0
n_false_pos=0
n_false_neg=0
false_pos <- array()
false_neg <- array()
n_true=0
n_true_pos=0
n_true_neg=0
true_pos <- array()
true_neg <- array()
for (j in c(1:length(l_test))){
  predictions[j,1]=l_test[j]
  predictions[j,2:3]=preds[j,]
  if(preds_classes[j]) {
    predictions[j,4]="nor"
  } else {
    predictions[j,4]="tum"
  }
  
  if(predictions[j,4]==substr(predictions[j,1],1,3)) {
    predictions[j,5]=""
    n_true=n_true+1
    if(predictions[j,4]=="nor") {
      n_true_pos=n_true_pos+1
      true_pos[n_true_pos] <- predictions[j,1]
    } else {
      n_true_neg=n_true_neg+1
      true_neg[n_true_neg] <- predictions[j,1]
    }
  } else {
    predictions[j,5]="false"
    n_false=n_false+1
    if(predictions[j,4]=="nor") {
      n_false_neg=n_false_neg+1
      false_neg[n_false_neg] <- predictions[j,1]
    } else {
      n_false_pos=n_false_pos+1
      false_pos[n_false_pos] <- predictions[j,1]
    }
  }
}
write.table(predictions, "D:\\dl\\5x\\test\\HMNT0783_bis\\results\\predictions", sep=",", 
            col.names=c("name","proba_tum","proba_nor","class","verification"),row.names=FALSE)
#the following command cannot write the proper colomn names
# write.csv(predictions, "D:\\qinghe\\results\\predictions", sep=",",
#           col.names=c("name","proba_neg","proba_pos","class","verification"),row.names=FALSE)
rm(j)

#save some information about the evaluation of the prediciton 
test_loss <- model %>% evaluate(x_test, y_test)
#to calculate the confusion matrix in percentage.
confusion_matrix <- data.frame(pre_tum=c(n_true_neg/length(l_test), n_false_pos/length(l_test)), 
                               pre_nor=c(n_false_neg/length(l_test), n_true_pos/length(l_test)),
                               row.names = c("GT_tum", "GT_nor"))
#to write test information into a file .txt. 
#If the entities (of an element of the list) are more than 500, we have to write it into a file .csv. 
test_result <- list(length(l_test),test_loss$loss,test_loss$acc,n_pos,
                    n_neg,confusion_matrix,n_false,n_false_pos,n_false_neg,false_pos,false_neg)
names(test_result) <- c("n_test","loss","acc","n_nor_test","n_tum_test","confusion_matrix",
                        "n_false","n_false_nor","n_false_tum","false_nor","false_tum")
sink("D:\\dl\\5x\\test\HMNT0783_bis\\results\\test_result.txt",FALSE)
print(test_result)
sink()

#seperate all the test data into four folders: false_neg,true_neg,false_pos,true_pos.
for(i in c(1:length(false_neg))) {
  file.copy(paste(path,"\\",false_neg[i], sep=""),"D:\\dl\\5x\\results\\false_tum")
}
for(i in c(1:length(true_neg))) {
  file.copy(paste(path,"\\",true_neg[i], sep=""),"D:\\dl\\5x\\results\\true_tum")
}
path="D:\\vis_db\\img\\split64\\nor"
for(i in c(1:length(false_pos))) {
  file.copy(paste(path,"\\",false_pos[i], sep=""),"D:\\dl\\5x\\results\\false_nor")
}
for(i in c(1:length(true_pos))) {
  file.copy(paste(path,"\\",true_pos[i], sep=""),"D:\\dl\\5x\\results\\true_nor")
}

rm(predictions,n_false,n_false_pos,n_false_neg,false_pos,false_neg,n_true,n_true_pos,n_true_neg,true_pos,true_neg,confusion_matrix)

#extract features from the last convolutional layer
get_output_at(get_layer(model,"activation_4"), 1)

