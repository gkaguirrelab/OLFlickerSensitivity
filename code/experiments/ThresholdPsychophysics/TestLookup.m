% Set timing properties
frameDurationSecs = 1/128;
durationSecs = 1.5;
cosineWindowSecs = 0.25;
t = 0:frameDurationSecs:durationSecs-frameDurationSecs;

% Get the calibration structure
cal = OLGetCalibrationStructure;

% Set the sounds
fs = 8192;
nSeconds = 5;
durSecs = 0.05;
frequency = 440;
soundStim1On = sin(linspace(0, nSeconds*frequency*2*pi, round(nSeconds*fs)))/2;
audNullOn = audioplayer(soundStim1On, fs);

nTotal = length(t);
COSINE_WINDOW = true;
if COSINE_WINDOW
    nWindowed = cosineWindowSecs/frameDurationSecs;
    
    % Define the cosine window indices
    cosineWindowInIdx = 1:nWindowed;
    cosineWindowOutIdx = (nTotal-(nWindowed))+1:nTotal;
    
    % Actually calculate the cosine window
    cosineWindowIn = ((cos(pi + linspace(0, 1, nWindowed)*pi)+1)/2);
    cosineWindowOut = cosineWindowIn(end:-1:1);
end

% Load in primary values
tmp = load('Cache-MelanopsinDirectedPenumbralIgnore.mat')
bgPrimary = tmp.BoxCRandomizedLongCableBEyePiece1BeamSplitterOff{end}.data(32).backgroundPrimary;
diffPrimary = tmp.BoxCRandomizedLongCableBEyePiece1BeamSplitterOff{end}.data(32).modulationPrimarySignedPositive-tmp.BoxCRandomizedLongCableBEyePiece1BeamSplitterOff{end}.data(32).backgroundPrimary;
tmp = load('Cache-LMSDirectedNoise.mat');
noisePrimary1 = tmp.BoxCRandomizedLongCableBEyePiece1BeamSplitterOff{end}.data(32).modulationPrimarySignedPositive-tmp.BoxCRandomizedLongCableBEyePiece1BeamSplitterOff{end}.data(32).backgroundPrimary;
tmp = load('Cache-LMinusMDirectedNoise.mat');
noisePrimary2 = tmp.BoxCRandomizedLongCableBEyePiece1BeamSplitterOff{end}.data(32).modulationPrimarySignedPositive-tmp.BoxCRandomizedLongCableBEyePiece1BeamSplitterOff{end}.data(32).backgroundPrimary;
basisPrimary = [bgPrimary diffPrimary noisePrimary1 noisePrimary2];

CONE_NOISE = true;
coneNoiseHz = 8; % Hz
dIdxConeNoise = (1/coneNoiseHz)/frameDurationSecs; % How many samples correspond to one cone noise 'step'

