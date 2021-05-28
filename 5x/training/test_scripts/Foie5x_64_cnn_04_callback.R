#It reaches 0.12 validation/test logloss and 0.95 validation/test accuracy in 80 epochs, using the dataset without white (mean>200).

# README ------------------------------------------------------------------

#Compared to Foie5x_64_cnn_01.R, this script uses the function "callbacks" to realize the following functions:
#1. Enable cross validation;
#2. Predict the test dataset and save the probablities into a .txt file;
#3. Save the weights at checkpoints;
#4. Set multiple learning rates, decays and even optimizers;
#5. Print the structure of model;
#6. Save training logloss, training accuracy, validation loss and validation accuracy into a .txt file.

#It reaches 0.0945 validation logloss and 0.9671 validation accuracy in 75 epochs,
#with the setting validation_split=0.2, batch_sise=300, learning rate=0.0001.

# Installation of libraries ----------------------------------------------

# devtools::install_github("rstudio/tensorflow")
# install_keras(tensorflow = "gpu")

#If we use the command "install.packages("EBImage")", it will output a warning:
#package 'EBImage' is not available (for R version 3.3.1).
#So the solution is to find the URL of "EBImage",
#and use the command as following.
# devtools::install_github("aoles/EBImage") # works
#It will print a question: 'BiocInstaller' must be installed to install Bioconductor packages.
#Just input 1 and the packages of various kinds of images including "tiff" will be installed automatically.

#Sometimes some packages in "EBImage" cannot be successfully installed.
#The solution is to install them using BioInstaller and re-run the installation command of "EBImage".
# BiocInstaller::biocLite("bitops")
# BiocInstaller::biocLite("digest")

# Including libraries -----------------------------------------------------

library(keras)
library(EBImage)
#If we load "keras" after "EBImage", there will be a warning:
#Attachement du package : 'keras'
#The following object is masked from 'package:EBImage': normalize

# Parameters --------------------------------------------------------------

batch_size <- 32
epochs <- 250
data_augmentation <- TRUE

# Data Preparation --------------------------------------------------------

#With the workplace (~_load_data.RData) saved before, we don't need to run this part of code.
#It is better is set the Working Directory to a disk of more than 45G, 
#if you want to prepare the data of a slide split into 64*64 with 5* resolution without removing the intermediate parameters.
#Also don't forget to use these two commands to check the using memory and to increase the limit of memory (every time you run a new session)
# memory.size()
# memory.limits(45000) #Size in Mb (1048576 bytes), rounded to 0.01 Mb 

#Load images
path="X:\\DeepLearning\\ProjetHepatocarcinomes\\00_HepatoCarcinomesDataSet\\test\\split64\\Pos"
lpos=list.files(path, pattern = "\\.tif$") #only return the file end with ".tif". 
                                          #Attention that label files end with ".tiff".
# lpos= lpos[-length(lpos)] #To delete the hidden file "Thumbs.db" which we read into the dataset by mistake. 
#Otherwise it will break the whole training process by making the four results remain constants.
#So make sure the number of files in the path equals to the number of .tiff in the path.
#lpos=list.files(path,all.files = FALSE) # If FALSE, only the names of visible files are returned. BUT CANNOT WORK
#with "Thumbs.db". "Thumbs.db" is System thumbnail file, which is not visible on some computers.
pos=array(dim=c(length(lpos),64,64,3))

for (i in c(1:length(lpos))){
  pos[i,,,]=imageData(readImage(paste(path,"\\",lpos[i],sep=""))) #remember to use imageData(), or it will remain
                                                                  #a class of image.
  # print(paste(path,"\\",lpos[i], sep=""))
}

path="X:\\DeepLearning\\ProjetHepatocarcinomes\\00_HepatoCarcinomesDataSet\\test\\split64\\Neg"
lneg=list.files(path, pattern = "\\.tif$")
lneg=lneg[-length(lneg)]
neg=array(dim=c(length(lneg),64,64,3))

for (i in c(1:length(lneg))){
  neg[i,,,]=imageData(readImage(paste(path,"\\",lneg[i], sep="")))
}

dim(neg)
dim(pos)

