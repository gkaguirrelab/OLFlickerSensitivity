function FEATConcatenateCopes(sessionDir, statsFolder, copeName)
% FEATCalculateAmplitudeFromSinCos(sessionDir)
%
% Concatenates copes.
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

%% Find feat directories in the session directory
theDirs = listdir(fullfile(sessionDir,'*.feat'),'dirs');
nruns = length(theDirs);
disp(['> Found ' num2str(nruns) ' feat directories']);

%% Calculate the amplitude
currDir = pwd;

fprintf('********************************\n');

c = 'fslmerge -t xrun.nii.gz ';
for m = 1:length(copeName)
    for r = 1:length(theDirs)
        c = [c ' ' fullfile(sessionDir, theDirs{r}, statsFolder, copeName{m}) ' '];
    end
end

system(c);

%% Make mask
c = 'fslmerge -t mask.nii.gz ';
for r = 1:length(theDirs)
    c = [c ' ' fullfile(sessionDir, theDirs{r}, 'reg_standard', 'mask.nii.gz') ' '];
end

system(c);

system('/usr/local/fsl/bin/fslmaths mask -Tmin mask');