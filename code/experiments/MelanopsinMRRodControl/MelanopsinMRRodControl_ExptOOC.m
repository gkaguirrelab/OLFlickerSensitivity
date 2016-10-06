%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare for the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ask for the observer age
commandwindow;
observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_test');
observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
todayDate = datestr(now, 'mmddyy');

%% Set up the cal
theCalType = 'BoxBRandomizedLongCableDStubby1_ND02';
cacheDir = fullfile(getpref('OneLight', 'cachePath'), 'stimuli');
cal = LoadCalFile(theCalType, [], getpref('OneLight', 'OneLightCalData'));

%% Load the cache files
% MaxMel
olCache1 = OLCache(cacheDir, cal);
params1.modulationDirection = 'MelanopsinDirectedRodControl';
params1.cacheFile = ['Cache-' params1.modulationDirection '.mat'];
cacheData1 = olCache.load(params1.cacheFile);
params1.cacheFile = ['Cache-' params1.modulationDirection '_' observerID '_' todayDate '.mat'];

% L-M
olCache2 = OLCache(cacheDir, cal);
params2.modulationDirection = 'LMinusMDirectedRodControl';
params2.cacheFile = ['Cache-' params2.modulationDirection '.mat'];
cacheData2 = olCache.load(params2.cacheFile);
params2.cacheFile = ['Cache-' params2.modulationDirection '_' observerID '_' todayDate '.mat'];

% Get the photoreceptors
theCanonicalPhotoreceptors = cacheData1.data(observerAgeInYrs).describe.photoreceptors;
T_receptors = cacheData1.data(observerAgeInYrs).describe.T_receptors;
postreceptoralCombinations = [1 1 1 0 0 ; 1 -1 0 0 0 ; 0 0 1 0 0 ; 0 0 0 1 0 ; 0 0 0 0 1]; % LMS, L-M, S, Mel, Rod

%% Correct the spectra
primaryValues = [cacheDataMaxMel.data(observerAgeInYrs).backgroundPrimary ...
    cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedPositive ...
    cacheDataMaxMel.data(observerAgeInYrs).modulationPrimarySignedNegative ...
    cacheDataLMinusM.data(observerAgeInYrs).modulationPrimarySignedPositive ...
    cacheDataLMinusM.data(observerAgeInYrs).modulationPrimarySignedNegative];
NIter = 2;
lambda = 0.8;
NDFilter = [];
cacheDataMaxMel.cal
meterType = 'PR-670';
spectroRadiometerOBJ = [];
spectroRadiometerOBJWillShutdownAfterMeasurement = true;

% Run the correction
[correctedPrimaryValues primariesCorrectedAll deltaPrimariesCorrectedAll measuredSpd measuredSpdRaw predictedSpd] = OLCorrectPrimaryValues(cal, primaryValues, NIter, lambda, NDFilter, ...
    meterType, spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement);

% Calculate the contrasts
for iter = 1:NIter
    % Save out information about the correction
    [contrastsPositive1(:, iter) postreceptoralContrastsPositive1(:, iter)] = ComputeAndReportContrastsFromSpds(['Iteration ' num2str(iter, '%02.0f')] ,theCanonicalPhotoreceptors,T_receptors,...
        measuredSpd{1}(:, end), measuredSpd{2}(:, end), postreceptoralCombinations, true);
    [contrastsNegative1(:, iter) postreceptoralContrastsNegative1(:, iter)] = ComputeAndReportContrastsFromSpds(['Iteration ' num2str(iter, '%02.0f')] ,theCanonicalPhotoreceptors,T_receptors,...
        measuredSpd{1}(:, end), measuredSpd{3}(:, end), postreceptoralCombinations, true);
    [contrastsPositive2(:, iter) postreceptoralContrastsPositive2(:, iter)] = ComputeAndReportContrastsFromSpds(['Iteration ' num2str(iter, '%02.0f')] ,theCanonicalPhotoreceptors,T_receptors,...
        measuredSpd{1}(:, end), measuredSpd{4}(:, end), postreceptoralCombinations, true);
    [contrastsNegative2(:, iter) postreceptoralContrastsNegative2(:, iter)] = ComputeAndReportContrastsFromSpds(['Iteration ' num2str(iter, '%02.0f')] ,theCanonicalPhotoreceptors,T_receptors,...
        measuredSpd{1}(:, end), measuredSpd{5}(:, end), postreceptoralCombinations, true);
end

