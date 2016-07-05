close all;
%% Assemble data points for distortion product measurements and plot frequency response
theCols = [142	142	56 ; 173	216	230	; 113	198	113 ; 110	80	60 ; 40 40 120]/255;
theSubjects = {'s004' 's004Brimonidine' };
for s = 1:length(theSubjects)
    m = csvread(['/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/PupillometryDistortionProduct/' theSubjects{s} '-results.csv'], 1, 1);
    
    freqs = [4 8 16 32 64 128];
    errorbar(log2(freqs), 100*m(1:6, 4), 100*m(1:6, 6), 'Color', [0.5 0.5 0.5]); hold on;
    a(s) = plot(log2(freqs), 100*m(1:6, 4), '-s', 'Color', theCols(s, :), 'MarkerFaceColor', theCols(s, :), 'MarkerEdgeColor', 'k');
    pbaspect([1 1 1]);
    set(gca, 'TickDir', 'out');
    box off;
    xlabel({'Frequency' '[Hz]'});
    ylabel({'Pupil amplitude' '[% change]'});
    set(gca, 'XTick', log2([4 8 16 32 64 128]));
    set(gca, 'XTickLabel', [4 8 16 32 64 128]);
    ylim([0 3]);
    
    hold on;
end
legend(a, theSubjects, 'Location', 'NorthEast'); legend boxoff;
%legend(a, 'Session 1', 'Session 2', 'Location', 'NorthEast'); legend boxoff;
title({'Isochromatic distortion product' ; 's002 across runs'});
set(gcf, 'PaperPosition', [0 0 5 5]);
set(gcf, 'PaperSize', [5 5]);
saveas(gcf, 'DistortionProduct_s004Brimonidine', 'pdf');
close(gcf);
