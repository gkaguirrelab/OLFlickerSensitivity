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
load(fullfile(cachePath, 'MaxMelPulsePsychophysics', '122316',  'Cache-MelanopsinDirectedSuperMaxMel_HERO_IterTest_122316.mat'));
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
 nShortPrimariesSkip = theData{1}.cal.describe.nShortPrimariesSkip;
 nLongPrimariesSkip = theData{1}.cal.describe.nLongPrimariesSkip;

%% Determine some axis limits
%
% Spectral power
ylimMax = 1.1*max(max([theData{1}.data(theObserverAge).correction.modSpdAll theData{1}.data(theObserverAge).correction.bgSpdAll]));

hFig = figure;
movieObj = VideoWriter('Mel_350.mp4','MPEG-4');
movieObj.FrameRate = 2;
movieObj.Quality = 100;
open(movieObj);
theColors = ['r' 'g' 'b' 'k' 'c'];
for ii = 1:nIterations
    subplot(2, 3, 1); hold on;
    plot(wls, theData{1}.data(theObserverAge).correction.bgSpdAll(:, ii),theColors(mod(ii-1,length(theColors)-1)+1));
    xlabel('Wavelength [nm]'); xlim([380 780]);
    ylabel('Radiance'); ylim([-ylimMax*0.01 ylimMax]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    text(700, 0.9*ylimMax, num2str(ii));
    title('Background');
    
    subplot(2, 3, 2); hold on;
    plot(wls, theData{1}.data(theObserverAge).correction.modSpdAll(:, ii),theColors(mod(ii-1,length(theColors)-1)+1));
    xlabel('Wavelength [nm]'); xlim([380 780]);
    ylabel('Radiance'); ylim([-ylimMax*0.01 ylimMax]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    title('Modulation');
    
    subplot(2, 3, 4); hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedAll(:, ii),theColors(mod(ii-1,length(theColors)-1)+1));
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Setting'); ylim([-0.1 1.1]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
       
    subplot(2, 3, 5); hold on;
    plot(1:nPrimaries, theData{1}.data(theObserverAge).correction.modulationPrimaryCorrectedAll(:, ii),theColors(mod(ii-1,length(theColors)-1)+1));
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Setting'); ylim([-0.1 1.1]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
     
    subplot(2, 3, 3);
    hold off;
    plot(1:ii, 100*theData{1}.data(theObserverAge).correction.contrasts(1, 1:ii), '-sr', 'MarkerFaceColor', 'r'); hold on
    plot(1:ii, 100*theData{1}.data(theObserverAge).correction.contrasts(2, 1:ii), '-sg', 'MarkerFaceColor', 'g');
    plot(1:ii, 100*theData{1}.data(theObserverAge).correction.contrasts(3, 1:ii), '-sb', 'MarkerFaceColor', 'b');
    xlabel('Iteration #'); xlim([0 nIterations+1]);
    ylabel('Contrast'); %ylim(]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    title('Contrast');
    drawnow;
    writeVideo(movieObj,getframe(hFig));
    
    %% Report some things we might want to know
    nZeroBgSettings = length(find(theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedAll(:, ii) == 0));
    nOneBgSettings = length(find(theData{1}.data(theObserverAge).correction.backgroundPrimaryCorrectedAll(:, ii) == 1));
    nZeroModSettings = length(find(theData{1}.data(theObserverAge).correction.modulationPrimaryCorrectedAll(:, ii) == 0));
    nOneModSettings = length(find(theData{1}.data(theObserverAge).correction.modulationPrimaryCorrectedAll(:, ii) == 0));
    fprintf('Iteration %d\n',ii);
    fprintf('\tNumber zero bg primaries: %d, one bg primaries: %d, zero mod primaries: %d, one mod primaries: %d\n',nZeroBgSettings,nOneBgSettings,nZeroModSettings,nOneModSettings);
    
end
close(movieObj);