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

# connectivity maps corrected for batch effect
connectivity_map_path=/data3/autism_center/projects/marco/clustering_autism/07_discovery/04_combat_to_nifti/ # edit this

# path of brain mask
roi_path=$PWD/ # edit this

# output name of csv file
output_name_txt_file=subject_mean_global_connectivity # edit this


for connectivity_map in ${connectivity_map_path}/* ; do

	for roi in ${roi_path}/Schaefer2018_400Parcels_plus_subcortex_cerebellum_MNI152_2mm_bin.* ; do

		connectivity_map_basename=`basename ${connectivity_map} .nii.gz`
	
		roi_basename=`basename ${roi} .nii.gz`    		
			
		fslmaths \
			${connectivity_map} \
			-mul ${roi} \
			${connectivity_map_basename}_${roi_basename}.nii.gz 			
			
		mean=`fslstats ${connectivity_map_basename}_${roi_basename}.nii.gz -n -M`
		
		echo ${connectivity_map_basename%_globalconn_voxelwise} ${roi_basename} ${mean}
		
		echo "${connectivity_map_basename%_globalconn_voxelwise},${mean}" >> ${output_name_txt_file}.csv
	
		rm ${connectivity_map_basename}_${roi_basename}.nii.gz

	done

done

# add variable name in the first line
sed -i '1 i\nifti_id,functional_connectivity' ${output_name_txt_file}.csv
