%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'TTFMRFlickerPurkinje';
theCalType = 'BoxDRandomizedLongCableAEyePiece2_ND10';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1.5);
params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
params.fieldSizeDegrees = 27.5;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.02;
params.pupilDiameterMm = 8;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make optimal background
params.pegBackground = false;
params.backgroundType = 'BackgroundHalfOn';
params.modulationDirection = {'MelanopsinDirected'};
params.modulationContrast = [];
params.whichReceptorsToIsolate = {[4]};
params.whichReceptorsToIgnore = {[]};
params.whichReceptorsToMinimize = {[]};
params.directionsYoked = [0];
params.directionsYokedAbs = [0];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


%%% PURKINJE TREE MODULATIONS
%% LMUmbraDirected
params.modulationDirection = 'LMPenumbraDirected';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [6 7];
params.whichReceptorsToIgnore = [5];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

