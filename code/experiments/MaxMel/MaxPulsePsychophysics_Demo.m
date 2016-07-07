%% Rating task
function MaxPulsePsychophysics_Demo
% MaxPulsePsychophysics_Demo
%
% Simple program for demo of MaxMel/MaxLMS pulses
%
% 7/7/16    ms      Wrote it.
SpeakRateDefault = getpref('OneLight', 'SpeakRateDefault');

% Adaptation time
params.adaptTimeSecs = 30; % 30 seconds
params.frameDurationSecs = 1/64;
params.observerAgeInYrs = GetWithDefault('> <strong>Enter the observer age?</strong>', 20);
params.ISISecs = 5;
params.NRepeatsPerStimulus = 5;
params.NStimuli = 2;

% Assemble the modulations
modulationDir = fullfile(getpref('OneLight', 'modulationPath'));
pathToModFileLMS = ['Modulation-PIPRMaxPulse-PulseMaxLMS_3s_MaxContrast3sSegment-' num2str(params.observerAgeInYrs) '.mat'];
pathToModFileMel = ['Modulation-PIPRMaxPulse-PulseMaxLMS_3s_MaxContrast3sSegment-' num2str(params.observerAgeInYrs) '.mat'];

% Load in the files
modFileLMS = load(fullfile(modulationDir, pathToModFileLMS));
modFileMel = load(fullfile(modulationDir, pathToModFileMel));

startsLMS = modFileLMS.modulationObj.modulation.starts;
stopsLMS = modFileLMS.modulationObj.modulation.stops;
startsMel = modFileMel.modulationObj.modulation.starts;
stopsMel = modFileMel.modulationObj.modulation.stops;

stimLabels = {'MaxLMS', 'MaxMel'};
stimStarts = {startsLMS startsMel};
stimStops = {stopsLMS stopsMel};
stimStartsBG = {modFileLMS.modulationObj.modulation.background.starts modFileMel.modulationObj.modulation.background.starts};
stimStopsBG = {modFileLMS.modulationObj.modulation.background.stops modFileMel.modulationObj.modulation.background.stops};

% Wait for button press
Speak('Press key to start demo', [], SpeakRateDefault);
WaitForKeyPress;
fprintf('* <strong>Experiment started</strong>\n');

% Open the OneLight
ol = OneLight;

% Open the file to save to
f = fopen(fullfile(savePath, saveFileCSV), 'w');

for is = 1:params.NStimuli
    % Set to background
    ol.setMirrors(stimStartsBG{is}', stimStopsBG{is}');
    
    % Adapt to background for 5 minutes
    Speak(sprintf('Adapt to background for %g seconds. Press key to start adaptation', params.adaptTimeSecs), [], SpeakRateDefault);
    WaitForKeyPress;
    fprintf('\tAdaption started.');
    Speak('Adaptation started', [], SpeakRateDefault);
    tic;
    mglWaitSecs(params.adaptTimeSecs);
    Speak('Adaptation complete', [], SpeakRateDefault);
    fprintf('\n\tAdaption completed.\n\t');
    toc;
    
    for js = 1:params.NRepeats
        fprintf('\t- Stimulus: <strong>%s</strong>\n', stimLabels{is});
        fprintf('\t- Repeat: <strong>%g</strong>\n', js);
        Speak(['Press key to start.'], [], 200);
        WaitForKeyPress;
        
        fprintf('* Showing stimulus...')
        modulationFlickerStartsStops(ol, stimStarts{is}, stimStops{is}, params.frameDurationSecs, 1);
        fprintf('Done.\n')
    end
end