function FEATRegisterToFSAnatLinear(session_dir, subjID)

SUBJECTS_DIR = getenv('SUBJECTS_DIR');
FSL_DIR = getenv('FSL_DIR');
stat_files = {'cope' 'varcope' 'zstat' 'tstat'};

hemi = {'lh', 'rh'};

%% Find feat directories in the session directory
d = listdir(fullfile(session_dir,'*.feat'),'dirs');
nruns = length(d);
disp(['found ' num2str(nruns) ' feat directories']);
%% Register functional to freesurfer anatomical
%progBar = ProgressBar(nruns, 'Registering functional runs to surface...');
mincost = nan(nruns,1);
for r = 1:nruns
    cd(fullfile(session_dir, d{r}));
    
    % Use bbregister to register slab scout image (example_func.nii.gz) to freesurfer anatomy (G042514A-TTFMRFlickerY) and write the registered slab scout image (example_func-2-FS-Anat.nii.gz)
    [s, o] = system(['bbregister --s ' subjID ' --bold --mov example_func.nii.gz --init-fsl --reg example_func-2-FS-Anat.dat --o example_func-2-FS-Anat.nii.gz']);
    disp(o);
    
%     % Binarize the registered slab scout image (example_func-2-FS-Anat.nii.gz) to create a binary mask (exf_mask.nii.gz)
%     [s, o] = system(['mri_binarize --i example_func-2-FS-Anat.nii.gz --min 0.1 --binval 1 --o exf_mask.nii.gz']);
%     disp(o);
%     
%     % Apply the slab mask (exf_mask.nii.gz) to brain.nii.gz create a 'slab' Anatomy (slab-brain.nii.gz)
%     [s, o] = system(['mri_mask  ' fullfile(SUBJECTS_DIR, subjID, 'mri', 'brain.nii.gz') ' exf_mask.nii.gz slab-brain.nii.gz']);
%     disp(o);
%     
%     % binarize the  'slab' Anatomy (slab-brain.nii.gz) to create a binary slab Anatomy mask (slab-brain-exf_mask.nii.gz)
%     [s, o] = system(['mri_binarize --i slab-brain.nii.gz --min 0.1 --binval 1 --o slab-brain-exf_mask.nii.gz']);
%     disp(o);
%     
%     % apply the binary slab Anatomy mask to the registered slab image to create a masked registered slab image
%     [s, o] = system(['mri_mask example_func-2-FS-Anat.nii.gz slab-brain-exf_mask.nii.gz masked-example_func-2-FS-Anat.nii.gz']);
%     disp(o);
%     
%     % Use ANTS non-linear registration to coregister 'masked-example_func-2-FS-Anat.nii.gz' to 'slab' Anatomy
%     [s, o] = system(['ANTS 3 -m CC[slab-brain.nii.gz,masked-example_func-2-FS-Anat.nii.gz,1,2] -o ab']);
%     disp(o);
%     
%     % Apply the affine transforms and the non-linear warps to write the final masked registered slab image (masked-example_func-2-FS-Anat-bbr.nii.gz)
%     [s, o] = system(['WarpImageMultiTransform 3 masked-example_func-2-FS-Anat.nii.gz masked-example_func-2-FS-Anat-bbr.nii.gz -R slab-brain.nii.gz abWarp.nii.gz abAffine.txt']);
%     disp(o);
%     
%     % Apply the transforms calculated in the previous steps to register slab brain to MNI space
%     [s, o] = system(['WarpImageMultiTransform 3 slab-brain.nii.gz slab-brain-2-MNI-CC.nii.gz -R ' fullfile(FSL_DIR, 'data', 'standard', 'MNI152_T1_1mm_brain.nii.gz') ' ' fullfile(SUBJECTS_DIR, subjID, 'mri', 'brain-2-MNI-ANTS-CC-Warp.nii.gz') ' '  fullfile(SUBJECTS_DIR, subjID, 'mri', 'brain-2-MNI-ANTS-CC-Affine.txt')]);
%     disp(o);
    
