# Load a post-processed probability map, with 64x64 subtile to 1 pixel (5x)
# Save a probability table of 2 classes (the values of normal class are set to 0)

library(tiff)

######################################################
#edit train/test and slide name
slide_name="test\\HMNT0783_bis"
######################################################

path=paste("E:\\deeplearning\\data\\5x\\detector\\",slide_name,"\\results",sep="")

img = readTIFF(paste(path, "\\prob_map_tum_8_subtile_post.tiff",sep=""))
# img = readTIFF(paste(path, "prob_map.tif"))
prob = array(dim = c(dim(img)[1] * dim(img)[2] ,2))

left_right = 0 #0 is a line begin from left, and 1 is from right
j = 1 #pointer to a probability of tumoral class, always even
row = seq(1, dim(img)[1]-8+1, 8)
col = seq(1, dim(img)[2]-8+1, 8)
col_inv = seq(dim(img)[2]-8+1, 1, -8)


for(rr in row){
  left_right = left_right + 1
  if(left_right %% 2 == 1) {
    
    for(cc in col) {
      
      for(c in c(1:8))
      {
        for(r in c(1:8))
        {
          if(img[rr+r-1, cc+c-1] == 1)
          {
            prob[j,1] = 1
            prob[j,2] = 0
          }
          else {
            prob[j,1] = 0
            prob[j,2] = 1
          }
          j = j+1
        }
      }
    }
  } else {

    for(cc in col_inv){

      for(c in c(1:8))
      {
        for(r in c(1:8))
        {
          if(img[rr+r-1,cc+c-1] == 1)
          {
            prob[j,1] = 1
            prob[j,2] = 0
          }
          else {
            prob[j,1] = 0
            prob[j,2] = 1}
          j = j+1
        }
      }
    }
  }
}

write.table(prob,
            paste(path,"\\vgg_dense_bn_prob_post",sep=""),
            sep=",",
            row.names = FALSE,
            col.names = c("tum", "nor"))

      