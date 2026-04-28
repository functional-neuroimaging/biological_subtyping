# this code calculates the spatial overlap between brain maps
brainmask=Schaefer2018_400Parcels_plus_subcortex_cerebellum_MNI152_2mm_bin.nii.gz

cluster_path=/data3/autism_center/projects/marco/clustering_autism/27c_discovery_vs_replication_mouse_rois_metaregion/15_mean_regressed_discovery_replication_togheter/04_yeo_components/00_mean_regressed_global_connectivity_maps/

yeo_path=/data3/autism_center/projects/marco/clustering_autism/27c_discovery_vs_replication_mouse_rois_metaregion/15_mean_regressed_discovery_replication_togheter/04_yeo_components/01_original_yeo_cognitive_maps/


# thresholds
cluster_threshold=0.2
yeo_threshold=3


# threshold and binarise maps 
for img in $cluster_path/*.nii.gz; do
	fslmaths $img -thr $cluster_threshold -bin ${img%.nii.gz}_thresholded.nii.gz
done

for img in $yeo_path/*.nii.gz; do
	fslmaths $img -thr $yeo_threshold -bin ${img%.nii.gz}_thresholded.nii.gz
done


# calculate conjunction maps
for cluster_map in ${cluster_path}/*_thresholded.nii.gz; do

	cluster_map_basename=`basename ${cluster_map} .nii.gz`
	
	for yeo_map in ${yeo_path}/*_thresholded.nii.gz; do

		yeo_map_basename=`basename ${yeo_map} .nii.gz`

		fslmaths \
			$cluster_map \
			-mul $yeo_map \
			${cluster_map_basename}_${yeo_map_basename}.nii.gz
			
			cluster_map_vol_mm3=`fslstats ${cluster_map} -V | awk '{print $2}'` # volume in mm3
			cluster_map_vol_vox=`fslstats ${cluster_map} -V | awk '{print $1}'` # volume in voxel	
			
			yeo_map_vol_mm3=`fslstats ${yeo_map} -V | awk '{print $2}'` # volume in mm3
			yeo_map_vol_vox=`fslstats ${yeo_map} -V | awk '{print $1}'` # volume in voxel
			
			overlap_vol_mm3=`fslstats ${cluster_map_basename}_${yeo_map_basename}.nii.gz -V | awk '{print $2}'` # volume in mm3
			overlap_vol_vox=`fslstats ${cluster_map_basename}_${yeo_map_basename}.nii.gz -V | awk '{print $1}'` # volume in voxel	
			
			echo "${cluster_map_basename}_${yeo_map_basename} $cluster_map_vol_vox $yeo_map_vol_vox $overlap_vol_vox" >> overlap_volume.txt

			rm ${cluster_map_basename}_${yeo_map_basename}.nii.gz

	done
done

rm $cluster_path/*_thresholded.nii.gz
rm $yeo_path/*_thresholded.nii.gz
