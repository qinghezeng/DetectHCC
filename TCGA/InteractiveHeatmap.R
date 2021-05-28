# devtools::install_github("rstudio/d3heatmap")
# install.packages("htmlwidgets")

# load package
# library(pheatmap)
# library(d3heatmap)
# library(htmlwidgets)

# # Interactive heatmap:
# # 1 Shows the row/column/value under the mouse cursor
# # 2 Click row/column labels to highlight
# # 3 Drag a rectangle over the image to zoom in
# map <- d3heatmap(data, colors = "Blues", scale = "row", k_row = 3, k_col = 3, show_grid = TRUE)
# # Save heatmap as a html
# saveWidget(map, "E:\\deeplearning\\Hepatocarcinomes\\TCGA\\heatmap\\test.html")



ncluster_col = 9
ddg_col_cut <- get_subdendrograms(as.dendrogram(hc_col), ncluster_col)[[1]]
dist3_col <- cophenetic(ddg_col_cut)
cor(dist_col, dist3_col)

as.dendrogram(hc_col) %>% color_branches(k=5) %>%
  plot(horiz = FALSE) 

# The output value, is the cophenetic correlation coefficient.
# The magnitude of this value should be very close to 1 for a high-quality solution. 
# This measure can be used to compare alternative cluster solutions obtained using different algorithms.


dend <- iris[,-5] %>% dist %>% hclust %>% as.dendrogram %>%  set("labels_to_character") %>% color_branches(k=5)
dend_list <- get_subdendrograms(dend, 5)

# Plotting the result
par(mfrow = c(2,3))
plot(dend, main = "Original dendrogram")
sapply(dend_list, plot)
