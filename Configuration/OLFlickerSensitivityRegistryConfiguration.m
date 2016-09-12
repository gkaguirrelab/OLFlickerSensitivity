%% OLFlickerSensitivityRegistryConfig
%
% Declare the toolboxes we need for the IBIOColorDetect project and
% write them into a JSON file.  This will let us use the ToolboxToolbox to
% deliver unto us the perfect runtime environment for this project.
%
% 2016 benjamin.heasly@gmail.com

% Clear
clear;

%% Declare some toolboxes we want.
config = [ ...  
    tbToolboxRecord( ...
    'name', 'BrainardLabToolbox', ...
    'type', 'git', ...
    'url', 'https://github.com/brainardlab/BrainardLabToolbox.git'), ...
    tbToolboxRecord( ...
    'name', 'Psychtoolbox-3', ...
    'type', 'git', ...
    'url', 'https://github.com/Psychtoolbox-3/Psychtoolbox-3.git', ...
    'subfolder','Psychtoolbox') ...
    tbToolboxRecord( ...
    'name', 'OneLightDriver', ...
    'type', 'git', ...
    'url', 'https://github.com/DavidBrainard/OneLightDriver.git'), ...
    tbToolboxRecord( ...
    'name', 'OneLightToolbox', ...
    'type', 'git', ...
    'url', 'https://github.com/DavidBrainard/OneLightToolbox.git'), ...
    tbToolboxRecord( ...
    'name', 'SilentSubstitutionToolbox', ...
    'type', 'git', ...
    'url', 'https://github.com/Spitschan/SilentSubstitutionToolbox.git'), ...
    tbToolboxRecord( ...
    'name','mgl', ...
    'type','webget', ...
    'update','never', ...
    'url','') ...
    tbToolboxRecord( ...
    'name','PsychCalLocalData', ...
    'type','webget', ...
    'update','never', ...
    'url','') ...
    % tbToolboxRecord( ...
    % type', 'git', ...
    % 'name', 'Psychtoolbox-3', ...
    % 'url', 'https://github.com/Psychtoolbox-3/Psychtoolbox-3.git', ...
    % 'subfolder','Psychtoolbox') ...
    ];

%% Write the config to a JSON file.
configPath = 'OLFlickerSensitivityConfig.json';
tbWriteConfig(config, 'configPath', configPath);
