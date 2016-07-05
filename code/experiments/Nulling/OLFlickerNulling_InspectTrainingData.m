nNulls = length(nulling_training);
for ii = 1:nNulls
    switch nulling_training{ii}.nullingModes{1}
        case 'LMS'
            whichIndex = 1;
        case 'LMinusM'
            whichIndex = 2;
        case 'S'
            whichIndex = 3;
    end
    condition(ii) = whichIndex;
    contrasts(ii) = nulling_training{ii}.contrasts(whichIndex)
end

theUniqueConds = unique(condition);
plot([0 4], [0 0], '--', 'Color', [0.5 0.5 0.5]); hold on;
for ii = 1:length(theUniqueConds)
    contrasts_aggregate(:, ii) = contrasts(find(condition == theUniqueConds(ii)));
    for ij = 1:length(contrasts_aggregate(:, ii))
        plot(ii+rand/10, contrasts_aggregate(ij, ii)*100, 'ok', 'MarkerFaceColor', 'r'); hold on;
    end
end
contrasts_aggregate(find(abs(contrasts_aggregate) == 0.1)) = NaN;

meanContrasts = nanmean(contrasts_aggregate);
sdContrasts = nanstd(contrasts_aggregate);
for ii = 1:length(theUniqueConds)
    plot(ii-0.2, 100*meanContrasts(ii), 'ok', 'MarkerFaceColor', 'k', 'MarkerSize', 5);
    errorbar(ii-0.2, 100*meanContrasts(ii), 100*sdContrasts(ii), '-k');
end
xlim([0 4]); ylim([-2.5 2.5]);
set(gca, 'XTick', [1 2 3]); set(gca, 'XTickLabel', {'L+M+S' 'L-M', 'S'});
title({'Ground truth nulling' 'MELA\_Pilot\_0005'});
xlabel('Condition'); ylabel('Contrast of perceptual null [%]');
set(gca, 'TickDir', 'out');
pbaspect([1 1 1]);
box off;

%% Save plots
set(gcf, 'Color', [1 1 1]);
set(gcf, 'InvertHardCopy', 'off');
set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 15 and height 6.
set(gcf, 'PaperSize', [5 5]); %Set the paper to have width 15 and height 6.
saveas(gcf, fullfile('~/Desktop/Nulling_0005.pdf'), 'pdf')