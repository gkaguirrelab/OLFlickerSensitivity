function FEATRun2MNI(BASE_PATH, SUBJECT_FSL)

%% EPI_wholebrain_brain to MPRAGE
% Run ANTS
commandc = ['ANTS 3 -m MI[' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'MPRAGE_brain.nii.gz') ',' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'EPI_wholebrain_brain.nii.gz') ',1,4] --use-Histogram-Matching --number-of-affine-iterations 10000x10000x10000x10000x10000 --rigid-affine true --affine-gradient-descent-option 0.5x0.95x1.e-4x1.e-4  --MI-option 32x16000 -o ' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'EPI_wholebrain_brain_2_MPRAGE') '- -i 0x0x0 -v -t SyN[0.5]'];
[RuN o] = system(commandc);
if RuN ~= 0
    disp('WARNING: EPI_wholebrain_brain to MPRAGE, ANTS');
else
    disp('SUCCESS: EPI_wholebrain_brain to MPRAGE, ANTS');
end

% Run WarpImageMultiTransform
commandc = ['WarpImageMultiTransform 3 ' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'EPI_wholebrain_brain.nii.gz') ' ' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'EPI_wholebrain_brain_2_MPRAGE.nii.gz') ' -R ' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'MPRAGE_brain.nii.gz') ' ' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'EPI_wholebrain_brain_2_MPRAGE-Affine.txt')];
[RuN o] = system(commandc);
if RuN ~= 0
    disp('WARNING: EPI_wholebrain_brain to MPRAGE, WarpImageMultiTransform');
else
    disp('SUCCESS: EPI_wholebrain_brain to MPRAGE, WarpImageMultiTransform');
end


%% MPRAGE to MNI
% Run ANTS
commandc = ['ANTS 3 -m CC[/usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz,' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'MPRAGE_brain.nii.gz') ',1,2] -i 100x100x10 -o ' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'MPRAGE-2-MNI152_T1_2mm_brain-CC') '- -t SyN[0.8] -r Gauss[3,0]'];
[RuN o] = system(commandc);
if RuN ~= 0
    disp('WARNING: MPRAGE to MNI, ANTS');
else
    disp('SUCCESS: MPRAGE to MNI, ANTS');
end

% Run WarpImageMultiTransform
commandc = ['WarpImageMultiTransform 3 ' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'MPRAGE_brain.nii.gz') ' ' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'MPRAGE_brain_2_MNI-CC.nii.gz') ' -R /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz ' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'MPRAGE-2-MNI152_T1_2mm_brain-CC-Warp.nii.gz') ' ' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'MPRAGE-2-MNI152_T1_2mm_brain-CC-Affine.txt')];
[RuN o] = system(commandc);
if RuN ~= 0
    disp('WARNING: MPRAGE to MNI, WarpImageMultiTransform');
else
    disp('SUCCESS: MPRAGE to MNI, WarpImageMultiTransform');
end
