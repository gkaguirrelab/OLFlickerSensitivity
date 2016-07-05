function [cacheData cacheDataMel olCacheDataMel paramsMel cacheDataLMS olCacheDataLMS paramsLMS cacheDataLMSNull cacheDataLMinusMNull cacheDataSNull] =  OLMakeMelAndLMS(params)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make optimal background
params.pegBackground = false;
params.primaryHeadRoom = 0.05;
params.backgroundType = 'BackgroundOptim';
params.modulationDirection = {'MelanopsinDirected' 'LMSDirected'};
params.modulationContrast = {[] []};
params.whichReceptorsToIsolate = {[4] [1 2 3]};
params.whichReceptorsToIgnore = {[] []};
params.whichReceptorsToMinimize = {[] []};
params.directionsYoked = [0 1];
params.directionsYokedAbs = [0 0];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MelanopsinDirectedPenumbralIgnore - not silencing penumbral cones
params.backgroundType = 'BackgroundOptim';
params.primaryHeadRoom = 0.02;
params.modulationDirection = 'MelanopsinDirectedPenumbralIgnore';
params.modulationContrast = [params.targetContrast];
params.whichReceptorsToIsolate = [4];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataMel, olCacheDataMel, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheDataMel, olCacheDataMel, params);
paramsMel = params;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% L+M+S-Directed
params.backgroundType = 'BackgroundOptim';
params.modulationDirection = 'LMSDirected';
params.modulationContrast = [params.targetContrast params.targetContrast params.targetContrast];
params.whichReceptorsToIsolate = [1 2 3];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataLMS, olCacheDataLMS, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheDataLMS, olCacheDataLMS, params);
paramsLMS = params;

params.primaryHeadRoom = 0.05;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% L+M+S-Directed
params.backgroundType = 'BackgroundOptim';
params.modulationDirection = 'LMSDirectedNull';
params.modulationContrast = [0.10 0.10 0.10];
params.whichReceptorsToIsolate = [1 2 3];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataLMSNull, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheDataLMSNull, olCache, params);
paramsLMSNull = params;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% L-M
params.backgroundType = 'BackgroundOptim';
params.modulationDirection = 'LMinusMDirectedNull';
params.modulationContrast = [0.10 -0.10];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataLMinusMNull, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheDataLMinusMNull, olCache, params);
paramsLMinusMNull = params;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% S
params.backgroundType = 'BackgroundOptim';
params.modulationDirection = 'SDirectedNull';
params.modulationContrast = [0.10];
params.whichReceptorsToIsolate = [3];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataSNull, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheDataSNull, olCache, params);
paramsSNull = params;

%% Noise
% LMS scaled for noise
params.modulationDirection = 'LMSDirectedNoise';
params.modulationContrast = [0.02 0.02 0.02];
params.whichReceptorsToIsolate = [1 2 3];
params.whichReceptorsToIgnore = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% LMS scaled for noise
params.modulationDirection = 'LMinusMDirectedNoise';
params.modulationContrast = [0.02 -0.02];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);