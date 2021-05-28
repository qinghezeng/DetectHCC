install.packages("colorscience")
install.packages("BBmisc")
library(colorscience)
library(BBmisc)

for(i in c(1:200000)) {
  for(j in c(1:64)) {
    for (k in c(1:64)) {
      x_train[i,j,k,] = RGB2YUV(x_train[i,j,k,]) #package colorscience
    }
  }
  x_train[i,,,1] = normalize(x = x_train[i,,,1], method = "standardize")
  x_train[i,,,2] = normalize(x = x_train[i,,,2], method = "standardize")
  x_train[i,,,3] = normalize(x = x_train[i,,,3], method = "standardize")
}
rm(i,j,k)

display(as.Image(x_train[1,,,]))