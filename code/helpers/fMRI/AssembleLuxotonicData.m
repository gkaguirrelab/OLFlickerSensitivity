luxFig = figure;

roi = 'v1';
subs = {'A092014B' 'A092714B'};
subX = 'A092x14B';
[t, cyc_avg1] = AssembleTSDataSurf({['/Volumes/PASSPORT/MRLuxotonic/Subjects/' subs{1} '/BOLD'] ['/Volumes/PASSPORT/MRLuxotonic/Subjects/' subs{2} '/BOLD']}, 'LMS_', luxFig, 3, 2, roi);
[t, cyc_avg2] = AssembleTSDataSurf({['/Volumes/PASSPORT/MRLuxotonic/Subjects/' subs{1} '/BOLD'] ['/Volumes/PASSPORT/MRLuxotonic/Subjects/' subs{2} '/BOLD']}, 'Melanopsin_', luxFig, 3, 3, roi);

AssembleTSDataSurf({['/Volumes/PASSPORT/MRLuxotonic/Subjects/' subs{1} '/BOLD'] ['/Volumes/PASSPORT/MRLuxotonic/Subjects/' subs{2} '/BOLD']}, 'Isochromatic_', luxFig, 3, 1, roi);

subplot(1, 3, 1); hold on
plot(t, cyc_avg1+cyc_avg2, '--r');

set(luxFig, 'PaperPosition', [0 0 20 12])
set(luxFig, 'PaperSize', [20 12]); %Set the paper to have width 5 and height 5.
saveas(luxFig, ['~/Desktop/' subX '_cycleAvg_' roi], 'pdf');



%% LGN plots
addpath(genpath('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/helpers'));
luxFig = figure;

%[t, cyc_avg1] = AssembleTSDataVol('G092014A-MRLuxotonic', {'/Volumes/PASSPORT/MRLuxotonic/Subjects/G092014A/BOLD' '/Volumes/PASSPORT/MRLuxotonic/Subjects/G092714A/BOLD'}, 'LMS_', luxFig, 3, 2);
[t, cyc_avg1] = AssembleTSDataVol('G092014A-MRLuxotonic', {'/Volumes/PASSPORT/MRLuxotonic/Subjects/G092014A/BOLD'}, 'LMS_', luxFig, 3, 2);

[t, cyc_avg2] = AssembleTSDataVol('G092014A-MRLuxotonic', {'/Volumes/PASSPORT/MRLuxotonic/Subjects/G092014A/BOLD'}, 'Melanopsin_', luxFig, 3, 3);

AssembleTSDataVol('G092014A-MRLuxotonic', {'/Volumes/PASSPORT/MRLuxotonic/Subjects/G092014A/BOLD'}, 'Isochromatic_', luxFig, 3, 1);

subplot(1, 3, 1); hold on
plot(t, cyc_avg1+cyc_avg2, '--r');

set(luxFig, 'PaperPosition', [0 0 20 12])
set(luxFig, 'PaperSize', [20 12]); %Set the paper to have width 5 and height 5.
saveas(luxFig, '~/Desktop/cycleAvg_lgn', 'pdf');

