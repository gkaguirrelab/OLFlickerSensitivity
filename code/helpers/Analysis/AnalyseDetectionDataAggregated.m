
%% Go to the main directory
basePath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/PsychophysicsMelConeThreshold';
cd(basePath);

theFiles = {'D072815B.csv' 'D080415B.csv' 'D080715B.csv' 'D081115B.csv'};

for f = 1:length(theFiles)
    [aggregatedData{f} aggregatedDataPerRun{f}] = AnalyseDetectionData(theFiles{f}, 8);
end
%% Per run
figure;
thresholdAgg = {[], [], [], []};
thePossibleDirections = {'LMSDirected-25.6%' 'LMSDirected25.6%' 'MelanopsinDirectedLegacy-25.6%' 'MelanopsinDirectedLegacy25.6%'};
for theDirection = 1:4
    for theRun = 1:length(theFiles)
        for theBlock = 1:length(aggregatedDataPerRun{theRun});
            if strcmp(thePossibleDirections{theDirection}, aggregatedDataPerRun{theRun}(theBlock).label)
                thresholdAgg{theDirection} = [thresholdAgg{theDirection} aggregatedDataPerRun{theRun}(theBlock).threshPsig];
            end
        end
    end
end

theThresholds = cell2mat(thresholdAgg');
meanThresholds = mean(theThresholds, 2);
semThresholds = std(theThresholds, [], 2)/sqrt(size(theThresholds, 2));

for t = 1:size(theThresholds, 2)
    plot([1 2], 100*[theThresholds(1, t) theThresholds(2, t)], '-', 'Color', [0.8 0.8 0.8]); hold on;
    plot([3 4], 100*[theThresholds(3, t) theThresholds(4, t)], '-', 'Color', [0.8 0.8 0.8]);
end

for theDirection = 1:4
    for theRun = 1:length(thresholdAgg{theDirection})
        plot(theDirection, 100*theThresholds(theDirection, theRun), 'ok', 'MarkerFaceColor', [0.6 0.6 0.6]); hold on;
    end
    plot([theDirection theDirection], 100*[meanThresholds(theDirection)-semThresholds(theDirection) meanThresholds(theDirection)+semThresholds(theDirection)], 'LineStyle', '-', 'Color', [0.8 0.1 0.1], 'LineWidth', 1.2);
    plot([theDirection-0.2 theDirection+0.2], 100*[meanThresholds(theDirection) meanThresholds(theDirection)], 'LineStyle', '-', 'Color', [1 0 0], 'LineWidth', 1.2)
    plot([theDirection-0.05 theDirection+0.05], 100*[meanThresholds(theDirection)-semThresholds(theDirection) meanThresholds(theDirection)-semThresholds(theDirection)], 'LineStyle', '-', 'Color', [0.8 0.1 0.1], 'LineWidth', 1.2)
     plot([theDirection-0.05 theDirection+0.05], 100*[meanThresholds(theDirection)+semThresholds(theDirection) meanThresholds(theDirection)+semThresholds(theDirection)], 'LineStyle', '-', 'Color', [0.8 0.1 0.1], 'LineWidth', 1.2)
end

xlim([0 5]);
ylim([0 2.5]);
ylabel('LMS Detection threshold [%]');
xlabel('Background direction');
set(gca, 'XTick', [1 1.5 2 3 3.5 4]);
set(gca, 'XTickLabel', {'-25%', 'LMS', '+25%', '-25', 'Mel', '+25%'});
pbaspect([1 1 1]);
[H,P1] = ttest(theThresholds(1, :), theThresholds(2, :));
[H,P2] = ttest(theThresholds(3, :), theThresholds(4, :));


% Plot the mean and predicted thresholds according to Weber's law
globalThreshold = mean(theThresholds(:)); % Estimate of neutral background

plot([0.5 4.5], 100*[globalThreshold globalThreshold], '--k');
plot([0.5 4.5], 100*0.744*[globalThreshold globalThreshold], '--', 'Color', [0.7 0.7 0.7]);
plot([0.5 4.5], 100*1.256*[globalThreshold globalThreshold], '--', 'Color', [0.7 0.7 0.7]);

title({['LMS - vs. +: p = ' num2str(P1)] ['Mel - vs. +: p = ' num2str(P2)]});
box off;
set(gca,'TickDir','out')
set(gcf, 'PaperPosition', [0 0 4.5 4.5]);
set(gcf, 'PaperSize', [4.5 4.5]);
saveas(gcf, ['AggAnalysisDHB.pdf'], 'pdf');

