# this procedure performs agglomerative cluster analysis and gives cluster membership
#
# quarda anche questo pacchetto nel caso
# https://www.datanovia.com/en/lessons/heatmap-in-r-static-and-interactive-visualization/

# https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/hclust
# https://www.rdocumentation.org/packages/stats/versions/3.6.2/topics/dist
#
# ricordati che se hai troppe colonne (voxels), la visualizzazione crasha di conseguenza fai downsampling!)

# https://www.rdocumentation.org/packages/grDevices/versions/3.4.1/topics/png


# loading required libraries
library('gplots')
library('corrplot')
library('RColorBrewer')
library('ggplot2')


# loading feature matrix
feature_by_etiology_matrix <- as.matrix(read.table("/media/DATA1/rsfMRI_all_autism_mutations_Marie_Curie/06_20_etiologies_IL6/03_clustering/02/02_features_for_clustering_txt/feature_etiology_matrix.txt", sep = " "))


# renaming etiologies 
colnames(feature_by_etiology_matrix)[1] <- '16p11.2'
colnames(feature_by_etiology_matrix)[2] <- 'Btbr'
colnames(feature_by_etiology_matrix)[3] <- 'Cdkl5 [ht]'
colnames(feature_by_etiology_matrix)[4] <- 'Cdkl5 [ko]'
colnames(feature_by_etiology_matrix)[5] <- 'Chd8'
colnames(feature_by_etiology_matrix)[6] <- 'Cntnap2'
colnames(feature_by_etiology_matrix)[7] <- 'En2'
colnames(feature_by_etiology_matrix)[8] <- 'Fmr1'
colnames(feature_by_etiology_matrix)[9] <- 'Il6'
colnames(feature_by_etiology_matrix)[10] <- '22q11.2'
colnames(feature_by_etiology_matrix)[11] <- 'Mecp2'
colnames(feature_by_etiology_matrix)[12] <- 'Nlgn3-R451'
colnames(feature_by_etiology_matrix)[13] <- 'Nlgn3 [ko]'
colnames(feature_by_etiology_matrix)[14] <- 'Oxtr'
colnames(feature_by_etiology_matrix)[15] <- 'Sgsh'
colnames(feature_by_etiology_matrix)[16] <- 'Shank3'
colnames(feature_by_etiology_matrix)[17] <- 'Syn2'
colnames(feature_by_etiology_matrix)[18] <- 'Trem2'
colnames(feature_by_etiology_matrix)[19] <- 'Tsc2'
colnames(feature_by_etiology_matrix)[20] <- 'Ube3a'


# transposing the matrix. Here I transpose because I want 
# etiologies to be the raws 
etiology_by_feature_matrix <- t(feature_by_etiology_matrix)


# dimensions of the matrix
dim(etiology_by_feature_matrix)


# in case needed, this subsets the matrix - too large matrices don't get visualised by R
# etiology_by_feature_matrix_subset <- etiology_by_feature_matrix[c(1:20),c(1:100)]


# loading and reversing color palettes
hmcol <- rev(colorRampPalette(brewer.pal(11, "RdBu"))(256))

# set the maximum and minimum value of the colorbar
range_colors = seq(from = -1.2, to = 1.2, by = 0.009375)


# saving the figure in tiff
png(filename = "/media/DATA1/rsfMRI_all_autism_mutations_Marie_Curie/06_20_etiologies_IL6/03_clustering/02/dendrogram.png", 
		width = 15, 
		height = 10, 
		units = "cm", 
		res= 600, 
		pointsize = 4)


# visualising the matrix with agglomerative clustering (about 1 minute to plot)
matrix_with_dendrogram <- heatmap.2(etiology_by_feature_matrix,
				    Rowv = T,							# cluster rows
				    Colv = T,							# don't cluster columns
	 			    symm = F, 							# matrix is not symmetrical
				    revC = T,
				    distfun = function(x) dist(x, method = "euclidean"),	# define distance metrics
  				    hclustfun = function(x) hclust(x, method = "ward.D2"), 	# define clustering method (complete, ward.D2)
				    trace = c("none"), 						# don't display trace	
				    dendrogram = "row",						# show dendrogram
				    col = hmcol, 						# color of the cells
				    key = T,
				    key.title = NA, 
				    key.xlab = "Cohen's d",
				    density.info = "none", 
			            keysize = 1, 
				    cexRow = 3.5, 						# size labels x-axis
				    cexCol = 0.01,						# size labels y-axis, practically not visible	
				    breaks = range_colors,
				    margins = c(1,15),
				    labRow=as.expression(lapply(rownames(etiology_by_feature_matrix), function(a) bquote(italic(.(a)))))
				    ) 

dev.off()


# save and write sorted matrix
sorted_matrix_csv <- etiology_by_feature_matrix[rev(matrix_with_dendrogram$rowInd), matrix_with_dendrogram$colInd]
write.table(sorted_matrix_csv, file = "sorted_etiology_by_feature_matrix.csv", sep = ",", dec = ".", row.names = TRUE, col.names = FALSE)