%     for s = 1:length(stat_files)
%         % Find the number of stat files in each feat directory
%         f = listdir(fullfile(session_dir,d{r},'stats',[stat_files{s} '*']),'files');
%         nfiles = length(f);
%         for n = 1:nfiles
%             
%             [~, ft] = fileparts(f{n});
%             [~, ft] = fileparts(ft);
%             
%             % register the statmaps to freesurfer anatomy
%             [s, o] = system(['mri_vol2vol --mov ' fullfile(session_dir, d{r}, 'stats', [ft '.nii.gz']) ' --reg example_func-2-FS-Anat.dat --targ slab-brain.nii.gz --o ' fullfile(session_dir, d{r}, 'stats', [ft '-2-FS-Anat.nii.gz'])]);
%             disp(o);
%             
%             [s, o] = system(['WarpImageMultiTransform 3 ' fullfile(session_dir, d{r}, 'stats', [ft '-2-FS-Anat.nii.gz']) ' ' fullfile(session_dir, d{r}, 'stats', [ft '-2-FS-Anat-bbr.nii.gz'])  ' -R slab-brain.nii.gz abWarp.nii.gz abAffine.txt']);
%             disp(o);
%             
%             % move to surface
%             for h = 1:length(hemi)
%                 % Project cope files to surface, for each hemisphere
%                 %% Unsmoothed - native
%                 [s,o] = system(['mri_vol2surf --regheader ' subjID ' --src ' fullfile(session_dir, d{r}, 'stats', [ft '-2-FS-Anat-bbr.nii.gz']) ' --hemi ' hemi{h} ...
%                     ' --out ' fullfile(session_dir, d{r}, 'stats', [ft '.bbr.' hemi{h} '.mgh']) ' --projfrac 0.5']);
%                 disp(o);
%                 %% Unsmooth - fsaverage_sym
%                 if strcmp(hemi{h}, 'rh')
%                     [s,o] = system(['mri_surf2surf --hemi lh --trgsurfreg sphere.reg --srcsurfreg fsaverage_sym.sphere.reg --srcsubject ' subjID '/xhemi --srcsurfval ' ...
%                         fullfile(session_dir, d{r}, 'stats', [ft '.bbr.' hemi{h} '.mgh']) ' --trgsubject fsaverage_sym --trgsurfval ' ...
%                         fullfile(session_dir, d{r}, 'stats', [ft '.bbr.' hemi{h} '.sym.mgh']) ]);
%                     disp(o);
%                 else
%                     [s,o] = system(['mri_surf2surf --hemi lh --trgsurfreg sphere.reg --srcsurfreg fsaverage_sym.sphere.reg --srcsubject ' subjID ' --srcsurfval ' ...
%                         fullfile(session_dir, d{r}, 'stats', [ft '.bbr.' hemi{h} '.mgh']) ' --trgsubject fsaverage_sym --trgsurfval ' ...
%                         fullfile(session_dir, d{r}, 'stats', [ft '.bbr.' hemi{h} '.sym.mgh']) ]);
%                     disp(o);
%                 end
%             end
%             
%         end
    end
%     
    f = {'filtered_func_data' 'mean_func'};
    for n = 1:length(f)
        [~, ft] = fileparts(f{n});
        %register the statmaps to freesurfer anatomy
%         [s, o] = system(['mri_vol2vol --mov ' fullfile(session_dir, d{r}, [ft '.nii.gz']) ' --reg example_func-2-FS-Anat.dat --targ slab-brain.nii.gz --o ' fullfile(session_dir, d{r}, [ft '-2-FS-Anat.nii.gz'])]);
%         disp(o);
%         
%         [s, o] = system(['WarpImageMultiTransform 3 ' fullfile(session_dir, d{r}, [ft '-2-FS-Anat.nii.gz']) ' ' fullfile(session_dir, d{r}, [ft '-2-FS-Anat-bbr.nii.gz'])  ' -R slab-brain.nii.gz abWarp.nii.gz abAffine.txt']);
%         disp(o);
%         
        %move to surface
        for h = 1:length(hemi)
            %Project cope files to surface, for each hemisphere
            % Unsmoothed - native
            [s,o] = system(['mri_vol2surf --regheader ' subjID ' --src ' fullfile(session_dir, d{r}, [ft '-2-FS-Anat.nii.gz']) ' --hemi ' hemi{h} ...
                ' --out ' fullfile(session_dir, d{r}, [ft '.bbr.' hemi{h} '.mgh']) ' --projfrac 0.5']);
            disp(o);
            % Unsmooth - fsaverage_sym
            if strcmp(hemi{h}, 'rh')
                [s,o] = system(['mri_surf2surf --hemi lh --trgsurfreg sphere.reg --srcsurfreg fsaverage_sym.sphere.reg --srcsubject ' subjID '/xhemi --srcsurfval ' ...
                    fullfile(session_dir, d{r}, [ft '.bbr.' hemi{h} '.mgh']) ' --trgsubject fsaverage_sym --trgsurfval ' ...
                    fullfile(session_dir, d{r}, [ft '.bbr.' hemi{h} '.sym.mgh']) ]);
                disp(o);
            else
                [s,o] = system(['mri_surf2surf --hemi lh --trgsurfreg sphere.reg --srcsurfreg fsaverage_sym.sphere.reg --srcsubject ' subjID ' --srcsurfval ' ...
                    fullfile(session_dir, d{r}, [ft '.bbr.' hemi{h} '.mgh']) ' --trgsubject fsaverage_sym --trgsurfval ' ...
                    fullfile(session_dir, d{r}, [ft '.bbr.' hemi{h} '.sym.mgh']) ]);
                disp(o);
            end
        end
    end
end

