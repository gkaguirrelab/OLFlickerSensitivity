
%FEATRegisterToFSAnat(0, 0, pwd,'G092014A-MRLuxotonic')
function [t, cyc_avg] = AssembleTSDataVol(fsSubj, session_dirs, direction, theFig, nPlots, plotInd, masks)
%   Registers functional runs in feat to freesurfer anatomical
%
%   Usage:
%   register_functional_feat(session_dirs,subject,func,SUBJECTS_DIR)
%
%   e.g. register_functional_feat(1,0,'~/data/ASB'),'ASB')
%
%   Defaults:
%   check = 0; do not check registration
%   adjust = 0; do not manually adjust registration
%   session_dirs = NO DEFAULT, must define
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

%close all;
trSecs = 2;

%% Set up FSL variables
fsl_path = '/usr/local/fsl/';
setenv('FSLDIR',fsl_path)
setenv('FSLOUTPUTTYPE','NIFTI_GZ')
curpath = getenv('PATH');
setenv('PATH',sprintf('%s:%s',fullfile(fsl_path,'bin'),curpath));
%% Find feat directories in the session directory

d = [];
for i = 1:length(session_dirs)
    d = [d fullfile(session_dirs{i}, listdir(fullfile(session_dirs{i},['*' direction '*.feat']),'dirs'))];
end

nruns = length(d);
disp(['found ' num2str(nruns) ' feat directories']);

['/Applications/freesurfer/subjects/' fsSubj '/mri/roi/lgn-native-bin.nii.gz']
%% Do the math
 
for r = 1:nruns
    %%
    cd(d{r});
    run(r).name = d{r};
    
    [s, o] = system(['fslmaths filtered_func_data-2-FS-Anat.nii.gz -mas /Applications/freesurfer/subjects/' fsSubj '/mri/roi/lgn-native-bin.nii.gz -sub mean_func-2-FS-Anat.nii.gz -div mean_func-2-FS-Anat.nii.gz filtered_func_data-2-FS-Anat_norm.nii.gz'])
    disp(o);
    if s == 0
        fprintf('> fslmaths successful');
    end
    
    
    [s, o] = system(['fslmeants -i filtered_func_data-2-FS-Anat_norm.nii.gz -o meants_lgn_diffeo.txt -m /Applications/freesurfer/subjects/' fsSubj '/mri/roi/lgn-native-bin.nii.gz -v']);
    disp(o);
    if s == 0
        fprintf('> fslmeants successful');
    end

    
    C = csvread('meants_lgn_diffeo.txt');
    run(r).ts_roi_mean = C;
    
end

nVols = 156;

% Make plots
t0 = (0:0.01:nVols-1)*trSecs;
t1 = (0:1:nVols-1)*trSecs;
%title([direction '/roi signal']);
%subplot(2, 1, 1);
% plot(t0, 0.03*square(2*pi*1/48*t0)+0.7, '-k'); hold on;
% plot(t1, mean([ run(:).ts_roi_mean], 2)*100, '-k', 'LineWidth', 2);
% plot([min(t0) max(t0)], [0 0], '--k');
% xlim([0 312]); ylim([-0.9 0.9]); xlabel('Time [s]'); ylabel('BOLD Signal change [%]');
% pbaspect([1 0.3 1]);

%
% % Look at cycle averages
% xrun_ts_roi_mean = mean([ run(:).ts_roi_mean], 2);
% xrun_ts_roi_mean(1:12) = [];
% xrun_ts_roi_mean_per_cyc = reshape(xrun_ts_roi_mean, 24, 6);
%
% subplot(2, 1, 2);
% shadedErrorBar([0:23]*2, 100*mean(xrun_ts_roi_mean_per_cyc, 2), 100*std(xrun_ts_roi_mean_per_cyc, [], 2)/sqrt(length(xrun_ts_roi_mean_per_cyc)))
% xlim([0 47]); ylim([-0.4 0.4]); xlabel('Time [s]'); ylabel('BOLD Signal change [%]');
% pbaspect([1 0.3 1]);

tmp = mean([ run(:).ts_roi_mean], 2);
% Get rid of first 12
tmp(1:12) = [];

%set(luxFig, 'PaperPosition', [0 0 20 12])
%set(luxFig, 'PaperSize', [20 12]); %Set the paper to have width 5 and height 5.
%saveas(luxFig, 'cycleAvg', 'pdf');

figure(theFig)
subplot(1, nPlots, plotInd);
nCyc = 6;
cyc_avg = 100*mean(reshape(tmp, 24, nCyc), 2);
cyc_sem = 100*std(reshape(tmp, 24, nCyc), [], 2)/sqrt(nCyc);

t = 0:2:47;
t0 = 0:0.1:47;
shadedErrorBar(t, cyc_avg, cyc_sem, {'LineWidth', 2, 'Color', 'k'}); hold on;
plot(t0, 0.4+0.05*square(2*pi*1/48*t0-pi), '-k')
plot([0 48], [0 0], '--k'); hold on;
pbaspect([1 1 1]);

            title([strrep(direction, '_', '')]);
set(gca, 'XTick', [0 24 48]);
set(gca, 'YTick', [-0.8 -0.6 -0.4 -0.2 0.0 0.2 0.4 0.6 0.8]);
ylim([-0.55 0.55]);
xlim([-1 48]);


%% Save the figure
set(gca,'TickDir','out')
%set(gcf, 'PaperPosition', [0 0 12 4]);
%set(gcf, 'PaperSize', [12 4]);
%saveas(gcf, ['ts_roi_' direction], 'pdf');

