% Set up hemoglobin and resample
addpath(genpath('/Users/Shared/Matlab/Analysis/LightAndReceptorCalculations/HemoglobinTransmissivity'));
load trans_Hemoglobin;
S = [380 2 201];
trans_hemoglobin = SplineRaw(S_Hemoglobin, trans_Hemoglobin, S);

% Re-analyze the cache.
theDirections = {'LMDirected', 'LMinusMDirected', 'SDirected', 'MelanopsinDirected', 'RodDirected', 'MelanopsinDirectedRobust', 'OmniSilent', 'Isochromatic'};
cacheDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli';
calType = 'BoxBLongCableBEyePiece1';
params.fieldSizeDegrees = 27.5;
params.REFERENCE_OBSERVER_AGE = 32;

for d = 1:length(theDirections)
    OLAnalyzeCacheReceptorIsolate(fullfile(cacheDir, ['Cache-' theDirections{d} '.mat']), calType, params, S, trans_hemoglobin, 'hemo');
end

for ii = 1:length(w1)
transmittance(:,ii) = 10.^(-(w1(ii)*mean([oxy deoxy], 2)));
end