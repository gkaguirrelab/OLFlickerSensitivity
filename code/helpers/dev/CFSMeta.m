close all;
subjectID = 's006';

%% Assemble data points for distortion product measurements and plot frequency response
theCols = [142	142	56 ; 173	216	230	; 113	198	113 ; 110	80	60 ; 40 40 120]/255;
theOrder = [1:8];
theLabels = {'Background', 'LF [AM, 16 Hz]', 'LF [AM,  4 Hz]', 'LF [FM]'};
theSubjects = {subjectID};
amp = []; ampErr = [];
for s = 1:length(theSubjects)
    m = csvread(['/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/PupillometryBrimonidineAttenuationBattery/' theSubjects{s} '-results.csv'], 1, 1);
    amp = [amp 100*m(theOrder, 4)];
    ampErr = [ampErr 100*m(theOrder, 6)];
end

xTicks = [1:4];

c = 1;
for i = [1:2:8]
    a = bar(c-0.15, amp(i, 1), 0.25, 'FaceColor',[0 .5 .5],'EdgeColor',[0 .9 .9],'LineWidth',1.5); hold on;
    errorbar(c-0.15, amp(i, 1), ampErr(i, 1), 'Color', 'k');
    c = c+1;
end

c = 1;
for i = [2:2:8]
    b = bar(c+0.15, amp(i, 1), 0.25, 'FaceColor',[.5 .5 .5],'EdgeColor',[.9 .9 .9],'LineWidth',1.5); hold on;
    errorbar(c+0.15, amp(i, 1), ampErr(i, 1), 'Color', 'k');
    c = c+1;
end

pbaspect([1 1 1]);
set(gca, 'TickDir', 'out');
box off;
xlabel({'Modulation direction'});
ylabel({'Pupil amplitude' '[% change]'});
set(gca, 'XTick', xTicks);
set(gca, 'XTickLabel', theLabels);
ylim([0 7]);

hold on;
title(subjectID)

legend([a b], 'Static', 'CFS'); legend boxoff;
%legend(a, 'Session 1', 'Session 2', 'Location', 'NorthEast'); legend boxoff;
set(gcf, 'PaperPosition', [0 0 6 6]);
set(gcf, 'PaperSize', [6 6]);
saveas(gcf, ['PupillometryCFSAttenuationBattery_' subjectID '_xrun'], 'pdf');
%close(gcf);
