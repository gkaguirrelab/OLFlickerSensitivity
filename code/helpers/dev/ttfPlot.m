function ttfPlot
%% ttfPlot

%Create line graph measuring log carrier frequency vs. change in amplitude
clear all; close all;
%% Set Subjects
subjects = {'s001' 's002' 's003' 's004'};
carrierFreqs = [4 8 16 32 64 128];
totalAmplitudes = zeros(length(carrierFreqs),1);
totalAmplitudeErrors = zeros(length(carrierFreqs),1);
outputDir = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/code/helpers/dev/';
inputDir = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/analysis/results/PupillometryDistortionProductTTF/';


hold all;
for i = 1:length(subjects)
    %% Open CSV and load subject data
    dataPath = strcat(inputDir, subjects(i), '-results.csv');
    data = csvread(char(dataPath),1,2);
    amplitudes = data(1:length(carrierFreqs),3)*100;
    amplitudeErrors = data(1:length(carrierFreqs),5)*100;
    
    totalAmplitudes = totalAmplitudes + amplitudes;
    totalAmplitudeErrors = totalAmplitudeErrors + amplitudeErrors;
    
    %% Plot Results

    errorbar(log2(carrierFreqs),amplitudes,amplitudeErrors, '-s');
    ax = gca;
    set(ax,'XTick', log2([carrierFreqs]));
    set(ax,'XTickLabel', [carrierFreqs]);
    title('Amplitude vs. Log Carrier Frequency');
    ay = gca;
    set(ay, 'YLim', [0 inf]);
    xlabel('Carrier Frequency');
    ylabel('Increase in Amplitude (%)');
end
legend(subjects);
legend boxoff;
ylim([0 2.6]);
print(char([outputDir 'TTFPlot']), '-dpdf');
hold off;

%% Plot Group Average

avgAmplitudes = totalAmplitudes./length(subjects);
avgAmplitudeErrors = totalAmplitudeErrors./sqrt(length(subjects));

errorbar(log2(carrierFreqs),avgAmplitudes,avgAmplitudeErrors, '-s');
ax = gca;
set(ax,'XTick', log2([carrierFreqs]));
set(ax,'XTickLabel', [carrierFreqs]);
title('Group Average: Amplitude vs. Log Carrier Frequency');
ay = gca;
set(ay, 'YLim', [0 2.6]);
xlabel('Carrier Frequency');
ylabel('Increase in Amplitude (%)');
print(char([outputDir 'TTFPlotGroupAverage']), '-dpdf')