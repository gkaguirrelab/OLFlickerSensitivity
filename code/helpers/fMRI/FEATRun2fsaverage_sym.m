function FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, FEAT_DIR, SUBJECT_FS, SUBJECT_FSL, SUBJECT_FSL_RUN, FWHM, INPUT_FILES)

%% Registration
commandc = ['bbregister --s ' SUBJECT_FS  ' --int ' fullfile(BASE_PATH, SUBJECT_FSL_RUN, 'Anatomy', 'EPI_wholebrain_brain.nii.gz') ' --feat ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR)];
[RuN o] = system(commandc);
if RuN ~= 0
    disp (['WARNING: bbregister error on ' FEAT_DIR]);
else
    disp (['SUCCESS: bbregister on ' FEAT_DIR]);
end

% Check registration
inputVal = 1;%GetWithDefault(' > Call tkregister2 to check registration?', 0);
if inputVal == 1
    commandc = ['tkregister2 --mov ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'example_func.nii.gz') ' --reg ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'reg', 'freesurfer', 'anat2exf.register.dat') ' --surf'];
    [RuN o] = system(commandc);
    if RuN ~= 0
        disp (['WARNING: tkregister2 error']);
    else
        disp (['SUCCESS: tkregister2']);
    end
elseif inputVal == 0
else
end

%% Iterate over runs
for i = 1:length(INPUT_FILES)
    INPUT_FILE = INPUT_FILES{i};
    INPUT_FILE_PREFIX = 'stats';
    INPUT_FILE_SUFFIX = '.nii.gz';
    
    %% Process the hemispheres
    hemis = {'lh' , 'rh'};
    for h = 1:length(hemis)
        hemi = hemis{h};
        
        %% mri_vol2surf
        inFile = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, INPUT_FILE_PREFIX, [INPUT_FILE INPUT_FILE_SUFFIX]);
        outFile = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, INPUT_FILE_PREFIX, [INPUT_FILE '.' hemi '.surf.' SUBJECT_FS '.mgh']);
        srcReg = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, 'reg', 'freesurfer', 'anat2exf.register.dat');
        commandc = ['mri_vol2surf --src ' inFile ' --srcreg ' srcReg ' --hemi ' hemi ' --projfrac 0.5 --noreshape --o ' outFile];
        [RuN o] = system(commandc);
        if RuN ~= 0
            disp (['WARNING: mri_vol2surf error on ' INPUT_FILE '/' hemi]);
        else
            disp (['SUCCESS: mri_vol2surf on ' INPUT_FILE '/' hemi]);
        end
        
        
        %% mri_surf2surf
        inFile = outFile;
        outFile = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIR, INPUT_FILE_PREFIX, [INPUT_FILE '.' hemi '.surf.fsaverage_sym.mgh']);
        switch hemi
            case 'lh'
                commandc = ['mri_surf2surf --srcsubject ' SUBJECT_FS ' --srcsurfreg fsaverage_sym.sphere.reg --trgsubject fsaverage_sym --trgsurfreg sphere.reg --hemi ' hemi ' --fwhm ' FWHM ' --cortex --sval ' inFile ' --tval ' outFile];
            case 'rh'
                commandc = ['mri_surf2surf --srcsubject ' SUBJECT_FS '/xhemi --srcsurfreg fsaverage_sym.sphere.reg --trgsubject fsaverage_sym --trgsurfreg sphere.reg --hemi lh --fwhm ' FWHM ' --cortex --sval ' inFile ' --tval ' outFile];
        end
        [RuN o] = system(commandc);
        if RuN ~= 0
            disp (['WARNING: mri_surf2surf error on ' INPUT_FILE '/' hemi]);
        else
            disp (['SUCCESS: mri_surf2surf on ' INPUT_FILE '/' hemi]);
        end
    end
end