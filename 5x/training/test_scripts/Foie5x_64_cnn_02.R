# README ------------------------------------------------------------------

#Compared to Foie5x_64_cnn_01.R, this script adds some extra functions without using function "callbacks" in Keras:
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

#If we use the command "install.packages("EBImage")", it will output a warning:
#package 'EBImage' is not available (for R version 3.3.1).
#So the solution is to find the URL of "EBImage",
#and use the command as following.
#It will print a question: 'BiocInstaller' must be installed to install Bioconductor packages.
#Just input 1 and the packages of various kinds of images including "tiff" will be installed automatically.
# devtools::install_github("aoles/EBImage") # works
# install.packages("EBImage")  # cannot work

#Sometimes some packages in "EBImage" cannot be successfully installed.
#The solution is to install them using BioInstaller and re-run the installation command of "EBImage".
# BiocInstaller::biocLite("bitops")
# BiocInstaller::biocLite("digest")

# install_keras(tensorflow = "gpu")

# Including libraries -----------------------------------------------------

library(keras)
library(EBImage)
# library(tiff)
#If we load "keras" after "EBImage", there will be a warning:
#Attachement du package : 'keras'
#The following object is masked from 'package:EBImage': normalize

# Parameters --------------------------------------------------------------

batch_size <- 300
epochs <- 8
data_augmentation <- FALSE

#some parameters about the checkpoint
checkpoint <- 3
total_loop=epochs%/%checkpoint
n_loop=total_loop
epochs_in_a_loop=checkpoint
epochs_in_the_last_loop=epochs%%checkpoint
# print(n_loop)

# Data Preparation --------------------------------------------------------

#With the workplace (~_load_data.RData) saved before, we don't need to run this part of code.
#It is better is set the Working Directory to a disk of more than 45G, 
#if you want to prepare the data of a slide split into 64*64 with 5* resolution without removing the intermediate parameters.
#Also don't forget to use these two commands to check the using memory and to increase the limit of memory (every time you run a new session)
# memory.size()
# memory.limits(45000) #Size in Mb (1048576 bytes), rounded to 0.01 Mb 

#Load images
path="X:\\DeepLearning\\ProjetHepatocarcinomes\\00_HepatoCarcinomesDataSet\\test\\split64\\Pos"
lpos=list.files(path,pattern = "\\.tif$") #only return the file end with ".tif". 
#Attention that label files end with ".tiff".
# lpos= lpos[-length(lpos)] #To delete the hidden file "Thumbs.db" which we read into the dataset by mistake. 
#Otherwise it will break the whole training process by making the four results remain constants.
#So make sure the number of files in the path equals to the number of .tiff in the path.
#lpos=list.files(path,all.files = FALSE) # If FALSE, only the names of visible files are returned. BUT CANNOT WORK
#with "Thumbs.db". "Thumbs.db" is System thumbnail file, which is not visible on some computers.
pos=array(dim=c(length(lpos),64,64,3))

for (i in c(1:length(lpos))){
  pos[i,,,]=readImage(paste(path,"\\",lpos[i], sep=""))
  # pos[i,,,]=imageData(readImage(paste(path,"\\",lpos[i],sep=""))) #the same
  # print(paste(path,"\\",lpos[i], sep=""))
}

path="X:\\DeepLearning\\ProjetHepatocarcinomes\\00_HepatoCarcinomesDataSet\\test\\split64\\Neg"
lneg=list.files(path)
lneg= lneg[-length(lneg)]
neg=array(dim=c(length(lneg),64,64,3))

