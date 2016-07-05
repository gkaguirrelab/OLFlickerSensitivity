function [weights, keepRunning, smallAdjustmentMade] = OLFlickerNulling_DoNull(ol, cal, primaries, weights, weight_gamut, params, frequencyHzNulling, flickerMode, indexWhichWeightToChange, backgroundStarts, backgroundStops, sounds)
% Keep record if a small adjustment has been made
smallAdjustmentMade = false;

% Flush the queue
mglGetKeyEvent;

% Set the sound sampling rate
fs = 8192;
nSeconds = 5;
frequency = 440;
soundNullOn = sin(linspace(0, nSeconds*frequency*2*pi, round(nSeconds*fs)))/2;
audNullOn = audioplayer(soundNullOn, fs);
soundLimit = sounds{1};
audLimit = audioplayer(soundLimit, fs);
soundFeedback = sounds{2};
audFeedback = audioplayer(soundFeedback, fs);

% Assemble the primaries
modulationPrimaryNow = primaries*weights';

% Convert to settings and starts and stops
modulationSettings = OLPrimaryToSettings(cal, modulationPrimaryNow);
[modulationStartsPos,modulationStopsPos] = OLSettingsToStartsStops(cal, modulationSettings);

% Set to background
ol.setMirrors(backgroundStarts, backgroundStops);

play(audNullOn);
switch flickerMode
    case 'step'
        % Step
        ol.setMirrors(modulationStartsPos, modulationStopsPos);
        mglWaitSecs(1/(frequencyHzNulling*2));
    case 'flicker'
        % Flicker
        for j = 1:round(frequencyHzNulling/2)
            ol.setMirrors(backgroundStarts, backgroundStops);
            mglWaitSecs(1/(frequencyHzNulling*2));
            ol.setMirrors(modulationStartsPos, modulationStopsPos);
            mglWaitSecs(1/(frequencyHzNulling*2));
        end
end


% Go back to background
ol.setMirrors(backgroundStarts, backgroundStops);
stop(audNullOn);

keepRunning = true;

% Get the key
t0 = mglGetSecs;
checkKb = true;
while checkKb
    
    if mglGetSecs-t0 > 1
        checkKb= false;
    end
    tmp = mglGetKeyEvent;
    if ~isempty(tmp);
        weights0(indexWhichWeightToChange) = weights(indexWhichWeightToChange); % Save this in case we're out of gamut and need to revert
        key = tmp;
        if (str2num(key.charCode) == 1)
            weights(indexWhichWeightToChange) = weights(indexWhichWeightToChange) + params.leftKeyPolarity * params.weightForContrastStepsSmall(indexWhichWeightToChange);
            checkKb = false; smallAdjustmentMade = true;
            play(audFeedback);
        end
        if (str2num(key.charCode) == 6)
            weights(indexWhichWeightToChange) = weights(indexWhichWeightToChange) + params.rightKeyPolarity * params.weightForContrastStepsSmall(indexWhichWeightToChange);
            checkKb = false; smallAdjustmentMade = true;
            play(audFeedback);
        end
        if (str2num(key.charCode) == 2)
            weights(indexWhichWeightToChange) = weights(indexWhichWeightToChange) + params.leftKeyPolarity * params.weightForContrastStepsLarge(indexWhichWeightToChange);
            checkKb = false;
            play(audFeedback);
        end
        if (str2num(key.charCode) == 5)
            weights(indexWhichWeightToChange) = weights(indexWhichWeightToChange) + params.rightKeyPolarity * params.weightForContrastStepsLarge(indexWhichWeightToChange);
            checkKb = false;
            play(audFeedback);
        end
        if (strcmp(key.charCode, 'z'))
            keepRunning = false;
            checkKb = false;
        end
    end
    if weights(indexWhichWeightToChange) > weight_gamut(indexWhichWeightToChange)
        weights(indexWhichWeightToChange) = weight_gamut(indexWhichWeightToChange);
        playblocking(audLimit);
    elseif weights(indexWhichWeightToChange) < -weight_gamut(indexWhichWeightToChange)
        weights(indexWhichWeightToChange) = -weight_gamut(indexWhichWeightToChange);
        playblocking(audLimit);
    end
    
    %% Test if we are hitting the gamut limit.
    % We first save out the weights in the variable 'tmp',
    % and test if it is in the gamut with the in-line
    % function OLIsPrimaryInGamut.
    tmp = primaries*weights';
    if ~OLIsPrimaryInGamut(tmp)
        weights(indexWhichWeightToChange) = weights0(indexWhichWeightToChange); % Revert this to what it was
        % Make a %sound if we reach the gamut
        playblocking(audLimit);
        fprintf('\n*** GAMUT LIMIT***\n');
    end
end

