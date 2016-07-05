clear; close all; clc;
%% Make the cache file
theCalType = 'BoxARandomizedLongCableCStubby1_ND00';
% 
%% Standard parameters
params.experiment = 'MaxMelfMRI';
params.experimentSuffix = 'MaxMelSplatterControl';
params.calibrationType = theCalType;
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1);
params.photoreceptorClasses = 'LConeTabulatedAbsorbance,MConeTabulatedAbsorbance,SConeTabulatedAbsorbance,Melanopsin';
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
params.modulationContrast = [2/3];
params.whichReceptorsToIsolate = {[4]};
params.whichReceptorsToIgnore = {[]};
params.whichReceptorsToMinimize = {[]};
params.directionsYoked = [0];
params.directionsYokedAbs = [0];
params.receptorIsolateMode = 'Standard';

% High mel
params.backgroundType = 'BackgroundOptim';
params.cacheFile = ['Cache-' params.backgroundType  '.mat'];
[cacheDataBackground, olCache, params] = OLReceptorIsolateMakeBackground(params, true);
OLReceptorIsolateSaveCache(cacheDataBackground, olCache, params);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 2) Find the splatter control direction.
% This direction has the following post-receptoral splatter properties:
%
%	 LMS	 +0.02173
%	 L-M	 +0.00877
%	 S       -0.10451
%
% See the program MelanopsinMR_SplatterAnalysis.m in MelanopsinMR.git for
% more information.
postReceptoralMechanisms = [1 1 1 ; 1 -1 0 ; 0 0 1]'
postReceptoralContrast = [0.02173 0.00877 -0.10451]
LCone = postReceptoralContrast(1) + postReceptoralContrast(2);
MCone = postReceptoralContrast(1) - postReceptoralContrast(2);
SCone = postReceptoralContrast(1) + postReceptoralContrast(3);
postReceptoralMechanisms \ [LCone MCone SCone]'

params.primaryHeadRoom = 0.005;
params.backgroundType = 'BackgroundOptim';
params.modulationDirection = 'MaxMelPostreceptoralSplatterControl';
params.modulationContrast = [LCone MCone SCone];
params.whichReceptorsToIsolate = [1 2 3];
params.whichReceptorsToIgnore = [];
params.whichReceptorsToMinimize = [];
params.receptorIsolateMode = 'Standard';
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheDataSplatter, olCacheSplatter paramsSplatter] = OLReceptorIsolateFindIsolatingPrimarySettings(params, true);
OLReceptorIsolateSaveCache(cacheDataSplatter, olCache, params);

%% 3) Mirrors off
cacheDataMirrorsOff = cacheDataSplatter;
for observerAgeInYrs = [20:60]
    cacheDataMirrorsOff.data(observerAgeInYrs).differencePrimary(:) = 0;
    cacheDataMirrorsOff.data(observerAgeInYrs).differenceSpd = [];
    cacheDataMirrorsOff.data(observerAgeInYrs).modulationPrimarySignedNegative = [];
    cacheDataMirrorsOff.data(observerAgeInYrs).modulationSpdSignedNegative = [];
    cacheDataMirrorsOff.data(observerAgeInYrs).modulationPrimarySignedPositive(:) = 0;
    cacheDataMirrorsOff.data(observerAgeInYrs).modulationSpdSignedPositive = [];
end
paramsMaxMel.modulationDirection = 'MirrorsOffSplatterControl';
paramsMaxMel.cacheFile = ['Cache-' paramsMaxMel.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMirrorsOff, olCacheSplatter, paramsMaxMel);

%% 4) make the modulations
%% Make the mod
for observerAgeInYrs = [27 28 32 46]
    OLMakeModulations('Modulation-MelanopsinMR-SplatterControlAttentionTask16sSegment.cfg', observerAgeInYrs, theCalType, [], []);
    OLMakeModulations('Modulation-MelanopsinMR-SplatterControlPulse_3s_CRF16sSegment.cfg', observerAgeInYrs, theCalType, [], []);
end

%% Validate
% [6] Validate
for i = 1:5
    theDirections = {'MaxMelPostreceptoralSplatterControl'};
    cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
    zeroVector = zeros(1, length(theDirections));
    theOnVector = zeroVector;
    theOnVector(1) = 1;
    
    theOffVector = zeroVector;
    theOffVector(end) = 1;
    WaitSecs(2);
    for d = 1:length(theDirections)
        [~, ~, validationPath{d}] = OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
            theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', false, 'selectedCalType', theCalType, ...
            'CALCULATE_SPLATTER', false, 'powerLevels', [0 0.25 0.5 1 1.95]);
        close all;
    end
end