%% CheckCorr
%
% This script analyzes the output of the modulation seeking procedure, to
% help us figure out why it isn't working quite right.

%% Clear
clear; close all;

%% Get some data to analyze
cachePath = getpref('OneLight', 'materialsPath');
load(fullfile(cachePath, 'MaxMelPulsePsychophysics', '011717',  'Cache-MelanopsinDirectedSuperMaxMel_HERO_LambdaSmoothness_011717.mat'));
theBox = 'BoxBRandomizedLongCableBStubby1_ND02';

% Convert data to standardized naming for here
eval(['theData = ' theBox ';  clear ' theBox ';']);

%% Discover the observer age
theObserverAge = find(~(cellfun(@isempty, {theData{1}.data.correction})));

%% How many iterations were run?  And how many primaries were there?
nIterations = size(theData{1}.data(theObserverAge).correction.bgSpdAll, 2);
nPrimaries = size(theData{1}.data(theObserverAge).correction.modulationPrimaryCorrectedAll, 1);

%% What's the wavelength sampling?
wls = SToWls([380 2 201]);

%% Skipped primaries
%
% Not sure we need this
nShortPrimariesSkip = theData{1}.cal.describe.nShortPrimariesSkip;
nLongPrimariesSkip = theData{1}.cal.describe.nLongPrimariesSkip;

%% Determine some axis limits
%
% Spectral power
ylimMax = 1.1*max(max([theData{1}.data(theObserverAge).correction.modSpdAll theData{1}.data(theObserverAge).correction.bgSpdAll]));

%% Print some diagnostic information
fprintf('Value of kScale: %0.2f\n',theData{1}.data(theObserverAge).correction.kScale);

%% Start a diagnositic plot
hFig = figure; set(hFig,'Position',[220 600 1150 725]);
hFig2 = figure; clf;
% movieObj = VideoWriter('Mel_350.mp4','MPEG-4');
% movieObj.FrameRate = 2;
% movieObj.Quality = 100;
% open(movieObj);
theColors = ['r' 'g' 'b' 'k' 'c'];

%% Get the calibration file, for some checks
cal = theData{1}.data(theObserverAge).cal;
% cal.describe.useAverageGamma = true;
% cal = OLInitCal(cal);
% calAnalyzer = OLCalAnalyzer('cal',cal, ...
%         'refitGammaTablesUsingLinearInterpolation', false, ...
%         'forceOLInitCal', true);
% gammaType = 'computed';
% calAnalyzer.plotGamma(gammaType,'plotRatios', false);

%% This is a temp fix for a typo in the correction routine
% if (isfield(theData{1}.data(theObserverAge).correction,'cal'))
%     theData{1}.data(theObserverAge).correction.deltaBackgroundPrimaryInferredAll = theData{1}.data(theObserverAge).correction.cal;
% end

