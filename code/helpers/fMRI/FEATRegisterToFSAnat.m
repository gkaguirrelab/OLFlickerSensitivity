function FEATRegisterToFSAnat(check,adjust,session_dir,subject,func,overwrite_standard)
%   Registers functional runs in feat to freesurfer anatomical
%
%   Usage:
%   register_functional_feat(session_dir,subject,func,SUBJECTS_DIR)
%
%   e.g. register_functional_feat(1,0,'~/data/ASB'),'ASB')
%
%   Defaults:
%   check = 0; do not check registration
%   adjust = 0; do not manually adjust registration
%   session_dir = NO DEFAULT, must define
%   subject = NO DEFAULT, must define
%   func = 'filtered_func_data'
%   hemi = {'lh','rh'};
%
%   Outputs:
%   The function will display the minimum cost value of registraion, for
%   each feat direcotry
%
%   The function will also create the following files:
%   # = number, for each stat file (e.g. cope1, tstat1, zstat1)
%   m = hemisphere, either l - left, or r - right
%   1) mh_surf_cope#.nii.gz; cope, unsmoothed
%   2) mh_smooth_surf_cope#.nii.gz; cope, smoothed on surface, 5mm kernel
%   3) mh_surf_tstat#.nii.gz; tstat, unsmoothed
%   4) mh_smooth_surf_tstat#.nii.gz; tstat, smoothed on surface, 5mm kernel
%   5) mh_surf_zstat#.nii.gz; zstat, unsmoothed
%   6) mh_smooth_surf_zstat#.nii.gz; zstat, smoothed on surface, 5mm kernel
%
%   Written by Andrew S Bock Sept 2014
%% Set default variables
if ~exist('check','var')
    check = 0; % check registration
end
if ~exist('adjust','var')
    adjust = 0; % manually adjust registration
end
if ~exist('session_dir','var')
    error('"session_dir" not defined')
end
if ~exist('subject','var')
    error('"subject" not defined')
end
if ~exist('func','var')
    func = 'example_func'; % functional data file
end
if ~exist('hemi','var')
    hemi = {'lh','rh'};
end
if ~exist('overwrite_standard')
    overwrite_standard = false;
end
if ~exist('stat_files','var')
    stat_files = {''};
