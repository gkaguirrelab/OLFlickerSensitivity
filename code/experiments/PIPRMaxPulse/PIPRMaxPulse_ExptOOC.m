%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare for the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ask for the observer age
commandwindow;
observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_test');
observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
todayDate = datestr(now, 'mmddyy');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Correct the spectrum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
theCalType = 'BoxDRandomizedLongCableAEyePiece2_ND06';
spectroRadiometerOBJ = [];
spectroRadiometerOBJWillShutdownAfterMeasurement = false;
theDirections = {'MelanopsinDirectedSuperMaxMel' 'LMSDirectedSuperMaxLMS' 'PIPRBlue', 'PIPRRed'};
theDirectionsCorrect = [1 1 0 0];
cacheDir = getpref('OneLight', 'cachePath');
materialsPath = getpref('OneLight', 'materialsPath');

for d = 1:length(theDirections)
    % Print out some information
    fprintf(' * Direction:\t<strong>%s</strong>\n', theDirections{d});
    fprintf(' * Observer:\t<strong>%s</strong>\n', observerID);
    fprintf(' * Date:\t<strong>%s</strong>\n', todayDate);
    
    % Correct the cache
    fprintf(' * Starting spectrum-seeking loop...\n');
    [cacheData olCache spectroRadiometerOBJ] = OLCorrectCacheFileOOC(...
        fullfile(cacheDir, 'stimuli', ['Cache-' theDirections{d} '.mat']), ...
        'igdalova@mail.med.upenn.edu', ...
        'PR-670', spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement, ...
        'FullOnMeas', false, ...
        'CalStateMeas', false, ...
        'DarkMeas', false, ...
        'REFERENCE_OBSERVER_AGE', observerAgeInYrs, ...
        'ReducedPowerLevels', false, ...
        'selectedCalType', theCalType, ...
        'CALCULATE_SPLATTER', false, ...
        'lambda', 0.8, ...
        'NIter', 10, ...
        'powerLevels', [0 1.0000], ...
        'doCorrection', theDirectionsCorrect(d), ...
        'outDir', fullfile(materialsPath, 'PIPRMaxPulse', todayDate));
    fprintf(' * Spectrum seeking finished!\n');
    
    % Save the cache
    fprintf(' * Saving cache ...');
    params = cacheData.data(observerAgeInYrs).describe.params;
    params.modulationDirection = theDirections{d};
    params.cacheFile = ['Cache-' params.modulationDirection '_' observerID '_' todayDate '.mat'];
    
    OLReceptorIsolateSaveCache(cacheData, olCache, params);
    fprintf('done!\n');
end

if (~isempty(spectroRadiometerOBJ))
    spectroRadiometerOBJ.shutDown();
    spectroRadiometerOBJ = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the modulations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make the mod
% LMS
%%
customSuffix = ['_' observerID '_' todayDate];
OLMakeModulations('Modulation-PIPRMaxPulse-BackgroundLMS_45sSegment.cfg', observerAgeInYrs, theCalType, [], customSuffix);
OLMakeModulations('Modulation-PIPRMaxPulse-PulseMaxLMS_3s_MaxContrast17sSegment.cfg', observerAgeInYrs, theCalType, [], customSuffix); % Attention task

% Mel
customSuffix = ['_' observerID '_' todayDate];
OLMakeModulations('Modulation-PIPRMaxPulse-BackgroundMel_45sSegment.cfg', observerAgeInYrs, theCalType, [], customSuffix);
OLMakeModulations('Modulation-PIPRMaxPulse-PulseMaxMel_3s_MaxContrast17sSegment.cfg', observerAgeInYrs, theCalType, [], customSuffix); % Attention task

% PIPR
OLMakeModulations('Modulation-PIPRMaxPulse-BackgroundPIPR_45sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Background.
OLMakeModulations('Modulation-PIPRMaxPulse-PulsePIPRBlue_3s_MaxContrast17sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Blue PIPR
OLMakeModulations('Modulation-PIPRMaxPulse-PulsePIPRRed_3s_MaxContrast17sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Red PIPR


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Validate the spectrum before and after the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
commandwindow;
observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_test');
observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
todayDate = datestr(now, 'mmddyy');

theCalType = 'BoxDRandomizedLongCableAEyePiece2_ND06';
spectroRadiometerOBJ = [];
spectroRadiometerOBJWillShutdownAfterMeasurement = false;
theDirections = {['Cache-MelanopsinDirectedSuperMaxMel_' observerID '_' todayDate '.mat'] ...
    ['Cache-LMSDirectedSuperMaxLMS_' observerID '_' todayDate '.mat'] ...
    'Cache-PIPRRed.mat' ...
    'Cache-PIPRBlue.mat'};
cacheDir = getpref('OneLight', 'cachePath');
materialsPath = getpref('OneLight', 'materialsPath');

for d = 1:length(theDirections)
    [~, ~, validationPath{d}, spectroRadiometerOBJ] = OLValidateCacheFileOOC(...
        fullfile(cacheDir, 'stimuli', theDirections{d}), ...
        'igdalova@mail.med.upenn.edu', ...
        'PR-670', spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement, ...
        'FullOnMeas', false, ...
        'CalStateMeas', true, ...
        'DarkMeas', false, ...
        'REFERENCE_OBSERVER_AGE', observerAgeInYrs, ...
        'ReducedPowerLevels', false, ...
        'selectedCalType', theCalType, ...
        'CALCULATE_SPLATTER', false, ...
        'powerLevels', [0 1.0000], ...
        'pr670sensitivityMode', 'STANDARD', ...
        'outDir', fullfile(materialsPath, 'PIPRMaxPulse', datestr(now, 'mmddyy')));
    close all;
end

if (~isempty(spectroRadiometerOBJ))
    spectroRadiometerOBJ.shutDown();
    spectroRadiometerOBJ = [];
end