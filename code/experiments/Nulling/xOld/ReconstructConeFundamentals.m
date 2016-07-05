clear all;
cd /Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/Nulling
theFiles = dir('*_validation_nulling_meas*');
for f = 1:length(theFiles)
    tmp = load(theFiles(f).name);
    
    % Get the calibration file    
    cal = tmp.cache(1).cal;
    
    % Observer age
    observerAgeInYears = tmp.nulling{1, 1}.observerAge;
    
    % Get the spds
    modulationSpd = tmp.nullingval{1, 1}.meas.modulation.pr670.spectrum;
    backgroundSpd = tmp.nullingval{1, 1}.meas.background.pr670.spectrum;

    % Fraction bleachedc
    fractionBleachedLMS = tmp.cache.cacheMelanopsin.data(observerAgeInYears).describe.fractionBleached(1:3);
    fieldSizeDegrees = tmp.cache.cacheMelanopsin.data(observerAgeInYears).describe.params.fieldSizeDegrees;
    pupilDiameterMm = 4.7;
    
    [x contrast] = OLFindSilencingPhotoreceptors(backgroundSpd, modulationSpd, observerAgeInYears, fractionBleachedLMS, fieldSizeDegrees, pupilDiameterMm)
    
    ageReconstructed(f) = x(1);
    lShift(f) = x(2);
    mShift(f) = x(3);
    sShift(f) = x(4);
    ageActual(f) = observerAgeInYears;
    contrastNow(:, f) = contrast;
end

keyboard;


subplot(1, 3, 1);
plot(contrastNow(1, :), '-sr', 'MarkerFaceColor', 'r'); hold on;
plot(contrastNow(2, :), '-sg', 'MarkerFaceColor', 'g');
plot(contrastNow(3, :), '-sb', 'MarkerFaceColor', 'b');
set(gca, 'XTick', 1:length(theFiles))
xlim([0 11])
xlabel('Observer');
ylabel('Contrast');
pbaspect([1 1 1]);
title('Contrasts');
legend('L', 'M', 'S', 'Location', 'NorthWest'); legend boxoff;

subplot(1, 3, 2);
plot(lShift, '-sr', 'MarkerFaceColor', 'r'); hold on
plot(mShift, '-sg', 'MarkerFaceColor', 'g');
plot(sShift, '-sb', 'MarkerFaceColor', 'b');
pbaspect([1 1 1]);
title('Shift \lambda_{max}');
xlabel('Observer');
ylabel('Shift \lambda_{max}');
set(gca, 'XTick', 1:length(theFiles))
xlim([0 11])

subplot(1, 3, 3);
plot(ageActual, ageReconstructed, 'ok'); hold on;
xlabel('Age (actual)');
ylabel('Age (reconstructed)');
plot([20 60], [20 60], '--k');
pbaspect([1 1 1])

set(gcf, 'PaperPosition', [0 0 9 4]); %Position plot at left hand corner with width 15 and height 6.
set(gcf, 'PaperSize', [9 4]); %Set the paper to have width 15 and height 6.
saveas(gcf, 'ReconstructedCMFNulling.pdf', 'pdf');
