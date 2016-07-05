function TestOLExpPurkinjeTreeDemo(theFreq)

% Set up a demo
cal = OLGetCalibrationStructure;

% Load in the cache file
cacheDir = fullfile('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code', 'cache', 'stimuli');
olCache = OLCache(cacheDir, cal);
cacheData = olCache.load(['Cache-LMPenumbraDirected']);

% Select cable information
waveform.cal = OLGetCalibrationStructure;

% Setup the cache.
olCache = OLCache(cacheDir, waveform.cal);

dt = 1/64;
bgVals =  0.5*ones(cal.describe.numWavelengthBands, 1);
[bgStarts bgStops]= OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, bgVals));

paramsValues = [20 30 40 50 60];
nParamsVals = length(paramsValues);

% Iterate
t0 = (0:dt:1-dt);
for k = 1:nParamsVals
    for i = 1:length(t0)
        primaryVals1(:, i) = bgVals+sin(2*pi*theFreq*t0(i))*cacheData.data(paramsValues(k)).differencePrimary;
        [primaryStarts1{k}(:, i) primaryStops1{k}(:, i)] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, primaryVals1(:, i)));
    end
end


% Copy over, since they will be the same
paramsLabel = 'age';

%% Create the experiment object
expt = OLExperimentObj('adjustment', ...
    'olRefreshRate', 1/dt, ...
    'interval1_olStarts', primaryStarts1, ...
    'interval1_olStops', primaryStops1, ...
    'interval1_paramsValues', paramsValues, ...
    'interval1_paramsCurrIndex', 1, ...
    'interval1_paramsLabel', paramsLabel, ...
    'interval1_isFlicker', true, ...
    'interval1_duration', [], ...
    'bg_olStarts', bgStarts, ...
    'bg_olStops', bgStops, ...
    'isi', 0.5);

% Initialize the OneLight
ol = OneLight;

%% Run the trial
pause;

%% Run the trial
while true
    fprintf('*** Current parameter value (%s): %.2f\n', getParamsLabel(expt, 1), getCurrentParamsValue(expt, 1));
    [expt, keyEvent] = doTrial(expt, ol);
    
    if ~isempty(keyEvent)
        switch keyEvent.charCode
            case '1'
                dIdx = -1;
            case '2'
                dIdx = 1;
            otherwise
                dIdx = 0;
        end
        
        % Make sure that we're not outside of the range, and only then
        % update the counter
        if ~(getCurrentParamsIndex(expt, 1)+dIdx > nParamsVals) && ~(getCurrentParamsIndex(expt, 1)+dIdx < 1)
            expt = updateParamsIndex(expt, getCurrentParamsIndex(expt, 1)+dIdx, []);
        end
    end
end