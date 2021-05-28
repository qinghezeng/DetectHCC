# README ------------------------------------------------------------------

#Use the 64*64 classified subtiles as data, this script uses 10k subtiles of each class for training (0.8) and validation (0.2).

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

batch_size <- 128
epochs <- 250

# Data Preparation --------------------------------------------------------

#With the workplace (~_load_data.RData) saved before, we don't need to run this part of code.
#It is better is set the Working Directory to a disk of more than 45G, 
#if you want to prepare the data of a slide split into 64*64 with 5* resolution without removing the intermediate parameters.
#Also don't forget to use these two commands to check the using memory and to increase the limit of memory (every time you run a new session)
# memory.size()
memory.limit(75000) #Size in Mb (1048576 bytes), rounded to 0.01 Mb

#Load images
path="D:\\deeplearning\\Hepatocarcinomes\\data\\5x\\training\\split64_image\\nor_100k+"
lpos_=list.files(path, pattern = "\\.tif$") #only return the file end with ".tif". 
#Attention that label files end with ".tiff".
sam_100000=sample(seq(1:length(lpos_)),size=100000)
lpos=lpos_[sam_100000]
pos=array(dim=c(length(lpos),64,64,3))
for (i in c(1:length(lpos))){
  pos[i,,,]=readTIFF(paste(path,"\\",lpos[i],sep=""))
}

path="D:\\deeplearning\\Hepatocarcinomes\\data\\5x\\training\\split64_image\\tum_100k+"
lneg_=list.files(path, pattern = "\\.tif$")
lneg=lneg_[sam_100000]
neg=array(dim=c(length(lneg),64,64,3))
for (i in c(1:length(lneg))){
  neg[i,,,]=readTIFF(paste(path,"\\",lneg[i], sep=""))
}

#create label vectors
poslabels=rep(1,length(lpos))
#print(poslabels)
neglabels=rep(0,length(lneg))

#bind pos and negative exemples for training and test sets
library(abind)
x_train=abind(pos,neg, along=1)
rm(pos,neg)
#bind pos and negative labels for training and test sets
y_train=c(poslabels,neglabels)
#bind pos and negative names for only test sets
rm(lpos,lneg)

#randomize training and test set
rand_train=sample(seq(1:length(y_train)))
y_train=y_train[rand_train]
x_train=x_train[rand_train, , ,]

#labels to categorical
y_train <- to_categorical(y_train, num_classes = 2)

#remove unused data
rm(i,neglabels,poslabels,rand_train,lneg_,lpos_)

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

summary(model)

opt <- optimizer_sgd(lr = 0.001, decay = 1e-7)
#opt <- optimizer_rmsprop(lr = lr_scale, decay = 1e-6) #It is recommended to leave the parameters of this optimizer
#at their default values (except the learning rate, which can be freely tuned).

model %>% compile(
  loss = "categorical_crossentropy",
  optimizer = opt,
  metrics = "accuracy"
)

#if we use a pretrained model
# model <- load_model_hdf5(filepath = "D:\\dl\\5x\\vgg16_512dense\\best_model")
# Attention should not set the optimizer and the compile again

# Training ----------------------------------------------------------------

history <- model %>% fit(
   x_train, y_train,
  batch_size = batch_size,
  epochs = epochs,
  validation_split = 0.2, #if "validation_data" is enabled, it will overwrite "validation_split"
  shuffle = TRUE,
  callbacks=list(callback_csv_logger("D:\\dl\\5x\\log\\logger.csv",separator = ",", append=TRUE),
                 callback_tensorboard(log_dir = "D:\\dl\\5x\\tensorboard_log\\view", histogram_freq = 3, 
                                      batch_size = batch_size, write_graph = TRUE, write_grads = TRUE,
                                      write_images = TRUE,embeddings_freq = 0, embeddings_layer_names = NULL,
                                      embeddings_metadata = NULL),
                  callback_model_checkpoint(filepath="D:\\dl\\5x\\models\\weights.{epoch:02d}-{val_acc:.4f}.hdf5",
                                           monitor = "val_acc", save_best_only = TRUE, save_weights_only = TRUE,
                                           mode = "auto", period = 15),
                 callback_reduce_lr_on_plateau(monitor = "val_acc", factor = 0.1,verbose=1,mode="auto",min_delta=0.003),
                 callback_early_stopping(monitor="val_acc",min_delta = 0.0005,patience=8,mode="auto"))
)

save_model_hdf5(model, "D:\\dl\\5x\\models\\best_model", overwrite = TRUE,
                include_optimizer = TRUE)


# Visualization ---------------------------------------

tensorboard("D:\\dl\\5x\\tensorboard_log\\view")

rm(model)
