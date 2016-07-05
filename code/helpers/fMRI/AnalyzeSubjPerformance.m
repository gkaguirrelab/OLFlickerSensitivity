theFig = figure;
subplot(1, 2, 1);
boxplot([perfGA(:, 1) perfMM(:, 1) perfMS(:, 1) perfLL(:, 1)]);
pbaspect([1 1 1]);
set(gca, 'XTick', [1 2 3 4]);
set(gca, 'XTickLabel', {'GA', 'MM', 'MS', 'LL'});
title('Hit rate');

subplot(1, 2, 2);
boxplot([perfGA(:, 2) perfMM(:, 2) perfMS(:, 2) perfLL(:, 2)]);
pbaspect([1 1 1]);
set(gca, 'XTick', [1 2 3 4]);
set(gca, 'XTickLabel', {'GA', 'MM', 'MS', 'LL'});
title('False alarm rate');


%% Save plots
set(theFig, 'Color', [1 1 1]);
set(theFig, 'InvertHardCopy', 'off');
set(theFig, 'PaperPosition', [0 0 10 5]); %Position plot at left hand corner with width 15 and height 6.
set(theFig, 'PaperSize', [10 5]); %Set the paper to have width 15 and height 6.
saveas(theFig, 'Performance', 'pdf');