#display one example
#display one color channel in grey
# image(neg[30570, , ,1],col=grey(seq(0,1,length=255)))
#diplay in color
# imgcol = as.Image(x_train[1,,,1:3])
# colorMode(imgcol) = Color
# display(imgcol)

#create label vectors
poslabels=rep(1,length(lpos))
#print(poslabels)
neglabels=rep(0,length(lneg))

#split pos and negative exemple to 80/20 training/test
#number of pos and neg for test data rouned
#"%%" means to take the remainder; "%/%" means to do interger division (to leave out the remainder) 
n_pos=length(lpos)%/%5
n_neg=length(lneg)%/%5

#create a vector for selecting randomly 20% of pos exemples 
sample_posTest=sample(length(lpos),n_pos,replace=F)

#create a vector for selecting randomly 20% of neg exemples 
sample_negTest=sample(length(lneg),n_neg,replace=F)
# print(-sample_negTest) 
#When we directly print the variable produced by the function sample with a "-" added above, 
#it will just do the opposite operation.
#But if use the negative one as a parameter in an array, it will produce the rest in the array. 
#extract pos test exemples and labels
xpos_test=pos[sample_posTest,,,];
ypos_test=poslabels[sample_posTest];
#extract the correspondant names only for test dataset
lpos_test=lpos[sample_posTest];
#keep the others for training
xpos_train=pos[-sample_posTest,,,];
ypos_train=poslabels[-sample_posTest];
rm(pos)

#extract neg test exemples and labels
xneg_test=neg[sample_negTest,,,];
yneg_test=neglabels[sample_negTest];
#extract the correspondant names only for test dataset
lneg_test=lneg[sample_negTest];
#keep the others for training
xneg_train=neg[-sample_negTest,,,];
yneg_train=neglabels[-sample_negTest];
rm(neg)

#bind pos and negative exemples for training and test sets
library(abind)
x_test=abind(xpos_test,xneg_test, along=1)
#dim(x_test)
rm(xpos_test,xneg_test)
x_train=abind(xpos_train,xneg_train, along=1)
rm(xpos_train,xneg_train)
#bind pos and negative labels for training and test sets
y_test=c(ypos_test,yneg_test)
y_train=c(ypos_train,yneg_train)
#bind pos and negative names for only test sets
l_test=c(lpos_test,lneg_test)
rm(lpos_test,lneg_test)

#randomize training and test set
rand_train=sample(seq(1:length(y_train)))
y_train=y_train[rand_train]
x_train=x_train[rand_train, , ,]

rand_test=sample(seq(1:length(y_test)))
y_test=y_test[rand_test]
x_test=x_test[rand_test, , ,]
l_test=l_test[rand_test]

#labels to categorical
y_train <- to_categorical(y_train, num_classes = 2)
y_test <- to_categorical(y_test, num_classes = 2)

#to display a image rebuilt by the data convented
# n=1110
# img=rgbImage(x_test[n,,,1],x_test[n,,,2],x_test[n,,,3])
# display(img)

#remove unused data
rm(i,img,imgcol,neglabels,poslabels,rand_test,rand_train,sample_negTest,sample_posTest,yneg_test,ypos_test,ypos_train,yneg_train)

# Defining and training the model -----------------------------------------

#At first I want to realize the fonction to save callbacks via multiple calls to the definition of model.
#In this way, there is an extra advantage that everytime we define the model, we can choose a pretrained model,
#and reset all the parameters like learning rate, decay, etc.
#But in fact, it is not efficient, and RStudio will only display the curves of the last epoch (because of the object "history").
#Fortunately, we can save the four results into a file .txt and plot them.
#And we can also use Tensorboard (the fonction .callbacks) to visiualise the results and some outputs/parameters of the layers.
#By the way, we can use the function .callbacks to save the callbacks, to find the best model according to a specific perfomance,

# Defining the model ------------------------------------------------------

model <- keras_model_sequential()

