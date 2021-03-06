%% Rating task
function MaxPulsePsychophysics_Demo
% MaxPulsePsychophysics_Demo
%
% Simple program for demo of MaxMel/MaxLMS pulses
%
% 7/7/16    ms      Wrote it.
SpeakRateDefault = getpref('OneLight', 'SpeakRateDefault');

commandwindow;
observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'MELA_xxxx');
observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
todayDate = datestr(now, 'mmddyy');

% Adaptation time
params.adaptTimeSecs = 60; % 1 minute
params.frameDurationSecs = 1/64;
params.observerAgeInYrs = observerAgeInYrs;
params.ISISecs = 5;
params.NRepeatsPerStimulus = 3;
params.NStimuli = 3;

% Assemble the modulations
modulationDir = fullfile(getpref('OneLight', 'modulationPath'));
pathToModFileLMS = ['Modulation-MaxMelPulsePsychophysics-PulseMaxLMS_3s_MaxContrast3sSegment-' num2str(params.observerAgeInYrs) '_' observerID '_' todayDate '.mat'];
pathToModFileMel = ['Modulation-MaxMelPulsePsychophysics-PulseMaxMel_3s_MaxContrast3sSegment-' num2str(params.observerAgeInYrs) '_' observerID '_' todayDate '.mat'];
pathToModFileLightFlux = ['Modulation-MaxMelPulsePsychophysics-PulseMaxLightFlux_3s_MaxContrast3sSegment-' num2str(params.observerAgeInYrs) '_' observerID '_' todayDate '.mat'];

% Load in the files
modFileLMS = load(fullfile(modulationDir, pathToModFileLMS));
modFileMel = load(fullfile(modulationDir, pathToModFileMel));
modFileLightFlux = load(fullfile(modulationDir, pathToModFileLightFlux));

startsLMS = modFileLMS.modulationObj.modulation.starts;
stopsLMS = modFileLMS.modulationObj.modulation.stops;
startsMel = modFileMel.modulationObj.modulation.starts;
stopsMel = modFileMel.modulationObj.modulation.stops;
startsLightFlux = modFileLightFlux.modulationObj.modulation.starts;
stopsLightFlux = modFileLightFlux.modulationObj.modulation.stops;

stimLabels = {'LightFlux', 'MaxLMS', 'MaxMel'};
stimStarts = {startsLightFlux startsLMS startsMel};
stimStops = {stopsLightFlux stopsLMS stopsMel};
stimStartsBG = {modFileLightFlux.modulationObj.modulation.background.starts modFileLMS.modulationObj.modulation.background.starts modFileMel.modulationObj.modulation.background.starts};
stimStopsBG = {modFileLightFlux.modulationObj.modulation.background.stops modFileLMS.modulationObj.modulation.background.stops modFileMel.modulationObj.modulation.background.stops};

% Wait for button press
Speak('Press key to start demo', [], SpeakRateDefault);
WaitForKeyPress;
fprintf('* <strong>Experiment started</strong>\n');

% Open the OneLight
ol = OneLight;

for is = 1:params.NStimuli
    % Set to background
    ol.setMirrors(stimStartsBG{is}', stimStopsBG{is}');
    
    % Adapt to background for 1 minute
    Speak(sprintf('Adapt to background for %g seconds. Press key to start adaptation', params.adaptTimeSecs), [], SpeakRateDefault);
    WaitForKeyPress;
    fprintf('\tAdaptation started.');
    Speak('Adaptation started', [], SpeakRateDefault);
    tic;
    mglWaitSecs(params.adaptTimeSecs);
    Speak('Adaptation complete', [], SpeakRateDefault);
    fprintf('\n\tAdaptation completed.\n\t');
    toc;
    
    for js = 1:params.NRepeatsPerStimulus
        fprintf('\t- Stimulus: <strong>%s</strong>\n', stimLabels{is});
        fprintf('\t- Repeat: <strong>%g</strong>\n', js);
        Speak(['Press key to start.'], [], 200);
        WaitForKeyPress;
        
        fprintf('* Showing stimulus...')
        modulationFlickerStartsStops(ol, stimStarts{is}, stimStops{is}, params.frameDurationSecs, 1);
        fprintf('Done.\n')
    end
end

% Inform user
Speak('End of demo.', [], SpeakRateDefault);