function hfpPrep(calString)

% Load the calibration
cal = LoadCalFile(calString);
nPrimaries = size(cal.computed.pr650M, 2);
S = cal.describe.S;
wls = SToWls(S);

allPrimaries = eye(nPrimaries);
% Scale to the smallest primary we have, at the short wl end
scalFactor = max(cal.computed.pr650M(:, 2));
for i = 1:nPrimaries
    allPrimaries(:, i) = allPrimaries(:, i)*(scalFactor/max(cal.computed.pr650M(:, i)));
end

% Select the primaries we want.
idx = 2:2:nPrimaries;
refPrimaries = allPrimaries(:, idx);
nPrimaries = length(idx);

% Select test and reference values. For this we assume that for wavelengths
% below the maximum of the photopic luminosity function, we take always the
% longer wavelengths as the test. For wavelengths above the maximum of the
% photopic luminosity function, we take the shorter wavelengths as the
% test.
%
% We assume that the peak is at 555 nm.
for i = 1:nPrimaries
    [~, peakWlIdx(i)] = max(cal.computed.pr650M*refPrimaries(:, i));
    peakWl(i) = wls(peakWlIdx(i));
    if peakWl(i) < 555
        testPrimaries{i} =  idx(i+1:i+3);
    end
    if peakWl(i) >= 555
        testPrimaries{i} =  idx(i-3:i-1);
    end
end

% Convert them to starts and stops
intensities = 0:0.005:1.2;
nIntensities = length(intensities);

for i = 1:nPrimaries
    for k = 1:nIntensities
        refPrimaryVals{i}(:, k) = intensities(k)*refPrimaries(:, i);
        [refPrimaryStarts{i}(:, k) refPrimaryStops{i}(:, k)] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, refPrimaryVals{i}(:, k)));
    end
end

% Find the index where the normalized primary intensity is 1
idxUnitIntensity = find(intensities == 1);

theFileName = [calType '-MonochromaticPrimaries'];
save(theFileName, 'cal', 'S', 'wls', 'intensities', 'refPrimaryVals', 'refPrimaryStarts', 'refPrimaryStops', 'idxUnitIntensity', 'nIntensities');