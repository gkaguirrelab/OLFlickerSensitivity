%%%%%%%%%% PHOTOPIC %%%%%%%%%%
%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'fMRIPhotoreceptorDirectedModulations';
params.calibrationType = 'BoxCRandomizedLongCableCStubby1NoLens_ND10_ContactLens_0_5mm';
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1);
params.photoreceptorClasses = 'LCone2DegTabulatedSS,MCone2DegTabulatedSS,SCone2DegTabulatedSS,LCone10DegTabulatedSS,MCone10DegTabulatedSS,SCone10DegTabulatedSS,LConeHemo,MConeHemo,SConeHemo';
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
params.whichReceptorsToIsolate = [1 2 3 4 5 6];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% 2° & 10° targeted
%% L-M
params.backgroundType = 'BackgroundHalfOn';
params.modulationDirection = 'LMinusMDirectedXEccentricity';
params.modulationContrast = [0.08 -0.08 0.08 -0.08];
params.whichReceptorsToIsolate = [1 2 4 5];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% 2° & 10° targeted
%% S
params.backgroundType = 'BackgroundHalfOn';
params.modulationDirection = 'SDirectedXEccentricity';
params.modulationContrast = [0.5 0.5];
params.whichReceptorsToIsolate = [3 6];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


%% 2° & 10° targeted
%% S
params.backgroundType = 'BackgroundHalfOn';
params.modulationDirection = 'SDirectedXEccentricity';
params.modulationContrast = [0.4 0.4];
params.whichReceptorsToIsolate = [3 6];
params.whichReceptorsToIgnore = [9];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Validation
theDirections = {'LightFlux' 'LMinusMDirectedXEccentricity' 'SDirectedXEccentricity'};
cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
zeroVector = zeros(1, length(theDirections));
theOnVector = zeroVector;
theOnVector(1) = 1;
theOffVector = zeroVector;
theOffVector(end) = 1;
WaitSecs(2);
for d = 1:length(theDirections)
    [~, ~, validationPath{d}] = OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
        theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', true, 'selectedCalType', params.calibrationType, 'CALCULATE_SPLATTER', false);
    close all;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate the modulations
for observerAgeInYrs = [26 30 46];
    OLMakeModulations('Modulation-LightFlux-12sWindowedFrequencyModulation.cfg', ...
        observerAgeInYrs, params.calibrationType, []) % Light flux
    OLMakeModulations('Modulation-LMinusMDirectedXEccentricity-12sWindowedFrequencyModulation.cfg', ...
        observerAgeInYrs, params.calibrationType, []) % L+M+S
    OLMakeModulations('Modulation-SDirectedXEccentricity-12sWindowedFrequencyModulation.cfg', ...
        observerAgeInYrs, params.calibrationType, []) % S
end