model %>%
  layer_conv_2d(filter = 20, kernel_size = c(5,5),input_shape = c(64, 64, 3)) %>%
  layer_activation("relu") %>%
  layer_max_pooling_2d(pool_size = c(2,2)) %>%
  layer_conv_2d(filter = 50, kernel_size = c(5,5)) %>%
  layer_activation("relu") %>%
  layer_max_pooling_2d(pool_size = c(2,2)) %>%
  layer_dropout(0.25) %>%
  
  layer_flatten() %>%
  layer_dense(512) %>%
  layer_activation("relu") %>%
  layer_dropout(0.5) %>%
  layer_dense(100) %>%
  layer_activation("relu") %>%
  layer_dropout(0.5) %>%
  layer_dense(2) %>%
  layer_activation("softmax")

#if we use a pretrained model
# load_model_hdf5(filepath = )

summary(model)

opt <- optimizer_sgd(lr = 0.001, decay = 1e-7)
#opt <- optimizer_rmsprop(lr = lr_scale, decay = 1e-6) #It is recommended to leave the parameters of this optimizer
#at their default values (except the learning rate, which can be freely tuned).

model %>% compile(
  loss = "categorical_crossentropy",
  optimizer = opt,
  metrics = "accuracy"
)

# Training ----------------------------------------------------------------

if(!data_augmentation){
  
  history <- model %>% fit(
    x_train, y_train,
    batch_size = batch_size,
    epochs = epochs,
    validation_split = 0.2,
    shuffle = TRUE,
    callbacks=list(callback_csv_logger("D:\\qinghe\\log\\log.csv",separator = ",", append=TRUE),
                   callback_tensorboard(log_dir = "D:\\qinghe\\tensorboard_log\\new", histogram_freq = 3, batch_size = batch_size,
                                        write_graph = TRUE, write_grads = TRUE, write_images = TRUE,
                                        embeddings_freq = 0, embeddings_layer_names = NULL,
                                        embeddings_metadata = NULL),
                   callback_model_checkpoint(filepath="D:\\qinghe\\models\\weights.{epoch:02d}-{val_acc:.4f}.hdf5",
                                             monitor = "val_acc", save_best_only = TRUE, save_weights_only = TRUE,
                                             mode = "auto", period = 15),
                   callback_reduce_lr_on_plateau(monitor = "val_acc", factor = 0.1,verbose=1,mode="auto",min_delta=0.003),
                   callback_early_stopping(monitor="val_acc",min_delta = 0.0005,patience=8,mode="auto"))
  )
  
  
} else {
  
  datagen <- image_data_generator(
    featurewise_center = TRUE,
    featurewise_std_normalization = TRUE,
    rotation_range = 20,
    horizontal_flip = TRUE,
    vertical_flip = TRUE,
    validation_split = 0.2
  )
  
  datagen %>% fit_image_data_generator(x_train, seed=1)
  
  history <- model %>% fit_generator(
    flow_images_from_data(x_train, y_train, datagen, batch_size = batch_size, save_to_dir = 
                            "D:\\qinghe\\data\\train", subset = "training", seed=1),
    steps_per_epoch = as.integer(45797/batch_size), 
    epochs = epochs, 
    callbacks=list(callback_csv_logger("D:\\qinghe\\log\\log.csv",separator = ",", append=TRUE),
                   callback_tensorboard(log_dir = "D:\\qinghe\\tensorboard_log\\new", histogram_freq = 3, batch_size = batch_size,
                                        write_graph = TRUE, write_grads = TRUE, write_images = TRUE,
                                        embeddings_freq = 0, embeddings_layer_names = NULL,
                                        embeddings_metadata = NULL),
                   callback_model_checkpoint(filepath="D:\\qinghe\\models\\weights.{epoch:02d}-{val_acc:.4f}.hdf5",
                                             monitor = "val_acc", save_best_only = TRUE, save_weights_only = TRUE,
                                             mode = "auto", period = 15),
                   callback_reduce_lr_on_plateau(monitor = "val_acc", factor = 0.1,verbose=1,mode="auto",min_delta=0.003),
                   callback_early_stopping(monitor="val_acc",min_delta = 0.0005,patience=8,mode="auto")),
    #validation_data = list(x_test, y_test),
    validation_data = flow_images_from_data(x_train, y_train, datagen, batch_size = batch_size,
                                            save_to_dir = "D:\\qinghe\\data\\validation",
                                            subset = "validation", seed=1), #cross validation
    validation_steps = as.integer(19188/batch_size)
  )
  
}

