%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare for the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ask for the observer age
commandwindow;
observerAgeInYrs = GetWithDefault('>> Enter observer age:', 32);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Correct the spectrum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
theCalType = 'BoxDRandomizedLongCableAEyePiece2_ND06_Warmup';
spectroRadiometerOBJ = [];
spectroRadiometerOBJWillShutdownAfterMeasurement = false;
theDirections = {'MelanopsinDirectedSuperMaxMel' 'LMSDirectedSuperMaxLMS'};
cacheDir = getpref('OneLight', 'cachePath');
materialsPath = getpref('OneLight', 'materialsPath');

for d = 1:length(theDirections)
    [cacheData openSpectroRadiometerOBJ] = OLCorrectCacheFileOOC(...
        fullfile(cacheDir, 'stimuli', ['Cache-' theDirections{d} '.mat']), ...
        'igdalova@mail.med.upenn.edu', ...
        'PR-670', spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement, ...
        'FullOnMeas', false, ...
        'CalStateMeas', true, ...
        'DarkMeas', false, ...
        'REFERENCE_OBSERVER_AGE', observerAgeInYrs, ...
        'ReducedPowerLevels', false, ...
        'selectedCalType', theCalType, ...
        'CALCULATE_SPLATTER', false, ...
        'lambda', 0.8, ...
        'NIter', 8, ...
        'powerLevels', [0 1.0000], ...
        'pr670sensitivityMode', 'STANDARD', ...
        'outDir', fullfile(materialsPath, 'PIPRMaxPulse', datestr(now, 'mmddyy'), num2str(theLearningRate)));
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
OLMakeModulations('Modulation-PIPRMaxPulse-BackgroundLMS_45sSegment.cfg', observerAgeInYrs, theCalType, [], []);
OLMakeModulations('Modulation-PIPRMaxPulse-PulseMaxLMS_3s_MaxContrast17sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Attention task

% Mel
OLMakeModulations('Modulation-PIPRMaxPulse-BackgroundMel_45sSegment.cfg', observerAgeInYrs, theCalType, [], []);
OLMakeModulations('Modulation-PIPRMaxPulse-PulseMaxMel_3s_MaxContrast17sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Attention task

% PIPR
OLMakeModulations('Modulation-PIPRMaxPulse-BackgroundPIPR_45sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Background.
OLMakeModulations('Modulation-PIPRMaxPulse-PulsePIPRBlue_3s_MaxContrast17sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Blue PIPR
OLMakeModulations('Modulation-PIPRMaxPulse-PulsePIPRRed_3s_MaxContrast17sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Red PIPR


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Validate the spectrum before and after the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
observerAgeInYrs = GetWithDefault('>> Enter observer age:', 32);

theCalType = 'BoxDRandomizedLongCableAEyePiece2_ND06_Warmup';
spectroRadiometerOBJ = [];
spectroRadiometerOBJWillShutdownAfterMeasurement = false;
theDirections = {'MelanopsinDirectedSuperMaxMel' 'LMSDirectedSuperMaxLMS', 'PIPRRed', 'PIPRBlue'};
cacheDir = getpref('OneLight', 'cachePath');
materialsPath = getpref('OneLight', 'materialsPath');

for d = 1:length(theDirections)
    [~, ~, validationPath{d}, spectroRadiometerOBJ] = OLValidateCacheFileOOC(...
        fullfile(cacheDir, 'stimuli', ['Cache-' theDirections{d} '.mat']), ...
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