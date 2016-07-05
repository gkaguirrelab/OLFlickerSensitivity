%% Set up some parameters
observerAgeInYrs = 32;
whichMeter = 'PR-670';
meterType = 5;
S = [380 2 201];
nAverage = 1;
meterToggle = [1 0];

%% Open devices
global g_useIOPort;
% Open up the radiometer.
g_useIOPort = 1;

% Open up the radiometer.
CMCheckInit(meterType);

% Open the Omni and the OneLight
od = [];
ol = OneLight;

% Load in the cache files
%% Load the calibration file.
cType = OLCalibrationTypes.('BoxAShortCableCEyePiece2');
cal = LoadCalFile(cType.CalFileName);

%% Setup the cache
cacheDir = fullfile('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/', 'cache', 'stimuli');
olCache = OLCache(cacheDir, cal);
cacheDataLMS = olCache.load('Cache-LMSDirected.mat');
cacheDataMel = olCache.load('Cache-MelanopsinDirectedPenumbralIgnore.mat');

% Pull out and calculate the background starts and stops
bgPrimary = cacheDataLMS.data(observerAgeInYrs).backgroundPrimary;
settings = OLPrimaryToSettings(cal, bgPrimary);
[bgStarts, bgStops] = OLSettingsToStartsStops(cal, settings);
bgSpdPred = OLPrimaryToSpd(cal, bgPrimary);

% Make a measurement of the background
measBG = OLTakeMeasurement(ol, od, bgStarts, bgStops, S, meterToggle, meterType, nAverage);
bgSpdMeas = measBG.pr650.spectrum;

scaleFactor = bgSpdPred' / bgSpdMeas';

%% Take a background spectrum
primaries = bgPrimary + 0.5*cacheDataLMS.data(observerAgeInYrs).differencePrimary;
settings = OLPrimaryToSettings(cal, primaries);
[starts, stops] = OLSettingsToStartsStops(cal, settings);

SPD_target = OLPrimaryToSpd(cal, primaries);
meas = OLTakeMeasurement(ol, od, starts, stops, S, meterToggle, meterType, nAverage);
SPD_meas_1 = scaleFactor*meas.pr650.spectrum;
SPD_meas_0 = SPD_meas_1;

% Set the learning rate
lambda = 0.75;
for i = 1:20;
    % calculate the delta
    SPD_delta = SPD_meas_1-SPD_target;
    SPD_target_1 = SPD_target - lambda*SPD_delta;

    % Reconstruct the primaries for SPD_target_1
    PRIM_target_1 = OLSpdToPrimary(cal, SPD_target_1, 0.01);
    PRIM_target_1  = PRIM_target_1(1:16:end);
    PRIM_target_1([1:9 end-3:end]) = [];

    % Measure SPD_meas_1
    primaries(:, i) = PRIM_target_1;
    [starts, stops] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, PRIM_target_1));
    meas = OLTakeMeasurement(ol, od, starts, stops, S, meterToggle, meterType, nAverage);
    SPD_meas_1 = scaleFactor*meas.pr650.spectrum;
    spds(:, i) = SPD_meas_1;
end

plot(SToWls(S), SPD_target, '-k')
hold on
plot(SToWls(S), SPD_meas_0, '-r')
plot(SToWls(S), spds(:, end), '-b')
xlabel('Wavelength [nm]');
ylabel('Power');
pbaspect([1 1 1]);
legend('Target', 'Measured', 'After optimization', 'Location', 'NorthWest'); legend boxoff;

% Calculate RMS
for i = 1:50
   rms(:, i) = (sum((spds(:,i)-SPD_target).^2))
end

% Define the wavelength spacing
S = [380 2 201];
wls = SToWls(S);

% Load in the cache
load('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/Cache-MelanopsinDirectedLegacy/BoxBLongCableCEyePiece2/15-Jan-2015_09_05_19/validation/16-Jan-2015_13_49_38/Cache-MelanopsinDirectedLegacy-BoxBLongCableCEyePiece2-SpotCheck.mat')

% Pull out the cal
cal = cals{1}.describe.cal;

% Pull out the relevant SPDs
targetSpd = cals{1}.modulationAllMeas(41).predictedSpd;
targetPrimaries = cals{1}.modulationAllMeas(41).primaries;
measuredSpd = cals{1}.modulationAllMeas(41).meas.pr650.spectrum;

% Plot them
plot(wls, measuredSpd, '-r'); hold on
plot(wls, targetSpd, '-k');

% Pull out the spectral characterization of the primaries
B_primary = cals{1}.describe.cal.computed.pr650M;

% Determine the primary values that gave rise to the target spectrum
% using left divide.
targetPrimaries_reconstructed = OLSpdToPrimary(cal, targetSpd, 0);

% Bring them into 'reduced' representation, i.e. 64x1 instead of 1024x1
targetPrimaries_reconstructed  = targetPrimaries_reconstructed(1:16:end);

% Remove all zero entries. These arise when there are skipped wavelength
% bands
targetPrimaries_reconstructed(targetPrimaries_reconstructed == 0) = [];

% Same thing with the measured primaries
measuredPrimaries_reconstructed = OLSpdToPrimary(cal, measuredSpd, 0);
measuredPrimaries_reconstructed  = measuredPrimaries_reconstructed(1:16:end);
measuredPrimaries_reconstructed([1:5 end:end-2]) = [];

figure;
plot(targetPrimaries, '-b'); hold on;
plot(targetPrimaries_reconstructed, '-k');
plot(measuredPrimaries_reconstructed, '-r');


pbaspect([1 1 1]);
xlabel('Primary number');
ylabel('Value');
legend('Target primaries', ...
    'Reconstructed target primaries', ...
    'Reconstructed measured primaries'); legend boxoff;

set(gcf, 'PaperPosition', [0 0 5 5])
set(gcf, 'PaperSize', [5 5]); %Set the paper to have width 5 and height 5.
saveas(gcf, 'ReconstructedPrimaries', 'pdf');



%% Test case
primaries = gausswin(56)*0.98;
figure;
tmp = OLSpdToPrimary(cal, OLPrimaryToSpd(cal, primaries), 0)
tmp(tmp == 0) = [];
primaries_recovered = tmp(1:16:end);

plot(primaries, '-b'); hold on;
plot(primaries_recovered, 'r')
legend('Target primaries', ...
    'Reconstructed target primaries', ...
    'Reconstructed measured primaries'); legend boxoff;
set(gcf, 'PaperPosition', [0 0 5 5])
set(gcf, 'PaperSize', [5 5]); %Set the paper to have width 5 and height 5.
saveas(gcf, 'ReconstructedPrimariesGeneral', 'pdf');
