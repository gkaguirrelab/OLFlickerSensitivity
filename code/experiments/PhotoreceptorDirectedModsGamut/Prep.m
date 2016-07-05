%% General procedure
theCalibrationTypes = {'BoxCLongCableBEyePieceStubby1'};

%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'Test';
params.calibrationType = 'BoxCLongCableBEyePieceStubby1';
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1);
params.photoreceptorClasses = 'LCone2DegTabulatedSS,MCone2DegTabulatedSS,SCone2DegTabulatedSS,LCone10DegTabulatedSS,MCone10DegTabulatedSS,SCone10DegTabulatedSS,Melanopsin';
params.fieldSizeDegrees = 27.5;
params.pupilDiameterMm = 6;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.05;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Make optimal background
    params.pegBackground = false;
    params.backgroundType = 'BackgroundOptim';
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
%% 2° targeted, 10° silenced
%% LMS
params.backgroundType = 'BackgroundOptim';
params.modulationDirection = 'MelanopsinDirected';
    params.modulationContrast = [0.4];
    params.whichReceptorsToIsolate = [7];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


%% 2° targeted, 10° silenced
%% L-M
params.backgroundType = 'BackgroundHalfOn';
params.modulationDirection = 'LMinusMDirected2DegTargeted10DegSilenced';
params.modulationContrast = [0.006 -0.006];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% 2° targeted, 10° silenced
%% S
params.backgroundType = 'BackgroundHalfOn';
params.modulationDirection = 'SConeDirected2DegTargeted10DegSilenced';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [3];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 10° targeted, 2° silenced
%% LMS
params.backgroundType = 'BackgroundHalfOn';
params.modulationDirection = 'LMSDirected2DegTargeted10DegSilenced';
params.modulationContrast = [0.015 0.015 0.015];
params.whichReceptorsToIsolate = [4 5 6];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% 10° targeted, 2° silenced
%% L-M
params.backgroundType = 'BackgroundHalfOn';
params.modulationDirection = 'LMinusMDirected2DegTargeted10DegSilenced';
params.modulationContrast = [0.007 -0.007];
params.whichReceptorsToIsolate = [4 5];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% 10° targeted, 2° silenced
%% S
params.backgroundType = 'BackgroundHalfOn';
params.modulationDirection = 'SConeDirected2DegTargeted10DegSilenced';
params.modulationContrast = [];
params.whichReceptorsToIsolate = [6];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2° & 10° equal contrast
%% LMS
params.backgroundType = 'BackgroundHalfOn';
params.modulationDirection = 'LMSDirected2DegTargeted10DegSilenced';
params.modulationContrast = [0.89 0.89 0.89 0.89 0.89 0.89];
params.whichReceptorsToIsolate = [1 2 3 4 5 6];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% 2° & 10° equal contrast
%% L-M
params.backgroundType = 'BackgroundHalfOn';
params.modulationDirection = 'LMinusMDirected2DegTargeted10DegSilenced';
params.modulationContrast = [0.08 0.08 -0.08 0.08];
params.whichReceptorsToIsolate = [1 2 4 5];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% 2° & 10° equal contrast
%% S
params.backgroundType = 'BackgroundHalfOn';
params.modulationDirection = 'SConeDirected2DegTargeted10DegSilenced';
params.modulationContrast = [0.5 0.5];
params.whichReceptorsToIsolate = [3 6];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);