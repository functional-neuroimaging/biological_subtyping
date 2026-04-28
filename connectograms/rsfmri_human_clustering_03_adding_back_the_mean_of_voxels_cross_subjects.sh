#!/bin/bash

# This script extracts mean regional connectivity values of multiple ROIs 
# of multiple connectivity maps. You can then use this code to carry out
# quantifications of global and local connectivity maps.
#
# Each ROI is a binary image saved in a single separate nifti file.
#
# This code can now also handle NaN or Inf values as they are read as zeros 
# and then excluded from the averaging.
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------

connectivity_map_path=0_global_connectivity_maps_filtered/ # edit this

voxelwise_mean_connectivity_across_subjects=/data3/autism_center/projects/marco/clustering_autism/13_discovery_asd_global_mean_regression/03_plus_mean_of_voxels_cross_subjects/voxelwise_mean_connectivity_across_subjects.nii.gz

mkdir 0_global_connectivity_maps_filtered_plus_mean

for connectivity_map in $connectivity_map_path/*; do 

	echo $connectivity_map

	connectivity_map_basename=$(basename $connectivity_map .nii.gz)
	
	fslmaths $connectivity_map \
		 -add $voxelwise_mean_connectivity_across_subjects \
		 0_global_connectivity_maps_filtered_plus_mean/${connectivity_map_basename}_plus_mean.nii.gz

done