end
%% Set up FSL variables
fsl_path = '/usr/local/fsl/';
setenv('FSLDIR',fsl_path)
setenv('FSLOUTPUTTYPE','NIFTI_GZ')
curpath = getenv('PATH');
setenv('PATH',sprintf('%s:%s',fullfile(fsl_path,'bin'),curpath));
%% Find feat directories in the session directory
d = listdir(fullfile(session_dir,'*.feat'),'dirs');
nruns = length(d);
disp(['found ' num2str(nruns) ' feat directories']);
% %% Register functional to freesurfer anatomical
% %progBar = ProgressBar(nruns, 'Registering functional runs to surface...');
% mincost = nan(nruns,1);
% for r = 1:nruns
%     filefor_reg = fullfile(session_dir,d{r},[func '.nii.gz']); % Functional file for bbregister
%     bbreg_out_file = fullfile(session_dir,d{r},'bbreg_example_func2orig.dat'); % name registration file
%     [~, bbreg_out_filename] = fileparts(bbreg_out_file);
%     % Register functional volume to anatomical volume using bbregister
%     ['bbregister --s ' subject ' --mov ' filefor_reg ' --reg ' bbreg_out_file ' --init-fsl --bold']
%     %[s, o] = system(['bbregister --s ' subject ' --mov ' filefor_reg ' --int /Data/Imaging/Protocols/TTFMRFlickerY/Subjects/G042514A/Anatomy/EPI_wholebrain_brain.nii.gz' ' --reg ' bbreg_out_file ' --init-fsl --bold']);
%     disp(o);
%     if check % Check the registration
%         ['tkregister2 --mov ' filefor_reg ' --reg ' bbreg_out_file ' --surf']
%         [s, o] = system(['tkregister2 --mov ' filefor_reg ' --reg ' bbreg_out_file ' --surf']);
%         disp(o);
%     end
%     if adjust % reiterate following manual adjustment
%         [s, o] = system(['bbregister --s ' subject ' --mov ' filefor_reg ' --reg ' ...
%             bbreg_out_file ' --init-reg ' bbreg_out_file ' --t2']);
%         disp(o);
%         [s, o] = system(['tkregister2 --mov ' filefor_reg ' --reg ' bbreg_out_file ' --surf']);
%         disp(o);
%     end
%     load(fullfile(session_dir,d{r},'bbreg_example_func2orig.dat.mincost'));
%     mincost(r) = bbreg_example_func2orig_dat(1);
%     clear bbreg_dat
% end
% %% Display the results of registration
% disp('The min cost values of registration for each feat directory are:')
% disp(num2str(mincost));
% 
% %% Ask if we want to replace the standard.nii.gz in the FSL folder with orig.
% if overwrite_standard
%     %% First, let's see if there's an .nii.gz image of orig for that subject. If not, make it.
%     origPath = fullfile(getenv('SUBJECTS_DIR'), subject, 'mri');
%     if exist(fullfile(origPath, 'orig.nii.gz'), 'file')
%         remakeOrig = GetWithDefault('orig.nii.gz already exists, regenerate?', 1);
%     else
%         remakeOrig = true;
%     end
%     
%     % Now, call orig
%     if remakeOrig
%         [s, o] = system(['mri_convert -i ' fullfile(origPath, 'orig.mgz') ' -o ' fullfile(origPath, 'orig.nii.gz')]);
%         [s, o] = system(['mri_convert -i ' fullfile(origPath, 'brain.mgz') ' -o ' fullfile(origPath, 'brain.nii.gz')]);
%     end
%     
%     if s == 0
%         fprintf('**************************************\n');
%         fprintf('orig conversion successful\n');
%         fprintf('**************************************\n');
%         disp(o);
%     end
%     
%     %% Second, produce an FSL friendly registration matrix.
%     [s, o] = system(['tkregister2 --noedit --mov ' filefor_reg ' --reg ' bbreg_out_file ' --fslregout ' fullfile(session_dir,d{r},'bbreg_example_func2orig.mat')]);
%     
%     if s == 0
%         fprintf('**************************************\n');
%         fprintf('bbreg conversion successful\n');
%         fprintf('**************************************\n');
%         disp(o);
%     end
%     
%     %% Third, ask if 'standard' should be overwritten
%     overwrite_standard = GetWithDefault('Overwrite standard.nii.gz and corresponding registration matrix?', 1);
%     if overwrite_standard
%         % First, make back-up copies of all files
%         fprintf('> Making a back-up copy ... ');
%         copyfile(fullfile(session_dir,d{r}, 'reg'), fullfile(session_dir,d{r}, 'reg.old'));
%         fprintf('done.\n');
%         
%         % Replacing files
%         movefile(fullfile(session_dir,d{r},'bbreg_example_func2orig.mat'), fullfile(session_dir,d{r},'reg', 'example_func2standard.mat'));
%         movefile(fullfile(origPath, 'brain.nii.gz'), fullfile(session_dir,d{r},'reg', 'standard.nii.gz'));
%     end
%     
% end


% %% Project cope files to surface
% % use the bbreg_out_file registration file created above
%progBar = ProgressBar(nruns, 'Projecting stat files to surface...');
for r = 1:nruns
    % For each stat file (e.g. cope, tstat, zstat)