% Replace the values in the cache files
for ii = 1:length(cacheData1.data)
    if ii == observerAgeInYrs;
        cacheData1.data(ii).backgroundPrimary = correctedPrimaryValues(:, 1);
        cacheData1.data(ii).modulationPrimarySignedPositive = correctedPrimaryValues(:, 2);
        cacheData1.data(ii).modulationPrimarySignedNegative = correctedPrimaryValues(:, 3);
        cacheData1.data(ii).differencePrimary = cacheData1.data(ii).modulationPrimarySignedPositive - cacheData1.data(ii).backgroundPrimary;
        cacheData1.data(ii).correction.backgroundPrimaryCorrectedAll = primariesCorrectedAll{1};
        cacheData1.data(ii).correction.deltaBackgroundPrimaryInferredAll = deltaPrimariesCorrectedAll{1};
        cacheData1.data(ii).correction.bgSpdAll = measuredSpd{1};
        cacheData1.data(ii).correction.modulationPrimaryPositiveCorrectedAll = primariesCorrectedAll{2};
        cacheData1.data(ii).correction.deltaModulationPrimaryPositveInferredAll = deltaPrimariesCorrectedAll{2};
        cacheData1.data(ii).correction.modPositiveSpdAll = measuredSpd{2};
        cacheData1.data(ii).correction.modulationPrimaryNegativeCorrectedAll = primariesCorrectedAll{3};
        cacheData1.data(ii).correction.deltaModulationPrimaryNegativeInferredAll = deltaPrimariesCorrectedAll{3};
        cacheData1.data(ii).correction.modNegativeSpdAll = measuredSpd{3};
        cacheData1.data(ii).correction.contrastsPositive = contrastsPositive1;
        cacheData1.data(ii).correction.postreceptoralContrastsPositive = postreceptoralContrastsPositive1;
        cacheData1.data(ii).correction.contrastsNegative = contrastsNegative1;
        cacheData1.data(ii).correction.postreceptoralContrastsNegative = postreceptoralContrastsNegative1;
    else
        cacheData1.data(ii).describe = [];
        cacheData1.data(ii).backgroundPrimary = [];
        cacheData1.data(ii).backgroundSpd = [];
        cacheData1.data(ii).differencePrimary = [];
        cacheData1.data(ii).differenceSpd = [];
        cacheData1.data(ii).modulationPrimarySignedPositive = [];
        cacheData1.data(ii).modulationPrimarySignedNegative = [];
        cacheData1.data(ii).modulationSpdSignedPositive = [];
        cacheData1.data(ii).modulationSpdSignedNegative = [];
        cacheData1.data(ii).ambientSpd = [];
        cacheData1.data(ii).operatingPoint = [];
        cacheData1.data(ii).computeMethod = [];
    end
end

% Replace the values in the cache files
for ii = 1:length(cacheData2.data)
    if ii == observerAgeInYrs;
        cacheData2.data(ii).backgroundPrimary = correctedPrimaryValues(:, 1);
        cacheData2.data(ii).modulationPrimarySignedPositive = correctedPrimaryValues(:, 2);
        cacheData2.data(ii).modulationPrimarySignedNegative = correctedPrimaryValues(:, 3);
        cacheData2.data(ii).differencePrimary = cacheData2.data(ii).modulationPrimarySignedPositive - cacheData2.data(ii).backgroundPrimary;
        cacheData2.data(ii).correction.backgroundPrimaryCorrectedAll = primariesCorrectedAll{1};
        cacheData2.data(ii).correction.deltaBackgroundPrimaryInferredAll = deltaPrimariesCorrectedAll{1};
        cacheData2.data(ii).correction.bgSpdAll = measuredSpd{1};
        cacheData2.data(ii).correction.modulationPrimaryPositiveCorrectedAll = primariesCorrectedAll{2};
        cacheData2.data(ii).correction.deltaModulationPrimaryPositveInferredAll = deltaPrimariesCorrectedAll{2};
        cacheData2.data(ii).correction.modPositiveSpdAll = measuredSpd{2};
        cacheData2.data(ii).correction.modulationPrimaryNegativeCorrectedAll = primariesCorrectedAll{3};
        cacheData2.data(ii).correction.deltaModulationPrimaryNegativeInferredAll = deltaPrimariesCorrectedAll{3};
        cacheData2.data(ii).correction.modNegativeSpdAll = measuredSpd{3};
        cacheData2.data(ii).correction.contrasts = contrasts;
        cacheData2.data(ii).correction.postreceptoralContrasts = postreceptoralContrasts;
    else
        cacheData2.data(ii).describe = [];
        cacheData2.data(ii).backgroundPrimary = [];
        cacheData2.data(ii).backgroundSpd = [];
        cacheData2.data(ii).differencePrimary = [];
        cacheData2.data(ii).differenceSpd = [];
        cacheData2.data(ii).modulationPrimarySignedPositive = [];
        cacheData2.data(ii).modulationPrimarySignedNegative = [];
        cacheData2.data(ii).modulationSpdSignedPositive = [];
        cacheData2.data(ii).modulationSpdSignedNegative = [];
        cacheData2.data(ii).ambientSpd = [];
        cacheData2.data(ii).operatingPoint = [];
        cacheData2.data(ii).computeMethod = [];
    end
end

%% Save out the corrected cache files
OLReceptorIsolateSaveCache(cacheData1, olCache1, params1);
OLReceptorIsolateSaveCache(cacheData2, olCache2, params2);