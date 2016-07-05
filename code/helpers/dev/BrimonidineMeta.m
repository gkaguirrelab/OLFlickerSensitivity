close all;
%% Assemble data points for distortion product measurements and plot frequency response
theCols = [142	142	56 ; 173	216	230	; 113	198	113 ; 110	80	60 ; 40 40 120]/255;
theOrder = [1 5 4 3 2];
theLabels = {'Background', 'L-M [AM]', 'L-M [FM]', 'LF [AM]', 'LF [FM]'};
theSubjects = {'s001WithoutBrimonidine' 's001WithBrimonidine' };
amp = []; ampErr = [];
for s = 1:length(theSubjects)
    m = csvread(['/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/PupillometryBrimonidineAttenuationBattery/' theSubjects{s} '-results.csv'], 1, 1);
    amp = [amp 100*m(theOrder, 4)];
    ampErr = [ampErr 100*m(theOrder, 6)];
end

xTicks = [1:5];

for i = 1:length(amp);
    a = bar(i-0.15, amp(i, 1), 0.25, 'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5); hold on;
    b = bar(i+0.15, amp(i, 2), 0.25, 'FaceColor',[.5 .5 .5],'EdgeColor',[.9 .9 .9],'LineWidth',1.5); hold on;
    errorbar(i-0.15, amp(i, 1), ampErr(i, 1), 'Color', 'k');
    errorbar(i+0.15, amp(i, 2), ampErr(i, 1), 'Color', 'k');
end
pbaspect([1 1 1]);
set(gca, 'TickDir', 'out');
box off;
xlabel({'Modulation direction'});
ylabel({'Pupil amplitude' '[% change]'});
set(gca, 'XTick', xTicks);
set(gca, 'XTickLabel', {theLabels{theOrder}});
ylim([0 7]);

hold on;
title('s001')

legend([a b], 'Pre', 'Post'); legend boxoff;
%legend(a, 'Session 1', 'Session 2', 'Location', 'NorthEast'); legend boxoff;
set(gcf, 'PaperPosition', [0 0 5 5]);
set(gcf, 'PaperSize', [5 5]);
saveas(gcf, 'PupillometryBrimonidineAttenuationBattery_s001Brimonidine', 'pdf');
%close(gcf);
