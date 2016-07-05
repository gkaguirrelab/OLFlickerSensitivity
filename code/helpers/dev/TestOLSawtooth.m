function TestOLExpMel(theAge)
cacheFile = ['Cache-Isochromatic'];

cacheDir = fullfile('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code', 'cache', 'stimuli');
modFile = [cacheFile '-' num2str(theAge) '-modulation'];

if ~exist(fullfile(cacheDir, [modFile '.mat']))
    % Set up a demo
    cal = OLGetCalibrationStructure;
    
    % Load in the cache file
    olCache = OLCache(cacheDir, cal);
    
    cacheData = olCache.load(cacheFile);
    % Setup the cache.
    olCache = OLCache(cacheDir, cal);
    
    dt = 1/64;
    bgVals =  cacheData.data(theAge).backgroundPrimary;
    [bgStarts bgStops]= OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, bgVals));
    
    paramsValues = [2];
    nParamsVals = length(paramsValues);
    
    % Iterate
    t0 = (0:dt:10-dt);
    for k = 1:nParamsVals
        theFreq = paramsValues(k);
        for i = 1:length(t0)
            primaryVals1(:, i) = bgVals+sawtooth(2*pi*t0(i))'*cacheData.data(theAge).differencePrimary*1.9;
            [primaryStarts1{k}(:, i) primaryStops1{k}(:, i)] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, primaryVals1(:, i)));
        end
    end
    save(fullfile(cacheDir, modFile), 'primaryStarts1', 'primaryStops1', 'nParamsVals', 'paramsValues', 'bgStarts', 'bgStops', 'dt');
else
    load(fullfile(cacheDir, modFile));
end

% Sounds
fs = 20000; durSecs = 0.1; t = linspace(0, durSecs, durSecs*fs);
yReady = sin(660*2*pi*linspace(0, 3*durSecs, 3*durSecs*fs));
yHint = [sin(880*2*pi*linspace(0, 0.1, 0.1*fs))];

% Copy over, since they will be the same
paramsLabel = 'frequency';

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
    'isi', 5);

% Initialize the OneLight
ol = OneLight;

% Make a sound to show we're ready
sound(yReady, fs);
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