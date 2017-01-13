%% CheckCorr
%
% This script analyzes the output of the modulation seeking procedure, to
% help us figure out why it isn't working quite right.

%% Clear
clear; close all;

%% Get some data to analyze
cachePath = getpref('OneLight', 'materialsPath');
% load(fullfile(cachePath, 'MaxMelPulsePsychophysics', '121916',  'Cache-MelanopsinDirectedSuperMaxMel_HERO_JAR_test350_121916.mat'));
% theBox = 'BoxARandomizedLongCableBStubby1_ND02';
% load(fullfile(cachePath, 'MaxMelPulsePsychophysics', '122316',  'Cache-MelanopsinDirectedSuperMaxMel_HERO_IterTest_122316.mat'));
% theBox = 'BoxBRandomizedLongCableBStubby1_ND02';
% load(fullfile(cachePath, 'MaxMelPulsePsychophysics', '010417',  'Cache-MelanopsinDirectedSuperMaxMel_HERO_Lambda04_010417.mat'));
% theBox = 'BoxBRandomizedLongCableBStubby1_ND02';
load(fullfile(cachePath, 'MaxMelPulsePsychophysics', '011017',  'Cache-MelanopsinDirectedSuperMaxMel_HERO_Lambda03_011017.mat'));
theBox = 'BoxBRandomizedLongCableBStubby1_ND02';
% load(fullfile(cachePath, 'PIPRMaxPulse', '122216',  'Cache-MelanopsinDirectedSuperMaxMel_HERO_Test122216_122216.mat'));
% theBox = 'BoxDRandomizedLongCableAEyePiece2_ND03';

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
movieObj = VideoWriter('Mel_350.mp4','MPEG-4');
movieObj.FrameRate = 2;
movieObj.Quality = 100;
open(movieObj);
theColors = ['r' 'g' 'b' 'k' 'c'];

%% Get the calibration file, for some checks
%load TestCalFile

%% Plot what we got
%
% For each iteration
%   Dashed black line on each iteration is desired (spd or primary).
%   Green solid line is what was measured (spd or primary).
%   Red solid line is what to try next (primary only)
for ii = 1:nIterations
    subplot(4, 4, 1); hold off;
    plot(wls, theData{1}.data(theObserverAge).correction.bgDesiredSpd,'k:','LineWidth',2);
    hold on;
    plot(wls, theData{1}.data(theObserverAge).correction.bgSpdAll(:,ii),'g');
    xlabel('Wavelength [nm]'); xlim([380 780]);
    ylabel('Radiance'); ylim([-ylimMax*0.01 ylimMax]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    text(700, 0.9*ylimMax, num2str(ii));
    title('Background');
    %plot(wls,cal.computed.pr650MeanDark,'b');
    
    subplot(4, 4, 2); hold off;
    plot(wls, theData{1}.data(theObserverAge).correction.modDesiredSpd,'k:','LineWidth',2);
    hold on;
    plot(wls, theData{1}.data(theObserverAge).correction.modSpdAll(:,ii),'g');
    xlabel('Wavelength [nm]'); xlim([380 780]);
    ylabel('Radiance'); ylim([-ylimMax*0.01 ylimMax]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    title('Modulation');
    
    subplot(4, 4, 3);
    hold off;
    plot(1:ii, 100*theData{1}.data(theObserverAge).correction.contrasts(1, 1:ii), '-sr', 'MarkerFaceColor', 'r'); hold on
    plot(1:ii, 100*theData{1}.data(theObserverAge).correction.contrasts(2, 1:ii), '-sg', 'MarkerFaceColor', 'g');
    plot(1:ii, 100*theData{1}.data(theObserverAge).correction.contrasts(3, 1:ii), '-sb', 'MarkerFaceColor', 'b');
    xlabel('Iteration #'); xlim([0 nIterations+1]);
    ylabel('Contrast'); %ylim(]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    title('Contrast');
    
    % The inferred primary should be obtainable from the measured spectrum
    % and the calibratile file.  Let's try it and check
%     backgroundPrimaryInferredHereFromCal = OLSpdToPrimary(cal,theData{1}.data(theObserverAge).correction.bgSpdAll(:,ii));
%     backgroundPrimaryWeThinkOnFirstIter = theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedNotTruncatedAll(:,ii) + 0.3 * ...
%         theData{1}.data(theObserverAge).correction.deltaBackgroundPrimaryInferredAll(:,ii);
        
    subplot(4, 4, 5); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInitial,'k:','LineWidth',2);
    hold on; 
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedAll(:,ii),'r');
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInferredAll(:,ii),'g');
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([-0.1 1.1]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
       
    subplot(4, 4, 6); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryInitial,'k:','LineWidth',2);
    hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryCorrectedAll(:,ii),'r');
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryInferredAll(:,ii),'g');
    xlabel('Primary #');
    xlim([0 60]);
    ylabel('Primary Value'); ylim([-0.1 1.1]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
     
    subplot(4, 4, 9); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInitial,'k:','LineWidth',2);
    hold on
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedAll(:,ii),'r');
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInferredAll(:,ii),'g');
    plot([0 60],[1 1],'k:','LineWidth',1);
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([0.98 1.02]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
       
    subplot(4, 4, 10); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryInitial,'k:','LineWidth',2);
    hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryCorrectedAll(:,ii),'r');
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryInferredAll(:,ii),'g');
    plot([0 60],[1 1],'k:','LineWidth',1);plot([0 60],[1 1],'k:','LineWidth',1);
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([0.98 1.02]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    
    subplot(4, 4, 11); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInitial,'k:','LineWidth',2);
    hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedNotTruncatedAll(:,ii),'r');
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInferredAll(:,ii),'g');
    plot([0 60],[1 1],'k:','LineWidth',1);
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([0.98 1.02]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
       
    subplot(4, 4, 12); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryInitial,'k:','LineWidth',2);
    hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryCorrectedNotTruncatedAll(:,ii),'r');
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryInferredAll(:,ii),'g');
    plot([0 60],[1 1],'k:','LineWidth',1);
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([0.98 1.02]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    
    subplot(4, 4, 13); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInitial,'k:','LineWidth',2);
    hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedAll(:,ii),'r');
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInferredAll(:,ii),'g');
    plot([0 60],[0 0],'k:','LineWidth',1);
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([-0.02 0.02]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
       
    subplot(4, 4, 14); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInitial,'k:','LineWidth',2);
    hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryCorrectedAll(:,ii),'r');
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryInferredAll(:,ii),'g');
    plot([0 60],[0 0],'k:','LineWidth',1);
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([-0.02 0.02]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    
    subplot(4, 4, 15); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInitial,'k:','LineWidth',2);
    hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedNotTruncatedAll(:,ii),'r');
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInferredAll(:,ii),'g');
    plot([0 60],[0 0],'k:','LineWidth',1);
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([-0.02 0.02]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
       
    subplot(4, 4, 16); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInitial,'k:','LineWidth',2);
    hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryCorrectedNotTruncatedAll(:,ii),'r');
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryInferredAll(:,ii),'g');
    plot([0 60],[0 0],'k:','LineWidth',1);
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Primary Value'); ylim([-0.02 0.02]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    
    drawnow;
    %writeVideo(movieObj,getframe(hFig));
      
    %% Report some things we might want to know
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