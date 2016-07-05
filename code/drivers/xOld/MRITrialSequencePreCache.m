function params = MRITrialSequencePreCache(exp)
% params = MRITrialSequencePreCache(exp)

%% Setup basic parameters for the experiment
params = initParams(exp);

%% Iterate over the cache files to be loaded in.
for i = 1:length(params.cacheFileName)
    % Load the cache data.
    cacheData{i} = params.olCache.load(params.cacheFileName{i});
    
    % Store the internal date of the cache data we're using.  The cache
    % data date is a unique timestamp identifying a specific set of cache
    % data. We want to save that to associate data sets to specific
    % versions of the cache file.
    params.cacheDate{i} = cacheData{i}.date;
end

%% Run the trial loop.
params = trialLoop(params, cacheData, exp);

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

function params = trialLoop(params, cacheData, exp)
% [params, responseStruct] = trialLoop(params, cacheData, exp)
% This function runs the experiment loop
%% Store out the primaries from the cacheData into a cell.  The length of
% cacheData corresponds to the number of different stimuli that are being
% shown
fprintf(['\n* Running precalculations for ' params.preCacheFile '\n']);

% Do the calculations
for trial = 1:params.nTrials
    fprintf('* Precalculating settings for trial %i/%i.\n', trial, params.nTrials);
    direction = params.directionTrials(trial);
    
    % Construct the time vector
    frequencyHz = params.frequencyTrials(trial); % Frequency
    duration = params.trialDuration(trial);      % Trial duration
    t = 0:params.timeStep:duration-params.timeStep;  % Time vector
    
    % This contains the modulation variable. It is a cosine-windowed
    % sinusoid.
    x = sin(2*pi*frequencyHz*t + deg2rad(params.phase(trial)));
    
    % Cosine window the modulation
    windowDurationSecs = params.windowDurationSecs;
    nWindowed = windowDurationSecs/params.timeStep;
    cosineWindow = ((cos(pi + linspace(0, 1, nWindowed)*pi)+1)/2);
    cosineWindowReverse = cosineWindow(end:-1:1);
    
    % Replacing vlaues
    x(1:nWindowed) = cosineWindow.*x(1:nWindowed);
    x(end-nWindowed+1:end) = cosineWindowReverse.*x(end-nWindowed+1:end);
    
    % Calculate the alpha factor
    alpha = 0.5+0.5*x';
    isolatingPrimary = cacheData{direction}.isolatingPrimary;
    
    % Bring into extended form
    isolatingPrimary = params.oneLightCal.computed.D*isolatingPrimary;
    
    % Get the primaries
    primaries = isolatingPrimary*alpha' + (1-isolatingPrimary)*(1-alpha)';
    
    % Get the settings
    settings = OLPrimaryToSettings(params.oneLightCal, primaries, false);
    
    % Save out relevant stuff
    block(trial).isolatingPrimary = isolatingPrimary;
    block(trial).alpha = 0.5+0.5*x';
    block(trial).date = datestr(now);
    
    % Convert the settings from [0,1] to [0,NumRows-1].
    block(trial).correctedStops = round(settings * (params.oneLightCal.describe.numRowMirrors-1));
    block(trial).correctedStopsBackground = block(trial).correctedStops(:, 1);
    fprintf('  - Done.\n');
end

params = rmfield(params, 'olCache'); % Throw away the olCache field
for trial = 1:params.nTrials
    block(trial).params = params;
end

fprintf(['* Saving pre-calculated settings to ' params.preCacheFile '\n']);
SaveCalFile(block, params.preCacheFile, [params.cacheDir '/']);
fprintf('  - Done.\n');

params = [];

end