%     for s = 1:length(stat_files)
%         % Find the number of stat files in each feat directory
%         f = listdir(fullfile(session_dir,d{r},'stats',[stat_files{s} '*']),'files');
%         nfiles = length(f);
%         for n = 1:nfiles
%             cd(fullfile(session_dir,d{r},'stats'));
%             % Define registration file
%             bbreg_out_file = fullfile(session_dir,d{r},'example_func-2-FS-Anat.dat');
%             
%             [~, ft] = fileparts(f{n});
%             [~, ft] = fileparts(ft);
%             [s, o] = system(['mri_vol2vol --mov ' ft '.nii.gz --reg ' bbreg_out_file ' --fstarg --o ' ft '_orig.nii.gz']);
%             disp(o);
%             for h = 1:length(hemi)
%                 % Project cope files to surface, for each hemisphere
%                 %% Unsmoothed - native
%                 [s,o] = system(['mri_vol2surf --src ' ft '.nii.gz --reg ' bbreg_out_file ' --hemi ' hemi{h} ...
%                     ' --out ' ft '_surf_' hemi{h} '.mgh --projfrac 0.5']);
%                 disp(o);
%                 %% Unsmooth - fsaverage_sym
%                 [s,o] = system(['mri_surf2surf --hemi ' hemi{h} ' --srcsubject ' subject ' --srcsurfval ' ...
%                     ft '_surf_' hemi{h} '.mgh --trgsubject fsaverage_sym --trgsurfval ' ...
%                     ft '_surf_' hemi{h} '_fsaverage_sym.mgh' ]);
%                 disp(o);
%                 %% Smoothed - native
%                 %[s,o] = system(['mri_vol2surf --src ' ft '.nii.gz --reg ' bbreg_out_file ' --hemi ' hemi{h} ...
%                 %    ' --surf-fwhm 5 --out  ' ft '_surf_' hemi{h} '_smooth.mgh --projfrac 0.5']);
%                 %disp(o);
%                 %% Smoothed - fsaverage_sym
%                 %[s,o] = system(['mri_surf2surf --hemi ' hemi{h} ' --srcsubject ' subject ' --srcsurfval ' ...
%                 %    ft '_surf_' hemi{h} '_smooth.mgh --trgsubject fsaverage_sym --trgsurfval ' ...
%                 %    ft '_surf_' hemi{h} '_fsaverage_sym_smooth.mgh']);
%                 %disp(o);
%             end
%         end
%         
%     end
    
    %% Filtered func & mean func
    cd ..
    
    f = {'filtered_func_data' 'mean_func'};
    for n = 1:length(f)
        [~, ft] = fileparts(f{n});
        
        [s, o] = system(['mri_vol2vol --mov ' ft '.nii.gz --reg ' bbreg_out_file ' --fstarg --o ' ft '_orig.nii.gz']);
        disp(o);
           for h = 1:length(hemi)
                % Project cope files to surface, for each hemisphere
                %% Unsmoothed - native
                [s,o] = system(['mri_vol2surf --src ' ft '.nii.gz --reg ' bbreg_out_file ' --hemi ' hemi{h} ...
                    ' --out ' ft '_surf_' hemi{h} '.mgh --projfrac 0.5']);
                disp(o);
                %% Unsmooth - fsaverage_sym
                [s,o] = system(['mri_surf2surf --hemi ' hemi{h} ' --srcsubject ' subject ' --srcsurfval ' ...
                    ft '_surf_' hemi{h} '.mgh --trgsubject fsaverage_sym --trgsurfval ' ...
                    ft '_surf_' hemi{h} '_fsaverage_sym.mgh' ]);
                disp(o);
                %% Smoothed - native
                %[s,o] = system(['mri_vol2surf --src ' ft '.nii.gz --reg ' bbreg_out_file ' --hemi ' hemi{h} ...
                %    ' --surf-fwhm 5 --out  ' ft '_surf_' hemi{h} '_smooth.mgh --projfrac 0.5']);
                %disp(o);
                %% Smoothed - fsaverage_sym
                %[s,o] = system(['mri_surf2surf --hemi ' hemi{h} ' --srcsubject ' subject ' --srcsurfval ' ...
                %    ft '_surf_' hemi{h} '_smooth.mgh --trgsubject fsaverage_sym --trgsurfval ' ...
                %    ft '_surf_' hemi{h} '_fsaverage_sym_smooth.mgh']);
                %disp(o);
            end
    end
end
