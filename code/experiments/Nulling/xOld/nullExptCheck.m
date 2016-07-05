function nullExptCheck(subjectID)
% nullExptCheck(subjectID)
%
% Quick check of nulling data.
%
% 11/11/15  ms  Wrote it.

% Define the nulling directory
theNullingDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/Nulling';

% Load the data
tmp = load(fullfile(theNullingDir, [subjectID '_nulling.mat']));

% Extract the nulling values
LMScontrastAddedToMelPos = tmp.nulling{1, 1}.LMScontrastadded;
LMinusMcontrastAddedToMelPos = tmp.nulling{1, 1}.LMinusMcontrastadded;
LMScontrastAddedToMelNeg = tmp.nulling{1, 2}.LMScontrastadded;
LMinusMcontrastAddedToMelNeg = tmp.nulling{1, 2}.LMinusMcontrastadded;
LMinusMcontrastAddedToLMSPos = tmp.nulling{2, 1}.LMinusMcontrastadded;
LMinusMcontrastAddedToLMSNeg = tmp.nulling{2, 2}.LMinusMcontrastadded;


%% Plot the two for negative and positive arms
subplot(1, 2, 1);
plot(LMScontrastAddedToMelPos, LMinusMcontrastAddedToMelPos, '.', 'Color', 'r', 'MarkerSize', 10); hold on;
plot(LMScontrastAddedToMelNeg, LMinusMcontrastAddedToMelNeg, '.', 'Color', 'b', 'MarkerSize', 10); hold on;
xlim([-0.065 0.065]);
ylim([-0.065 0.065]);
plot([0 0], [-0.065 0.065], '-', 'Color', [0.8 0.8 0.8]);
plot([-0.065 0.065], [0 0], '-', 'Color', [0.8 0.8 0.8]);
set(gca, 'XTick', [-0.05:0.025:0.05]);
set(gca, 'YTick', [-0.05:0.025:0.05]);
set(gca, 'TickDir', 'out');
box off;
ylabel('L-M contrast added to Mel');
xlabel('L+M+S contrast added to Mel');
title('Mel nulling');
pbaspect([1 1 1]);

subplot(1, 2, 2);
plot(0, LMinusMcontrastAddedToLMSPos, '.', 'Color', 'r', 'MarkerSize', 10); hold on;
plot(0, LMinusMcontrastAddedToLMSNeg, '.', 'Color', 'b', 'MarkerSize', 10); hold on;
set(gca, 'YTick', [-0.05:0.025:0.05]);
set(gca, 'XTick', [0]);
ylim([-0.065 0.065]);
plot([-1 1], [0 0], '-', 'Color', [0.8 0.8 0.8]);
xlim([-1 1]);
title('L+M+S nulling');
set(gca, 'TickDir', 'out');
box off;
ylabel('L-M contrast added to L+M+S');
pbaspect([1 1 1]);
figure(gcf);
commandwindow;
saveFile = GetWithDefault('Save plot?', 1);
if saveFile
    set(gcf, 'PaperPosition', [0 0 8 5]); %Position plot at left hand corner with width 5 and height 5.
    set(gcf, 'PaperSize', [8 5]); %Set the paper to have width 5 and height 5.
    saveas(gcf, fullfile(theNullingDir, [subjectID '_nulling.pdf']));
end
