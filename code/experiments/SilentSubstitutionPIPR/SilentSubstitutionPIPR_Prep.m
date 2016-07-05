%% [1] We construct the following modulations
%       Main modulations
%       - 42% melanopsin-isolating, cone-silent
%       - 42% LMS-directed, melanopsin-silent
%
%       Null modulations
%       - ±10% LMS-directed
%       - ±10% L-M-directed
%       - ±10% S-directed
%
% To do this, we use our standard machinery and the wrapper code
% OLMakeMelAndLMS(...). This function also finds an 'optimal' background
% around which we get the most melanopsin- and LMS-directed contrast.


% Contrasts read in from x/xConesTabulatedAbsorbance/Absorbance/MelLMS_GrandMean.csv
MelLMSNullTabulated = -0.001688; MelLMSNullTabulatedSD = 0.012465;
MelLMinusMNullTabulated = -0.003165; MelLMinusMNullTabulatedSD = 0.006846;
MelSNullTabulated = 0.040468; MelSNullTabulatedSD = 0.024395;
LMSLMinusMNullTabulated = 0.003818; LMSLMinusMNullTabulatedSD = 0.008105;
LMSSNullTabulated = -0.050641; LMSSNullTabulatedSD = 0.020280;

postReceptoralContrastMel = [MelLMSNullTabulated MelLMinusMNullTabulated MelSNullTabulated];
postReceptoralContrastLMS = [NaN LMSLMinusMNullTabulated LMSSNullTabulated];

% Set up some standard parameters.
params.targetContrast = 0.42;
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'SilentSubstitutionPIPR';
params.calibrationType = 'BoxDRandomizedLongCableAEyePiece2_ND07CassetteB';
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-2);
params.fieldSizeDegrees = 27.5;
params.pupilDiameterMm = 6;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;

postreceptoralChannels = [1 1 1 0 ; 1 -1 0 0 ; 0 0 1 0]';
postreceptoralLabels = {'L+M+S', 'L-M', 'S'};

% Generate the set of modulations using the table-constructed cone
% fundamentals
params.photoreceptorClasses = 'LConeTabulatedAbsorbance,MConeTabulatedAbsorbance,SConeTabulatedAbsorbance,Melanopsin';
photoreceptorClasses =  allwords(params.photoreceptorClasses);
[cacheData, cacheDataMelTabulated, olCacheDataMelTabulated, paramsMelTabulated, cacheDataLMSTabulated, olCacheDataLMSTabulated, paramsLMSTabulated, cacheDataLMSNullTabulated, cacheDataLMinusMNullTabulated, cacheDataSNullTabulated] =  OLMakeMelAndLMSPopulationNull(params);

% Here, we also record the contrast on the null modulations (0.1, or 10%)
maxContrastNulls = 0.1;

%% [3] Using the average nulls, synthesize the null modulations for each observer
% Obtain the calibration in order to be able to get the predicted spds
cal = LoadCalFile(OLCalibrationTypes.(params.calibrationType).CalFileName);

% Indeed, we also wish to save out the synthetic Mel and LMS
% modulations into cache files. We do this by basically making a copy
% of our un-nulled modulations (from the tabulated cone fundamentals),
% and re-assigned the primary vector for each age.
cacheDataMelTabulatedNulled = cacheDataMelTabulated;
cacheDataLMSTabulatedNulled = cacheDataLMSTabulated;

