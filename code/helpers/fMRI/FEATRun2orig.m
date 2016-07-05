function FEATRun2orig(BASE_PATH, BOLD_DIR, FEAT_DIR, SUBJECT_FS, SUBJECT_FSL, SUBJECT_FSL_RUN, FWHM, INPUT_FILES)
%
%% Registration
commandc = ['bbregister --s ' SUBJECT_FS  ' --int ' fullfile(BASE_PATH, SUBJECT_FSL_RUN, 'Anatomy', 'EPI_wholebrain_brain.nii.gz') ' --feat ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR)];

% Save out the command
dataPath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/helpers/fMRI/bbregister_list.txt';
fid = fopen(fullfile(dataPath), 'a');
fprintf(fid, '%s\n', commandc);
fclose(fid)

% [RuN o] = system(commandc);
% if RuN ~= 0
%     disp (['WARNING: bbregister error on ' FEAT_DIR]);
% else
%     disp (['SUCCESS: bbregister on ' FEAT_DIR]);
% end

% % Check registration
% inputVal = 1;%GetWithDefault(' > Call tkregister2 to check registration?', 0);
% if inputVal == 1
%     commandc = ['tkregister2 --mov ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'example_func.nii.gz') ' --reg ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'reg', 'freesurfer', 'anat2exf.register.dat') ' --surf'];
%     [RuN o] = system(commandc);
%     if RuN ~= 0
%         disp (['WARNING: tkregister2 error']);
%     else
%         disp (['SUCCESS: tkregister2']);
%     end
% elseif inputVal == 0
% else
% end
%
% commandc = ['mri_vol2vol --mov ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'example_func.nii.gz') ' --fstarg  --reg ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'reg', 'freesurfer', 'anat2exf.register.dat') ' --o ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'example_func.orig.nii.gz')];
% [RuN o] = system(commandc);
% if RuN ~= 0
%     disp (['WARNING: mri_vol2vol error on exf']);
% else
%     disp (['SUCCESS: mri_vol2vol on exf']);
% end

% %% Iterate over runs
% for i = 1:length(INPUT_FILES)
%     INPUT_FILE = INPUT_FILES{i};
%     INPUT_FILE_PREFIX = 'stats';
%     INPUT_FILE_SUFFIX = '.nii.gz';
%
%     %% mri_vol2vol
%     inFile = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, INPUT_FILE_PREFIX, [INPUT_FILE INPUT_FILE_SUFFIX]);
%     outFile = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, INPUT_FILE_PREFIX, [INPUT_FILE '.vol.orig.nii.gz']);
%     srcReg = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'reg', 'freesurfer', 'anat2exf.register.dat');
%     commandc = ['mri_vol2vol --mov ' inFile ' --fstarg  --reg ' srcReg ' --o ' outFile];
%     [RuN o] = system(commandc);
%     if RuN ~= 0
%         disp (['WARNING: mri_vol2vol error on ' INPUT_FILE]);
%     else
%         disp (['SUCCESS: mri_vol2vol on ' INPUT_FILE]);
%     end
%
% end