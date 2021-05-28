# README ------------------------------------------------------------------

#Use the 128*128 classified subtiles as data, this script uses 100k subtiles of each class for training (0.8) and validation (0.2). 
#Load data by batch from disk when training model. Slow but is available with relatively small RAM.
#The acc_val is up to 87% only after 1 epoch!

# Installation of libraries ----------------------------------------------

# devtools::install_github("rstudio/tensorflow")
# install_keras(tensorflow = "gpu")
# install.packages("tiff")

# Including libraries -----------------------------------------------------

library(keras)
library(tiff)

# Parameters --------------------------------------------------------------

batch_size <- 128
epochs <- 250

#Not necessary
# memory.size()
memory.limit(750000) #Size in Mb (1048576 bytes), rounded to 0.01 Mb

# Defining the model ------------------------------------------------------

model <- keras_model_sequential()

model %>%
  layer_conv_2d(filter = 20, kernel_size = c(5,5),input_shape = c(128, 128, 3)) %>%
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

datagen <- image_data_generator(validation_split = 0.2) #cross validation

history <- model %>% fit_generator( #fit the model batch by batch to reduce the requirement of RAM
  
  flow_images_from_directory(directory = "Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\10x\\split128",
                             datagen, target_size = c(128, 128), classes = c("neg_tum", "pos_nor"), 
                             #The order of the labels is arranged in alphabetical order by subdirectory name>
                             #That's to say, "neg_tum" is 0, and "pos_nor" is 1.
                             batch_size = batch_size, subset = "training"), #produce batch infinitely. To generate (x, y)
  steps_per_epoch = as.integer(160000/batch_size), #until the batch number (steps) reach this number
  epochs = epochs, 
  callbacks=list(callback_csv_logger("D:\\dl\\10x\\log\\logger.csv",separator = ",", append=TRUE),
                 # callback_tensorboard(log_dir = "D:\\dl\\10x\\tensorboard_log\\view", histogram_freq = 0, batch_size = batch_size,
                 #                      write_graph = TRUE, write_grads = FALSE, write_images = FALSE,
                 #                      embeddings_freq = 0, embeddings_layer_names = NULL,
                 #                      embeddings_metadata = NULL),
                 # #set the histogram_freq = 0, because of:
                 # #ValueError: If printing histograms, validation_data must be provided, and cannot be a generator.
                 callback_model_checkpoint(filepath="D:\\dl\\10x\\models\\weights.{epoch:02d}-{val_acc:.4f}.hdf5",
                                           monitor = "val_acc", save_best_only = TRUE, save_weights_only = TRUE,
                                           mode = "auto", period = 15),
                 callback_reduce_lr_on_plateau(monitor = "val_loss", factor = 0.1,verbose=1, mode="auto", 
                                               patience=8, min_delta=0.002, cooldown = 3),
                 callback_early_stopping(monitor="val_loss", min_delta = 0.0005, patience=15, mode="auto")),
  validation_data = flow_images_from_directory(directory = "Y:\\IMAGES\\CK\\JulienCalderaro\\Hepatocarcinomes\\10x\\split128", 
                                               datagen, target_size = c(128, 128), classes = c("neg_tum", "pos_nor"), 
                                               batch_size = batch_size, subset = "validation"),
  validation_steps = as.integer(40000/batch_size)
)

save_model_hdf5(model, "D:\\dl\\10x\\models\\best_model", overwrite = TRUE,
                include_optimizer = TRUE)


# Visualization ---------------------------------------

# tensorboard("D:\\dl\\10x\\tensorboard_log\\view")

rm(model)