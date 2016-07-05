function run = AssembleTSData(session_dir)
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

% Get the mask
cd /Data/Imaging/Protocols/MRLuxotonic/Subjects/G092014A/BOLD/Localizer/MRInteraction_IsochromaticLocalizer_B.feat
v1_lh = MRIread('lh_surf_v1_mask.mgh');
v1_rh = MRIread('rh_surf_v1_mask.mgh');
v1_lh_mask = find(v1_lh.vol);
v1_rh_mask = find(v1_rh.vol);

for r = 1:nruns
    %%
    cd(fullfile(session_dir,d{r}));
    run{r}.name = d{r};
    

    run{r}.fdata_lh = MRIread('lh_surf_filtered_func_data.mgh')
    run{r}.fmean_lh = MRIread('lh_surf_mean_func.mgh')
    
    run{r}.fdata_rh = MRIread('rh_surf_filtered_func_data.mgh')
    run{r}.fmean_rh = MRIread('rh_surf_mean_func.mgh')
    
    run{r}.v1_fdata_lh = squeeze(run{r}.fdata_lh.vol(1, v1_lh_mask, 1, :));
    run{r}.v1_fmean_lh = squeeze(run{r}.fmean_lh.vol(1, v1_lh_mask, 1, :));
    
    run{r}.v1_fdata_rh = squeeze(run{r}.fdata_rh.vol(1, v1_rh_mask, 1, :));
    run{r}.v1_fmean_rh = squeeze(run{r}.fmean_rh.vol(1, v1_rh_mask, 1, :));
    
    run{r}.v1_ts_lh = (run{r}.v1_fdata_lh-repmat(run{r}.v1_fmean_lh', 1, size(run{r}.v1_fdata_lh, 2)))./repmat(run{r}.v1_fmean_lh', 1, size(run{r}.v1_fdata_lh, 2));
    run{r}.v1_ts_rh = (run{r}.v1_fdata_rh-repmat(run{r}.v1_fmean_rh', 1, size(run{r}.v1_fdata_rh, 2)))./repmat(run{r}.v1_fmean_rh', 1, size(run{r}.v1_fdata_rh, 2));
    
end

[run{1}.v1_ts_lh run{2}.v1_ts_lh run{3}.v1_ts_lh run{4}.v1_ts_lh run{5}.v1_ts_lh]


iso_ts = mean([mean([run{1}.v1_ts_lh ; run{1}.v1_ts_rh]) ; mean([run{2}.v1_ts_lh ; run{2}.v1_ts_rh]) ; mean([run{3}.v1_ts_lh ; run{3}.v1_ts_rh]) ; mean([run{5}.v1_ts_lh ; run{5}.v1_ts_rh]) ; mean([run{6}.v1_ts_lh ; run{6}.v1_ts_rh])]);
lms_ts = mean([mean([run{7}.v1_ts_lh ; run{7}.v1_ts_rh]) ; mean([run{8}.v1_ts_lh ; run{8}.v1_ts_rh]) ; mean([run{9}.v1_ts_lh ; run{9}.v1_ts_rh]) ; mean([run{10}.v1_ts_lh ; run{10}.v1_ts_rh]) ; mean([run{11}.v1_ts_lh ; run{11}.v1_ts_rh]) ; mean([run{12}.v1_ts_lh ; run{12}.v1_ts_rh])]);
mel_ts = mean([mean([run{13}.v1_ts_lh ; run{13}.v1_ts_rh]) ; mean([run{14}.v1_ts_lh ; run{14}.v1_ts_rh]) ; mean([run{15}.v1_ts_lh ; run{15}.v1_ts_rh]) ; mean([run{16}.v1_ts_lh ; run{16}.v1_ts_rh]) ; mean([run{17}.v1_ts_lh ; run{17}.v1_ts_rh]) ; mean([run{18}.v1_ts_lh ; run{18}.v1_ts_rh])]);

subplot(4, 1, 1);
plot([0:0.5:155]*2, square([0:0.5:155]*2*2*pi*1/48), '--k', 'LineWidth', 2)
xlim([0 312]); ylim([-1.1 1.1]);

subplot(4, 1, 2);
plot([0:1:155]*2, iso_ts*100, '-k', 'LineWidth', 2); 
xlim([0 312]); ylim([-0.6 0.6]); xlabel('Time [s]'); ylabel('BOLD Signal change [%]');
title('Isochromatic');

subplot(4, 1, 3);
plot([0:1:155]*2, lms_ts*100, '-r', 'LineWidth', 2);
xlim([0 312]); ylim([-0.6 0.6]); xlabel('Time [s]'); ylabel('BOLD Signal change [%]');
title('LMS');

subplot(4, 1, 4);
plot([0:1:155]*2, mel_ts*100, '-b', 'LineWidth', 2); 
xlim([0 312]); ylim([-0.6 0.6]); xlabel('Time [s]'); ylabel('BOLD Signal change [%]');
title('Melanopsin');
