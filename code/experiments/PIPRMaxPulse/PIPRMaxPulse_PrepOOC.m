%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the cache
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
theCalType = 'BoxDRandomizedLongCableAEyePiece2_ND06_Warmup';

%% Standard parameters
params.experiment = 'PIPRMaxPulse';
params.experimentSuffix = 'PIPRMaxPulse';
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
params.primaryHeadRoom = 0.01;

% 470 nm
params.backgroundType = 'MirrorsOff';
params.modulationDirection = 'PIPRBlue';
params.receptorIsolateMode = 'PIPR';
params.peakWavelengthNm = 475;
params.fwhmNm = 25;
params.filteredRetinalIrradianceLogPhotons = 12.3; % In log quanta/cm2/sec
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLMakePIPR(params);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

% 623 nm
params.backgroundType = 'MirrorsOff';
params.modulationDirection = 'PIPRRed';
params.receptorIsolateMode = 'PIPR';
params.peakWavelengthNm = 623;
params.fwhmNm = 25;
params.filteredRetinalIrradianceLogPhotons = 12.3; % In log quanta/cm2/sec
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLMakePIPR(params);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Silent substitution
%% MaxMel
params.pegBackground = false;
params.modulationDirection = {'MelanopsinDirected'};
params.modulationContrast = [2/3];
params.whichReceptorsToIsolate = {[4]};
params.whichReceptorsToIgnore = {[]};
params.whichReceptorsToMinimize = {[]};
params.directionsYoked = [0];
params.directionsYokedAbs = [0];
params.receptorIsolateMode = 'Standard';

% Mel shifted background
params.backgroundType = 'BackgroundMaxMel';
params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
[cacheDataBackground, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheDataBackground, olCache, params);

% Now, make the modulation
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

%% MaxLMS
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

% Now, make the modulation
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the modulations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make the mod
%%
theCalType = 'BoxDRandomizedLongCableAEyePiece2_ND06_Warmup';
for o = [20:60]
    observerAgeInYrs = o;
    % LMS
    OLMakeModulations('Modulation-PIPRMaxPulse-BackgroundLMS_45sSegment.cfg', observerAgeInYrs, theCalType, [], []);
    OLMakeModulations('Modulation-PIPRMaxPulse-PulseMaxLMS_3s_MaxContrast17sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Attention task
    
    % Mel
    OLMakeModulations('Modulation-PIPRMaxPulse-BackgroundMel_45sSegment.cfg', observerAgeInYrs, theCalType, [], []);
    OLMakeModulations('Modulation-PIPRMaxPulse-PulseMaxMel_3s_MaxContrast17sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Attention task
    
    % PIPR
    OLMakeModulations('Modulation-PIPRMaxPulse-BackgroundPIPR_45sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Background.
    OLMakeModulations('Modulation-PIPRMaxPulse-PulsePIPRBlue_3s_MaxContrast17sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Blue PIPR
    OLMakeModulations('Modulation-PIPRMaxPulse-PulsePIPRRed_3s_MaxContrast17sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Red PIPR
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Validate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
% OOC_checkPR670;
% ol = OneLight;
% 
%%

theCalType = 'BoxDRandomizedLongCableAEyePiece2_ND06_Warmup';
spectroRadiometerOBJ = [];
spectroRadiometerOBJWillShutdownAfterMeasurement = false;
%theDirections = {'MelanopsinDirectedSuperMaxMel' 'LMSDirectedSuperMaxLMS' 'PIPRRed' 'PIPRBlue'};
theDirections = {'MelanopsinDirectedSuperMaxMel' 'LMSDirectedSuperMaxLMS'};
cacheDir = getpref('OneLight', 'cachePath');
materialsPath = getpref('OneLight', 'materialsPath');
%OLWarmUpOOC;

%while true
%for i = 1:5
% for theLearningRate = [0.5 0.6 0.7 0.8 0.9 1.0]
%     WaitSecs(2);
%     for d = 1:length(theDirections)
%         [~, ~, validationPath{d}, spectroRadiometerOBJ] = OLCorrectCacheFileOOC(...
%             fullfile(cacheDir, 'stimuli', ['Cache-' theDirections{d} '.mat']), ...
%             'igdalova@mail.med.upenn.edu', ...
%             'PR-670', spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement, ...
%             'FullOnMeas', false, ...
%             'CalStateMeas', true, ...
%             'DarkMeas', false, ...
%             'ReducedPowerLevels', false, ...
%             'selectedCalType', theCalType, ...
%             'CALCULATE_SPLATTER', false, ...
%             'lambda', theLearningRate, ...
%             'powerLevels', [0 1.0000], ...
%             'outDir', fullfile(materialsPath, 'PIPRMaxPulse', datestr(now, 'mmddyy'), num2str(theLearningRate)));
%         close all;
%     end
% end
c = 1;
while true
    if mod(10, c)
        powerLevels = [0 0.2 0.4 0.6 0.8 1.0]
    else
        powerLevels = [0 1.0];
    end
    WaitSecs(2);
    for d = 1:length(theDirections)
        [~, ~, validationPath{d}, spectroRadiometerOBJ] = OLValidateCacheFileOOC(...
            fullfile(cacheDir, 'stimuli', ['Cache-' theDirections{d} '.mat']), ...
            'igdalova@mail.med.upenn.edu', ...
            'PR-670', spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement, ...
            'FullOnMeas', false, ...
            'CalStateMeas', true, ...
            'DarkMeas', false, ...
            'ReducedPowerLevels', false, ...
            'selectedCalType', theCalType, ...
            'CALCULATE_SPLATTER', false, ...
            'powerLevels', powerLevels, ...
            'outDir', fullfile(materialsPath, 'PIPRMaxPulse', datestr(now, 'mmddyy')));
        close all;
    end
    c = c+1;
end
%end
if (~isempty(spectroRadiometerOBJ))
    spectroRadiometerOBJ.shutDown();
    spectroRadiometerOBJ = [];
end