function FEATCalculateAmplitudeFromSinCos(sessionDir)
% FEATCalculateAmplitudeFromSinCos(sessionDir)
%
% Calculates amplitude based on sin and cos regressors by sqrt(beta_sin^2 +
% beta_cos^2). 
%
% We take the variance of the sin regressor. This is probably not the right
% way to do it.
%
% 08/xx/14      asb     Written for bbregister purposes.
% 09/16/14      ms      Adapted.

if ~exist('sessionDir','var')
    error('"sessionDir" not defined')
end

%% Set up FSL variables
fsl_path = '/usr/local/fsl/';
setenv('FSLDIR',fsl_path)
setenv('FSLOUTPUTTYPE','NIFTI_GZ')
curpath = getenv('PATH');
setenv('PATH',sprintf('%s:%s',fullfile(fsl_path,'bin'),curpath));

%% Define what is what
sin_cope = 'cope1';
cos_cope = 'cope2';

%% Find feat directories in the session directory
theDirs = listdir(fullfile(sessionDir,'*.feat'),'dirs');
nruns = length(theDirs);
disp(['> Found ' num2str(nruns) ' feat directories']);

%% Calculate the amplitude
currDir = pwd;

for r = 1:length(theDirs)
    % Copy over the stats directly for safety
    %fprintf('* Making back up of "stats" directory ...');
    %copyfile(fullfile(theDirs{r}, 'stats'), fullfile(theDirs{r}, 'stats.bk'));
    %fprintf(' done.\n');
    
    % Do the arithmetic
    cd(fullfile(theDirs{r}, 'stats'))
    fprintf('* Calling fslmaths on %s ...', theDirs{r});
    system(['fslmaths ' sin_cope '.nii.gz -sqr ' sin_cope '_squared.nii.gz']);
    system(['fslmaths ' cos_cope '.nii.gz -sqr ' cos_cope '_squared.nii.gz']);
    system(['fslmaths ' sin_cope '_squared.nii.gz -add ' cos_cope '_squared.nii.gz -sqrt cope0_amplitude.nii.gz']);
    system(['cp var' sin_cope '.nii.gz varcope0_amplitude.nii.gz']);
    fprintf(' done.\n');
    cd(currDir);
end 