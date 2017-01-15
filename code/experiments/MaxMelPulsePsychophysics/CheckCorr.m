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
% load(fullfile(cachePath, 'MaxMelPulsePsychophysics', '011017',  'Cache-MelanopsinDirectedSuperMaxMel_HERO_Lambda03_011017.mat'));
% theBox = 'BoxBRandomizedLongCableBStubby1_ND02';
load(fullfile(cachePath, 'MaxMelPulsePsychophysics', '011317',  'Cache-MelanopsinDirectedSuperMaxMel_HERO_Lambda03_011317.mat'));
theBox = 'BoxBRandomizedLongCableBStubby1_ND02';
% load(fullfile(cachePath, 'MaxMelPulsePsychophysics', '011317',  'Cache-MelanopsinDirectedSuperMaxMel_HERO_Lambda08_011317.mat'));
% theBox = 'BoxBRandomizedLongCableBStubby1_ND02';
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
cal = theData{1}.data(theObserverAge).cal;

%% This is a temp fix for a typo in the correction routine
if (isfield(theData{1}.data(theObserverAge).correction,'cal'))
    theData{1}.data(theObserverAge).correction.deltaBackgroundPrimaryInferredAll = theData{1}.data(theObserverAge).correction.cal;
end

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
    
    % A key part of our algorithm is being able to estimate the appropriate
    % delta primaries given current primaries and measured/desired
    % spectrum.  This does not seem to be working all that well.
    % and the calibratile file.  Let's try it and check. 
    backgroundSpectrumWeWant = theData{1}.data(theObserverAge).correction.bgDesiredSpd;
    backgroundSpectrumWeMeasured = theData{1}.data(theObserverAge).correction.bgSpdAll(:,ii);
    backgroundPrimaryInitial = theData{1}.data(theObserverAge).correction.backgroundPrimaryInitial;
    backgroundPrimaryUsed = theData{1}.data(theObserverAge).correction.backgroundPrimaryMeasuredAll(:,ii);
    backgroundSpectrumInferredInitial = OLPrimaryToSpd(cal,backgroundPrimaryInitial);
         
    backgroundPrimaryInferredLambda_00 = OLSpdToPrimary(cal,theData{1}.data(theObserverAge).correction.bgSpdAll(:,ii),'lambda',0);
    backgroundSpectrumInferredLambda_00 = OLPrimaryToSpd(cal,backgroundPrimaryInferredLambda_00);
     
    backgroundPrimaryInferredLambda_001 = OLSpdToPrimary(cal,theData{1}.data(theObserverAge).correction.bgSpdAll(:,ii),'lambda',0.001);
    backgroundSpectrumInferredLambda_001 = OLPrimaryToSpd(cal,backgroundPrimaryInferredLambda_001);
    
    backgroundPrimaryInferredLambda_01 = OLSpdToPrimary(cal,theData{1}.data(theObserverAge).correction.bgSpdAll(:,ii),'lambda',0.01);
    backgroundSpectrumInferredLambda_01 = OLPrimaryToSpd(cal,backgroundPrimaryInferredLambda_01); 

    backgroundDeltaPrimaryInferredLambda_0 = OLSpdToPrimary(cal,backgroundSpectrumWeMeasured-backgroundSpectrumWeWant,'differentialMode',true,'lambda',0.00);
    backgroundPrimaryInferredDeltaLambda_0 = backgroundPrimaryUsed+backgroundDeltaPrimaryInferredLambda_0;
    backgroundSpectrumInferredDeltaLambda_0 = OLPrimaryToSpd(cal,backgroundPrimaryInferredDeltaLambda_0);
    
    backgroundDeltaPrimaryInferredLambda_0001 = OLSpdToPrimary(cal,backgroundSpectrumWeMeasured-backgroundSpectrumWeWant,'differentialMode',true,'lambda',0.001);
    backgroundPrimaryInferredDeltaLambda_0001 = backgroundPrimaryUsed+backgroundDeltaPrimaryInferredLambda_0001;
    backgroundSpectrumInferredDeltaLambda_0001 = OLPrimaryToSpd(cal,backgroundPrimaryInferredDeltaLambda_0001);
    
    backgroundDeltaPrimaryInferredLambda_01 = OLSpdToPrimary(cal,backgroundSpectrumWeMeasured-backgroundSpectrumWeWant,'differentialMode',true,'lambda',0.1);
    backgroundPrimaryInferredDeltaLambda_01 = backgroundPrimaryUsed+backgroundDeltaPrimaryInferredLambda_01;
    backgroundSpectrumInferredDeltaLambda_01 = OLPrimaryToSpd(cal,backgroundPrimaryInferredDeltaLambda_01);

    figure(2); clf;  
    subplot(2,2,1); hold on 
    plot(wls,backgroundSpectrumWeWant,'k:','LineWidth',2);
    plot(wls,backgroundSpectrumInferredInitial,'k','LineWidth',1);
    plot(wls,backgroundSpectrumWeMeasured,'g','LineWidth',2);
    %plot(wls,backgroundSpectrumInferredLambda_00,'r','LineWidth',1);
    %plot(wls,backgroundSpectrumInferredLambda_001,'k','LineWidth',1);
    plot(wls,backgroundSpectrumInferredDeltaLambda_0,'k','LineWidth',1);
    plot(wls,backgroundSpectrumInferredDeltaLambda_01,'b','LineWidth',1);
    plot(wls,backgroundSpectrumInferredDeltaLambda_0001,'r','LineWidth',1);

    subplot(2,2,2); hold on
    plot(1:nPrimaries,backgroundPrimaryInitial,'k:','LineWidth',3);
    plot(1:nPrimaries,backgroundPrimaryUsed,'g','LineWidth',1);
    %plot(1:nPrimaries,backgroundPrimaryInferredLambda_00,'r','LineWidth',1);
    %plot(1:nPrimaries,backgroundPrimaryInferredLambda_001,'k','LineWidth',1);
    plot(1:nPrimaries,backgroundPrimaryInferredDeltaLambda_0,'k','LineWidth',1);
    plot(1:nPrimaries,backgroundPrimaryInferredDeltaLambda_01,'b','LineWidth',1);
    plot(1:nPrimaries,backgroundPrimaryInferredDeltaLambda_0001,'r','LineWidth',1);

    subplot(2,2,3); hold on 
    plot(wls,backgroundSpectrumWeMeasured-backgroundSpectrumInferredDeltaLambda_0,'k','LineWidth',2);
    plot(wls,backgroundSpectrumWeMeasured-backgroundSpectrumInferredDeltaLambda_01,'g','LineWidth',2);
    plot(wls,backgroundSpectrumWeMeasured-backgroundSpectrumInferredDeltaLambda_0001,'r','LineWidth',2);

    subplot(2,2,4); hold on
    plot(1:nPrimaries,backgroundPrimaryUsed-backgroundPrimaryInferredDeltaLambda_0,'k','LineWidth',2);
    plot(1:nPrimaries,backgroundPrimaryUsed-backgroundPrimaryInferredDeltaLambda_01,'g','LineWidth',2);
    plot(1:nPrimaries,backgroundPrimaryUsed-backgroundPrimaryInferredDeltaLambda_0001,'r','LineWidth',2);
        
    subplot(4, 4, 5); hold off;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInitial,'k:','LineWidth',2);
    hold on; 
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedAll(:,ii),'r');
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryInferredAll(:,ii),'g');
    plot(1:nPrimaries, backgroundPrimaryInferredHereFromCal,'g:');
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