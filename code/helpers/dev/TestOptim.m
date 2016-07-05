theBackgroundType = 'BackgroundHalfOn';
theCalType = 'BoxAShortCableBEyePiece2_ND06';
% Make some backgrounds
% x = 0.33, y = 0.33
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
theBackgroundType = 'BackgroundHalfOn';
theCalType = 'BoxAShortCableBEyePiece2_ND06';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1.5);
%params.photoreceptorClasses = 'LCone10DegTabulatedSS,MCone10DegTabulatedSS,SCone10DegTabulatedSS,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
params.fieldSizeDegrees = 27.5;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.02;
params.backgroundType = theBackgroundType;

%% MAIN MODULATIONS
%% LMDirected
params.modulationDirection = 'LMDirected';
params.modulationContrast = [0.40 0.40];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [5 6 7];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
%OLReceptorIsolateSaveCache(cacheData, olCache, params);
theContrasts(:, 1) = cacheData.data(32).describe.contrast;

%% LMDirected
params.modulationDirection = 'LMPenumbraDirected';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [6 7];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
%OLReceptorIsolateSaveCache(cacheData, olCache, params);
theContrasts(:, 1) = cacheData.data(32).describe.contrast;


%% LMSDirected
params.modulationDirection = 'LMSDirected';
params.modulationContrast = [0.45 0.45 0.45];
params.whichReceptorsToIsolate = [1 2 3];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);
theContrasts(:, 2) = cacheData.data(32).describe.contrast;

%% SDirected
params.modulationDirection = 'SDirected';
params.modulationContrast = [0.40];
params.whichReceptorsToIsolate = [3];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);
theContrasts(:, 3) = cacheData.data(32).describe.contrast;

%% MelanopsinDirected
params.modulationDirection = 'MelanopsinDirected';
params.modulationContrast = [0.45];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);
theContrasts(:, 4) = cacheData.data(32).describe.contrast;

%% MelanopsinDirected
params.modulationDirection = 'MelanopsinDirectedScreeningUncorrected';
params.modulationContrast = [0.45];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);
theContrasts(:, 4) = cacheData.data(32).describe.contrast;

%% MelanopsinDirected
params.modulationDirection = 'MelanopsinDirectedPenumbralSilent';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [5];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);
theContrasts(:, 4) = cacheData.data(32).describe.contrast;

% %% MelanopsinDirected
% params.photoreceptorClasses = 'LCone10DegTabulatedSS,MCone10DegTabulatedSS,SCone10DegTabulatedSS,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
% params.modulationDirection = 'MelanopsinDirectedPenumbralSilentSS';
% params.modulationContrast = [0.10];
% params.whichReceptorsToIsolate = [4];
% params.whichReceptorsToIgnore = [5];
% params.receptorIsolateMode = 'Standard';
% params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% [cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
% OLReceptorIsolateSaveCache(cacheData, olCache, params);
% theContrasts(:, 4) = cacheData.data(32).describe.contrast;
% 
% 
% %% MelanopsinDirected
% params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
% params.modulationDirection = 'MelanopsinDirectedPenumbralSilentCIE';
% params.modulationContrast = [0.10];
% params.whichReceptorsToIsolate = [4];
% params.whichReceptorsToIgnore = [5];
% params.receptorIsolateMode = 'Standard';
% params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
% [cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
% OLReceptorIsolateSaveCache(cacheData, olCache, params);
% theContrasts(:, 4) = cacheData.data(32).describe.contrast;

%% LMinusMDirected
params.modulationDirection = 'LMinusMDirected';
params.modulationContrast = [0.02 -0.02];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [5 6 7];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);
%theContrasts(:, 5) = cacheData.data(32).describe.contrast;


%% LMinusMDirected
params.modulationDirection = 'RodDirected';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [5];
params.whichReceptorsToIgnore = [6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


%% LMinusMDirected
params.modulationDirection = 'Isochromatic';
params.modulationContrast = [0.45];
params.whichReceptorsToIsolate = [];
params.whichReceptorsToIgnore = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% OmniSilent
params.modulationDirection = 'AllSilent';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [];
params.whichReceptorsToIgnore = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

