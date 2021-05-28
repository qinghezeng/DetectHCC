# README ------------------------------------------------------------------

#Use the 64*64 annotated subtiles as data, this script uses 100k images of each class for training (0.8) and validation (0.2). 

# Installation of libraries ----------------------------------------------

# devtools::install_github("rstudio/tensorflow")
# install_keras(tensorflow = "gpu")
# install.packages("tiff")

# Including libraries -----------------------------------------------------

library(keras)
library(tiff)

# Parameters --------------------------------------------------------------

batch_size <- 256
epochs <- 120
amount <- 100000

# Data Preparation --------------------------------------------------------

#With the workplace (~_load_data.RData) saved before, we don't need to run this part of code.
#It is better is set the Working Directory to a disk of more than 45G, 
#if you want to prepare the data of a slide split into 64*64 with 5* resolution without removing the intermediate parameters.
#Also don't forget to use these two commands to check the using memory and to increase the limit of memory (every time you run a new session)
# memory.size()
memory.limit(18000000000000000) #Size in Mb (1048576 bytes), rounded to 0.01 Mb
#memory.limit() #To check what is the limit of the memory now

# Defining the model ------------------------------------------------------

# create the base pre-trained model
base_model <- application_vgg16(include_top = FALSE, 
                                weights = "imagenet",
                                input_tensor = NULL, 
                                input_shape = c(64,64,3), 
                                pooling = NULL)

# add our custom layers
predictions <- base_model$output %>% 
  layer_flatten(name = "flatten_1") %>%
  layer_dense(units = 4096, use_bias = FALSE, name = "dense_1") %>% 
  layer_batch_normalization(name = "dense1_bn") %>%
  layer_activation("relu") %>%
  layer_dropout(0.5,name = "dropout_1") %>%
  layer_dense(units = 512, use_bias = FALSE, name = "dense_2") %>%
  layer_batch_normalization(name = "dense2_bn") %>%
  layer_activation("relu") %>%
  layer_dropout(0.5, name = "dropout_2") %>%
  layer_dense(units = 2, activation = 'softmax', name = "dense_3")

# this is the model we will train
model <- keras_model(inputs = base_model$input, outputs = predictions)

summary(model)

# opt <- optimizer_sgd(lr = 0.01, momentum = 0.9, decay = 1e-3)
# opt <- optimizer_rmsprop(lr = 0.01, decay = 1e-3) #It is recommended to leave the parameters of this optimizer
#at their default values (except the learning rate, which can be freely tuned).
opt <- optimizer_adagrad(lr=0.01, decay=1e-3)

model %>% compile(
  loss = "categorical_crossentropy",
  optimizer = opt,
  metrics = "accuracy"
)

#if we use a pretrained model
# model <- load_model_hdf5(filepath = "D:\\dl\\5x\\models\\best_model")
# Attention should not set the optimizer and the compile again

# load_model_weights_hdf5(object = model,
                        # filepath = "E:\\deeplearning\\Hepatocarcinomes\\models\\5x\\test_dataAmount\\200k\\weights.10-0.8829.hdf5")

# Training ----------------------------------------------------------------

datagen <- image_data_generator(validation_split = 0.2) #cross validation

history <- model %>% fit_generator( #fit the model batch by batch to reduce the requirement of RAM
  
  flow_images_from_directory(directory = "E:\\deeplearning\\Hepatocarcinomes\\data\\5x\\training\\split64_image",
                             datagen, target_size = c(64, 64), classes = c("neg_tum_5k", "pos_nor_5k"), 
                             #The order of the labels is arranged in alphabetical order by subdirectory name>
                             #That's to say, "neg_tum" is 0, and "pos_nor" is 1.
                             batch_size = batch_size, subset = "training"), #produce batch infinitely. To generate (x, y)
  steps_per_epoch = as.integer(160000/batch_size), #until the batch number (steps) reach this number #training data for all classes
  epochs = epochs, 
  callbacks=list(callback_csv_logger("E:\\deeplearning\\Hepatocarcinomes\\models\\5x\\test_dataAmount\\200k\\logger.csv",separator = ",", append=TRUE),
                 # callback_tensorboard(log_dir = "D:\\dl\\10x\\tensorboard_log\\view", histogram_freq = 0, batch_size = batch_size,
                 #                      write_graph = TRUE, write_grads = FALSE, write_images = FALSE,
                 #                      embeddings_freq = 0, embeddings_layer_names = NULL,
                 #                      embeddings_metadata = NULL),
                 # #set the histogram_freq = 0, because of:
                 # #ValueError: If printing histograms, validation_data must be provided, and cannot be a generator.
                 callback_model_checkpoint(filepath="E:\\deeplearning\\Hepatocarcinomes\\models\\5x\\test_dataAmount\\200k\\weights.{epoch:02d}-{val_acc:.4f}.hdf5",
                                           monitor = "val_acc", 
                                           save_best_only = TRUE, 
                                           save_weights_only = TRUE,
                                           mode = "auto", 
                                           period = 10),
                 
                 callback_reduce_lr_on_plateau(monitor = "val_acc",
                                               factor = 0.1,verbose=1, 
                                               mode="auto", 
                                               patience=8, 
                                               min_delta=0.002, 
                                               cooldown = 3),
                 
                 callback_early_stopping(monitor="val_acc",
                                         min_delta = 0.001, 
                                         patience=15, 
                                         mode="auto")),
  
  validation_data = flow_images_from_directory(directory = "E:\\deeplearning\\Hepatocarcinomes\\data\\5x\\training\\split64_image",
                                               datagen, target_size = c(64, 64), classes = c("neg_tum_5k", "pos_nor_5k"), 
                                               batch_size = batch_size, subset = "validation"),
  validation_steps = as.integer(40000/batch_size),
  verbose = 2,
  initial_epoch = 0)


save_model_hdf5(model, "E:\\deeplearning\\Hepatocarcinomes\\models\\5x\\test_dataAmount\\200k\\best_model", 
                overwrite = TRUE,
                include_optimizer = TRUE)

# Visualization ---------------------------------------

# tensorboard("D:\\dl\\5x\\tensorboard_log\\view")

rm(model)
