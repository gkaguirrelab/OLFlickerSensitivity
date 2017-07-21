function OLFlickerSensitivityLocalHook
% OLFlickerSensitivityLocalHook
%
% Configure things for working on OneLight projects.
%
% For use with the ToolboxToolbox.  If you copy this into your
% ToolboxToolbox localToolboxHooks directory (by defalut,
% ~/localToolboxHooks) and delete "LocalHooksTemplate" from the filename,
% this will get run when you execute tbUse({'OLFlickerSensitivityConfig'}) to set up for
% this project.  You then edit your local copy to match your local machine.
%
% The thing that this does is add subfolders of the project to the path as
% well as define Matlab preferences that specify input and output
% directories.
%
% You will need to edit the project location and i/o directory locations
% to match what is true on your computer.

%% Say hello
fprintf('Running OLFlickerSensitivitylocal hook\n');

%% Clear prefs before setting
%
% 'OneLightToolbox' is used by new code, 'OneLight' by this legacy code.
% We clear both, and then below set 'OneLight' to be what we want.
if (ispref('OneLightToolbox'))
    rmpref('OneLightToolbox');
end
if (ispref('OneLight'))
    rmpref('OneLight');
end

%% Set preferences

% Obtain the Dropbox path
[~, userID] = system('whoami');
userID = strtrim(userID);
switch userID
    case {'melanopsin' 'pupillab'}
        dropboxBaseDir = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/'];
        dataPath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/'];
    case {'dhb'}
        dropboxBaseDir = ['/Users1'  '/Dropbox (Aguirre-Brainard Lab)/'];
        dataPath = ['/Users1/' '/Dropbox (Aguirre-Brainard Lab)/MELA_data/'];        
    case 'connectome'
        dropboxBaseDir = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)'];
        dataPath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/TOME_data/'];
    otherwise
        dropboxBaseDir = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)'];
        dataPath = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/'];
end

% Set the Dropox path
setpref('OneLight', 'dropboxPath', dropboxBaseDir);

% Set the data path
setpref('OneLight', 'dataPath', dataPath);

% Set the modulation path
setpref('OneLight', 'modulationPath', fullfile(dropboxBaseDir, 'MELA_materials', 'Legacy', 'modulations/'));

% Set the materials path
setpref('OneLight', 'materialsPath', fullfile(dropboxBaseDir, 'MELA_materials', 'Legacy/'));

% Set the cache path
setpref('OneLight', 'cachePath', fullfile(dropboxBaseDir, 'MELA_materials', 'Legacy', 'cache/'));

% Set the calibration path
setpref('OneLight', 'OneLightCalData', fullfile(dropboxBaseDir, 'MELA_materials', 'Legacy', 'OneLightCalData/'));

% Set the default speak rate
setpref('OneLight', 'SpeakRateDefault', 230);

% Add OmniDriver.jar to java path
OneLightDriverPath = tbLocateToolbox('OneLightDriver');
JavaAddToPath(fullfile(OneLightDriverPath,'xOceanOpticsJava/OmniDriver.jar'),'OmniDriver.jar');

% Point at the code
olFlickerProjectDir = tbLocateProject('OLFlickerSensitivity');
setpref('OneLight', 'OLFlickerSensitivityBaseDir', fullfile(olFlickerProjectDir,'code'));

% Add OLFlickerSensitivity to the path
addpath(genpath(olFlickerProjectDir));