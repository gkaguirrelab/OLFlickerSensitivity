function params = MRITrialSequence(exp)
% params = MRITrialSequence(exp)

%% Setup basic parameters for the experiment
params = initParams(exp);

%% Load the run file
disp(['* Loading run file from ' params.preCacheFile]);
block = LoadCalFile(params.preCacheFile, [], [params.cacheDir '/']);
fprintf('  - Loaded.')

%% Create the OneLight object.
% This makes sure we are talking to OneLight.
global ol
ol = OneLight;

fprintf('\n* Creating keyboard listener\n');
mglListener('init');

%% Run the trial loop.
params = trialLoop(params, block, exp);

% Toss the OLCache and OneLight objects because they are really only
% ephemeral.
params = rmfield(params, {'olCache'});

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% SUBFUNCTIONS FOR PROGRAM LOGIC %%%%%%%%%%%%%%%%%%%%%%%%
%
% Contains:
%       - initParams(...)
%       - trialLoop(...)

function params = initParams(exp)
% params = initParams(exp)
% Initialize the parameters

% Load the config file for this condition.
cfgFile = ConfigFile(exp.configFileName);

% Convert all the ConfigFile parameters into simple struct values.
params = convertToStruct(cfgFile);
params.cacheDir = fullfile(exp.baseDir, 'cache');

% Load the calibration file.
cType = OLCalibrationTypes.(params.calibrationType);
params.oneLightCal = LoadCalFile(cType.CalFileName);

% Setup the cache.
params.olCache = OLCache(params.cacheDir, params.oneLightCal);

file_names = allwords(params.directionCacheFile,',');
for i = 1:length(file_names)
    % Create the cache file name.
    [~, params.cacheFileName{i}] = fileparts(file_names{i});
end
end

function params = trialLoop(params, block, exp)
% [params, responseStruct] = trialLoop(params, cacheData, exp)
% This function runs the experiment loop
global ol

%% Store out the primaries from the cacheData into a cell.  The length of
% cacheData corresponds to the number of different stimuli that are being
% shown

% Set some other parameters
starts = zeros(1, ol.NumCols);

% Set the background to the 'idle' background appropriate for this
% trial.
fprintf('- Setting mirrors to background, waiting for t.\n');
ol.setMirrors(starts, block(1).correctedStopsBackground);

%% Code to wait for 't' -- the go-signal from the scanner
triggerReceived = false;
while ~triggerReceived
    key = mglGetKeyEvent;
    % If a key was pressed, get the key and exit.
    if ~isempty(key)
        keyPress = key.charCode;
        if (strcmp(keyPress,'t'))
            triggerReceived = true;
        end
    end
end
mglListener('quit');
fprintf('  * t received.\n');
tBlockStart = mglGetSecs;

fprintf('- Starting trials.\n');

% Iterate over trials
for trial = 1:params.nTrials
    fprintf('* Start trial %i/%i.\n', trial, params.nTrials);
    % Launch into OLPDFlickerSettings.
    tTrialStart(trial) = mglGetSecs;
    OLFlickerMRISettings(ol, block(trial).correctedStops, params.timeStep, 1);
    tTrialEnd(trial) = mglGetSecs;
    fprintf('  - Done.\n');
end

fprintf('- Done with block.\n');
tBlockEnd = mglGetSecs;

% Turn all mirrors off
ol.setAll(false);

% Put the timing information into a struct
responseStruct.tBlockStart = tBlockStart;
responseStruct.tBlockEnd = tBlockEnd;
responseStruct.tTrialStart = tTrialStart;
responseStruct.tTrialEnd = tTrialEnd;

% Tack data that we want for later analysis onto params structure.  It then
% gets passed back to the calling routine and saved in our standard place.
params.responseStruct = responseStruct;

end