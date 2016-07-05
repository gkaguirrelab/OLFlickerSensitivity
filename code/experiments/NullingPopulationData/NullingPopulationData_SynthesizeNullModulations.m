%% NullingPopulationData_SynthesizeNullModulations.m
%
% This program performs in-depth analyses of the nulling population data.
% It compares contrasts seen by the nomogram-constructed LMS cone
% fundamentals to those seen by the table-constructed LMS cone
% fundamentals.
%
% 2/12/16   ms      Written,

clear; close all;

%% [1] Obtain grand averages for the nulling
% Contrasts read in from MelLMS_GrandMean.csv
MelLMSNull = -0.009391; MelLMSNullSD = 0.012872;
MelLMinusMNull = -0.013146; MelLMinusMNullSD = 0.005962;
MelSNull = 0.009577; MelSNullSD = 0.023602;
LMSLMinusMNull = 0.014859; LMSLMinusMNullSD = 0.006967;
LMSSNull = -0.029586; LMSSNullSD = 0.018985;

% Contrasts read in from x/xConesFromTabulatd/Absorbance/MelLMS_GrandMean.csv
MelLMSNullTabulated = -0.001688; MelLMSNullTabulatedSD = 0.012465;
MelLMinusMNullTabulated = -0.003165; MelLMinusMNullTabulatedSD = 0.006846;
MelSNullTabulated = 0.040468; MelSNullTabulatedSD = 0.024395;
LMSLMinusMNullTabulated = 0.003818; LMSLMinusMNullTabulatedSD = 0.008105;
LMSSNullTabulated = -0.050641; LMSSNullTabulatedSD = 0.020280;

% Define the postreceptoral channels
postreceptoralChannels = [1 1 1 0 ; 1 -1 0 0 ; 0 0 1 0]';

%% [2] We construct the following modulations
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

% Set up some standard parameters.
% We use the calibration type 'BoxDRandomizedLongCableAEyePiece2_ND10',
% which corresponds to what we have used for the nulling population data
params.targetContrast = 0.42;
params.experiment = 'OLFlickerSensitivity';
params.experimentSuffix = 'NullingPopulationData';
params.calibrationType = 'BoxDRandomizedLongCableAEyePiece2_ND10';
params.whichReceptorsToMinimize = [];
params.CALCULATE_SPLATTER = false;
params.maxPowerDiff = 10^(-2);
params.fieldSizeDegrees = 27.5;
params.pupilDiameterMm = 6;
params.isActive = 1;
params.useAmbient = 1;
params.REFERENCE_OBSERVER_AGE = 32;
params.primaryHeadRoom = 0.05;

% First, generate the set of directions using the nomogram-constructed cone
% fundamentals
params.photoreceptorClasses = 'LCone,MCone,SCone,Melanopsin';
[cacheData, cacheDataMel, olCacheMel, paramsMel, cacheDataLMS, olCacheLMS, paramsLMS, cacheDataLMSNull, cacheDataLMinusMNull, cacheDataSNull] =  OLMakeMelAndLMS(params);

% Then, generate the set of modulations using the table-constructed cone
% fundamentals
params.photoreceptorClasses = 'LConeTabulatedAbsorbance,MConeTabulatedAbsorbance,SConeTabulatedAbsorbance,Melanopsin';
[cacheDataTabulated, cacheDataMelTabulated, olCacheMelTabulated, paramsMelTabulated, cacheDataLMSTabulated, olCacheLMSTabulated, paramsLMSTabulated, cacheDataLMSNullTabulated, cacheDataLMinusMNullTabulated, cacheDataSNullTabulated] =  OLMakeMelAndLMS(params);

% Here, we also record the contrast on the null modulations (0.1, or 10%)
maxContrastNulls = 0.1;

%% [3] Using the average nulls, synthesize the null modulations for each observer
% Obtain the calibration in order to be able to get the predicted spds
cal = LoadCalFile(OLCalibrationTypes.(params.calibrationType).CalFileName);

c = 1; % Counter variable


