function FEATRun2MNI(BASE_PATH, BOLD_DIR, FEAT_DIR, SUBJECT_FSL, SUBJECT_FSL_RUN, FWHM, INPUT_FILES)

%% example_func to EPI_wholebrain_brain
% BET
commandc = ['bet2 ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'example_func.nii.gz') ' ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'example_func_brain.nii.gz') ' -m -f 0.2'];
[RuN o] = system(commandc);
if RuN ~= 0
    disp (['WARNING: bet2 error on ' FEAT_DIR]);
else
    disp (['SUCCESS: bet2 on ' FEAT_DIR]);
end

% Run ANTS
commandc = ['ANTS 3 -m MI[' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'EPI_wholebrain_brain.nii.gz') ',' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'example_func_brain.nii.gz') ',1,32] -i 0 -o ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'example_func_brain_2_EPI_wholebrain') '-'];
[RuN o] = system(commandc);
if RuN ~= 0
    disp (['WARNING: example_func to EPI_wholebrain_brain, ANTS on ' FEAT_DIR]);
else
    disp (['SUCCESS: example_func to EPI_wholebrain_brain, ANTS on ' FEAT_DIR]);
end

% Run WarpImageMultiTransform
commandc = ['WarpImageMultiTransform 3 ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'example_func_brain.nii.gz') ' ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'example_func_brain_2_EPI_wholebrain.nii.gz') ' -R ' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'EPI_wholebrain_brain.nii.gz') ' ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'example_func_brain_2_EPI_wholebrain-Affine.txt')];
[RuN o] = system(commandc);
if RuN ~= 0
    disp (['WARNING: example_func to EPI_wholebrain_brain, WarpImageMultiTransform  on ' FEAT_DIR]);
else
    disp (['SUCCESS: example_func to EPI_wholebrain_brain, WarpImageMultiTransform on ' FEAT_DIR]);
end

%% example_func to MNI
commandc = ['WarpImageMultiTransform 3 ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'example_func_brain.nii.gz') ' ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'example_func_brain_2_MNI.nii.gz') ' -R /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz ' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'MPRAGE-2-MNI152_T1_2mm_brain-CC-Warp.nii.gz') ' ' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'MPRAGE-2-MNI152_T1_2mm_brain-CC-Affine.txt') ' ' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'EPI_wholebrain_brain_2_MPRAGE-Affine.txt') ' ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'example_func_brain_2_EPI_wholebrain-Affine.txt')];
[RuN o] = system(commandc);
if RuN ~= 0
    disp (['WARNING: example_func to MNI, WarpImageMultiTransform on ' FEAT_DIR]);
else
    disp (['SUCCESS: example_func to MNI, WarpImageMultiTransform on ' FEAT_DIR]);
end

%% Now, iterate over the copes/varcopes
for i = 1:length(INPUT_FILES)
    INPUT_FILE = INPUT_FILES{i};
    INPUT_FILE_PREFIX = 'stats';
    INPUT_FILE_SUFFIX = '.nii.gz';
    
    % Run this
    commandc = ['WarpImageMultiTransform 3 ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, INPUT_FILE_PREFIX, [INPUT_FILE INPUT_FILE_SUFFIX]) ' ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, INPUT_FILE_PREFIX, [INPUT_FILE '.mni152' INPUT_FILE_SUFFIX]) ' -R /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz ' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'MPRAGE-2-MNI152_T1_2mm_brain-CC-Warp.nii.gz') ' ' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'MPRAGE-2-MNI152_T1_2mm_brain-CC-Affine.txt') ' ' fullfile(BASE_PATH, SUBJECT_FSL, 'Anatomy', 'EPI_wholebrain_brain_2_MPRAGE-Affine.txt') ' ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'example_func_brain_2_EPI_wholebrain-Affine.txt')];
    [RuN o] = system(commandc);
    if RuN ~= 0
        disp (['WARNING: ' INPUT_FILE ' to MNI, WarpImageMultiTransform on ' FEAT_DIR]);
    else
        disp (['SUCCESS: ' INPUT_FILE ' to MNI, WarpImageMultiTransform on ' FEAT_DIR]);
    end
end