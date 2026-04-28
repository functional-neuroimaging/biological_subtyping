#!/bin/bash
#
# -----------------------------------------------------------
# Script written by Marco Pagani
# Functional Neuroimaging Lab, 
# Istituto Italiano di Tecnologia, Rovereto
# (2019)
# -----------------------------------------------------------

# connectivity maps corrected for batch effect
connectivity_map_path=/data3/autism_center/projects/marco/clustering_autism/07_discovery/04_combat_to_nifti/ # edit this

fslmerge -t 4d_voxelwise_connectivity_across_subjects.nii.gz $connectivity_map_path/*.nii.gz

fslmaths 4d_voxelwise_connectivity_across_subjects.nii.gz -Tmean voxelwise_mean_connectivity_across_subjects.nii.gz

rm 4d_voxelwise_connectivity_across_subjects.nii.gz 
