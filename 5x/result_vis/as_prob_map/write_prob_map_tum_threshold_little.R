# Load a probability table of 2 classes
# Save a probability map of Tumor class, with 64x64 subtile to 1 pixel (5x) 
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
n = field/label_size #number of subs in a tile

#EDIT train/test and slide name
slide_name="train\\HMNT0001"
########################################################

num_hor = (horizontal / (resu_orin / resu_split)) %/% field  + 1 #number of tiles per row (when spliting to 512)
num_ver = (vertical / (resu_orin / resu_split)) %/% field + 1 #per column

path=paste("E:\\deeplearning\\data\\5x\\detector\\",slide_name,"\\results\\",sep="")
# preds_classes1 <- c(t(read.table("D:\\qinghe\\results\\HMNT0001\\preds_classes", header = TRUE, sep = ",")))
prob <- c(t(read.table(paste(path, "\\vgg_dense_bn_prob",sep=""), header = TRUE, sep = ",")))

# vote for the label
label = array(dim=c(num_ver*n,num_hor*n)) #the output (/64)
label_field = array(dim=c(n,n)) #8x8 (for a 512x512)
j = 1 #pointer to a probability of tumoral class, always odd
left_right = 0 #0 is a line begin from left, and 1 is from right
hor_field = seq(1, num_hor*n-n+1, n)
hor_field_inv = seq(num_hor*n-n+1, 1, -n)
ver_field = seq(1, num_ver*n-n+1, n)

for(cc in ver_field) #the row and col is inverted when loaded
{
  cc_ = cc +n-1
  left_right = left_right + 1
  if(left_right %% 2 == 1) {
    for(rr in hor_field)
    {
      rr_ = rr+n-1
      for(r in c(1:(n))) #in fact is process by column
      {
        for(c in c(1:(n))) #1 to 8
        {
          if(prob[j]>=0.8) {
            label_field[c,r] = (prob[j]-0.8)*5
            j = j+2
          } else {
            label_field[c,r] = 0
            j = j+2
          }
        }
      }
      label[cc:cc_, rr:rr_] = label_field[,]
    }
  } else {
    for(rr in hor_field_inv)
    {
      rr_ = rr+n-1
      for(r in c(1:(n)))
      {
        for(c in c(1:(n)))
        {
          if(prob[j]>=0.8) {
            label_field[c,r] = (prob[j]-0.8)*5
            j = j+2
          } else {
            label_field[c,r] = 0
            j = j+2
          }
        }
      }
      label[cc:cc_, rr:rr_] = label_field[,]
    }
  }
}

writeTIFF(label, paste(path,"\\prob_map_tum_threshold_8_low",".tiff",sep=""),bits.per.sample = 32L)