% Indeed, we also wish to save out the synthetic Mel and LMS
% modulations into cache files. We do this by basically making a copy
% of our un-nulled modulations (from the tabulated cone fundamentals),
% and re-assigned the primary vector for each age.
cacheDataMelTabulatedNulled = cacheDataMelTabulated;
cacheDataLMSTabulatedNulled = cacheDataLMSTabulated;

% Iterate over all ages
for observerAgeInYrs = 20:60
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Pull out the primary values from the nomogram-constructed cache files
    bgPrimary = cacheData.data(observerAgeInYrs).backgroundPrimary;
    MelPrimary = cacheDataMel.data(observerAgeInYrs).differencePrimary;
    LMSPrimary = cacheDataLMS.data(observerAgeInYrs).differencePrimary;
    LMSNullPrimary = cacheDataLMSNull.data(observerAgeInYrs).differencePrimary;
    LMinusMNullPrimary = cacheDataLMinusMNull.data(observerAgeInYrs).differencePrimary;
    SNullPrimary = cacheDataSNull.data(observerAgeInYrs).differencePrimary;
    
    % Assemble the primaries in a matrix
    primary = [bgPrimary MelPrimary LMSPrimary LMSNullPrimary LMinusMNullPrimary SNullPrimary];
    
    % Construct the synthetic mel and LMS direction
    weights = [1 1 0 MelLMSNull/maxContrastNulls MelLMinusMNull/maxContrastNulls MelSNull/maxContrastNulls]';
    nulledMelanopsinPrimary = primary*weights; % Nulled Mel
    weights = [1 0 1 0 LMSLMinusMNull/maxContrastNulls LMSSNull/maxContrastNulls]';
    nulledLMSPrimary = primary*weights; % Nulled LMS
    
    % Calculate the spds
    bgSpd = OLPrimaryToSpd(cal, bgPrimary);
    nulledMelanopsinSpd = OLPrimaryToSpd(cal, nulledMelanopsinPrimary);
    nulledLMSSpd = OLPrimaryToSpd(cal, nulledLMSPrimary);
    
    % Extract the T_receptors and calculate the contrasts
    T_receptors = cacheDataMel.data(observerAgeInYrs).describe.T_receptors;
    T_receptorsTabulated = cacheDataMelTabulated.data(observerAgeInYrs).describe.T_receptors;
    contrastsMelNomoDirNomoContrast = ComputeAndReportContrastsFromSpds('',allwords(params.photoreceptorClasses),T_receptors,bgSpd,nulledMelanopsinSpd,false);
    postReceptoralContrastMelNomoDirNomoContrast(:, c) = postreceptoralChannels \ contrastsMelNomoDirNomoContrast;
    contrastsLMSNomoDirNomoContrast = ComputeAndReportContrastsFromSpds('',allwords(params.photoreceptorClasses),T_receptors,bgSpd,nulledLMSSpd,false);
    postReceptoralContrastLMSNomoDirNomoContrast(:, c) = postreceptoralChannels \ contrastsLMSNomoDirNomoContrast;
    contrastsMelNomoDirTabulatedContrast = ComputeAndReportContrastsFromSpds('',allwords(params.photoreceptorClasses),T_receptorsTabulated,bgSpd,nulledMelanopsinSpd,false);
    postReceptoralContrastMelNomoDirTabulatedContrast(:, c) = postreceptoralChannels \ contrastsMelNomoDirTabulatedContrast;
    contrastsLMSNomoDirTabulatedContrast = ComputeAndReportContrastsFromSpds('',allwords(params.photoreceptorClasses),T_receptorsTabulated,bgSpd,nulledLMSSpd,false);
    postReceptoralContrastLMSNomoDirTabulatedContrast(:, c) = postreceptoralChannels \ contrastsLMSNomoDirTabulatedContrast;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    bgPrimaryTabulated = cacheDataTabulated.data(observerAgeInYrs).backgroundPrimary;
    MelPrimaryTabulated = cacheDataMelTabulated.data(observerAgeInYrs).differencePrimary;
    LMSPrimaryTabulated = cacheDataLMSTabulated.data(observerAgeInYrs).differencePrimary;
    LMSNullPrimaryTabulated = cacheDataLMSNullTabulated.data(observerAgeInYrs).differencePrimary;
    LMinusMNullPrimaryTabulated = cacheDataLMinusMNullTabulated.data(observerAgeInYrs).differencePrimary;
    SNullPrimaryTabulated = cacheDataSNullTabulated.data(observerAgeInYrs).differencePrimary;
    
    % Assemble the primaries in a matrix
    PrimaryTabulated = [bgPrimaryTabulated MelPrimaryTabulated LMSPrimaryTabulated LMSNullPrimaryTabulated LMinusMNullPrimaryTabulated SNullPrimaryTabulated];
    
    % Construct the synthetic mel and LMS direction
    weights = [1 1 0 MelLMSNullTabulated/maxContrastNulls MelLMinusMNullTabulated/maxContrastNulls MelSNullTabulated/maxContrastNulls]';
    nulledMelanopsinPrimaryTabulated = PrimaryTabulated*weights; % Nulled Mel
    weights = [1 0 1 0 LMSLMinusMNullTabulated/maxContrastNulls LMSSNullTabulated/maxContrastNulls]';
    nulledLMSPrimaryTabulated = PrimaryTabulated*weights; % Nulled LMS
    
    % Calculate the spds
    bgSpd = OLPrimaryToSpd(cal, bgPrimaryTabulated);
    nulledMelanopsinSpd = OLPrimaryToSpd(cal, nulledMelanopsinPrimaryTabulated);
    nulledLMSSpd = OLPrimaryToSpd(cal, nulledLMSPrimaryTabulated);
    
    % Extract the T_receptors and calculate the contrasts
    T_receptors = cacheDataMel.data(observerAgeInYrs).describe.T_receptors;
    T_receptorsTabulated = cacheDataMelTabulated.data(observerAgeInYrs).describe.T_receptors;
    contrastsMelTabulatedDirNomoContrast = ComputeAndReportContrastsFromSpds('',allwords(params.photoreceptorClasses),T_receptors,bgSpd,nulledMelanopsinSpd,false);
    postReceptoralContrastMelTabulatedDirNomoContrast(:, c) = postreceptoralChannels \ contrastsMelTabulatedDirNomoContrast;
    contrastsLMSTabulatedDirNomoContrast = ComputeAndReportContrastsFromSpds('',allwords(params.photoreceptorClasses),T_receptors,bgSpd,nulledLMSSpd,false);
    postReceptoralContrastLMSTabulatedDirNomoContrast(:, c) = postreceptoralChannels \ contrastsLMSTabulatedDirNomoContrast;
    contrastsMelTabulatedDirTabulatedContrast = ComputeAndReportContrastsFromSpds('',allwords(params.photoreceptorClasses),T_receptorsTabulated,bgSpd,nulledMelanopsinSpd,false);
    postReceptoralContrastMelTabulatedDirTabulatedContrast(:, c) = postreceptoralChannels \ contrastsMelTabulatedDirTabulatedContrast;
    contrastsLMSTabulatedDirTabulatedContrast = ComputeAndReportContrastsFromSpds('',allwords(params.photoreceptorClasses),T_receptorsTabulated,bgSpd,nulledLMSSpd,false);
    postReceptoralContrastLMSTabulatedDirTabulatedContrast(:, c) = postreceptoralChannels \ contrastsLMSTabulatedDirTabulatedContrast;
    
    c = c+1; % Increment the counter
    % For a 32 year old observer, let's also find out the contrast seen by the tabulated cones in the nulling directions (LMS, L-M S)
    if observerAgeInYrs == 32
        % Get the background spds
        bgSpd = OLPrimaryToSpd(cal, bgPrimary);
        LMSNullSpd = OLPrimaryToSpd(cal, bgPrimary+LMSNullPrimary);
        LMinusMNullSpd = OLPrimaryToSpd(cal, bgPrimary+LMinusMNullPrimary);
        SNullSpd = OLPrimaryToSpd(cal, bgPrimary+SNullPrimary);
        
        % Calculate the contrast seen buy the nominal, nomogram-constructed
        % observer. This should be 10%.
        LMSContrastNominal = T_receptors*(LMSNullSpd-bgSpd)./(T_receptors*bgSpd);
        LMinusMContrastNominal = T_receptors*(LMinusMNullSpd-bgSpd)./(T_receptors*bgSpd);
        SContrastNominal = T_receptors*(SNullSpd-bgSpd)./(T_receptors*bgSpd);
        postReceptoralContrastLMSNominal= postreceptoralChannels \ LMSContrastNominal;
        postReceptoralContrastLMinusMNominal = postreceptoralChannels \ LMinusMContrastNominal;
        postReceptoralContrastSNominal = postreceptoralChannels \ SContrastNominal;
        
        % Calculate the contrast seen buy the nominal, nomogram-constructed
        % observer. This should be /around/ 10%, but not exactly.
        LMSContrastTabulated = T_receptorsTabulated*(LMSNullSpd-bgSpd)./(T_receptorsTabulated*bgSpd)
        LMinusMContrastTabulated = T_receptorsTabulated*(LMinusMNullSpd-bgSpd)./(T_receptorsTabulated*bgSpd)
        SContrastTabulated = T_receptorsTabulated*(SNullSpd-bgSpd)./(T_receptorsTabulated*bgSpd)
        postReceptoralContrastLMSTabulated= postreceptoralChannels \ LMSContrastTabulated;
        postReceptoralContrastLMinusMTabulated = postreceptoralChannels \ LMinusMContrastTabulated;
        postReceptoralContrastSTabulated = postreceptoralChannels \ SContrastTabulated;
        
        % Dump out a table of contrasts
        fid = fopen('NullingPopulationData_ContrastNominalVsTabulated.csv', 'w');
        fprintf(fid, 'Nulling direction,Cone Class,Assumed contrast,Tabulated contrast\n');
        fprintf(fid, 'LMS,L,%.4f,%.4f\n', LMSContrastNominal(1), LMSContrastTabulated(1));
        fprintf(fid, 'LMS,M,%.4f,%.4f\n', LMSContrastNominal(2), LMSContrastTabulated(2));
        fprintf(fid, 'LMS,S,%.4f,%.4f\n', LMSContrastNominal(3), LMSContrastTabulated(3));
        fprintf(fid, '\n');
        fprintf(fid, 'L-M,L,%.4f,%.4f\n', LMinusMContrastNominal(1), LMinusMContrastTabulated(1));
        fprintf(fid, 'L-M,M,%.4f,%.4f\n', LMinusMContrastNominal(2), LMinusMContrastTabulated(2));
        fprintf(fid, 'L-M,S,%.4f,%.4f\n', LMinusMContrastNominal(3), LMinusMContrastTabulated(3));
        fprintf(fid, '\n');
        fprintf(fid, 'S,L,%.4f,%.4f\n', postReceptoralContrastSNominal(1), postReceptoralContrastSTabulated(1));
        fprintf(fid, 'S,M,%.4f,%.4f\n', postReceptoralContrastSNominal(2), postReceptoralContrastSTabulated(2));
        fprintf(fid, 'S,S,%.4f,%.4f\n', postReceptoralContrastSNominal(3), postReceptoralContrastSTabulated(3));
        fclose(fid);
    end
    
    % Assign, for each age, the new nulled modulations
    diffPrimary = nulledMelanopsinPrimaryTabulated-bgPrimaryTabulated;
    cacheDataMelTabulatedNulled.data(observerAgeInYrs).differencePrimary = diffPrimary;
    cacheDataMelTabulatedNulled.data(observerAgeInYrs).differenceSpd = OLPrimaryToSpd(cal, bgPrimaryTabulated+diffPrimary)-OLPrimaryToSpd(cal, bgPrimaryTabulated);
    cacheDataMelTabulatedNulled.data(observerAgeInYrs).modulationPrimarySignedPositive = bgPrimaryTabulated+diffPrimary;
    cacheDataMelTabulatedNulled.data(observerAgeInYrs).modulationSpdSignedPositive = OLPrimaryToSpd(cal, bgPrimaryTabulated+diffPrimary);
    cacheDataMelTabulatedNulled.data(observerAgeInYrs).modulationPrimarySignedNegative = bgPrimaryTabulated-diffPrimary;
    cacheDataMelTabulatedNulled.data(observerAgeInYrs).modulationSpdSignedNegative = OLPrimaryToSpd(cal, bgPrimaryTabulated-diffPrimary);
    
    % Assign, for each age, the new nulled modulations
    diffPrimary = nulledLMSPrimaryTabulated-bgPrimaryTabulated;
    cacheDataLMSTabulatedNulled.data(observerAgeInYrs).differencePrimary = diffPrimary;
    cacheDataLMSTabulatedNulled.data(observerAgeInYrs).differenceSpd = OLPrimaryToSpd(cal, bgPrimaryTabulated+diffPrimary)-OLPrimaryToSpd(cal, bgPrimaryTabulated);
    cacheDataLMSTabulatedNulled.data(observerAgeInYrs).modulationPrimarySignedPositive = bgPrimaryTabulated+diffPrimary;
    cacheDataLMSTabulatedNulled.data(observerAgeInYrs).modulationSpdSignedPositive = OLPrimaryToSpd(cal, bgPrimaryTabulated+diffPrimary);
    cacheDataLMSTabulatedNulled.data(observerAgeInYrs).modulationPrimarySignedNegative = bgPrimaryTabulated-diffPrimary;
    cacheDataLMSTabulatedNulled.data(observerAgeInYrs).modulationSpdSignedNegative = OLPrimaryToSpd(cal, bgPrimaryTabulated-diffPrimary);
