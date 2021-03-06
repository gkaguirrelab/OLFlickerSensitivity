%% Standard parameters
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'EntopticPerceptsAlphaRhythmFlicker';
theCalType = 'BoxCLongCableBEyePieceStubby1';
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
params.backgroundType = 'BackgroundHalfOn';

%% Make background
params.modulationDirection = params.backgroundType;
params.calibrationType = theCalType;
params.maxPowerDiff = 10^(-1.5);
params.primaryHeadRoom = 0.02;
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LightFlux
params.modulationDirection = 'LightFlux';
params.modulationContrast = [0.9];
params.whichReceptorsToIsolate = [];
params.whichReceptorsToIgnore = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LightFlux
params.modulationDirection = 'LMinusMDirected';
params.modulationContrast = [0.1 -0.1];
params.whichReceptorsToIsolate = [1 2];
params.whichReceptorsToIgnore = [5 6 7 8];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Modulations
% Make the modulations
observerAgeInYrs = [32 46];
for i = 1:length(observerAgeInYrs)
    theCalType = 'BoxCLongCableBEyePieceStubby1';
    OLMakeModulations('Modulation-LMinusMDirected-9sFrequencyModulation2Hz.cfg', observerAgeInYrs(i), theCalType, []) % Light flux at 0, 8, 10, 12, 16, 20, 25 Hz
    OLMakeModulations('Modulation-LightFlux-9sFrequencyModulation32Hz.cfg', observerAgeInYrs(i), theCalType, []) % Light flux at 0, 8.5, 10.5, 12.5, 17, 21, 25 Hz
    OLMakeModulations('Modulation-Background-9sFrequencyModulation0Hz.cfg', observerAgeInYrs(i), theCalType, []) % Light flux at 0, 9, 11, 13, 18, 22, 26 Hz
end