%% Plot what we got
backgroundPredictedDifference = [];
for ii = 1:nIterations
    % Diagnostic figure.  Recreate what we think the iterative
    % procedure does and plot.
    learningRate = 0.8;
    smoothnessParam = 0.001;
    backgroundSpectrumWeWant = theData{1}.data(theObserverAge).correction.bgDesiredSpd;
    backgroundSpectrumWeMeasured = theData{1}.data(theObserverAge).correction.bgSpdAll(:,ii);
    backgroundPrimaryInitial = theData{1}.data(theObserverAge).correction.backgroundPrimaryInitial;
    backgroundSpectrumInferredInitial = OLPrimaryToSpd(cal,backgroundPrimaryInitial);
    backgroundPrimaryUsed = theData{1}.data(theObserverAge).correction.backgroundPrimaryMeasuredAll(:,ii);

    % In a completely linear system with no learning rate and no gamut
    % bounds, this is how much we'd tweak the primaries to exactly hit the
    % target spectrum.
    backgroundDeltaPrimaryIdealized = OLSpdToPrimary(cal,backgroundSpectrumWeWant-backgroundSpectrumWeMeasured,'differentialMode',true,'lambda',smoothnessParam);
    
    % How much would we change with and without truncation?
    backgroundNextPrimaryNotTruncatedNoLearningRate = backgroundPrimaryUsed+backgroundDeltaPrimaryIdealized;
    backgroundDeltaPrimaryNotTruncatedNoLearningRate = backgroundNextPrimaryNotTruncatedNoLearningRate - backgroundPrimaryUsed;
    backgroundNextPrimaryTruncatedNoLearningRate = backgroundNextPrimaryNotTruncatedNoLearningRate;
    backgroundNextPrimaryTruncatedNoLearningRate(backgroundNextPrimaryTruncatedNoLearningRate < 0) = 0;
    backgroundNextPrimaryTruncatedNoLearningRate(backgroundNextPrimaryTruncatedNoLearningRate > 1) = 1;
    backgroundDeltaPrimaryTruncatedNoLearningRate = backgroundNextPrimaryTruncatedNoLearningRate - backgroundPrimaryUsed;
    
    backgroundNextPrimaryNotTruncatedLearningRate = backgroundPrimaryUsed+learningRate*backgroundDeltaPrimaryIdealized;
    backgroundDeltaPrimaryNotTruncatedLearningRate = backgroundNextPrimaryNotTruncatedLearningRate - backgroundPrimaryUsed;
    backgroundNextPrimaryTruncatedLearningRate1 = backgroundNextPrimaryNotTruncatedLearningRate;
    backgroundNextPrimaryTruncatedLearningRate1(backgroundNextPrimaryTruncatedLearningRate1 < 0) = 0;
    backgroundNextPrimaryTruncatedLearningRate1(backgroundNextPrimaryTruncatedLearningRate1 > 1) = 1;
    backgroundNextPrimaryTruncatedLearningRate = OLSettingsToPrimary(cal,OLPrimaryToSettings(cal,backgroundNextPrimaryTruncatedLearningRate1));
    backgroundDeltaPrimaryTruncatedLearningRate1 = backgroundNextPrimaryTruncatedLearningRate1 - backgroundPrimaryUsed;
    backgroundDeltaPrimaryTruncatedLearningRate = backgroundNextPrimaryTruncatedLearningRate - backgroundPrimaryUsed;

    % Our prediction should be based on the local approximation.  We take the measurement and add the differential effect of the primary change. 
    backgroundNextSpectrumNotTruncatedLearningRate = backgroundSpectrumWeMeasured + OLPrimaryToSpd(cal,backgroundDeltaPrimaryNotTruncatedLearningRate,'differentialMode',true);
    backgroundNextSpectrumTruncatedLearningRate = backgroundSpectrumWeMeasured + OLPrimaryToSpd(cal,backgroundDeltaPrimaryTruncatedLearningRate,'differentialMode',true);
    
    realityCheck = theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedNotTruncatedAll(:,ii)-backgroundNextPrimaryNotTruncatedLearningRate;
    if (max(abs(realityCheck(:))) > 1e-8)
        error('Cannot now reproduce the next non-truncated primaries in the iteration');
    end
    realityCheck = theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedAll(:,ii)-backgroundNextPrimaryTruncatedLearningRate;
    if (max(abs(realityCheck(:))) > 1e-8)
        error('Cannot now reproduce the next primaries in the iteration');
    end
    
    figure(hFig2); clf;
    
    % Black is the spectrum our little heart desires.
    % Green is what we measured.
    % Red is what our procedure thinks we'll get on the next iteration.
    subplot(2,2,1); hold on 
    plot(wls,backgroundSpectrumWeWant,'k:','LineWidth',3);
    plot(wls,backgroundSpectrumInferredInitial,'k','LineWidth',2);
    plot(wls,backgroundSpectrumWeMeasured,'g','LineWidth',2);
    plot(wls,backgroundNextSpectrumNotTruncatedLearningRate,'r:','LineWidth',2);
    plot(wls,backgroundNextSpectrumTruncatedLearningRate,'b','LineWidth',2);

    % Black is the initial primaries we started with
    % Green is what we used to measure the spectra on this iteration.
    % Red is the primaries we'll ask for next iteration, with dashed
    % version not truncated.
    subplot(2,2,2); hold on
    plot(1:nPrimaries,backgroundPrimaryInitial,'k:','LineWidth',3);
    plot(1:nPrimaries,backgroundPrimaryUsed,'g','LineWidth',2);
    plot(1:nPrimaries,backgroundNextPrimaryNotTruncatedLearningRate,'r','LineWidth',2);
    plot(1:nPrimaries,backgroundNextPrimaryTruncatedLearningRate,'b','LineWidth',2);
    plot(1:nPrimaries,backgroundNextPrimaryTruncatedLearningRate1,'c','LineWidth',1);

    % Green is the difference between what we want and what we measured.
    % Red is what we think this difference should be on the next iteration.
    subplot(2,2,3); hold on 
    plot(wls,backgroundSpectrumWeWant-backgroundSpectrumWeMeasured,'g','LineWidth',2);
    plot(wls,backgroundSpectrumWeWant-backgroundNextSpectrumNotTruncatedLearningRate,'r:','LineWidth',2);
    plot(wls,backgroundSpectrumWeWant-backgroundNextSpectrumTruncatedLearningRate,'r','LineWidth',2);
    title('Predicted delta spectrum on next iteration');
    
    % Red is the difference between the primaries we will ask for on the
    % next iteration and those we just used.
    subplot(2,2,4); hold on
    plot(1:nPrimaries,backgroundNextPrimaryTruncatedLearningRate-backgroundPrimaryUsed,'g','LineWidth',2);
    title('Delta primary on next iteration');
    
    % For each iteration
    %   Dashed black line on each iteration is desired (spd or primary).
    %   Green solid line is what was measured (spd or primary).
    %   Red solid line is what to try next (primary only)
    figure(hFig);
    subplot(4, 4, 1); hold off;
    plot(wls, theData{1}.data(theObserverAge).correction.bgDesiredSpd,'k:','LineWidth',2);
    hold on;
    plot(wls, theData{1}.data(theObserverAge).correction.bgSpdAll(:,ii),'g');
    xlabel('Wavelength [nm]'); xlim([380 780]);
    ylabel('Radiance'); ylim([-ylimMax*0.01 ylimMax]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    text(700, 0.9*ylimMax, num2str(ii));
    title('Background');
    
    subplot(4, 4, 2); hold off;
    plot(wls, theData{1}.data(theObserverAge).correction.modDesiredSpd,'k:','LineWidth',2);
    hold on;
    plot(wls, theData{1}.data(theObserverAge).correction.modSpdAll(:,ii),'g');
    xlabel('Wavelength [nm]'); xlim([380 780]);
    ylabel('Radiance'); ylim([-ylimMax*0.01 ylimMax]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    title('Modulation');
    
    subplot(4, 4, 3); hold off;
    plot(wls, theData{1}.data(theObserverAge).correction.bgDesiredSpd-theData{1}.data(theObserverAge).correction.bgSpdAll(:,ii),'k','LineWidth',2);
    hold on;
    if (~isempty(backgroundPredictedDifference))
        plot(wls,backgroundPredictedDifference,'r','LineWidth',2);
    end
    xlabel('Wavelength [nm]'); xlim([380 780]);
    ylabel('Radiance');
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    title('Background Spectrum Difference');
    
    subplot(4, 4, 4);
    hold off;
    plot(1:ii, 100*theData{1}.data(theObserverAge).correction.contrasts(1, 1:ii), '-sr', 'MarkerFaceColor', 'r'); hold on
    plot(1:ii, 100*theData{1}.data(theObserverAge).correction.contrasts(2, 1:ii), '-sg', 'MarkerFaceColor', 'g');
    plot(1:ii, 100*theData{1}.data(theObserverAge).correction.contrasts(3, 1:ii), '-sb', 'MarkerFaceColor', 'b');
    xlabel('Iteration #'); xlim([0 nIterations+1]);
    ylabel('Contrast'); %ylim(]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    title('Contrast');
    
    subplot(4, 4, 5); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInitial,'k:','LineWidth',2);
    hold on; 
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedAll(:,ii),'r','LineWidth',2);
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([-0.1 1.1]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
       
    subplot(4, 4, 6); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryInitial,'k:','LineWidth',2);
    hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryCorrectedAll(:,ii),'r','LineWidth',2);
    xlabel('Primary #');
    xlim([0 60]);
    ylabel('Primary Value'); ylim([-0.1 1.1]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
     
    subplot(4, 4, 9); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInitial,'k:','LineWidth',2);
    hold on
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedAll(:,ii),'r','LineWidth',2);
    plot([0 60],[1 1],'k:','LineWidth',1);
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([0.98 1.02]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
       
    subplot(4, 4, 10); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryInitial,'k:','LineWidth',2);
    hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryCorrectedAll(:,ii),'r','LineWidth',2);
    plot([0 60],[1 1],'k:','LineWidth',1);plot([0 60],[1 1],'k:','LineWidth',1);
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([0.98 1.02]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    
    subplot(4, 4, 11); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInitial,'k:','LineWidth',2);
    hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedNotTruncatedAll(:,ii),'r','LineWidth',2);
    plot([0 60],[1 1],'k:','LineWidth',1);
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([0.98 1.02]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
       
    subplot(4, 4, 12); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryInitial,'k:','LineWidth',2);
    hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryCorrectedNotTruncatedAll(:,ii),'r','LineWidth',2);
    plot([0 60],[1 1],'k:','LineWidth',1);
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([0.98 1.02]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    
    subplot(4, 4, 13); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInitial,'k:','LineWidth',2);
    hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedAll(:,ii),'r','LineWidth',2);
    plot([0 60],[0 0],'k:','LineWidth',1);
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([-0.02 0.02]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
       
    subplot(4, 4, 14); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryInitial,'k:','LineWidth',2);
    hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryCorrectedAll(:,ii),'r','LineWidth',2);
    plot([0 60],[0 0],'k:','LineWidth',1);
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([-0.02 0.02]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    
    subplot(4, 4, 15); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInitial,'k:','LineWidth',2);
    hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedNotTruncatedAll(:,ii),'r','LineWidth',2);
    plot([0 60],[0 0],'k:','LineWidth',1);
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([-0.02 0.02]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
       
    subplot(4, 4, 16); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryInitial,'k:','LineWidth',2);
    hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryCorrectedNotTruncatedAll(:,ii),'r','LineWidth',2);
    plot([0 60],[0 0],'k:','LineWidth',1);
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([-0.02 0.02]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    
    drawnow; figure(hFig); figure(hFig2);
    %writeVideo(movieObj,getframe(hFig));
    
    % For next iteration plotting
    backgroundPredictedDifference = backgroundSpectrumWeWant - backgroundNextSpectrumTruncatedLearningRate;
    
    % Report some things we might want to know
    nZeroBgSettings(ii) = length(find(theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedAll(:,ii) == 0));
    nOneBgSettings(ii) = length(find(theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedAll(:,ii) == 1));
    nZeroModSettings(ii) = length(find(theData{1}.data(theObserverAge).correction.modulationPrimaryCorrectedAll(:,ii) == 0));
    nOneModSettings(ii) = length(find(theData{1}.data(theObserverAge).correction.modulationPrimaryCorrectedAll(:,ii) == 1));
    fprintf('Iteration %d\n',ii);
    fprintf('\tNumber zero bg primaries: %d, one bg primaries: %d, zero mod primaries: %d, one mod primaries: %d\n',nZeroBgSettings(ii),nOneBgSettings(ii),nZeroModSettings(ii),nOneModSettings(ii));
    
    commandwindow;
    pause;
    
end
close(movieObj);