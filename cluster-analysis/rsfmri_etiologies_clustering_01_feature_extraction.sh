# This code exports all the features you want use as inputs for a cluster analysis 
# from nifti format to a feature_etiology_matrix.txt. In my case the features are voxels 
# of voxelwise cohen's d between-group differences of seed based functional 
# connectivity maps for each etiology. Each connectivity map is concatenated one after another.
# Before exporting, features are downsampled to improve computational tractability and 
# to make sure you can visualise them with R heatmap.2
#
# The main output of this code is a feature*etiology matrix,
# where features = voxels * seed based maps.
#
# -----------------------------------------------------------
# Code written by Marco Pagani
# Functional Neuroimaging Lab, IIT, Rovereto (ITA)
# Autism Center, CMI, New York (US)
# (2020)
# -----------------------------------------------------------


# edit this, path of nifti files 
feature_nifti_path=$PWD/01_features/

# edit this, output path of feature_etiology_matrix.txt
feature_txt_path=$PWD/02_features_for_clustering_txt/

# edit this, brainmask
mask=chd8_functional_template_mask_wo_cerebellum.nii.gz

# edit this, voxelsize for resampling
voxel_size=6



mkdir $feature_txt_path

3dresample \
	-dxyz $voxel_size $voxel_size $voxel_size \
	-prefix ${mask%.nii.gz}_resampled.nii.gz \
	-input $mask


for feature in $feature_nifti_path/*_group_cohens_d.nii.gz; do

        feature_name=$(basename $feature .nii.gz)

	echo $feature_name

	3dresample \
		-dxyz $voxel_size $voxel_size $voxel_size \
		-rmode Linear \
		-prefix $feature_txt_path/${feature_name}_resampled.nii.gz \
		-input $feature

	3dmaskdump \
		-mask ${mask%.nii.gz}_resampled.nii.gz \
		-noijk \
		-o $feature_txt_path/${feature_name}_resampled.txt \
		$feature_txt_path/${feature_name}_resampled.nii.gz

rm $feature_txt_path/${feature_name}_resampled.nii.gz

done



# this concatenates all features for each etiology

cd $feature_txt_path

mutations=(16p11 btbr cdkl5ht cdkl5ko chd8 cntnp2IIT en2 fmr1 IL6 lgdel90 mecp2 nlgn3ko nlgn3ki oxtr sgsh shank3b syn2 tsc2 trem2 ube3a)

for mutation in "${mutations[@]}"; do

	cat ${mutation}*.txt >> ${mutation}_all_features.txt

done



# this creates a feature*etiology matrix

paste -d' ' *_all_features.txt >> feature_etiology_matrix.txt

rm *_all_features.txt

rm *_resampled.txt

cd ..
