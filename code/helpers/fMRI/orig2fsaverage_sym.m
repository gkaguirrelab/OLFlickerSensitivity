function orig2fsaverage_sym(glmDirs, INPUT_FILE, FS_SUBJECT);
% Convert from orig vol to surf.

hemis = {'lh' , 'rh'};
for d = 1:length(glmDirs)
    % Extract the file to process
    inFile = fullfile(glmDirs{d}, analysisFile)
    for h = 1:length(hemis)
        hemi = hemis{h};
        
        %% mri_vol2surf
        outFile = fullfile(glmDirs, [INPUT_FILE '.' hemi '.surf.' SUBJECT_FS '.mgh']);
        commandc = ['mri_vol2surf --src ' inFile ' --srcsubject ' FS_SUBJECT ' --hemi ' hemi ' --projfrac 0.5 --noreshape --o ' outFile];
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