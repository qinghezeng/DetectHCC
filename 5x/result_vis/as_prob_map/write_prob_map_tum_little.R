# Load a probability table of 2 classes
# Save a probability map of Tumor class, with 64x64 subtile to 1 pixel (5x) 

# install.packages("tiff")
library(tiff) # use tiff package rather than rtiff
library (EBImage)

########################################################
# EDIT size info 
horizontal <- 111104 #Visiopharm Image Information
vertical <- 85248
resu_orin <- 40 #original magnification
resu_split <- 5 #magnification when detection
field <- 512 #tile size from Visiopharm
label_size <- 64 #subtile size to be predicted
n = field/label_size #number of subs in a tile

#EDIT train/test and slide name
slide_name="test\\HMNT0932"
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
          label_field[c,r] = prob[j]
          j = j+2
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
          label_field[c,r] = prob[j]
          j = j+2
        }
      }
      label[cc:cc_, rr:rr_] = label_field[,]
    }
  }
}

# label_inv=1-label #label: white should be tumor. label_inv is for a python thesholding
# writeTIFF(label, paste(path,"\\prob_map_tum_32_subtile",".tiff",sep=""),bits.per.sample = 16L) #32L seems different
# writeTIFF(ra, paste(path,"\\hhh_",".tiff",sep=""),bits.per.sample = 16L, reduce=TRUE) #save GA (0=NA)

# readTIFF(paste("D:\\qinghe\\test\\probability_map","\\r_ga",".tiff",sep=""), native=TRUE) #alpha channel

# First calculate the resolution with 5x and 64 pixels. Transparence not supported in Visiopharm (black)
tiff("D:\\qinghe\\test\\probability_map\\test.tiff", res = 216.7929737109375, width = 224, height = 168, bg = "transparent")
par(mar=c(0,0,1,0)) #to avoid margin too large error
par(bg="NA") #transparent
img = max(label) - label #invert
img=rotate(img,270) #to remove the rotation made by tiff library
image(img, col=terrain.colors(255)) # Make plot, thresholding, color
dev.off()

# 
# img_offset=array(dim=c(481,183)) #offset read in Visiopharm
# img_offset[258:481,1:168]=img[,] #but visiopharm doesn't support the "alpaha" channel of tiff image
# 
# Officiel example
# if (exists("rasterImage")) { # can plot only in R 2.11.0 and higher
#   plot(1:2, type='n',bty = 'n')
#   
#   if (names(dev.cur()) == "windows") {
#     # windows device doesn't support semi-transparency so we'll need
#     # to flatten the image
#     transparent <- test[,,2] == 0
#     test <- as.raster(img[,])
#     test[transparent] <- NA
#     
#     # interpolate must be FALSE on Windows, otherwise R will
#     # try to interpolate transparency and fail
#     rasterImage(test, 1.2, 1.27, 1.8, 1.73, interpolate=FALSE)
#     
#   }
# }
# 