%% EVENT OBJECT
nVersions = 5;
for v = 1:nVersions
    clear startsBuffer stopsBuffer;
    % Waveform specified for each of the primaries
    s = zeros(size(basisPrimary, 2), nTotal);
    s(1, :) = 1;                % Background
    s(2, :) = 0.8;    % Modulation
    s(2, cosineWindowInIdx) = cosineWindowIn;
    s(2, cosineWindowOutIdx) = cosineWindowOut;
    
    % Noise
    startIdx = 1:(1/(frameDurationSecs)/(coneNoiseHz)):nTotal;
    endIdx = (1/(frameDurationSecs))/(coneNoiseHz):(1/(frameDurationSecs))/(coneNoiseHz):nTotal;
    nRandStates = 31;
    nRandLevels = linspace(-1, 1, nRandStates);
    
    for i = 1:length(startIdx)
        noiseStateVectorLMS(startIdx(i):endIdx(i)) = nRandLevels(randi(nRandStates, 1));
        noiseStateVectorLMinusM(startIdx(i):endIdx(i)) =  nRandLevels(randi(nRandStates, 1));
    end
    
    % Assign the noise vector
    s(3, :) = noiseStateVectorLMS;
    s(4, :) = noiseStateVectorLMinusM;
    
    % Calculate the primary settings as a simple linear operation
    primariesBuffer = basisPrimary*s;
    
    % Find the unique primary settings up to a tolerance value
    %[uniqPrimariesBuffer, ~, IC] = uniquetol(primariesBuffer', 'ByRows', true);
    [uniqPrimariesBuffer, ~, IC] = unique(primariesBuffer', 'rows');
    uniqPrimariesBuffer = uniqPrimariesBuffer'; % Transpose
    
    % Convert the unique primaries to starts and stops
    settingsBuffer = OLPrimaryToSettings(cal, uniqPrimariesBuffer);
    for si = 1:size(settingsBuffer, 2)
        [startsBuffer(:, si), stopsBuffer(:, si)] = OLSettingsToStartsStops(cal, settingsBuffer(:, si));
    end
    
    eventObj(v).IC = IC;
    eventObj(v).startsBuffer = startsBuffer;
    eventObj(v).stopsBuffer = stopsBuffer;
end

%% Background OBJECT
for v = 1:nVersions
    clear startsBuffer stopsBuffer;
    % Waveform specified for each of the primaries
    s = zeros(size(basisPrimary, 2), nTotal);
    s(1, :) = 1;                % Background
    s(2, :) = 0;    % Modulation
    
    % Noise
    startIdx = 1:(1/(frameDurationSecs)/(coneNoiseHz)):nTotal;
    endIdx = (1/(frameDurationSecs))/(coneNoiseHz):(1/(frameDurationSecs))/(coneNoiseHz):nTotal;
    nRandStates = 31;
    nRandLevels = linspace(-1, 1, nRandStates);
    
    for i = 1:length(startIdx)
        noiseStateVectorLMS(startIdx(i):endIdx(i)) = nRandLevels(randi(nRandStates, 1));
        noiseStateVectorLMinusM(startIdx(i):endIdx(i)) =  nRandLevels(randi(nRandStates, 1));
    end
    
    % Assign the noise vector
    s(3, :) = noiseStateVectorLMS;
    s(4, :) = noiseStateVectorLMinusM;
    
    % Calculate the primary settings as a simple linear operation
    primariesBuffer = basisPrimary*s;
    
    % Find the unique primary settings up to a tolerance value
    %[uniqPrimariesBuffer, ~, IC] = uniquetol(primariesBuffer', 'ByRows', true);
    [uniqPrimariesBuffer, ~, IC] = unique(primariesBuffer', 'rows');
    uniqPrimariesBuffer = uniqPrimariesBuffer'; % Transpose
    
    % Convert the unique primaries to starts and stops
    settingsBuffer = OLPrimaryToSettings(cal, uniqPrimariesBuffer);
    for si = 1:size(settingsBuffer, 2)
        [startsBuffer(:, si), stopsBuffer(:, si)] = OLSettingsToStartsStops(cal, settingsBuffer(:, si));
    end
    
    backgroundObj(v).IC = IC;
    backgroundObj(v).startsBuffer = startsBuffer;
    backgroundObj(v).stopsBuffer = stopsBuffer;
end

%% The trial vector
trialVector = [1 2 1 2 1 2 1 2 1 2 1 2 1 2];

ol = OneLight;
while true
    % Run the trials
    for m = 1:length(trialVector)
        if trialVector(m) == 1
            theString = 'backgroundObj';
        elseif trialVector(m) == 2
            theString = 'eventObj';
        end
        
        if trialVector(m) == 2
            play(audNullOn); % Play sound
        end
        mileStone = mglGetSecs + frameDurationSecs;
        i = 0;
        while i+1 <= length(IC)
            if mglGetSecs >= mileStone;
                i = i+1;
                mileStone = mglGetSecs + frameDurationSecs;
                eval(['ol.setMirrors(' theString '(v).startsBuffer(:, ' theString '(v).IC(i)), ' theString '(v).stopsBuffer(:, ' theString '(v).IC(i)));']);
            end
        end
        
        if trialVector(m) == 2
            stop(audNullOn);
        end
    end
end




% % Test
% settingsBuffer_orig = OLPrimaryToSettings(cal, primariesBuffer_orig);
% for si = 1:size(settingsBuffer_orig, 2)
%     [startsBuffer_orig(:, si), stopsBuffer_orig(:, si)] = OLSettingsToStartsStops(cal, settingsBuffer_orig(:, si));
% end
%
