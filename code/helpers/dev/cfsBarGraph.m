function cfsBarGraph
%% cfsBarGraph

%Create bar graph showing effects of CFS
clear all; close all;
%% Set Subjects
subjects = {'s001' 's002' 's005'};
modulations = {'Background' 'AM 16 Hz' 'AM 4 Hz' 'DM'};
totalAmplitudes = zeros(length(modulations)*2,1);
totalAmplitudeErrors = zeros(length(modulations)*2,1); %used for computing group average
outputDir = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/code/helpers/dev/';
inputDir = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/analysis/results/PupillometryCFSAttenuationBattery/';

for i = 1:length(subjects)
    
    %% Open CSV and load subject data
    dataPath = strcat(inputDir, subjects(i),'-results.csv');
    data = csvread(char(dataPath),1,2);
    amplitudes = data(1:(length(modulations)*2),3)*100;
    amplitudeErrors = data(1:(length(modulations)*2),5)*100;
    totalAmplitudes = totalAmplitudes + amplitudes;
    totalAmplitudeErrors = totalAmplitudeErrors + amplitudeErrors;
        
    staticBackground = amplitudes(1);
    cfsBackground = amplitudes(2);
    %% Plot Results
    for j = 2:length(modulations)
        cfsData(j-1,:) = [amplitudes((2*j-1):(2*j))]';
        cfsErrorData(j-1,:) = [amplitudeErrors((2*j-1):(2*j))]';
    end
    ax = subplot(2,2,i+1);
    graph = bar(ax,cfsData);
    hold on;
    set(ax,'XTick', 1:length(modulations)-1);
    set(ax,'XTickLabel', modulations(2:4));
    xlabel('Modulation');
    set(ax, 'YLim', [0 6]);
    ylabel('Increase in Amplitude (%)');
    
    title(subjects(i));
    plot(xlim, [staticBackground staticBackground], '--k');
    plot(xlim, [cfsBackground cfsBackground], '--g');      
    hold on;
    set(graph,'BarWidth',1);    % The bars will now touch each other
    numgroups = size(cfsData, 1); 
    numbars = size(cfsData, 2); 
    groupwidth = min(0.8, numbars/(numbars+1.5));
    for j = 1:numbars
          % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
          x = (1:numgroups) - groupwidth/2 + (2*j-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
          errorbar(x, cfsData(:,j), cfsErrorData(:,j), 'k', 'linestyle', 'none');
    end
end
legend('Static', 'CFS', 'Static Noise', 'CFS Noise', 'location', 'northwest');
legend boxoff
%% Plot Group Average
averageAmplitudes = totalAmplitudes./length(subjects);
averageAmplitudeErrors = totalAmplitudeErrors./sqrt(length(subjects));
avgStaticBackground = averageAmplitudes(1);
avgCFSBackground = averageAmplitudes(2);
for j = 2:length(modulations)
    cfsData(j-1,:) = [averageAmplitudes((2*j-1):(2*j))]';
    cfsErrorData(j-1,:) = [averageAmplitudeErrors((2*j-1):(2*j))]';
end
ax = subplot(2,2,1);
graph = bar(ax,cfsData);
hold on;
set(ax,'XTick', 1:length(modulations)-1);
set(ax,'XTickLabel', modulations(2:4));
xlabel('Modulation');
set(ax, 'YLim', [0 6]);
ylabel('Increase in Amplitude (%)');
title('Group Average');
plot(xlim, [avgStaticBackground avgStaticBackground], '--k');
plot(xlim, [avgCFSBackground avgCFSBackground], '--g');hold on;
set(graph,'BarWidth',1);    % The bars will now touch each other
numgroups = size(cfsData, 1); 
numbars = size(cfsData, 2); 
groupwidth = min(0.8, numbars/(numbars+1.5));

for j = 1:numbars
      % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
      x = (1:numgroups) - groupwidth/2 + (2*j-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
      errorbar(x, cfsData(:,j), cfsErrorData(:,j), 'k', 'linestyle', 'none');
end

%%
suptitle('AM and DM Modulation With and Without CFS');
print(char([outputDir 'CFSBarGraph']), '-dpdf')