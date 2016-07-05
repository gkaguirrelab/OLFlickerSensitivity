function waveform = OLMakeWaveform(waveform, cal, backgroundPrimary, modulationPrimary)
%% Pull out what we want

% Figure out the power levels
switch waveform.modulationMode
    case 'AM'
        waveModulation = 0.5+0.5*cos(2*pi*waveform.theEnvelopeFrequencyHz*waveform.t);
        eval(['waveCarrier = ' waveform.modulationWaveform '(2*pi*waveform.theFrequencyHz*waveform.t);']);
        powerLevels = waveModulation .* waveCarrier;
    case 'FM'
        eval(['powerLevels = waveform.theContrastRelMax*' waveform.modulationWaveform '(2*pi*waveform.theFrequencyHz*waveform.t - waveform.thePhaseRad);'])
    case 'asym_duty'
        eval(['powerLevels = waveform.theContrastRelMax*' waveform.modulationWaveform '(2*pi*waveform.theFrequencyHz*waveform.t - waveform.thePhaseRad);'])
        powerLevels = powerLevels.*rectify(square(2*pi*waveform.theEnvelopeFrequencyHz*waveform.t, 2/3*100), 'half');
end

if waveform.window.cosineWindowIn
    % Cosine window the modulation
    cosineWindow = ((cos(pi + linspace(0, 1, waveform.window.nWindowed)*pi)+1)/2);
    cosineWindowReverse = cosineWindow(end:-1:1);
    
    % Replacing values
    powerLevels(1:waveform.window.nWindowed) = cosineWindow.*powerLevels(1:waveform.window.nWindowed);
end

if waveform.window.cosineWindowOut
    powerLevels(end-waveform.window.nWindowed+1:end) = cosineWindowReverse.*powerLevels(end-waveform.window.nWindowed+1:end);
end

% If we have a frequency of 0 Hz, simply give back the
% background, otherwise compute the appropriate modulation
if waveform.theFrequencyHz == 0
    waveform.powerLevels = zeros(1, length(waveform.t));
    primaries = backgroundPrimary;
    settings = OLPrimaryToSettings(cal, primaries);
    [starts,stops] = OLSettingsToStartsStops(cal, settings);
    waveform.starts = repmat(starts, length(waveform.t), 1);
    waveform.stops = repmat(stops, length(waveform.t), 1);
    waveform.settings = repmat(settings, length(waveform.t), 1);
    waveform.primaries = repmat(primaries, length(waveform.t), 1);
else
    waveform.powerLevels = powerLevels;
    % Allocate memory
    waveform.starts = zeros(length(waveform.t), cal.describe.numColMirrors);
    waveform.stops = zeros(length(waveform.t), cal.describe.numColMirrors);
    waveform.settings = zeros(length(waveform.t), length(modulationPrimary));
    waveform.primaries = zeros(length(waveform.t), length(modulationPrimary));
    
    reverseStr = '';
    % Iterate over time steps.
    tic;
    for i = 1:length(waveform.t)
        primaries = backgroundPrimary+powerLevels(i).*modulationPrimary;
        settings = OLPrimaryToSettings(cal, primaries);
        [starts,stops] = OLSettingsToStartsStops(cal, settings);
        waveform.starts(i, :) = starts;
        waveform.stops(i, :) = stops;
        waveform.primaries(i, :) = primaries;
        waveform.settings(i, :) = settings;
        
        percentDone = 100 * i / length(waveform.t);
        msg = sprintf('Pct done: %3.1f', percentDone); %Don't forget this semicolon
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));
    end
    toc;
end