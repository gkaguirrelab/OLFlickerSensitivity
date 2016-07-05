%% Make the cache file
theCalType = 'BoxCRandomizedLongCableCStubby1NoLens_ND10_ContactLens_0_5mm';

%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'fMRIPhotoreceptorDirectedModulations';
params.calibrationType = theCalType
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1);
params.photoreceptorClasses = 'LConeTabulated,MConeTabulated,SConeTabulated';
params.fieldSizeDegrees = 27.5;
params.pupilDiameterMm = 8;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.02;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make optimal background
params.pegBackground = false;
params.backgroundType = 'BackgroundHalfOn';
params.modulationDirection = {'MelanopsinDirected'};
params.modulationContrast = [];
params.whichReceptorsToIsolate = {[7]};
params.whichReceptorsToIgnore = {[]};
params.whichReceptorsToMinimize = {[]};
params.directionsYoked = [0];
params.directionsYokedAbs = [0];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2° & 10° targeted
%% LMS
params.backgroundType = 'BackgroundHalfOn';
params.modulationDirection = 'LightFlux';
params.modulationContrast = [0.9];
params.whichReceptorsToIsolate = [1 2 3];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% Make the config file
% Create an empty config file
basePath = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/code/config/modulations';
modulationFileName = 'Modulation-LightFlux-12sWindowed16HzModulation.cfg';
fullPathCfgFile = fullfile(basePath, modulationFileName);
fclose(fopen(fullPathCfgFile, 'w'));

% Make a cfg file struct
cfgFile = ConfigFile(fullPathCfgFile);

% Add parameters
cfgFile = addParam(cfgFile, 'trialDuration', 'd', '12', 'Total duration of segment');
cfgFile = addParam(cfgFile, 'timeStep', 'd', '1/256', 'Time step');
cfgFile = addParam(cfgFile, 'cosineWindowIn', 'd', '1', 'Cosine windowing at onset?');
cfgFile = addParam(cfgFile, 'cosineWindowOut', 'd', '1', 'Cosine windowing at offset?');
cfgFile = addParam(cfgFile, 'cosineWindowDurationSecs', 'd', '3', 'Duration of cosine window');
cfgFile = addParam(cfgFile, 'nFrequencies', 'd', '2', 'Number of frequencies');
cfgFile = addParam(cfgFile, 'nPhases', 'd', '1', 'Number of phases');
cfgFile = addParam(cfgFile, 'modulationMode', 's', 'FM', 'Total duration of each trial');
cfgFile = addParam(cfgFile, 'modulationWaveForm', 's', 'sin', 'Parametric form');
cfgFile = addParam(cfgFile, 'modulationFrequencyTrials', 'd', '[]', 'Sequence of modulation frequencies');
cfgFile = addParam(cfgFile, 'modulationPhase', 'd', '[]', 'Phases of envelope');
cfgFile = addParam(cfgFile, 'carrierFrequency', 'd', '[0 16]', 'Frequencies used');
cfgFile = addParam(cfgFile, 'carrierPhase', 'd', '[0]', 'Phases of carrier');
cfgFile = addParam(cfgFile, 'nContrastScalars', 'd', '1', 'Number of different contrast scales');
cfgFile = addParam(cfgFile, 'contrastScalars', 'd', '[1]', 'Contrast scalars (as proportion of max.)');
cfgFile = addParam(cfgFile, 'direction', 's', 'LightFlux', 'Name of modulation direction');
cfgFile = addParam(cfgFile, 'directionCacheFile', 's', 'Cache-LightFlux.mat', 'Cache file to be used');
cfgFile = addParam(cfgFile, 'preCacheFile', 's', 'Modulation-LightFlux-12sWindowedFrequencyModulation.mat', 'Output file name');

cfgFile = setRawText(cfgFile, ['% 12s 16 Hz light flux flicker, ' datestr(now, 30)]);

% Write to file
cfgFile.write;

%% Make the modulation
observerAgeInYrs = 32;
OLMakeModulations(modulationFileName, observerAgeInYrs, theCalType, []);

%% Make the protocol file
% Create an empty config file
basePath = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/code/config/protocols';
modulationName = 'LightFluxLocalizer-300sLightFlux12sSegments-A';
modulationFileName = [modulationName '.cfg'];
fullPathCfgFile = fullfile(basePath, modulationFileName);
fclose(fopen(fullPathCfgFile, 'w'));

% Make a cfg file struct
cfgFile = ConfigFile(fullPathCfgFile);

% Add parameters
cfgFile = addParam(cfgFile, 'calibrationType', 's', theCalType, 'Calibration Type');
cfgFile = addParam(cfgFile, 'timeStep', 'd', '1/256', 'Time step');
cfgFile = addParam(cfgFile, 'nTrials', 'd', '15', 'Number of trials');
cfgFile = addParam(cfgFile, 'theFrequencyIndices', 'd', '[1 2 1 2 1 2 1 2 1 2 1 2 1 2 1]', 'Sequence of indices into frequency');
cfgFile = addParam(cfgFile, 'thePhaseIndices', 'd', '[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]', 'Sequence of indices into phase');
cfgFile = addParam(cfgFile, 'theDirections', 'd', '[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]', 'Sequence of indices into direction');
cfgFile = addParam(cfgFile, 'theContrastRelMaxIndices', 'd', '[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]', 'Sequence of indices into contrast scalar');
cfgFile = addParam(cfgFile, 'trialDuration', 'd', '[12 12 12 12 12 12 12 12 12 12 12 12 12 12 12]', 'Trial durations');
cfgFile = addParam(cfgFile, 'modulationFiles', 's', 'Modulation-LightFlux-12sWindowedFrequencyModulation.mat', 'Modulation name');
cfgFile = addParam(cfgFile, 'checkKB', 'd', '1', 'Check keyboard?');
cfgFile = addParam(cfgFile, 'waitForKeyPress', 'd', '1', 'Wait for key press?');
cfgFile = addParam(cfgFile, 'attentionTask', 'd', '[1 1 1 1 1 1 1 1 1 1 1 1 1 1 1]', 'Attention task per segment?');
cfgFile = addParam(cfgFile, 'attentionProbability', 'd', '0.333', 'Probability of attenion task');
cfgFile = addParam(cfgFile, 'attentionMarginDuration', 'd', '2', 'Margin in seconds in which we cannot have have a dimming');
cfgFile = addParam(cfgFile, 'attentionSegmentDuration', 'd', '12', 'Duration of segment of the trial duration in which the dimming occurs');
cfgFile = addParam(cfgFile, 'attentionBlankDuration', 'd', '0.25', 'Duration in seconds of the blank durations');

cfgFile = setRawText(cfgFile, ['% 15 segments of 12s 16 Hz light flux flicker, ' datestr(now, 30)]);

% Write to file
cfgFile.write;

%% Add the protocol to the master config file
basePath = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/code/config';
fileName = 'OLFlickerSensitivityProtocols.cfg';

name = modulationName;
configFile = modulationFileName;
driver = 'ModulationTrialSequenceMR';
dataDirectory = 'LightFluxLocalizer';

fid = fopen(fullfile(basePath, fileName), 'a');
fprintf(fid, '\n%s\t%s\t%s\t%s', name, configFile, driver, dataDirectory);
fclose(fid);