%% Make the mel nulled
% Iterate over all ages
for observerAgeInYrs = 20:60
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bgPrimaryTabulated = cacheData.data(observerAgeInYrs).backgroundPrimary;
    MelPrimaryTabulated = cacheDataMelTabulated.data(observerAgeInYrs).differencePrimary;
    LMSPrimaryTabulated = cacheDataLMSTabulated.data(observerAgeInYrs).differencePrimary;
    LMSNullPrimaryTabulated = cacheDataLMSNullTabulated.data(observerAgeInYrs).differencePrimary;
    LMinusMNullPrimaryTabulated = cacheDataLMinusMNullTabulated.data(observerAgeInYrs).differencePrimary;
    SNullPrimaryTabulated = cacheDataSNullTabulated.data(observerAgeInYrs).differencePrimary;
    
    % Assemble the primaries in a matrix
    PrimaryTabulated = [bgPrimaryTabulated MelPrimaryTabulated LMSPrimaryTabulated LMSNullPrimaryTabulated LMinusMNullPrimaryTabulated SNullPrimaryTabulated];
    T_receptors = cacheData.data(observerAgeInYrs).describe.T_receptors;
    
    % Construct the synthetic mel and LMS direction
    weights = [1 1 0 MelLMSNullTabulated/maxContrastNulls MelLMinusMNullTabulated/maxContrastNulls MelSNullTabulated/maxContrastNulls]';
    nulledMelanopsinPrimaryTabulated = PrimaryTabulated*weights; % Nulled Mel
    
    % Calculate the spds
    bgSpd = OLPrimaryToSpd(cal, bgPrimaryTabulated);
    nulledMelanopsinSpd = OLPrimaryToSpd(cal, nulledMelanopsinPrimaryTabulated);
    
    % Assign, for each age, the new nulled modulations
    diffPrimary = nulledMelanopsinPrimaryTabulated-bgPrimaryTabulated;
    cacheDataMelTabulatedNulled.data(observerAgeInYrs).differencePrimary = diffPrimary;
    cacheDataMelTabulatedNulled.data(observerAgeInYrs).differenceSpd = OLPrimaryToSpd(cal, bgPrimaryTabulated+diffPrimary)-OLPrimaryToSpd(cal, bgPrimaryTabulated);
    cacheDataMelTabulatedNulled.data(observerAgeInYrs).modulationPrimarySignedPositive = bgPrimaryTabulated+diffPrimary;
    cacheDataMelTabulatedNulled.data(observerAgeInYrs).modulationSpdSignedPositive = OLPrimaryToSpd(cal, bgPrimaryTabulated+diffPrimary);
    cacheDataMelTabulatedNulled.data(observerAgeInYrs).modulationPrimarySignedNegative = bgPrimaryTabulated-diffPrimary;
    cacheDataMelTabulatedNulled.data(observerAgeInYrs).modulationSpdSignedNegative = OLPrimaryToSpd(cal, bgPrimaryTabulated-diffPrimary);
    
    isolateContrastsSignedPositive = (T_receptors*cacheDataMelTabulatedNulled.data(observerAgeInYrs).differenceSpd) ./ (T_receptors*cacheDataMelTabulatedNulled.data(observerAgeInYrs).backgroundSpd);
    isolateContrastsSignedNegative = -(T_receptors*cacheDataMelTabulatedNulled.data(observerAgeInYrs).differenceSpd) ./ (T_receptors*cacheDataMelTabulatedNulled.data(observerAgeInYrs).backgroundSpd);
    fprintf('\n> Observer age: %g\n',observerAgeInYrs);
    for j = 1:size(T_receptors,1)
        fprintf('  - %s: contrast = \t<strong>%f</strong> [pos.] / <strong>%f</strong> [neg.]\n',photoreceptorClasses{j},isolateContrastsSignedPositive(j),isolateContrastsSignedNegative(j));
    end
    
    postReceptoralContrastMelTabulated = postreceptoralChannels \ isolateContrastsSignedPositive;
    for j = 1:size(postreceptoralChannels,2)
        fprintf('  - Postreceptoral %s: contrast = \t<strong>%f</strong> [measured] / <strong>%f</strong> [nominal]\n',postreceptoralLabels{j},postReceptoralContrastMelTabulated(j),postReceptoralContrastMel(j));
    end
end
paramsMelTabulated.modulationDirection = 'MelanopsinDirectedPenumbralIgnorePopulationNull';
paramsMelTabulated.cacheFile = ['Cache-' paramsMelTabulated.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMelTabulatedNulled, olCacheDataMelTabulated, paramsMelTabulated);