for (i in c(1:length(lneg))){
  neg[i,,,]=readImage(paste(path,"\\",lneg[i], sep=""))
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
#keep the others for training
xpos_train=pos[-sample_posTest,,,];
ypos_train=poslabels[-sample_posTest];
# rm(pos)

#extract neg test exemples and labels
xneg_test=neg[sample_negTest,,,];
yneg_test=neglabels[sample_negTest];
#keep the others for training
xneg_train=neg[-sample_negTest,,,];
yneg_train=neglabels[-sample_negTest];
# rm(neg)

#bind pos and negative exemples for training and test sets
library(abind)
x_test=abind(xpos_test,xneg_test, along=1)
#dim(x_test)
#rm(xpos_test,xneg_test)
x_train=abind(xpos_train,xneg_train, along=1)
#rm(xpos_train,xneg_train)
#bind pos and negative labels for training and test sets
y_test=c(ypos_test,yneg_test)
y_train=c(ypos_train,yneg_train)

#randomize training and test set
rand_train=sample(seq(1:length(y_train)))
y_train=y_train[rand_train]
x_train=x_train[rand_train, , ,]

rand_test=sample(seq(1:length(y_test)))
y_test=y_test[rand_test]
x_test=x_test[rand_test, , ,]

#labels to categorical
y_train <- to_categorical(y_train, num_classes = 2)
y_test <- to_categorical(y_test, num_classes = 2)

#to display a image rebuilt by the data convented
# n=1110
# img=rgbImage(x_test[n,,,1],x_test[n,,,2],x_test[n,,,3])
# display(img)

#remove unused data
# rm(i,img,imgcol,neglabels,path,poslabels,rand_test,rand_train,sample_negTest,sample_posTest,yneg_test,ypos_test,ypos_train,yneg_train)

# Defining and training the model -----------------------------------------

#At first I want to realize the fonction to save callbacks via multiple calls to the definition of model.
#In this way, there is an extra advantage that everytime we define the model, we can choose a pretrained model,
#and reset all the parameters like learning rate, decay, etc.
#But in fact, it is not efficient, and RStudio will only display the curves of the last epoch (because of the object "history").
#Fortunately, we can save the four results into a file .txt and plot them.
#And we can also use Tensorboard (the fonction .callbacks) to visiualise the results and some outputs/parameters of the layers.
#By the way, we can use the function .callbacks to save the callbacks, to find the best model according to a specific perfomance,
#and reduce the lr on this model.
for(i in c(1:(total_loop+1))) { #multiple calls to definition and training the model.
  if(n_loop==0){ #check if it is the last loop.
    epochs_in_a_loop=epochs_in_the_last_loop
  }
  
  # Defining the model ------------------------------------------------------
  
  if(n_loop==total_loop){ #check if it is the first loop.
    
    #if we use a pretrained model
    # load_model_hdf5(filepath = )
    
    model <- keras_model_sequential()
    
    model %>%
      layer_conv_2d(filter = 32, kernel_size = c(3,3), padding = "same",input_shape = c(64, 64, 3)) %>%
      layer_activation("relu") %>%
      layer_conv_2d(filter = 32, kernel_size = c(3,3)) %>%
      layer_activation("relu") %>%
      layer_max_pooling_2d(pool_size = c(2,2)) %>%
      layer_dropout(0.25) %>%
      
      layer_conv_2d(filter = 32, kernel_size = c(3,3), padding = "same") %>%
      layer_activation("relu") %>%
      layer_conv_2d(filter = 32, kernel_size = c(3,3)) %>%
      layer_activation("relu") %>%
      layer_max_pooling_2d(pool_size = c(2,2)) %>%
      layer_dropout(0.25) %>%
      
      layer_flatten() %>%
      layer_dense(512) %>%
      layer_activation("relu") %>%
      layer_dropout(0.5) %>%
      layer_dense(2) %>%
      layer_activation("softmax")
    
      #to continue training from a checkpoint
      # model %>% load_model_weights_hdf5(modelpath)
    
      summary(model)
      # keras_utils_plot_model(model, to_file='model.png') #cannot work
      
      lr_scale=0.001 #intialize the learning rate
      
  } 
  
  #to set multiple lr
  lr_scale=lr_scale/10
  num_epoch = (total_loop-n_loop)*checkpoint
  print(paste("epoch ", num_epoch, "-", (num_epoch + epochs_in_a_loop), ", lr=", lr_scale))
  opt <- optimizer_rmsprop(lr = lr_scale)
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
      epochs = epochs_in_a_loop,
      #validation_data = list(x_test, y_test), // validation_data will override validation_split
      validation_split = 0.2,
      shuffle = TRUE
      # callbacks=list(callback_tensorboard(log_dir = NULL, histogram_freq = 3, batch_size = 32,
      #                                     write_graph = TRUE, write_grads = TRUE, write_images = FALSE,
      #                                     embeddings_freq = 0, embeddings_layer_names = NULL,
      #                                     embeddings_metadata = NULL))
      # callback_model_checkpoint("checkpoints.h5"),
      # callback_reduce_lr_on_plateau(monitor = "val_loss", factor = 0.1)
    )
    
    
    # sink("D:\\qinghe\\0.1.txt",TRUE)
    # print(history)
    # sink()
    
    # history_df <- as.data.frame(history)
    # sink("C:\\Users\\visiopharm5.CICCDOM\\Desktop\\qinghe\\log\\0.1.txt",FALSE)
    # print(str(history_df))
    # sink()
  
    # to save the four results of each epoch to a file log.txt 
    history_df <- as.data.frame(history)
    loss <- subset(history_df,select=c(epoch,value),metric=='loss'&data=='training' )
    acc <- subset(history_df,select=c(epoch,value),metric=='acc'&data=='training' )
    val_loss <- subset(history_df,select=c(epoch,value),metric=='loss'&data=='validation' )
    val_acc <- subset(history_df,sselect=c(epoch,value),metric=='acc'&data=='validation' )
    mergedf <- merge(loss,acc,by.x="epoch",by.y="epoch")
    mergedf <- merge(mergedf,val_loss,by.x="epoch",by.y="epoch")
    mergedf <- merge(mergedf,val_acc,by.x="epoch",by.y="epoch") 
    #only the above will add two extra columns of acc and validation
    #and only this line will lead to the error of duplicated column name, c'est bizzard!
    names(mergedf)=c("epoch","loss","acc","val_loss","val_acc")
    mergedf <- mergedf[,c(-1)]
    mergedf <- subset(mergedf,select=c("loss","acc","val_loss","val_acc")) #to drop the column of epoch so that it is more tidy. The most important thing is that there cannot not be any repetition in one column.
    # row.names(history_df) <- history_df$epoch #name the row
    # names(history_df) <- history_df$epoch #name the column
    sink("C:\\Users\\visiopharm5.CICCDOM\\Desktop\\qinghe\\log\\log.txt",TRUE) #set append to TRUE so will not overwrite each time.
    print(mergedf)
    sink()
    
    
  } else {
    
    datagen <- image_data_generator(
      featurewise_center = TRUE,
      featurewise_std_normalization = TRUE,
      rotation_range = 20,
      width_shift_range = 0.2,
      height_shift_range = 0.2,
      horizontal_flip = TRUE
    )
    
    datagen %>% fit_image_data_generator(x_train)
    
    history <- model %>% fit_generator(
      flow_images_from_data(x_train, y_train, datagen, batch_size = batch_size),
      steps_per_epoch = as.integer(76426/batch_size), 
      epochs = epochs_in_a_loop, 
      #validation_data = list(x_test, y_test),
      validation_split = 0.2 #cross validation
    )
    
    
    # to save the four results of each epoch to a file log.txt 
    history_df <- as.data.frame(history)
    loss <- subset(history_df,select=c(epoch,value),metric=='loss'&data=='training' )
    acc <- subset(history_df,select=c(epoch,value),metric=='acc'&data=='training' )
    val_loss <- subset(history_df,select=c(epoch,value),metric=='loss'&data=='validation' )
    val_acc <- subset(history_df,sselect=c(epoch,value),metric=='acc'&data=='validation' )
    mergedf <- merge(loss,acc,by.x="epoch",by.y="epoch")
    mergedf <- merge(mergedf,val_loss,by.x="epoch",by.y="epoch")
    mergedf <- merge(mergedf,val_acc,by.x="epoch",by.y="epoch") 
    #only the above will add two extra columns of acc and validation
    #and only this line will lead to the error of duplicated column name, c'est bizzard!
    names(mergedf)=c("epoch","loss","acc","val_loss","val_acc")
    mergedf <- mergedf[,c(-1)]
    mergedf <- subset(mergedf,select=c("loss","acc","val_loss","val_acc")) #to drop the column of epoch so that it is more tidy. The most important thing is that there cannot not be any repetition in one column.
    # row.names(history_df) <- history_df$epoch #name the row
    # names(history_df) <- history_df$epoch #name the column
    sink("C:\\Users\\visiopharm5.CICCDOM\\Desktop\\qinghe\\log\\log.txt",TRUE) #set append to TRUE so will not overwrite each time.
    print(mergedf)
    sink()
    
  }
  
  #save the weights
  path="D:\\qinghe\\models"
  modelpath=paste(path,"\\epoch_",(num_epoch + epochs_in_a_loop),sep="")
  print(modelpath)
  save_model_weights_hdf5(model,modelpath,overwrite = TRUE)
  n_loop = n_loop-1
  
}

#view_savemodel("savemodel")

# Clean up the TF session.
coord$request_stop()
coord$join(threads)
k_clear_session()

# Test -----------------------------------------------------------------

#predict the test dataset and save the probabilites as "prediction.txt".
preds <- model %>% predict(x_test)
preds
sink("D:\\qinghe\\results\\prediction.txt",TRUE)
print(preds)
sink()


