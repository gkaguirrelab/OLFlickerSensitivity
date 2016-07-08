clear; close all; clc;
%% Make the cache file
theCalType = 'BoxARandomizedLongCableBStubby1_ND00';

%% Standard parameters
params.experiment = 'MaxMelfMRI';
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
params.modulationDirection = {'MelanopsinDirected'};
params.modulationContrast = [2/3];
params.whichReceptorsToIsolate = {[4]};
params.whichReceptorsToIgnore = {[]};
params.whichReceptorsToMinimize = {[]};
params.directionsYoked = [0];
params.directionsYokedAbs = [0];
params.receptorIsolateMode = 'Standard';

% High mel
params.backgroundType = 'BackgroundMaxMel';
params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
[cacheDataBackground, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheDataBackground, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3) Around, the melanopsin-optimized background, get the modulation primary again
params.primaryHeadRoom = 0.005;
params.backgroundType = 'BackgroundMaxMel';
params.modulationDirection = 'MelanopsinDirectedSuperMaxMel';
params.modulationContrast = [2/3];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataMaxMel, olCacheMaxMel, paramsMaxMel] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
% Replace the backgrounds
for observerAgeInYrs = [20:60]
    cacheDataMaxMel.data(observerAgeInYrs).backgroundPrimary = cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).backgroundSpd = cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).differencePrimary = cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedPositive-cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).differenceSpd = cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedPositive-cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
    cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedNegative = [];
end
paramsMaxMel.modulationDirection = 'MelanopsinDirectedSuperMaxMel';
paramsMaxMel.cacheFile = ['Cache-' paramsMaxMel.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMaxMel, olCacheMaxMel, paramsMaxMel);


%% Create a mirror off condition
% Replace the backgrounds
cacheDataMirrorsOff = cacheDataMaxMel;
for observerAgeInYrs = [20:60]
    cacheDataMirrorsOff.data(observerAgeInYrs).differencePrimary(:) = 0;
    cacheDataMirrorsOff.data(observerAgeInYrs).differenceSpd = [];
    cacheDataMirrorsOff.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
    cacheDataMirrorsOff.data(observerAgeInYrs).modulationSpdSignedNegative = [];
    cacheDataMirrorsOff.data(observerAgeInYrs).modulationPrimarySignedPositive(:) = 0;
    cacheDataMirrorsOff.data(observerAgeInYrs).modulationSpdSignedPositive = [];
end
paramsMaxMel.modulationDirection = 'MirrorsOffMaxMel';
paramsMaxMel.cacheFile = ['Cache-' paramsMaxMel.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMirrorsOff, olCacheMaxMel, paramsMaxMel);


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
theCalType = 'BoxARandomizedLongCableBStubby1_ND00';
for o = [27 28 32 46]
    observerAgeInYrs = o;
    OLMakeModulations('Modulation-MelanopsinMRMaxMel-PulseMaxMel_3s_CRF16sSegment.cfg', observerAgeInYrs, theCalType, [], []) % Mel CRF
    OLMakeModulations('Modulation-MelanopsinMRMaxMel-AttentionTask16sSegment.cfg', observerAgeInYrs, theCalType, [], []) % Attention task
    OLMakeModulations('Modulation-MelanopsinMRMaxLMS-PulseMaxLMS_3s_CRF16sSegment.cfg', observerAgeInYrs, theCalType, [], []) % LMS CRF
    OLMakeModulations('Modulation-MelanopsinMRMaxLMS-AttentionTask16sSegment.cfg', observerAgeInYrs, theCalType, [], []) % Attention task
end

%% Validate
% [6] Validate
theCalType = 'BoxARandomizedLongCableBStubby1_ND00';
for i = 1:5
    %theDirections = {'MelanopsinDirectedSuperMaxMel'};
    theDirections = {'LMSDirectedSuperMaxLMS'};
    cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
    zeroVector = zeros(1, length(theDirections));
    theOnVector = zeroVector;
    theOnVector(1) = 1;
    
    theOffVector = zeroVector;
    theOffVector(end) = 1;
    WaitSecs(2);
    for d = 1:length(theDirections)
        [~, ~, validationPath{d}] = OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
            theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', false, 'selectedCalType', theCalType, ...
            'CALCULATE_SPLATTER', false, 'powerLevels', [0 0.0625 0.1250 0.2500 0.5000 1.0000]);
        close all;
    end
end