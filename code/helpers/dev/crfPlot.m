function crfPlot
%% crfPlot

%Create line graph measuring log contrats vs. amplitude
clear all; close all;
%% Set Subjects
subjects = {'s001' 's002'};
outputDir = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/code/helpers/dev/';
inputDir = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/analysis/results/PupillometryLightFluxDistortion4HzCRF/';
hold all;
for i = 1:length(subjects)
    %% Open CSV and load subject data
    dataPath = strcat(inputDir, subjects(i), '-results.csv');
    data = csvread(char(dataPath),1,2);
    contrasts = [2 4 8 16 32 64];
    amplitudes = data(1:length(contrasts),3)*100;
    amplitudeErrors = data(1:length(contrasts),5)*100;

    %% Plot Results

    errorbar(log2(contrasts),amplitudes,amplitudeErrors, '-s');
    ax = gca;
    set(ax,'XTick', log2([contrasts]));
    set(ax,'XTickLabel', [contrasts]);
    xlabel('Percent Contrast');
    ay = gca;
    set(ay, 'YLim', [0 inf]);
    ylabel('Increase in Amplitude (%)');
end
legend(subjects, 'location', 'best');
legend boxoff
title('Amplitude vs. Log Contrast');
print(char([outputDir 'CRFPlot']), '-dpdf')