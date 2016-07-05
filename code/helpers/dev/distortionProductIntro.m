function distortionProductIntro
%% distortionProductIntro

% Bar graph showing results of subjects' amplitude response at 4 Hz to
% introduce concept of distortion product

subjects = {'s001' 's002' 's003' 's004'};
hold all;
amplitudes = zeros(1,length(subjects)+1);
amplitudeErrors = zeros(1,length(subjects)+1); 
outputDir = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/code/helpers/dev/';
inputDir = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/analysis/results/PupillometryDistortionProductTTF/';

for i = 1:length(subjects)
    %% Open CSV and load subject data
    dataPath = strcat(inputDir, subjects(i), '-results.csv');
    data = csvread(char(dataPath),1,2);
    amplitudes(i) = data(1,3)*100;
    amplitudeErrors(i) = data(1,5)*100;
end
amplitudes(length(subjects)+1) = mean(amplitudes(1:length(subjects))); %Group Average
amplitudeErrors(length(subjects)+1) = sum(amplitudeErrors(1:length(subjects)))/sqrt(length(subjects));
ax = subplot(1,1,1);
graph = bar(ax,amplitudes);
hold on;
set(ax, 'XTick', 1:(length(subjects)+1));
set(ax, 'XTickLabel', [subjects(1:4) 'Group Average']);
xlabel('Subject');
ylabel('Increase in Amplitude (%)');
title('Amplitude at 4 Hz AM Flicker');
errorbar(amplitudes, amplitudeErrors, 'r.');
print(char([outputDir 'distortionProductIntro']), '-dpdf')
