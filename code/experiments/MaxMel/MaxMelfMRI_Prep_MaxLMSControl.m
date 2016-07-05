clear; close all; clc;
%% Make the cache file
theCalType = 'BoxARandomizedLongCableCStubby1_ND00';

%% Standard parameters
params.experiment = 'MaxLMSfMRI';
params.experimentSuffix = 'MaxMel';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1);
params.photoreceptorClasses = 'LConeTabulatedAbsorbance,MConeTabulatedAbsorbance,SConeTabulatedAbsorbance,Melanopsin';
params.fieldSizeDegrees = 64;
params.pupilDiameterMm = 8;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.01;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1) Find an optimal background for a melanopsin-directed stimulus
params.pegBackground = false;
params.modulationDirection = {'LMSDirected'};
params.modulationContrast = {[2/3 2/3 2/3]};
params.whichReceptorsToIsolate = {[1 2 3]};
params.whichReceptorsToIgnore = {[]};
params.whichReceptorsToMinimize = {[]};
params.directionsYoked = [1];
params.directionsYokedAbs = [0];
params.receptorIsolateMode = 'Standard';

% LMS shifted background
params.backgroundType = 'BackgroundMaxLMS';
params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
[cacheDataBackground, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheDataBackground, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3) 
params.primaryHeadRoom = 0.005; 
params.backgroundType = 'BackgroundMaxLMS';
params.modulationDirection = 'LMSDirectedSuperMaxLMS';
params.modulationContrast = [2/3 2/3 2/3];
params.whichReceptorsToIsolate = [1 2 3];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataMaxLMS, olCacheMaxLMS, paramsMaxLMS] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
% Replace the backgrounds
for observerAgeInYrs = [20:60]
    cacheDataMaxLMS.data(observerAgeInYrs).backgroundPrimary = cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxLMS.data(observerAgeInYrs).backgroundSpd = cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxLMS.data(observerAgeInYrs).differencePrimary = cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedPositive-cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxLMS.data(observerAgeInYrs).differenceSpd = cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedPositive-cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxLMS.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
    cacheDataMaxLMS.data(observerAgeInYrs).modulationSpdSignedNegative = [];
end
paramsMaxLMS.modulationDirection = 'LMSDirectedSuperMaxLMS';
paramsMaxLMS.cacheFile = ['Cache-' paramsMaxLMS.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMaxLMS, olCacheMaxLMS, paramsMaxLMS);


%% Create a mirror off condition
% Replace the backgrounds
cacheDataMirrorsOff = cacheDataMaxLMS;
for observerAgeInYrs = [20:60]
    cacheDataMirrorsOff.data(observerAgeInYrs).differencePrimary(:) = 0;
    cacheDataMirrorsOff.data(observerAgeInYrs).differenceSpd = [];
    cacheDataMirrorsOff.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
    cacheDataMirrorsOff.data(observerAgeInYrs).modulationSpdSignedNegative = [];
    cacheDataMirrorsOff.data(observerAgeInYrs).modulationPrimarySignedPositive(:) = 0;
    cacheDataMirrorsOff.data(observerAgeInYrs).modulationSpdSignedPositive = [];
end
paramsMaxLMS.modulationDirection = 'MirrorsOffMaxLMS';
paramsMaxLMS.cacheFile = ['Cache-' paramsMaxLMS.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMirrorsOff, olCacheMaxLMS, paramsMaxLMS);


%% Make the mod
for o = [27 28 32 46]
observerAgeInYrs = o;
OLMakeModulations('Modulation-MelanopsinMRMaxLMSControl-PulseMaxLMS_3s_MaxContrast16sSegment.cfg', observerAgeInYrs, theCalType, [], []) % Noisy background
OLMakeModulations('Modulation-MelanopsinMRMaxLMSControl-AttentionTask16sSegment.cfg', observerAgeInYrs, theCalType, [], []) % Noisy background
end

%% Validate
% [6] Validate
for i = 1:5
    theDirections = {'LMSDirectedSuperMaxLMS'};
    cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
  bby  zeroVector = zeros(1, length(theDirections));
    theOnVector = zeroVector;
    theOnVector(1) = 1;
    
    theOffVector = zeroVector;
    theOffVector(end) = 1;
    WaitSecs(2);
    for d = 1:length(theDirections)
        [~, ~, validationPath{d}] = OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
            theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', false, 'selectedCalType', 'BoxARandomizedLongCableCStubby1_ND00', ...
            'CALCULATE_SPLATTER', false, 'powerLevels', [0 1]);
        close all;
    end
end