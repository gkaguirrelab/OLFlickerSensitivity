function AnalyzePhotodiode(fileName)

load(fileName);
t = time;
s = data';
s_demeaned = s-mean(s);
fs = 1/mean(diff(t));
[fftSignal, fSignal, dc_term] = ReturnDFT(t, s, fs, true);
fftSignalDemeaned = ReturnDFT(t, s_demeaned, fs, true);

%% Plot contrast spectrum
lowerFreq = 0;
upperFreq = 256;
contrast = abs(fftSignal)/abs(dc_term); % multiply by 2 in next line due to - and +
plot(fSignal(fSignal>lowerFreq & fSignal<upperFreq), 2*contrast(fSignal>lowerFreq & fSignal<upperFreq), '-k');

xlabel('f (Hz)');
ylabel('Contrast');
title('Contrast spectrum [around DC]');
ylim([0 0.5]);
pbaspect([1 1 1]);
xlim([lowerFreq upperFreq]);
