#
# this code uses glm to regress out covariates of no interest
# across subjects i.e. in group level analysis. in this case
# the covariate is mean global connectivity calculated in the
# previous script.
#
# to use this code you need ts in nifti format and covariates in csv
# make sure that your binary brainmask is set to "float".
#
# ----------------------------------------
# Code written by Marco Pagani,
# Autism Center, CMI
# Functional Neuroimaging Laboratory, IIT
# May 2021
# ----------------------------------------


# this loads the required libraries
library(oro.nifti)

# create outputdir
dir.create('0_global_connectivity_maps_filtered')


# edit this, this loads the binary brainmask, make sure it is in "float" format
mask_f <- 'Schaefer2018_400Parcels_plus_subcortex_cerebellum_MNI152_2mm_bin.nii.gz'
mask <- readNIfTI(mask_f) > 0


# edit this, this loads a csv file containing subject IDs and all the other info needed for this code to work.
# this file should also include the regressors.
pheno_info <- read.csv('/data3/autism_center/projects/marco/clustering_autism/03_phenotypic_info/phenotypic_info_ABIDE1-2merged_22_with_motion_info.csv', header = T)


# edit this, this loads a csv file containing extra regressors not included in the pheno_info
subject_mean_global_connectivity <- read.csv('subject_mean_global_connectivity.csv', header = T)


# this creates sub_id for the future matching
subject_mean_global_connectivity$sub_id <- substr(subject_mean_global_connectivity$nifti_id, 0, 8)


# edit this, this subsets the phenotypic data and keeps only subjects that has a connectivity_map.nii.gz, 
# age < 30 yo and included in discovery dataset. you should already have this info before using this code.
pheno_info_selected <- pheno_info[ which(pheno_info$nifti == "1" & pheno_info$age_at_scan < 30 & pheno_info$discovery_replication == "1"),]


# this merges the phenotypic info and the medianFD in a single file (and keep unmatched lines)
pheno_info_selected <- merge(pheno_info_selected, subject_mean_global_connectivity,  by.x = "sub_id", by.y = "sub_id", all.x = T)


# edit this, this creates a list of connectivity_maps.nii.gz that will be used as input names
subject_list_selected <- paste("/data3/autism_center/projects/marco/clustering_autism/07_discovery/04_combat_to_nifti/", pheno_info_selected$sub_id, "_globalconn_voxelwise.nii.gz", sep="")


# edit this, this creates a list of connectivity_maps.nii.gz that will be used as output names (without .nii.gz)
subject_list_selected_filtered <- paste("/data3/autism_center/projects/marco/clustering_autism/13_discovery_asd_global_mean_regression/02_plus_mean/0_global_connectivity_maps_filtered/", pheno_info_selected$sub_id, "_globalconn_voxelwise_filtered", sep="")


# this loads the connectivity_maps.nii.gz based on the list
connectivity_maps <- t(sapply(subject_list_selected, function(x) {
  message(x)
  readNIfTI(x)[mask]
}))



# -------------------------- filtering confounding variables ------------------------------- 
# -------------------- mean connectivity as covariate of fixed effect ----------------------

# this uses lm to calculate the voxelwise t-tests between diagnosis 
# and outputs for each voxel a coefficient that is the t-stat (3rd position).
tstat_connectivity_maps_filtered <- apply(connectivity_maps, 2, function(x) {
         	    			  resid(lm(x ~ pheno_info_selected$functional_connectivity))
       		   			  })


# this converts filtered values into data frame and 
# merges names of the filtered maps and filtered values in a single data frame.
tstat_connectivity_maps_filtered_df = as.data.frame(tstat_connectivity_maps_filtered)
subject_list_tstat_connectivity_maps_selected_filtered_df = cbind(subject_list_selected_filtered, tstat_connectivity_maps_filtered_df)


# this writes filtered nifti files
for(i in 1:nrow(subject_list_tstat_connectivity_maps_selected_filtered_df)) {

    # this gives to tmap_mixed the properties of mask.nii.gz
    tmap_mixed <- mask
     
    # number of voxels
    num_vox = length(tstat_connectivity_maps_filtered_df)

    # this writes filtered values into tmap_mixed
    tmap_mixed@.Data[mask] <- unlist(subject_list_tstat_connectivity_maps_selected_filtered_df[i,2:(num_vox+1)])

    # this writes the filename
    filename=paste(subject_list_tstat_connectivity_maps_selected_filtered_df[i,1], sep="")

    # this writes the nifti file
    writeNIfTI(tmap_mixed, filename)

}

