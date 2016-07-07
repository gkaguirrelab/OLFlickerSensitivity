clear; close all; clc;
%% Make the cache file
theCalType = 'BoxDRandomizedLongCableAEyePiece2_ND06';

%% Standard parameters
params.experiment = 'MaxRodsfMRI';
params.experimentSuffix = 'MaxMel';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1);
params.photoreceptorClasses = 'LConeTabulatedAbsorbance,MConeTabulatedAbsorbance,SConeTabulatedAbsorbance,Melanopsin,Rods';
params.fieldSizeDegrees = 64;
params.pupilDiameterMm = 8;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.01;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1) Find an optimal background for a melanopsin-directed stimulus
params.pegBackground = false;
params.modulationDirection = {'RodDirected'};
params.modulationContrast = {[]};
params.whichReceptorsToIsolate = {[5]};
params.whichReceptorsToIgnore = {[]};
params.whichReceptorsToMinimize = {[]};
params.directionsYoked = [0];
params.directionsYokedAbs = [0];
params.receptorIsolateMode = 'Standard';

% LMS shifted background
params.backgroundType = 'BackgroundMaxRod';
params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
[cacheDataBackground, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheDataBackground, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3) 
params.primaryHeadRoom = 0.005; 
params.backgroundType = 'BackgroundMaxRod';
params.modulationDirection = 'RodDirectedMaxRod';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [5];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataMaxRod, olCacheMaxRod, paramsMaxRod] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
% Replace the backgrounds
for observerAgeInYrs = [20:60]
    cacheDataMaxRod.data(observerAgeInYrs).backgroundPrimary = cacheDataMaxRod.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxRod.data(observerAgeInYrs).backgroundSpd = cacheDataMaxRod.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxRod.data(observerAgeInYrs).differencePrimary = cacheDataMaxRod.data(observerAgeInYrs).modulationPrimarySignedPositive-cacheDataMaxRod.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxRod.data(observerAgeInYrs).differenceSpd = cacheDataMaxRod.data(observerAgeInYrs).modulationSpdSignedPositive-cacheDataMaxRod.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxRod.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
    cacheDataMaxRod.data(observerAgeInYrs).modulationSpdSignedNegative = [];
end
paramsMaxRod.modulationDirection = 'RodDirectedMaxRod';
paramsMaxRod.cacheFile = ['Cache-' paramsMaxRod.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMaxRod, olCacheMaxRod, paramsMaxRod);



%% Standard parameters
params.experiment = 'MaxMelRodSilentfMRI';
params.experimentSuffix = 'MaxMel';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1);
params.photoreceptorClasses = 'LConeTabulatedAbsorbance,MConeTabulatedAbsorbance,SConeTabulatedAbsorbance,Melanopsin,Rods';
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
params.modulationContrast = {[]};
params.whichReceptorsToIsolate = {[4]};
params.whichReceptorsToIgnore = {[]};
params.whichReceptorsToMinimize = {[]};
params.directionsYoked = [0];
params.directionsYokedAbs = [0];
params.receptorIsolateMode = 'Standard';

% LMS shifted background
params.backgroundType = 'BackgroundMaxMelRodSilent';
params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
[cacheDataBackground, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheDataBackground, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3) 
params.primaryHeadRoom = 0.005; 
params.backgroundType = 'BackgroundMaxMelRodSilent';
params.modulationDirection = 'MelanopsinDirectedMaxMelRodSilent';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataMaxMelRodSilent, olCacheMaxMelRodSilent, paramsMaxMelRodSilent] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
% Replace the backgrounds
for observerAgeInYrs = [20:60]
    cacheDataMaxMelRodSilent.data(observerAgeInYrs).backgroundPrimary = cacheDataMaxMelRodSilent.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxMelRodSilent.data(observerAgeInYrs).backgroundSpd = cacheDataMaxMelRodSilent.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxMelRodSilent.data(observerAgeInYrs).differencePrimary = cacheDataMaxMelRodSilent.data(observerAgeInYrs).modulationPrimarySignedPositive-cacheDataMaxMelRodSilent.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxMelRodSilent.data(observerAgeInYrs).differenceSpd = cacheDataMaxMelRodSilent.data(observerAgeInYrs).modulationSpdSignedPositive-cacheDataMaxMelRodSilent.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxMelRodSilent.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
    cacheDataMaxMelRodSilent.data(observerAgeInYrs).modulationSpdSignedNegative = [];
end
paramsMaxMelRodSilent.modulationDirection = 'MelanopsinDirectedMaxMelRodSilent';
paramsMaxMelRodSilent.cacheFile = ['Cache-' paramsMaxMelRodSilent.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMaxMelRodSilent, olCacheMaxMelRodSilent, paramsMaxMelRodSilent);