#It reaches 0.0945 validation logloss and 0.9671 validation accuracy in 75 epochs,
#with the setting validation_split=0.2, batch_sise=300, learning rate=0.0001.

# Library -----------------------------------------------------------------
#devtools::install_github("aoles/EBImage")
library(keras)
library(EBImage)

# Parameters --------------------------------------------------------------

batch_size <- 32
epochs <- 3    
data_augmentation <- FALSE


# Data Preparation --------------------------------------------------------

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

#display one exemple
image(neg[30570, , ,1],col=grey(seq(0,1,length=255)))

#create label vectors
poslabels=rep(1,length(lpos))
neglabels=rep(0,length(lneg))

#split pos and negative exemple to 80/20 training/test
#number of pos and neg for test data rouned
n_pos=length(lpos)%/%5
n_neg=length(lneg)%/%5

#create a vector for selecting randomly 20% of pos exemples 
sample_posTest=sample(length(lpos),n_pos,replace=F)

#create a vector for selecting randomly 20% of neg exemples 
sample_negTest=sample(length(lneg),n_neg,replace=F)

#extract pos test exemples and labels
xpos_test=pos[sample_posTest,,,];
ypos_test=poslabels[sample_posTest];
#keep the others for training
xpos_train=pos[-sample_posTest,,,];
ypos_train=poslabels[-sample_posTest];
rm(pos)

#extract neg test exemples and labels
xneg_test=neg[sample_negTest,,,];
yneg_test=neglabels[sample_negTest];
#keep the others for training
xneg_train=neg[-sample_negTest,,,];
yneg_train=neglabels[-sample_negTest];
rm(neg)

#bind pos and negative exemples for training and test sets
library(abind)
x_test=abind(xpos_test,xneg_test, along=1)
rm(xpos_test,xneg_test)
x_train=abind(xpos_train,xneg_train, along=1)
rm(xpos_train,xneg_train)
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

#remove unused data
rm(i,img,neglabels,path,poslabels,rand_test,rand_train,sample_negTest,sample_posTest,yneg_test,ypos_test,ypos_train)

#to display images test
# n=1110
# img=rgbImage(x_test[n,,,1],x_test[n,,,2],x_test[n,,,3])
# display(img)

# Defining the model ------------------------------------------------------

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

opt <- optimizer_rmsprop(lr = 0.00001, decay = 1e-6)

model %>% compile(
  loss = "categorical_crossentropy",
  optimizer = opt,
  metrics = "accuracy"
)


# Training ----------------------------------------------------------------

if(!data_augmentation){
  
  model %>% fit(
    x_train, y_train,
    batch_size = batch_size,
    epochs = epochs,
    validation_data = list(x_test, y_test),
    shuffle = TRUE
  )
  
} else {
  
  datagen <- image_data_generator( #define the transformation
    featurewise_center = TRUE,
    featurewise_std_normalization = TRUE,
    rotation_range = 20,
    width_shift_range = 0.2,
    height_shift_range = 0.2,
    horizontal_flip = TRUE,
    validation_split = 0.2
  )
  
  model %>% fit_generator( #fit the model batch by batch
    flow_images_from_data(x_train, y_train, datagen, batch_size = batch_size), #produce batch infinitely. To generate (x, y)
    steps_per_epoch = as.integer(76426/batch_size), #until the batch number (steps) reach this number
    epochs = epochs, 
    subset()
  )
  
}