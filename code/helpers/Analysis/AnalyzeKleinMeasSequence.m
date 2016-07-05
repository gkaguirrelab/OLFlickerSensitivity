function AnalyzeKleinMeasSequence(importDirectory);
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
    
    %% Do the DFT
    [fftSignal, fSignal, dc_term] = ReturnDFT(t, s, fs, true);
    
    fftSignalDemeaned = ReturnDFT(t, s_demeaned, fs, true);
    
    %% Plot the data
    theKleinFig = figure;
    nSecondsToPlot = 20;
    subplot(1, 3, 1);
    plot(t, s_demeaned, '-k');
    pbaspect([1 1 1]);
    xlim([0 nSecondsToPlot]); xlabel('Time [s]');
    ylabel('Klein Y [arb, demeaned]');
    title({[direction ', ' num2str(frequency) ' Hz; ' num2str(nSecondsToPlot) ' of ' num2str(duration) ' seconds'] ; [rawDate(1:11) ' ' rawDate(12:end)]});
    
    %% Plot the FFT
    lowerFreq = 0;
    upperFreq = 2;
    subplot(1, 3, 2);
    % Add lines at the modulation frequency
    plot(fSignal(fSignal>lowerFreq & fSignal<upperFreq),abs(fftSignalDemeaned(fSignal>lowerFreq & fSignal<upperFreq))/max(abs(fftSignalDemeaned(fSignal>lowerFreq & fSignal<upperFreq))), '-k');
    set(gca, 'YTick', [0 0.5 1], 'YTickLabel', [0 round(0.5*max(abs(fftSignalDemeaned(fSignal>lowerFreq & fSignal<upperFreq)))) round(max(abs(fftSignalDemeaned(fSignal>lowerFreq & fSignal<upperFreq))))]);
    
    xlabel('f (Hz)');
    ylabel('Amplitude [arb]');
    title('Amplitude spectrum [demeaned, 0 DC shift]')
    xlim([lowerFreq upperFreq]);
    pbaspect([1 1 1]);
    
    %% Plot contrast spectrum
    subplot(1, 3, 3);
    contrast = abs(fftSignal)/abs(dc_term); % multiply by 2 in next line due to - and +
    plot(fSignal(fSignal>lowerFreq & fSignal<upperFreq), 2*contrast(fSignal>lowerFreq & fSignal<upperFreq), '-k');
    
    xlabel('f (Hz)');
    ylabel('Contrast');
    title('Contrast spectrum [around DC]');
    ylim([0 0.5]);
    pbaspect([1 1 1]);
    xlim([lowerFreq upperFreq]);
    
    %% Save the figure
    set(theKleinFig, 'PaperPosition', [0 0 9 3]);
    set(theKleinFig, 'PaperSize', [9 3]);
    saveas(theKleinFig, fullfile(importDirectory, saveFileName), 'pdf');
    close(theKleinFig);
    
    % Construct data struct
    data.describe.date = date;
    data.describe.rawDate = rawDate;
    data.describe.fileName = theFiles(f).name;
    data.describe.filePath = importDirectory;
    data.describe.durationSecs = duration;
    data.describe.frequencyHz = frequency;
    data.describe.direction = direction;
    
    % The actual data
    data.t = t;
    data.s = s;
    data.s_demeaned = s_demeaned;
    data.fft.fftSignal = fftSignal;
    data.fft.fSignal = fSignal;
    data.fft.contrast = contrast;
    
    save(fullfile(importDirectory, saveFileName), 'data');
    
    %% Move the raw file
    if ~isdir(fullfile(importDirectory, '_raw'))
        mkdir(fullfile(importDirectory, '_raw'));
    end
    movefile(fullfile(importDirectory, [baseFileName '.meta']), fullfile(importDirectory, '_raw', [baseFileName '.meta']));
    movefile(fullfile(importDirectory, [baseFileName '.txt']), fullfile(importDirectory, '_raw', [baseFileName '.txt']));
    
end

