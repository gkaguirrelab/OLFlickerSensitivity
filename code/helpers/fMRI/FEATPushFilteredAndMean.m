function FEATPushFilteredAndMean(session_dir,subject)
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
    stat_files = {'cope','varcope','tstat','zstat'};
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
%% Register functional to freesurfer anatomical
%progBar = ProgressBar(nruns, 'Registering functional runs to surface...');

% %% Project cope files to surface
% % use the bbreg_out_file registration file created above
%progBar = ProgressBar(nruns, 'Projecting stat files to surface...');
for r = 1:nruns
    
    cd(fullfile(session_dir,d{r}));
    % For each stat file (e.g. cope, tstat, zstat)
   system(['mri_vol2surf --src filtered_func_data.nii.gz --reg bbreg_example_func2orig.dat --hemi  lh --out  lh_surf_filtered_func_data.mgh  --projfrac 0.5']);
   system(['mri_vol2surf --src filtered_func_data.nii.gz --reg bbreg_example_func2orig.dat --hemi  rh --out  rh_surf_filtered_func_data.mgh  --projfrac 0.5']);
   
   system(['mri_vol2surf --src mean_func.nii.gz --reg bbreg_example_func2orig.dat --hemi  lh --out  lh_surf_mean_func.mgh  --projfrac 0.5']);
   system(['mri_vol2surf --src mean_func.nii.gz --reg bbreg_example_func2orig.dat --hemi  rh --out  rh_surf_mean_func.mgh  --projfrac 0.5']);
   
    
end
