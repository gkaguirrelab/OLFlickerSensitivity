%% Device and experiment specific parameters
theBackgroundType = 'BackgroundHalfOn';
theCalType = 'BoxAShortCableBEyePiece2_ND06';

%% Make background
params = [];
params.modulationDirection = theBackgroundType;
params.calibrationType = theCalType;
params.maxPowerDiff = 10^(-1.5);
params.primaryHeadRoom = 0.02;
params.backgroundType = theBackgroundType;
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% Standard parameters
params = [];
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1.5);
params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
params.fieldSizeDegrees = 27.5;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.02;
params.backgroundType = theBackgroundType;

%% ************************** EXPERIMENT 1 **************************
% Isochromatic (45% contrast)
params.modulationDirection = 'LightFlux';
params.modulationContrast = [0.45];
params.whichReceptorsToIsolate = [];
params.whichReceptorsToIgnore = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

% L-M (12% contrast)
params.modulationDirection = 'LMinusMDirected';
params.modulationContrast = [0.12 -0.12];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% Make modulations
theCalType = 'BoxAShortCableBEyePiece2_ND06';
theObserverAges = [27]% 45 55];
for o = theObserverAges
    %OLMakeModulations('Modulation-Background-60s.cfg', o, theCalType);
    %OLMakeModulations('Modulation-Background-45s.cfg', o, theCalType);
    %OLMakeModulations('Modulation-LightFlux-45sWindowedFrequencyModulationAllFreqs.cfg', o, theCalType);
    %OLMakeModulations('Modulation-LMinusMDirected-45sWindowedFrequencyModulation.cfg', o, theCalType);
    %OLMakeModulations('Modulation-LightFlux-45sWindowedDistortionProductModulation32Hz.cfg', o, theCalType);
    OLMakeModulations('Modulation-LightFlux-45sWindowedDistortionProductModulation4HzCRF.cfg', o, theCalType);
    %OLMakeModulations('Modulation-LightFlux-45sWindowedDistortionProductModulation16Hz.cfg', o, theCalType);
    %OLMakeModulations('Modulation-LMinusMDirected-45sWindowedDistortionProductModulation8Hz.cfg', o, theCalType);
end

%%
theCalType = 'BoxAShortCableBEyePiece2_ND06';
OLMakeModulations('Modulation-Isochromatic-45sWindowedDistortionProductModulationCRF05Pct.cfg', 20, theCalType);
OLMakeModulations('Modulation-Isochromatic-45sWindowedDistortionProductModulationCRF10Pct.cfg', 20, theCalType);
OLMakeModulations('Modulation-Isochromatic-45sWindowedDistortionProductModulationCRF15Pct.cfg', 20, theCalType);
OLMakeModulations('Modulation-Isochromatic-45sWindowedDistortionProductModulationCRF20Pct.cfg', 20, theCalType);
OLMakeModulations('Modulation-Isochromatic-45sWindowedDistortionProductModulationCRF25Pct.cfg', 20, theCalType);
OLMakeModulations('Modulation-Isochromatic-45sWindowedDistortionProductModulationCRF30Pct.cfg', 20, theCalType);
OLMakeModulations('Modulation-Isochromatic-45sWindowedDistortionProductModulationCRF35Pct.cfg', 20, theCalType);
OLMakeModulations('Modulation-Isochromatic-45sWindowedDistortionProductModulationCRF40Pct.cfg', 20, theCalType);

%% Test modulation
OLModulationDemoTest('Modulation-Isochromatic-45sWindowedDistortionProductModulation-20.mat');

%%
theCalType = 'BoxAShortCableBEyePiece2_ND06';
OLMakeModulations('Modulation-Isochromatic-45sSinusoidHz.cfg', 32, theCalType);
OLMakeModulations('Modulation-Isochromatic-45sSinusoid256Hz.cfg', 32, theCalType);
OLMakeModulations('Modulation-Isochromatic-45sSinusoid256Hz.cfg', 32, theCalType);

%%
theCalType = 'BoxAShortCableBEyePiece2_ND06';
OLMakeModulations('Modulation-Isochromatic-8sSinusoid512Hz_16Hz_KleinContrastCheck.cfg', 32, theCalType);
OLMakeModulations('Modulation-Isochromatic-8sSinusoid512Hz_2Hz_KleinContrastCheck.cfg', 32, theCalType);
OLMakeModulations('Modulation-Isochromatic-20sSinusoid512Hz_PhotodiodeInvarianceCheck.cfg', 32, theCalType);

%% Validate
theDirections = {'LightFlux'};

cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
zeroVector = zeros(1, length(theDirections));
theOnVector = zeroVector;
theOnVector(1) = 1;
theOffVector = zeroVector;
theOffVector(end) = 1;
WaitSecs(1);
for d = 1:length(theDirections)
    [~, ~, validationPath{d}] = OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
        theOnVector(d), theOffVector(d), 'DarkMeas', true, 'FullOnMeas', true, 'ReducedPowerLevels', false, 'selectedCalType', 'BoxAShortCableBEyePiece2_ND06', 'CALCULATE_SPLATTER', false);
    close all;
end