save_model_hdf5(model, "D:\\qinghe\\models\\model_100", overwrite = TRUE,
                include_optimizer = TRUE)

#view_savemodel("savemodel")

# # Clean up the TF session.
# coord$request_stop()
# coord$join(threads)
# k_clear_session()

# Test -----------------------------------------------------------------

#test a trained model weight (have to run the part of "Defining the model" first)
model %>% load_model_weights_hdf5("D:\\qinghe\\models\\model_100.hdf5")
#load the final model
# model %>% load_model_hdf5("D:\\qinghe\\models\\model")

#To predict the test dataset and save the probabilites as "preds.txt".
preds <- model %>% predict(x_test)
# write.csv(preds, "D:\\qinghe\\results\\preds", sep=",")

#The result is the same as "predict()".
# predict_proba <- model %>% predict_proba (x_test)
# write.csv(predict_proba, "D:\\qinghe\\results\\predict_proba", sep=",")

preds_classes <- model %>% predict_classes(x_test)
# write.csv(preds_classes, "D:\\qinghe\\results\\preds_classes", sep=",")

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
  predictions[j,4]="pos"
  } else {
  predictions[j,4]="neg"
  }
  
  if(predictions[j,4]==substr(predictions[j,1],1,3)) {
    predictions[j,5]=""
    n_true=n_true+1
    if(predictions[j,4]=="pos") {
      n_true_pos=n_true_pos+1
      true_pos[n_true_pos] <- predictions[j,1]
    } else {
      n_true_neg=n_true_neg+1
      true_neg[n_true_neg] <- predictions[j,1]
    }
  } else {
    predictions[j,5]="false"
    n_false=n_false+1
    if(predictions[j,4]=="pos") {
      n_false_neg=n_false_neg+1
      false_neg[n_false_neg] <- predictions[j,1]
    } else {
      n_false_pos=n_false_pos+1
      false_pos[n_false_pos] <- predictions[j,1]
    }
  }
}
rm(j)

write.table(predictions, "D:\\qinghe\\results\\predictions", sep=",", 
            col.names=c("name","proba_neg","proba_pos","class","verification"),row.names=FALSE)
#the following command cannot write the proper colomn names
# write.csv(predictions, "D:\\qinghe\\results\\predictions", sep=",",
#           col.names=c("name","proba_neg","proba_pos","class","verification"),row.names=FALSE)

test_loss <- model %>% evaluate(x_test, y_test)

#to write test information into a file .txt. 
#If the entities (of an element of the list) are more than 500, we have to write it into a file .csv. 
test_result <- list(length(l_test),test_loss$loss,test_loss$acc,n_pos,
                    n_neg,n_false,n_false_pos,n_false_neg,false_pos,false_neg)
names(test_result) <- c("n_test","loss","acc","n_ypos_test","n_yneg_test","
                        n_false","n_false_pos","n_false_neg","false_pos","false_neg")
sink("D:\\qinghe\\results\\test_result.txt",FALSE)
print(test_result)
sink()

# Visualization ---------------------------------------

tensorboard("D:\\qinghe\\tensorboard_log\\new1")

#seperate all the test data into four folders: false_neg,true_neg,false_pos,true_pos.
for(i in c(1:n_false_neg)) {
file.copy(paste(path,"\\",false_neg[i], sep=""),"D:\\qinghe\\results\\false_neg")
}
for(i in c(1:n_true_neg)) {
  file.copy(paste(path,"\\",true_neg[i], sep=""),"D:\\qinghe\\results\\true_neg")
}
path="X:\\DeepLearning\\ProjetHepatocarcinomes\\00_HepatoCarcinomesDataSet\\test\\split64\\Pos"
for(i in c(1:n_false_pos)) {
  file.copy(paste(path,"\\",false_pos[i], sep=""),"D:\\qinghe\\results\\false_pos")
}
for(i in c(1:n_true_pos)) {
  file.copy(paste(path,"\\",true_pos[i], sep=""),"D:\\qinghe\\results\\true_pos")
}
rm(predictions,n_false,n_false_pos,n_false_neg,false_pos,false_neg,n_true,n_true_pos,n_true_neg,true_pos,true_neg)
rm(model)
