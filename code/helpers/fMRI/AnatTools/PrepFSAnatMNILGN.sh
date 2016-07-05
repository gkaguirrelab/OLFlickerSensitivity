#!/bin/bash
#
# Warp a subject's FreeSurfer anatomy to MNI and extract LGN ROI.
#
# Code originally written by Ritobrato Datta.
#
# 9/24/14       spitschan       Adapted.

# --- Check input command ---
if [[ ( $# -ge 2 ) || ( $# -le 0 ) ]]; then
cat << EOF
USAGE: `basename $0` FS_SUBJ
EOF
        exit 1
fi

FS_SUBJ=$1

#### convert the freesurfer anatomical image (brain.mgz) to nii and save it in the working directory

mri_convert $SUBJECTS_DIR/$FS_SUBJ/mri/brain.mgz $SUBJECTS_DIR/$FS_SUBJ/mri/brain.nii.gz

#### check if we have an ROI dir in the FS directory
ROIDIR=$SUBJECTS_DIR/$FS_SUBJ/mri/roi
if [ ! -d $ROIDIR ];
then
    mkdir $ROIDIR
fi

#### Run ANTS non-linear registration to calculate transforms and warps so that brain.nii.gz can be registered to MNI space

/usr/bin/ANTS 3 -m CC[$FSL_DIR/data/standard/MNI152_T1_1mm_brain.nii.gz,$SUBJECTS_DIR/$FS_SUBJ/mri/brain.nii.gz,1,2] -i 100x100x10 -o $SUBJECTS_DIR/$FS_SUBJ/mri/brain-2-MNI-ANTS-CC- -t SyN[0.8] -r Gauss[3,0]

#### Apply the transforms calculated in the previous steps to register brain to MNI space

WarpImageMultiTransform 3 $SUBJECTS_DIR/$FS_SUBJ/mri/brain.nii.gz $SUBJECTS_DIR/$FS_SUBJ/mri/brain-2-MNI-CC.nii.gz -R $FSL_DIR/data/standard/MNI152_T1_1mm_brain.nii.gz $SUBJECTS_DIR/$FS_SUBJ/mri/brain-2-MNI-ANTS-CC-Warp.nii.gz $SUBJECTS_DIR/$FS_SUBJ/mri/brain-2-MNI-ANTS-CC-Affine.txt

#### Apply the inverse-transforms to register LGN ROI in MNI space to native subject freesurfer anatomy space

WarpImageMultiTransform 3 $FSL_DIR/data/standard/roi/lgn_MNI_Juelich.nii.gz $ROIDIR/lgn-native.nii.gz -R $SUBJECTS_DIR/$FS_SUBJ/mri/brain.nii.gz -i $SUBJECTS_DIR/$FS_SUBJ/mri/brain-2-MNI-ANTS-CC-Affine.txt $SUBJECTS_DIR/$FS_SUBJ/mri/brain-2-MNI-ANTS-CC-InverseWarp.nii.gz

#### binarize the LGN mask in native subject freesurfer anatomy space

mri_binarize --i $ROIDIR/lgn-native.nii.gz --min 0.1 --binval 1 --o $ROIDIR/lgn-native-bin.nii.gz
