# This code uses NbClust to calculate the optimal number of clusters.
#
# Here is the documentation:
# https://www.rdocumentation.org/packages/NbClust/versions/3.0/topics/NbClust
#
# This is a recurrent error you can get:
# https://stackoverflow.com/questions/20669596/nbclust-package-error/20894020 
#
# This code uses "euclidean" as distance metric, however you can pick any out 
# of the following:
#
# list.distance = c("index", "euclidean", "maximum", "manhattan", "canberra")
#
#
# This is the full list of the indexes you may want to use for your analysis:
#
# list.indexes = c("kl", "ch", "hartigan", "ccc", "scott", 
#		   "marriot", "trcovw", "tracew", "friedman", 
#		   "rubin", "cindex", "db", "silhouette", 
#		   "duda", "pseudot2", "beale", "ratkowsky", 
#		   "ball", "ptbiserial", "gap", "frey", 
#		   "mcclain", "gamma", "gplus", "tau", "dunn", 
#		   "hubert", "sdindex", "dindex", "sdbw")
#
# -----------------------------------------------------------
# Code written by Marco Pagani
# Functional Neuroimaging Lab, IIT, Rovereto (ITA)
# Autism Center, CMI, New York (US)
# (2020)
# -----------------------------------------------------------



# loading required libraries
library('gplots')
library('corrplot')
library('NbClust')
library('RColorBrewer')


# loading the matrix (where rows are ROIs and columns are subjects)
mydata=read.table("/media/DATA1/rsfMRI_all_autism_mutations_Marie_Curie/06_20_etiologies_IL6/03_clustering/02_features_for_clustering_txt/feature_etiology_matrix.txt", header=F, sep=" ")


# transforming data from data.frame to data.matrix and transpose
mydata_matrix <- data.matrix(mydata, rownames.force = NA)
mydata_matrix_t <- t(mydata_matrix)


# setting indices to be used with NbClust
list.indexes = c("kl", "ch", "hartigan", "cindex", "db", "silhouette", 
		 "duda", "pseudot2", "beale", "ratkowsky", 
		 "ball", "ptbiserial", "gap", "frey", 
		 "mcclain", "gamma", "gplus", "tau", "dunn", 
		 "sdindex", "sdbw")


# setting distances to be used with NbClust
list.distances = c("index", "euclidean")


# creating table to save results of NbClust
results.table = as.data.frame(matrix(ncol = length(list.distances), nrow = length(list.indexes)))
names(results.table) = list.distances


# this is the actual NbClust computation, the range of k solutions is 
# 2 < k < 8 and the method is complete

for (j in 2:length(list.distances)){

	for(i in 1:length(list.indexes)){

	message(c(list.distances[j], " - ", list.indexes[i]))

	nb = NbClust(mydata_matrix_t, 
	     	     distance = list.distances[j],
                     min.nc = 2, 
	             max.nc = 8, 
                     method = "complete", 
	             index = list.indexes[i])

	results.table[i,j] = nb$Best.nc[1]
	results.table[i,1] = list.indexes[i]

	}
}

# print table on screen
results.table

# save table in .txt file
write.table(results.table, 'NbClust_optimal_number_of_clusters.txt', sep = " ", row.names = F)