%% Make the LMS nulled
% Iterate over all ages
for observerAgeInYrs = 20:60
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bgPrimaryTabulated = cacheData.data(observerAgeInYrs).backgroundPrimary;
    MelPrimaryTabulated = cacheDataMelTabulated.data(observerAgeInYrs).differencePrimary;
    LMSPrimaryTabulated = cacheDataLMSTabulated.data(observerAgeInYrs).differencePrimary;
    LMSNullPrimaryTabulated = cacheDataLMSNullTabulated.data(observerAgeInYrs).differencePrimary;
    LMinusMNullPrimaryTabulated = cacheDataLMinusMNullTabulated.data(observerAgeInYrs).differencePrimary;
    SNullPrimaryTabulated = cacheDataSNullTabulated.data(observerAgeInYrs).differencePrimary;
    
    % Assemble the primaries in a matrix
    PrimaryTabulated = [bgPrimaryTabulated MelPrimaryTabulated LMSPrimaryTabulated LMSNullPrimaryTabulated LMinusMNullPrimaryTabulated SNullPrimaryTabulated];
    T_receptors = cacheData.data(observerAgeInYrs).describe.T_receptors;
    
    % Construct the synthetic mel and LMS direction
    weights = [1 0 1 0 LMSLMinusMNullTabulated/maxContrastNulls LMSSNullTabulated/maxContrastNulls]';
    nulledLMSPrimaryTabulated = PrimaryTabulated*weights; % Nulled LMS
    
    % Calculate the spds
    bgSpd = OLPrimaryToSpd(cal, bgPrimaryTabulated);
    nulledLMSSpd = OLPrimaryToSpd(cal, nulledLMSPrimaryTabulated);
    
    % Assign, for each age, the new nulled modulations
    diffPrimary = nulledLMSPrimaryTabulated-bgPrimaryTabulated;
    cacheDataLMSTabulatedNulled.data(observerAgeInYrs).differencePrimary = diffPrimary;
    cacheDataLMSTabulatedNulled.data(observerAgeInYrs).differenceSpd = OLPrimaryToSpd(cal, bgPrimaryTabulated+diffPrimary)-OLPrimaryToSpd(cal, bgPrimaryTabulated);
    cacheDataLMSTabulatedNulled.data(observerAgeInYrs).modulationPrimarySignedPositive = bgPrimaryTabulated+diffPrimary;
    cacheDataLMSTabulatedNulled.data(observerAgeInYrs).modulationSpdSignedPositive = OLPrimaryToSpd(cal, bgPrimaryTabulated+diffPrimary);
    cacheDataLMSTabulatedNulled.data(observerAgeInYrs).modulationPrimarySignedNegative = bgPrimaryTabulated-diffPrimary;
    cacheDataLMSTabulatedNulled.data(observerAgeInYrs).modulationSpdSignedNegative = OLPrimaryToSpd(cal, bgPrimaryTabulated-diffPrimary);
    
    isolateContrastsSignedPositive = (T_receptors*cacheDataLMSTabulatedNulled.data(observerAgeInYrs).differenceSpd) ./ (T_receptors*cacheDataLMSTabulatedNulled.data(observerAgeInYrs).backgroundSpd);
    isolateContrastsSignedNegative = -(T_receptors*cacheDataLMSTabulatedNulled.data(observerAgeInYrs).differenceSpd) ./ (T_receptors*cacheDataLMSTabulatedNulled.data(observerAgeInYrs).backgroundSpd);
    fprintf('\n> Observer age: %g\n',observerAgeInYrs);
    for j = 1:size(T_receptors,1)
        fprintf('  - %s: contrast = \t<strong>%f</strong> [pos.] / <strong>%f</strong> [neg.]\n',photoreceptorClasses{j},isolateContrastsSignedPositive(j),isolateContrastsSignedNegative(j));
    end
    
    postReceptoralContrastLMSTabulated = postreceptoralChannels \ isolateContrastsSignedPositive;
    for j = 1:size(postreceptoralChannels,2)
        fprintf('  - Postreceptoral %s: contrast = \t<strong>%f</strong> [measured] / <strong>%f</strong> [nominal]\n',postreceptoralLabels{j},postReceptoralContrastLMSTabulated(j),postReceptoralContrastLMS(j));
    end
end
paramsLMSTabulated.modulationDirection = 'LMSDirectedPopulationNull';
paramsLMSTabulated.cacheFile = ['Cache-' paramsLMSTabulated.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataLMSTabulatedNulled, olCacheDataLMSTabulated, paramsLMSTabulated);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PIPR
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'SilentSubstitutionPIPRPulse';
params.calibrationType = 'BoxDRandomizedLongCableAEyePiece2';
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-1.5);
params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin,Rods,LConeHemo,MConeHemo,SConeHemo';
params.fieldSizeDegrees = 27.5;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.05;
params.pupilDiameterMm = 6;

