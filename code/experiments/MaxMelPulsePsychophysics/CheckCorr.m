% CheckCorr
%
% This script analyzes the output of the modulation seeking procedure, to
% help us figure out why it isn't working quite right.

% 
Path = getpref('OneLight', 'materialsPath');
load(fullfile(Path, 'MaxMelPulsePsychophysics', '121916',  'Cache-MelanopsinDirectedSuperMaxMel_HERO_JAR_test350_121916.mat'));

% Discover the observer age
theObserverAge = find(~(cellfun(@isempty, {BoxARandomizedLongCableBStubby1_ND02{1}.data.correction})));

% How many iterations were run?
NIterations = size(BoxARandomizedLongCableBStubby1_ND02{1}.data(theObserverAge).correction.bgSpdAll, 2);
NPrimaries = size(BoxARandomizedLongCableBStubby1_ND02{1}.data(theObserverAge).correction.modulationPrimaryCorrectedAll, 1);

% What's the wavelength sampling?
wls = SToWls([380 2 201]);

% Determine some axis limits
ylimMax = 1.1*max(max([BoxARandomizedLongCableBStubby1_ND02{1}.data(theObserverAge).correction.modSpdAll BoxARandomizedLongCableBStubby1_ND02{1}.data(theObserverAge).correction.bgSpdAll]));

hFig = figure;

movieObj = VideoWriter('Mel_350.mp4','MPEG-4');
movieObj.FrameRate = 2;
movieObj.Quality = 100;
open(movieObj);
for ii = 1:NIterations
    subplot(2, 3, 1);
    plot(wls, BoxARandomizedLongCableBStubby1_ND02{1}.data(theObserverAge).correction.bgSpdAll(:, ii));
    xlabel('Wavelength [nm]'); xlim([380 780]);
    ylabel('Radiance'); ylim([-ylimMax*0.01 ylimMax]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    text(700, 0.9*ylimMax, num2str(ii));
    title('Background');
    
    subplot(2, 3, 2);
    plot(wls, BoxARandomizedLongCableBStubby1_ND02{1}.data(theObserverAge).correction.modSpdAll(:, ii));
    xlabel('Wavelength [nm]'); xlim([380 780]);
    ylabel('Radiance'); ylim([-ylimMax*0.01 ylimMax]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    title('Modulation');
    
    subplot(2, 3, 4);
    plot(1:NPrimaries, BoxARandomizedLongCableBStubby1_ND02{1}.data(theObserverAge).correction.modulationPrimaryCorrectedAll(:, ii));
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Setting'); ylim([-0.1 1.1]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    
    
    subplot(2, 3, 5);
    plot(1:NPrimaries, BoxARandomizedLongCableBStubby1_ND02{1}.data(theObserverAge).correction.modulationPrimaryCorrectedAll(:, ii));
    xlabel('Primary #'); xlim([0 60]);
    ylabel('Setting'); ylim([-0.1 1.1]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    
    
    subplot(2, 3, 3);
    hold off;
    plot(1:ii, 100*BoxARandomizedLongCableBStubby1_ND02{1}.data(theObserverAge).correction.contrasts(1, 1:ii), '-sr', 'MarkerFaceColor', 'r'); hold on
    plot(1:ii, 100*BoxARandomizedLongCableBStubby1_ND02{1}.data(theObserverAge).correction.contrasts(2, 1:ii), '-sg', 'MarkerFaceColor', 'g');
    plot(1:ii, 100*BoxARandomizedLongCableBStubby1_ND02{1}.data(theObserverAge).correction.contrasts(3, 1:ii), '-sb', 'MarkerFaceColor', 'b');
    xlabel('Iteration #'); xlim([0 NIterations+1]);
    ylabel('Contrast'); %ylim(]);
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    title('Contrast');
    drawnow;
    writeVideo(movieObj,getframe(hFig));

end
close(movieObj);