#!/bin/bash
#
# Make the LGN ROI, based on the Juelich Histological Atlas.See 
# https://cfn.upenn.edu/aguirre/wiki/private:making_lgn_roi for more 
# information.
#
# Code originally written by Ritobrato Datta.
#
# 9/24/14       spitschan       Adapted.

ROIDIR=$FSL_DIR/data/standard/roi
if [ ! -d $ROIDIR ];
then
    mkdir $ROIDIR
fi

fslmaths $FSL_DIR/data/atlases/Juelich/Juelich-maxprob-thr0-1mm.nii.gz -thr 103 -uthr 103 -bin $ROIDIR/lgn_MNI_Juelich_rh.nii.gz

fslmaths $FSL_DIR/data/atlases/Juelich/Juelich-maxprob-thr0-1mm.nii.gz -thr 104 -uthr 104 -bin $ROIDIR/lgn_MNI_Juelich_lh.nii.gz

if [ -f $ROIDIR/lgn_MNI_Juelich.nii.gz ];
then
   echo "File $ROIDIR/lgn_MNI_Juelich.nii.gz already exists. Not overwriting it. Delete manually if needed."
else
    fslmaths $ROIDIR/lgn_MNI_Juelich_rh.nii.gz -add $ROIDIR/lgn_MNI_Juelich_lh.nii.gz $ROIDIR/lgn_MNI_Juelich.nii.gz
fi


