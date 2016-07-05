function cfsDirectAttenuation
%% cfsDirectAttenuation

% Show amplitude response at both f and 2f
clear all; close all;
%% Set Subjects
subjects = {'s001' 's002' 's005'};
frequency = {'' '-2f'}; %indicates if measuring at f or 2f
modulations = {'0.05 Hz DM' '0.5 Hz DM'};
outputDir = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/code/helpers/dev/';
inputDir = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/analysis/results/PupillometryCFSDirectedFM/';

hold all;
for i = 1:length(frequency)
    totalAmplitudes = zeros(length(modulations)*2+2,1);
    totalAmplitudeErrors = zeros(length(modulations)*2+2,1); %used for computing group average
    for j = 1:length(subjects)
        %% Open CSV and load subject data
        dataPath = strcat(inputDir, subjects(j), frequency(i),'-results.csv');
        data = csvread(char(dataPath),1,2);
        amplitudes = data(:,3)*100;
        amplitudeErrors = data(:,5)*100;
        totalAmplitudes = totalAmplitudes + amplitudes;
        totalAmplitudeErrors = totalAmplitudeErrors + amplitudeErrors;
        
        firstBackground = amplitudes(length(modulations)*2+1);
        secondBackground = amplitudes(length(modulations)*2+2);

        %% Plot Results
        for k = 1:length(modulations)
            cfsData(k,:) = [amplitudes(k) amplitudes(k + length(modulations))];
            cfsErrorData(k,:) = [amplitudeErrors(k) amplitudeErrors(k + length(modulations))];
        end
        ax = subplot(2,2,j+1);
        graph = bar(ax,cfsData);
        hold on;
        set(ax,'XTick', 1:length(modulations));
        set(ax,'XTickLabel', modulations);
        set(ax, 'YLim', [0 5]);
        ylabel('Increase in Amplitude (%)');

        title(subjects(j));
        plot([0 1.5], [firstBackground firstBackground], '--k');
        plot([1.5 3], [secondBackground secondBackground], '--g');        
        hold on;
        set(graph,'BarWidth',1);    % The bars will now touch each other
        numgroups = size(cfsData, 1); 
        numbars = size(cfsData, 2); 
        groupwidth = min(0.8, numbars/(numbars+1.5));
        for k = 1:numbars
              % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
              x = (1:numgroups) - groupwidth/2 + (2*k-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
              errorbar(x, cfsData(:,k), cfsErrorData(:,k), 'k', 'linestyle', 'none');
        end
    end
    
    if i == 1
        legend('Static', 'CFS', 'location', 'southeast');
    end
    
    %% Plot Group Average
    averageAmplitudes = totalAmplitudes./length(subjects);
    averageAmplitudeErrors = totalAmplitudeErrors./sqrt(length(subjects));

    avgFirstBackground = averageAmplitudes(length(modulations)*2+1);
    avgSecondBackground = averageAmplitudes(length(modulations)*2+2);
    
    for k = 1:length(modulations)
        cfsData(k,:) = [averageAmplitudes(k) averageAmplitudes(k + length(modulations))];
        cfsErrorData(k,:) = [averageAmplitudeErrors(k) ...
            averageAmplitudeErrors(k + length(modulations))];
    end
    ax = subplot(2,2,1);
    graph = bar(ax,cfsData);
    hold on;
    set(ax,'XTick', 1:length(modulations));
    set(ax,'XTickLabel', modulations);
    set(ax, 'YLim', [0 5]);
    ylabel('Increase in Amplitude (%)');
    title('Group Average');
    plot([0 1.5], [avgFirstBackground avgFirstBackground], '--k');
    plot([1.5 3], [avgSecondBackground avgSecondBackground], '--g');
    hold on;
    set(graph,'BarWidth',1);    % The bars will now touch each other
    numgroups = size(cfsData, 1); 
    numbars = size(cfsData, 2); 
    groupwidth = min(0.8, numbars/(numbars+1.5));
    for k = 1:numbars
          % Based on barweb.m by Bolu Ajiboye from MATLAB File Exchange
          x = (1:numgroups) - groupwidth/2 + (2*k-1) * groupwidth / (2*numbars);  % Aligning error bar with individual bar
          errorbar(x, cfsData(:,k), cfsErrorData(:,k), 'k', 'linestyle', 'none');
    end
    if i == 1
        suptitle('DM Modulation With and Without CFS at f');
    else
        suptitle('DM Modulation With and Without CFS at 2f');
    end
    fileOutputName = char(strcat(outputDir,'DMDirectAttenuation', frequency(i)));
    print(fileOutputName, '-dpdf');
end
