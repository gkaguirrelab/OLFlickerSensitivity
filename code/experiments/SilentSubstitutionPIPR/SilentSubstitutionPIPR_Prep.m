%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PIPR
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'SilentSubstitutionPIPRPulse';
params.calibrationType = 'BoxDRandomizedLongCableAEyePiece2_ND06';
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1.5);
params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
params.fieldSizeDegrees = 27.5;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.05;
params.pupilDiameterMm = 8;

% 470 nm
params.backgroundType = 'MirrorsOff';
params.modulationDirection = 'PIPRBlue';
params.receptorIsolateMode = 'PIPR';
params.peakWavelengthNm = 475;
params.fwhmNm = 25;
params.filteredRetinalIrradianceLogPhotons = 12.5; % In log quanta/cm2/sec
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLMakePIPR(params);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

% 623 nm
params.backgroundType = 'MirrorsOff';
params.modulationDirection = 'PIPRRed';
params.receptorIsolateMode = 'PIPR';
params.peakWavelengthNm = 623;
params.fwhmNm = 25;
params.filteredRetinalIrradianceLogPhotons = 12.5; % In log quanta/cm2/sec
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLMakePIPR(params);
OLReceptorIsolateSaveCache(cacheData, olCache, params);


