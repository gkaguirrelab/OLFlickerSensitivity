function estimate = AnalyzeKleinMeasSequence(importDirectory);
% AnalyzeKleinMeasSequence(importDirectory);
%
% 3/1/2014  ms  Wrote it.

% Get the files.
theFiles = dir(fullfile(importDirectory, ['Klein*txt']));
% Iterate over the files
for f = 1:length(theFiles)
    %% File and file namingmanagement
    % Get the base file name
    [~, baseFileName] = fileparts(theFiles(f).name);
    
    % Get metadata
    [direction, frequency, duration] = ReadKleinMetaData(fullfile(importDirectory, [baseFileName '.meta']));
    
    %% Read in the file
    [t, s, s_demeaned, fs, range, date] = ReadKleinFileStream(fullfile(importDirectory, [baseFileName '.txt']));
    
    rawDate = date;
    date = strrep([date(1:11) '_' date(12:end)], ':', '_');
    
    %% Also get the cal type and cal date. This assumes the directory structure that is currently set up.
    cd(importDirectory);
    cd ../..
    [~, calDate] = fileparts(pwd);
    cd ..
    [~, calType] = fileparts(pwd);
    cd(importDirectory);
    
    % Construct a sensible file name to save into
    saveFileName = [direction '_' num2str(frequency) 'Hz_' num2str(duration) 's_meas_' date];
    %plot(t, s); hold on
    
  
    %% Mayank to fit sine and cosine here, extract amplitude
    meanS = mean(s);
    s = s-meanS; % mean average
    period = 1/frequency;
    
    X = ones(length(t),3);
    X(:,2) = cos(2*pi/period.*t');
    X(:,3) = sin(2*pi/period.*t');
    beta = X\s'; % beta gives values for coefficients for sin and cos
    avgAmplitude = sqrt(beta(2)^2+beta(3)^2) / meanS; % divison by mean should output contrast
    amplitudes(f) = avgAmplitude*100;
    
    %sinusoid = beta(2)*cos(2*pi/period.*t') + beta(3)*sin(2*pi/period.*t') + beta(1);
    %plot(t, sinusoid, t, s) %plots sinusoid of best fit
    
end

contrasts = 5:5:45; %hard-coded in
%linReg = polyfit(contrasts, amplitudes, 1);
%slope = linReg(1);
%intercept = linReg(2);
slope = amplitudes/contrasts; %intercept of 0

estimate = slope*[0:diff(contrasts):max(contrasts)+diff(contrasts)];
%hold on
%plot(contrasts, estimate) % line of best fit
%plot(contrasts, amplitudes, 'ob')
%plot(contrasts, contrasts, 'r')
%axis([0 max(contrasts)+min(contrasts) 0 max(contrasts) + min(contrasts)])