% 470 nm
params.backgroundType = 'MirrorsOff';
params.modulationDirection = 'BluePIPR';
params.receptorIsolateMode = 'PIPR';
params.peakWavelengthNm = 475;
params.fwhmNm = 25;
params.filteredRetinalIrradianceLogPhotons = 13; % In log quanta/cm2/sec
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLMakePIPR(params);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

% 623 nm
params.backgroundType = 'MirrorsOff';
params.modulationDirection = 'RedPIPR';
params.receptorIsolateMode = 'PIPR';
params.peakWavelengthNm = 623;
params.fwhmNm = 25;
params.filteredRetinalIrradianceLogPhotons = 13; % In log quanta/cm2/sec
params.cacheFile = ['Cache-' params.modulationDirection '.mat'];
[cacheData, olCache, params] = OLMakePIPR(params);
OLReceptorIsolateSaveCache(cacheData, olCache, params);

%% [5] Make the modulations
% Do not generate for 20, 21, 28, 29, 32, 36, 
for observerAgeInYrs = [19]
    tic
    OLMakeModulations('Modulation-SilentSubstitutionPIPRBackgroundSS-45s.cfg', observerAgeInYrs, 'BoxDRandomizedLongCableAEyePiece2_ND05CassetteB', [], []) % Background
    OLMakeModulations('Modulation-SilentSubstitutionPIPRMelanopsinDirected-45sPositivePulse5_5sConeNoise.cfg', observerAgeInYrs, 'BoxDRandomizedLongCableAEyePiece2_ND05CassetteB', [], []) % Nulled Melanopsin.
    OLMakeModulations('Modulation-SilentSubstitutionPIPRLMSDirected-45sPositivePulse5_5sConeNoise.cfg', observerAgeInYrs, 'BoxDRandomizedLongCableAEyePiece2_ND05CassetteB', [], []) % Nulled LMS.
    %
    OLMakeModulations('Modulation-SilentSubstitutionPIPRBackgroundPIPR-45s.cfg', observerAgeInYrs, 'BoxDRandomizedLongCableAEyePiece2', [], []) % Background.
    OLMakeModulations('Modulation-SilentSubstitutionPIPRBlue-45sPositivePulse5_5s.cfg', observerAgeInYrs, 'BoxDRandomizedLongCableAEyePiece2', [], []) % Blue PIPR
    OLMakeModulations('Modulation-SilentSubstitutionPIPRRed-45sPositivePulse5_5s.cfg', observerAgeInYrs, 'BoxDRandomizedLongCableAEyePiece2', [], []) % Red PIPR
    toc
end

%% [6] Validate
theDirections = {'MelanopsinDirectedPenumbralIgnorePopulationNull' 'LMSDirectedPopulationNull'};
cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
zeroVector = zeros(1, length(theDirections));
theOnVector = zeroVector;
theOnVector(1) = 1;
theOffVector = zeroVector;
theOffVector(end) = 1;

WaitSecs(2);
for d = 1:length(theDirections)
    [~, ~, validationPath{d}] = OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
        theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', false, 'selectedCalType', 'BoxDRandomizedLongCableAEyePiece2_ND07CassetteB', ...
        'CALCULATE_SPLATTER', false, 'powerLevels', [0 1]);
    close all;
end


Speak('Remove the cassette, then press enter');
pause;
theDirections = {'BluePIPR' 'RedPIPR'};
cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
zeroVector = zeros(1, length(theDirections));
theOnVector = zeroVector;
theOnVector(1) = 1;
theOffVector = zeroVector;
theOffVector(end) = 1;
WaitSecs(2);
for d = 1:length(theDirections)
    [~, ~, validationPath{d}] = OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
        theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', false, 'selectedCalType', 'BoxDRandomizedLongCableAEyePiece2', ...
        'CALCULATE_SPLATTER', false, 'powerLevels', [0 1]);
    close all;
end



