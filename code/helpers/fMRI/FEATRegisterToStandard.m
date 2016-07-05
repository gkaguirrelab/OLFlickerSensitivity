function FEATRegisterToStandard(sessionDir)
% FEATRegisterToStandard(sessionDir)
%
% Calls featregapply
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
for r = 1:length(theDirs)
    %fprintf('* Calling featregapply on %s ...', theDirs{r});
    

    
    fprintf('/usr/local/fsl/bin/featregapply %s\n', fullfile(sessionDir, theDirs{r}))
    %fprintf(' done.\n');
end 