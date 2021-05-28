# Load a probability table of 2 classes
# Save a probability map of Tumor class as (orginal size + border) (5x) 
# Thresholding and contrast++: set <0.8 as 0, rescale 0.8~1 to 0~1

# install.packages("tiff")
library(tiff) # use tiff package rather than rtiff
library (EBImage)

########################################################
# EDIT size info 
horizontal <- 59520 #Visiopharm Image Information
vertical <- 41216
resu_orin <- 20 #original magnification
resu_split <- 5 #magnification when detection
field <- 512 #tile size from Visiopharm
label_size <- 64 #subtile size to be predicted

#EDIT train/test and slide name
slide_name="train\\HMNT0001"
########################################################

num_hor = ((horizontal / (resu_orin / resu_split)) %/% field  + 1) * (field / label_size) #number of 64x64 sub per row in prob map
num_ver = ((vertical / (resu_orin / resu_split)) %/% field + 1) * (field / label_size)

path=paste("E:\\deeplearning\\data\\5x\\detector\\",slide_name,"\\results\\",sep="")
# preds_classes1 <- c(t(read.table("D:\\qinghe\\results\\HMNT0001\\preds_classes", header = TRUE, sep = ",")))
prob <- c(t(read.table(paste(path, "\\vgg_dense_bn_prob",sep=""), header = TRUE, sep = ",")))

# vote for the label
label = array(dim=c(num_ver*label_size,num_hor*label_size)) #the output, same size as 5x WSI
label_field = array(dim=c(field,field)) #512x512
j = 1 #pointer to a probability of tumoral class, always odd
left_right = 0 #0 is a line begin from left, and 1 is from right
hor_field = seq(1, num_hor*label_size-field+1, field)
hor_field_inv = seq(num_hor*label_size-field+1, 1, -field)
ver_field = seq(1, num_ver*label_size-field+1, field)
every_label_size = seq(1, field-label_size+1, label_size)

for(cc in ver_field) #the row and col is inverted when loaded
{
  cc_ = cc + field-1
  left_right = left_right + 1
  if(left_right %% 2 == 1) {
    for(rr in hor_field)
    {
      rr_ = rr+field-1
      for(r in every_label_size) #in fact is process by column
      {
        for(c in every_label_size) #1, 65, 129, ..., 449
        {
          r_ = r+label_size-1
          c_ = c+label_size-1
          if(prob[j]>=0.8) {
            label_field[c:c_,r:r_] = (prob[j]-0.8)*5
            j = j+2
          } else {
            label_field[c:c_,r:r_] = 0
            j = j+2
          }
        }
      }
      label[cc:cc_, rr:rr_] = label_field[,]
    }
  } else {
    for(rr in hor_field_inv)
    {
      rr_ = rr+field-1
      for(r in every_label_size)
      {
        for(c in every_label_size)
        {
          r_ = r+label_size-1
          c_ = c+label_size-1
          if(prob[j]>=0.8) {
            label_field[c:c_,r:r_] = (prob[j]-0.8)*5
            j = j+2
          } else {
            label_field[c:c_,r:r_] = 0
            j = j+2
          }
        }
      }
      label[cc:cc_, rr:rr_] = label_field[,]
    }
  }
}

writeTIFF(label, paste(path,"\\prob_map_tum_threshold",".tiff",sep=""),bits.per.sample = 16L)