end

% Save out our synthetic Mel and LMS
paramsMelTabulated.modulationDirection = 'MelanopsinDirectedPenumbralIgnorePopulationNull';
paramsMelTabulated.cacheFile = ['Cache-' paramsMelTabulated.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataMelTabulatedNulled, olCacheMelTabulated, paramsMelTabulated);
paramsLMSTabulated.modulationDirection = 'LMSDirectedPopulationNull';
paramsLMSTabulated.cacheFile = ['Cache-' paramsLMSTabulated.modulationDirection '.mat'];
OLReceptorIsolateSaveCache(cacheDataLMSTabulatedNulled, olCacheLMSTabulated, paramsLMSTabulated);

%% [4] Plot our results
figure;

% Set some useful parameters
xLimVals = [0 4]; ylimVals = [-0.08 0.08];
xOffset = linspace(-0.35, 0.35, 4);
randscale = 10; % Number to scale jitter by
NContrastVals = size(postReceptoralContrastMelNomoDirNomoContrast, 2);
RGBVals = [127 201 127 ; 190 174 212 ; 253 192 134 ; 230 85 13]/255;


% Plot the contrasts
subplot(2, 2, 1);

plot(xLimVals, [0 0], '-', 'Color', [0.3 0.3 0.3]); hold on;
for i = 1:3
    h1 = plot(i+xOffset(2)+((rand(1, NContrastVals)-0.5)/randscale), postReceptoralContrastMelNomoDirNomoContrast(i, :)', 'o', 'Color', 'k', 'MarkerFaceColor', RGBVals(2, :)); hold on;
    h2 = plot(i+xOffset(3)+((rand(1, NContrastVals)-0.5)/randscale), postReceptoralContrastMelTabulatedDirNomoContrast(i, :)', 'o', 'Color', 'k', 'MarkerFaceColor', RGBVals(3, :)); hold on;
end
h3 = errorbar(1+xOffset(1), MelLMSNull, MelLMSNullSD, 's', 'Color', 'k', 'MarkerFaceColor', RGBVals(1, :));
errorbar(2+xOffset(1), MelLMinusMNull, MelLMinusMNullSD, 's', 'Color', 'k', 'MarkerFaceColor', RGBVals(1, :));
errorbar(3+xOffset(1), MelSNull, MelSNullSD, 's', 'Color', 'k', 'MarkerFaceColor', RGBVals(1, :));
pbaspect([1 1 1]);
title('42% Mel modulation');

xlim(xLimVals); ylim(ylimVals);
set(gca, 'XTick', 1:3); set(gca, 'XTickLabel',  {'LMS', 'L-M', 'S'}); set(gca, 'YTick', [-0.075 -0.05 -0.025 0 0.025 0.05 0.075]); set(gca, 'YTick', [-0.075 -0.05 -0.025 0 0.025 0.05 0.075]);
xlabel('Null'); ylabel('Contrast seen by LMS_{nomo}');
box off;
set(gca, 'TickDir', 'out');

subplot(2, 2, 2);
plot(xLimVals, [0 0], '-', 'Color', [0.3 0.3 0.3]); hold on;
for i = 2:3
    plot(i+xOffset(2)+((rand(1, NContrastVals)-0.5)/randscale), postReceptoralContrastLMSNomoDirNomoContrast(i, :)', 'o', 'Color', 'k', 'MarkerFaceColor', RGBVals(2, :)); hold on;
    plot(i+xOffset(3)+((rand(1, NContrastVals)-0.5)/randscale), postReceptoralContrastLMSTabulatedDirNomoContrast(i, :)', 'o', 'Color', 'k', 'MarkerFaceColor', RGBVals(3, :)); hold on;
end
errorbar(2+xOffset(1), LMSLMinusMNull, LMSLMinusMNullSD, 's', 'Color', 'k', 'MarkerFaceColor', RGBVals(1, :));
errorbar(3+xOffset(1), LMSSNull, LMSSNullSD, 's', 'Color', 'k', 'MarkerFaceColor', RGBVals(1, :));
pbaspect([1 1 1]);
title('42% L+M+S modulation');
xlim(xLimVals); ylim(ylimVals);
set(gca, 'XTick', 1:3); set(gca, 'XTickLabel',  {'LMS', 'L-M', 'S'}); set(gca, 'YTick', [-0.075 -0.05 -0.025 0 0.025 0.05 0.075]);
xlabel('Null'); ylabel('Contrast seen by LMS_{nomo}');
box off;
set(gca, 'TickDir', 'out');

subplot(2, 2, 3);
plot(xLimVals, [0 0], '-', 'Color', [0.3 0.3 0.3]); hold on;
for i = 1:3
    plot(i+xOffset(2)+((rand(1, NContrastVals)-0.5)/randscale), postReceptoralContrastMelNomoDirTabulatedContrast(i, :)', 'o', 'Color', 'k', 'MarkerFaceColor', RGBVals(2, :)); hold on;
    plot(i+xOffset(3)+((rand(1, NContrastVals)-0.5)/randscale), postReceptoralContrastMelTabulatedDirTabulatedContrast(i, :)', 'o', 'Color', 'k', 'MarkerFaceColor', RGBVals(3, :)); hold on;
end
errorbar(1+xOffset(1), MelLMSNullTabulated, MelLMSNullTabulatedSD, 's', 'Color', 'k', 'MarkerFaceColor', RGBVals(1, :));
errorbar(2+xOffset(1), MelLMinusMNullTabulated, MelLMinusMNullTabulatedSD, 's', 'Color', 'k', 'MarkerFaceColor', RGBVals(1, :));
errorbar(3+xOffset(1), MelSNullTabulated, MelSNullTabulatedSD, 's', 'Color', 'k', 'MarkerFaceColor', RGBVals(1, :));
pbaspect([1 1 1]);
xlim(xLimVals); ylim(ylimVals);
set(gca, 'XTick', 1:3); set(gca, 'XTickLabel',  {'LMS', 'L-M', 'S'}); set(gca, 'YTick', [-0.075 -0.05 -0.025 0 0.025 0.05 0.075]);
xlabel('Null'); ylabel('Contrast seen by LMS_{tabulated}');
box off;
set(gca, 'TickDir', 'out');

subplot(2, 2, 4);
plot(xLimVals, [0 0], '-', 'Color', [0.3 0.3 0.3]); hold on;
for i = 2:3
    plot(i+xOffset(2)+((rand(1, NContrastVals)-0.5)/randscale), postReceptoralContrastLMSNomoDirTabulatedContrast(i, :)', 'o', 'Color', 'k', 'MarkerFaceColor', RGBVals(2, :)); hold on;
    plot(i+xOffset(3)+((rand(1, NContrastVals)-0.5)/randscale), postReceptoralContrastLMSTabulatedDirTabulatedContrast(i, :)', 'o', 'Color', 'k', 'MarkerFaceColor', RGBVals(3, :)); hold on;
end
errorbar(2+xOffset(1), LMSLMinusMNullTabulated, LMSLMinusMNullTabulatedSD, 's', 'Color', 'k', 'MarkerFaceColor', RGBVals(1, :));
errorbar(3+xOffset(1), LMSSNullTabulated, LMSSNullTabulatedSD, 's', 'Color', 'k', 'MarkerFaceColor', RGBVals(1, :));
pbaspect([1 1 1]);

xlim(xLimVals); ylim(ylimVals);
set(gca, 'XTick', 1:3); set(gca, 'XTickLabel',  {'LMS', 'L-M', 'S'}); set(gca, 'YTick', [-0.075 -0.05 -0.025 0 0.025 0.05 0.075]);
xlabel('Null'); ylabel('Contrast seen by LMS_{tabulated}');
box off;
set(gca, 'TickDir', 'out');

% Load in the validated spectra
basePath1 = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/Cache-LMSDirectedPopulationNull/BoxDRandomizedLongCableAEyePiece2_ND10/21-Jan-2016_16_04_06/validation';
theDirs = dir(basePath1);
c = 1; % Counter
for d = 1:length(theDirs)
    if ~(strcmp(theDirs(d).name, '.')) & ~(strcmp(theDirs(d).name, '..')) & theDirs(d).isdir
        tmp = load(fullfile(basePath1, theDirs(d).name, 'Cache-LMSDirectedPopulationNull-BoxDRandomizedLongCableAEyePiece2_ND10-SpotCheck.mat'));
        bgSpd = tmp(1).cals{1}.modulationBGMeas.meas.pr650.spectrum;
        modSpdPositive = tmp(1).cals{1}.modulationMaxMeas.meas.pr650.spectrum;
        modSpdNegative = tmp(1).cals{1}.modulationMinMeas.meas.pr650.spectrum;
        observerAgeInYrs = tmp(1).cals{1}.describe.REFERENCE_OBSERVER_AGE;
        T_receptors = tmp(1).cals{1}.describe.cache.data(observerAgeInYrs).describe.T_receptors;
        
        contrastLMSPosValidated(:, c) = T_receptors*(modSpdPositive-bgSpd) ./ (T_receptors*bgSpd);
        contrastLMSNegValidated(:, c) = -(T_receptors*(modSpdNegative-bgSpd) ./ (T_receptors*bgSpd));
        
        c = c+1; % Increment counter
    end
end

% Average the two arms
contrastLMSValidated(:, :, 1) = contrastLMSPosValidated;
contrastLMSValidated(:, :, 2) = contrastLMSNegValidated;
contrastLMSValidated = mean(contrastLMSValidated, 3);

% Extract the postreceptoral channels
postreceptoralContrastLMSValidated = postreceptoralChannels \ contrastLMSValidated;

basePath1 = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/Cache-MelanopsinDirectedPenumbralIgnorePopulationNull/BoxDRandomizedLongCableAEyePiece2_ND10/21-Jan-2016_16_04_06/validation';
theDirs = dir(basePath1);
c = 1; % Counter
for d = 1:length(theDirs)
    if ~(strcmp(theDirs(d).name, '.')) & ~(strcmp(theDirs(d).name, '..')) & theDirs(d).isdir
        tmp = load(fullfile(basePath1, theDirs(d).name, 'Cache-MelanopsinDirectedPenumbralIgnorePopulationNull-BoxDRandomizedLongCableAEyePiece2_ND10-SpotCheck.mat'));
        bgSpd = tmp(1).cals{1}.modulationBGMeas.meas.pr650.spectrum;
        modSpdPositive = tmp(1).cals{1}.modulationMaxMeas.meas.pr650.spectrum;
        modSpdNegative = tmp(1).cals{1}.modulationMinMeas.meas.pr650.spectrum;
        observerAgeInYrs = tmp(1).cals{1}.describe.REFERENCE_OBSERVER_AGE;
        T_receptors = tmp(1).cals{1}.describe.cache.data(observerAgeInYrs).describe.T_receptors;
        
        contrastMelPosValidated(:, c) = T_receptors*(modSpdPositive-bgSpd) ./ (T_receptors*bgSpd);
        contrastMelNegValidated(:, c) = -(T_receptors*(modSpdNegative-bgSpd) ./ (T_receptors*bgSpd));
        
        c = c+1; % Increment counter
    end
end

% Average the two arms
contrastMelValidated(:, :, 1) = contrastMelPosValidated;
contrastMelValidated(:, :, 2) = contrastMelNegValidated;
contrastMelValidated = mean(contrastMelValidated, 3);

% Extract the postreceptoral channels
postreceptoralContrastMelValidated = postreceptoralChannels \ contrastMelValidated;

% Plot all of this information, too
subplot(2, 2, 3);
NContrastVals = size(postreceptoralContrastMelValidated, 2);
h4 = plot(1+xOffset(4)+((rand(1, NContrastVals)-0.5)/randscale), postreceptoralContrastMelValidated(1, :), 's', 'Color', 'k', 'MarkerFaceColor', RGBVals(4, :));
plot(2+xOffset(4)+((rand(1, NContrastVals)-0.5)/randscale), postreceptoralContrastMelValidated(2, :), 's', 'Color', 'k', 'MarkerFaceColor', RGBVals(4, :));
plot(3+xOffset(4)+((rand(1, NContrastVals)-0.5)/randscale), postreceptoralContrastMelValidated(3, :), 's', 'Color', 'k', 'MarkerFaceColor', RGBVals(4, :));

subplot(2, 2, 4);
NContrastVals = size(postreceptoralContrastMelValidated, 2);
plot(1+xOffset(4)+((rand(1, NContrastVals)-0.5)/randscale), postreceptoralContrastLMSValidated(1, :), 's', 'Color', 'k', 'MarkerFaceColor', RGBVals(4, :));
plot(2+xOffset(4)+((rand(1, NContrastVals)-0.5)/randscale), postreceptoralContrastLMSValidated(2, :), 's', 'Color', 'k', 'MarkerFaceColor', RGBVals(4, :));
plot(3+xOffset(4)+((rand(1, NContrastVals)-0.5)/randscale), postreceptoralContrastLMSValidated(3, :), 's', 'Color', 'k', 'MarkerFaceColor', RGBVals(4, :));

% Add legend here
subplot(2, 2, 1);
legend([h3 h1 h2  h4], 'Nulling data mean\pm1SD', 'Modulations from LMS_{nomo}', 'Modulations from LMS_{tabulated}', 'Validated synthesized nulled spectra', 'Location', 'NorthWest'); legend boxoff;


set(gcf, 'PaperPosition', [0 0 9 9]); % Position plot at left hand corner with width 8 and height 4.
set(gcf, 'PaperSize', [9 9]); % Set the paper to have width 8 and height 4.
saveas(gcf, 'NullingPopulationData_ConeFundamentalDifference.pdf', 'pdf');



%% [6] Validation
VALIDATION = false;
if VALIDATION
    for AGE = [20 25 30 35 45 50 55];
        theDirections = {'MelanopsinDirectedPenumbralIgnorePopulationNull', 'LMSDirectedPopulationNull'}
        theCalType = 'BoxDRandomizedLongCableAEyePiece2_ND10';
        cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
        zeroVector = zeros(1, length(theDirections));
        theOnVector = zeroVector;
        theOnVector(1) = 1;
        theOffVector = zeroVector;
        theOffVector(end) = 0;
        WaitSecs(2);
        for d = 1:length(theDirections)
            [~, ~, validationPath{d}] = OLValidateCacheFile(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), 'mspits@sas.upenn.edu', 'PR-670', ...
                theOnVector(d), theOffVector(d), 'FullOnMeas', true, 'ReducedPowerLevels', true, ...
                'selectedCalType', theCalType, 'CALCULATE_SPLATTER', false, 'REFERENCE_OBSERVER_AGE', AGE);
            close all;
        end
    end
end