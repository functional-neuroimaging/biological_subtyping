# This code calculates and plots within-groups sum of squares (WSS)
# that can be used to identify the elbow that corresponds to your optimal number of clusters.
#
# https://stackoverflow.com/questions/15376075/cluster-analysis-in-r-determine-the-optimal-number-of-clusters
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
mydata=read.table("/media/DATA1/rsfMRI_all_autism_mutations_Marie_Curie/05_clustering/04_cluster_global_connectivity/02_features_for_clustering_txt/feature_etiology_matrix.txt", header=F, sep=" ")


# transforming data to data.frame to data.matrix and transpose
mydata_matrix <- data.matrix(mydata, rownames.force = NA)
mydata_matrix_t <- t(mydata_matrix)


# this calculates and plots the WSS for 2<k<15
mydata <- mydata_matrix_t
wss <- (nrow(mydata)-1)*sum(apply(mydata,2,var))
  for (i in 2:15) wss[i] <- sum(kmeans(mydata,
                                       centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters",
     ylab="Within groups sum of squares")


