% Observer age
observerAgeInYrs = 28;

% Initialize the OneLight
ol = OneLight;

% Load in the MaxMel cache file
cal = LoadCalFile('OLBoxDRandomizedLongCableAEyePiece2_ND06');
%tmp = load('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/Cache-LMSDirectedSuperMaxLMS.mat')
%tmp = load('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/Cache-MelanopsinDirectedSuperMaxMel.mat')
tmp = load('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/Cache-RodDirectedMaxRod.mat')
%tmp = load('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/cache/stimuli/Cache-MelanopsinDirectedMaxMelRodSilent.mat')
bgPrimary = tmp.BoxDRandomizedLongCableAEyePiece2_ND06{end}.data(observerAgeInYrs).backgroundPrimary;
diffPrimary =  tmp.BoxDRandomizedLongCableAEyePiece2_ND06{end}.data(observerAgeInYrs).differencePrimary;

%% Set up the time vector
dt = 1/128;
stimDurSecs = 3;
cosineWinSecs = 0.5;
nWindowed = cosineWinSecs/dt;
nSamples = stimDurSecs/dt;

% Cosine window the modulation
cosineWindow = ((cos(pi + linspace(0, 1, nWindowed)*pi)+1)/2);
cosineWindowReverse = cosineWindow(end:-1:1);
powerLevels = ones(1, nSamples);

% Replace values
powerLevels(1:nWindowed) = cosineWindow.*powerLevels(1:nWindowed);
powerLevels(end-nWindowed+1:end) = cosineWindowReverse.*powerLevels(end-nWindowed+1:end);
tmpPrimary = repmat(diffPrimary, 1, nSamples);
powerLevels = repmat(powerLevels, size(tmpPrimary, 1), 1);
modPrimary = powerLevels .* tmpPrimary + repmat(bgPrimary, 1, nSamples);

% Now, convert to starts and stops
[bgStarts, bgStops] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, bgPrimary));
[modStarts, modStops] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, modPrimary));

%% 
while true
    ol.setMirrors(bgStarts, bgStops);
    mglWaitSecs(0.5);
    OLFlickerStartsStopsDemo(ol, modStarts', modStops', dt, 1, false);
    ol.setMirrors(bgStarts, bgStops);
    mglWaitSecs(1);
end