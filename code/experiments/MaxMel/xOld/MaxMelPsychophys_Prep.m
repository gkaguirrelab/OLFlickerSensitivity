clear; close all; clc;
%% Make the cache file
theCalType = 'BoxARandomizedLongCableBEyePiece1_ND06';

%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'MaxMel';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1);
params.photoreceptorClasses = 'LConeTabulatedAbsorbance,MConeTabulatedAbsorbance,SConeTabulatedAbsorbance,Melanopsin';
params.fieldSizeDegrees = 27.5;
params.pupilDiameterMm = 6;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.05;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1) Find an optimal background for a melanopsin-directed stimulus
params.pegBackground = false;
params.modulationDirection = {'MelanopsinDirected'};
params.modulationContrast = [];
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
%% 3) Around, the melanopsin-directed stimulus, find the LMS and L-M directions
params.primaryHeadRoom = 0.04; 
params.backgroundType = 'BackgroundMaxMel';
params.modulationDirection = 'MelanopsinDirectedMaxMel';
params.modulationContrast = [0.50];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataMaxMel, olCacheMaxMel, paramsMaxMel] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 3) Around, the melanopsin-directed stimulus, find the LMS and L-M directions
params.primaryHeadRoom = 0.01; 
params.backgroundType = 'BackgroundMaxMel';
params.modulationDirection = 'LMSDirectedNoiseMaxMel';
params.modulationContrast = [0.02 0.02 0.02];
params.whichReceptorsToIsolate = [1 2 3];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataLMS, olCacheLMS, paramsLMS] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheDataLMS, olCacheLMS, paramsLMS);

params.primaryHeadRoom = 0.01; 
params.backgroundType = 'BackgroundMaxMel';
params.modulationDirection = 'LMinusMDirectedNoiseMaxMel';
params.modulationContrast = [0.01 -0.01];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataLMinusM, olCacheLMinusM, paramsLMinusM] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheDataLMinusM, olCacheLMinusM, paramsLMinusM);

% Replace the backgrounds
for observerAgeInYrs = 20:60
    cacheDataMaxMel.data(observerAgeInYrs).backgroundPrimary = cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).backgroundSpd = cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).differencePrimary = cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedPositive-cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).differenceSpd = cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedPositive-cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedNegative;
    cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
    cacheDataMaxMel.data(observerAgeInYrs).modulationSpdSignedNegative = [];
end
paramsMaxMel.modulationDirection = 'MelanopsinDirectedMaxMel';
paramsMaxMel.cacheFile = ['Cache-' paramsMaxMel.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMaxMel, olCacheMaxMel, paramsMaxMel);


%% Make the mod
%observerAgeInYrs = 28;
%OLMakeModulations('Modulation-MaxMelPos-45sPositivePulse1_5s.cfg', observerAgeInYrs, theCalType, [], []) % Noisy background
%OLMakeModulations('Modulation-MaxMelPos-45sPositivePulse2_5s.cfg', observerAgeInYrs, theCalType, [], []) % Noisy background
%OLMakeModulations('Modulation-MaxMelPos-45sPositivePulse3_5s.cfg', observerAgeInYrs, theCalType, [], []) % Noisy background
%OLMakeModulations('Modulation-MaxMelPos-45sPositivePulse4_5s.cfg', observerAgeInYrs, theCalType, [], []) % Noisy background
%OLMakeModulations('Modulation-MaxMelPos-45sPositivePulse5_5s.cfg', observerAgeInYrs, theCalType, [], []) % Noisy background
%OLMakeModulations('Modulation-MaxMelConeNoise-45s.cfg', observerAgeInYrs, theCalType, [], []) % Noisy background

% T_receptors = GetHumanPhotoreceptorSS([380 2 201], {'LConeTabulatedAbsorbance', 'LConeTabulatedAbsorbance', 'LConeTabulatedAbsorbance', 'Melanopsin'}, 27.5, 46, 6, [], [], [], []);
% bgSpd = modulationObj.modulation.spd(1, :);
% for i = 1:size(modulationObj.modulation.spd, 1)
% contrast(:, i) = (T_receptors*(modulationObj.modulation.spd(i, :)' - bgSpd')) ./ (T_receptors*(bgSpd'));
% end