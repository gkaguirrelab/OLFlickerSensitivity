%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the cache
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
theCalType = 'BoxCRandomizedLongCableDStubby1_ND10';

%% Standard parameters
params.experiment = 'MelanopsinMRRodControl';
params.experimentSuffix = 'MelanopsinMRRodControl';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1);
params.photoreceptorClasses = 'LConeTabulatedAbsorbance,MConeTabulatedAbsorbance,SConeTabulatedAbsorbance,Melanopsin,Rods';
params.fieldSizeDegrees = 27.5;
params.pupilDiameterMm = 8;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.01;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Silent substitution
%% MaxMel
params.pegBackground = false;
params.modulationDirection = {'RodDirected'};
params.modulationContrast = [];
params.whichReceptorsToIsolate = {[5]};
params.whichReceptorsToIgnore = {[]};
params.whichReceptorsToMinimize = {[]};
params.directionsYoked = [0];
params.directionsYokedAbs = [0];
params.receptorIsolateMode = 'Standard';

% Mel shifted background
params.backgroundType = 'BackgroundOptim';
params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
[cacheDataBackground, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheDataBackground, olCache, params);

% Now, make the modulation
params.primaryHeadRoom = 0.005;
params.backgroundType = 'BackgroundOptim';
params.modulationDirection = 'RodDirected';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [5];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataMaxMel, olCacheMaxMel, paramsMaxMel] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);

%paramsMaxMel.modulationDirection = 'MelanopsinDirectedSuperMaxMel';
%paramsMaxMel.cacheFile = ['Cache-' paramsMaxMel.modulationDirection '.mat'];
%OLReceptorIsolateSaveCache(cacheDataMaxMel, olCacheMaxMel, paramsMaxMel);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Silent substitution
% Now, make the modulation
params.primaryHeadRoom = 0.005;
params.backgroundType = 'BackgroundOptim';
params.modulationDirection = 'LMinusMDirected';
params.modulationContrast = [0.06 -0.06];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataMaxMel, olCacheMaxMel, paramsMaxMel] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);

%paramsMaxMel.modulationDirection = 'LMinusMDirected';
%paramsMaxMel.cacheFile = ['Cache-' paramsMaxMel.modulationDirection '.mat'];
%OLReceptorIsolateSaveCache(cacheDataMaxMel, olCacheMaxMel, paramsMaxMel);

