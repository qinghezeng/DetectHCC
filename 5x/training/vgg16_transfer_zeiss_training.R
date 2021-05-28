# README ------------------------------------------------------------------

#Use the 64*64 annotated subtiles as data, this script uses 100k images of each class for training (0.8) and validation (0.2). 
#
#NasNet Large pretraiened on imagenet
#Only learning on dense layers (frozen base model)
#input shape minimum = 32x32x3 thus does work on 64x64

# Installation of libraries ----------------------------------------------

# devtools::install_github("rstudio/tensorflow")
# install_keras(tensorflow = "gpu")
# install.packages("tiff")

# Including libraries -----------------------------------------------------

library(keras)
library(tiff)

# Parameters --------------------------------------------------------------

batch_size <- 32
epochs <- 50

# Data Preparation --------------------------------------------------------

#With the workplace (~_load_data.RData) saved before, we don't need to run this part of code.
#It is better is set the Working Directory to a disk of more than 45G, 
#if you want to prepare the data of a slide split into 64*64 with 5* resolution without removing the intermediate parameters.
#Also don't forget to use these two commands to check the using memory and to increase the limit of memory (every time you run a new session)
# memory.size()
memory.limit(180000000) #Size in Mb (1048576 bytes), rounded to 0.01 Mb
#memory.limit() #To check what is the limit of the memory now

#Load images
path="E:\\deeplearning\\Hepatocarcinomes\\data\\5x\\test_zeiss\\testset\\nor"
lpos_=list.files(path, pattern = "\\.tif$") #only return the file end with ".tif". 
#Attention that label files end with ".tiff".
sam_25000=sample(seq(1:length(lpos_)),size=25000)
lpos=lpos_[sam_25000]
pos=array(dim=c(length(lpos),64,64,3))
for (i in c(1:length(lpos))){
  pos[i,,,]=readTIFF(paste(path,"\\",lpos[i],sep=""))
}

path="E:\\deeplearning\\Hepatocarcinomes\\data\\5x\\test_zeiss\\testset\\tum"
lneg_=list.files(path, pattern = "\\.tif$")
lneg=lneg_[sam_25000]
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

#randomize training set
rand_train=sample(seq(1:length(y_train)))
y_train=y_train[rand_train]
x_train=x_train[rand_train, , ,]

#labels to categorical
y_train <- to_categorical(y_train, num_classes = 2)

#remove unused data
rm(i,neglabels,poslabels,rand_train,lneg_,lpos_)

# Defining the model ------------------------------------------------------

# create the base pre-trained model
# base_model <- application_nasnetmobile(include_top = FALSE, 
#                                       weights = "imagenet",
#                                       input_tensor = NULL, 
#                                       input_shape = c(64,64,3), 
#                                       pooling = NULL)

model <- load_model_hdf5(filepath = "E:\\deeplearning\\Hepatocarcinomes\\models\\5x\\vgg16_dense_bn\\best_model", compile = TRUE)

#freeze the conv base model
freeze_weights(base_model)

# add our custom layers
predictions <- base_model$output %>% 
  layer_flatten(name = "flatten_1") %>%
  layer_dense(units = 4096, use_bias = FALSE, name = "dense_1") %>% 
  #layer_batch_normalization(name = "dense1_bn") %>%
  layer_activation("relu") %>%
  layer_dropout(0.5,name = "dropout_1") %>%
  layer_dense(units = 512, use_bias = FALSE, name = "dense_2") %>%
  #layer_batch_normalization(name = "dense2_bn") %>%
  layer_activation("relu") %>%
  layer_dropout(0.5, name = "dropout_2") %>%
  layer_dense(units = 2, activation = 'softmax', name = "dense_3")

# this is the model we will train
model <- keras_model(inputs = base_model$input, outputs = predictions)

summary(model)

#opt <- optimizer_sgd(lr = 0.001, decay = 1e-4)
#opt <- optimizer_rmsprop(lr = lr_scale, decay = 1e-6) #It is recommended to leave the parameters of this optimizer
#at their default values (except the learning rate, which can be freely tuned).
opt=optimizer_adam(lr=0.0001)
  
  
model %>% compile(
  loss = "categorical_crossentropy",
  optimizer = opt,
  metrics = c("accuracy")
)

#if we use a pretrained model
# model <- load_model_hdf5(filepath = "D:\\dl\\5x\\models\\best_model")
# Attention should not set the optimizer and the compile again

# Training ----------------------------------------------------------------

history <- model %>% fit(
  x_train, y_train,
  batch_size = batch_size,
  epochs = epochs,
  validation_split = 0.2,
  shuffle = TRUE,
  callbacks=list(callback_csv_logger("E:\\deeplearning\\Hepatocarcinomes\\models\\5x\\vgg16_transfer_zeiss\\logger.csv",separator = ",", append=TRUE),
                 
                 # callback_tensorboard(log_dir = "D:\\dl\\5x\\tensorboard_log\\view", 
                 #                      histogram_freq = 5, 
                 #                      batch_size = batch_size,
                 #                      write_graph = TRUE, 
                 #                      write_grads = TRUE, 
                 #                      write_images = TRUE,
                 #                      embeddings_freq = 0, 
                 #                      embeddings_layer_names = NULL,
                 #                      embeddings_metadata = NULL),
                 
                 callback_model_checkpoint(filepath="E:\\deeplearning\\Hepatocarcinomes\\models\\5x\\vgg16_transfer_zeiss\\weights.{epoch:02d}-{val_acc:.4f}.hdf5",
                                           monitor = "val_acc", 
                                           save_best_only = TRUE, 
                                           save_weights_only = TRUE,
                                           mode = "auto", 
                                           period = 1),
                 
                 callback_reduce_lr_on_plateau(monitor = "val_acc",
                                               factor = 0.5,
                                               verbose=1, 
                                               mode="auto", 
                                               patience=3, 
                                               min_delta=0.002 
                                               #cooldown = 3
                                               ),
                 
                 callback_early_stopping(monitor="val_acc",
                                         min_delta = 0.0005, 
                                         patience=10, 
                                         mode="auto"))
)

save_model_hdf5(model, "E:\\deeplearning\\Hepatocarcinomes\\models\\5x\\vgg16_transfer_zeiss\\best_model_r", 
                overwrite = TRUE,
                include_optimizer = TRUE)

# Visualization ---------------------------------------

# tensorboard("D:\\dl\\5x\\tensorboard_log\\view")
# 
# rm(model)
