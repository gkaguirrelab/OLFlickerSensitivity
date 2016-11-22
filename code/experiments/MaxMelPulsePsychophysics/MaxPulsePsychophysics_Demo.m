%% Rating task
function MaxPulsePsychophysics_Demo
% MaxPulsePsychophysics_Demo
%
% Simple program for demo of MaxMel/MaxLMS pulses
%
% 7/7/16    ms      Wrote it.
SpeakRateDefault = getpref('OneLight', 'SpeakRateDefault');

commandwindow;
observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_test');
observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
todayDate = datestr(now, 'mmddyy');

% Adaptation time
% JR edit here
params.adaptTimeSecs = 60; % 1 minute
params.frameDurationSecs = 1/64;
params.observerAgeInYrs = observerAgeInYrs;
params.ISISecs = 5;
params.NRepeatsPerStimulus = 3;
params.NStimuli = 3;

% Assemble the modulations
% JR edit here
modulationDir = fullfile(getpref('OneLight', 'modulationPath'));
pathToModFileLMS = ['Modulation-MaxMelPulsePsychophysics-PulseMaxLMS_3s_MaxContrast3sSegment-' num2str(params.observerAgeInYrs) '_' observerID '_' todayDate '.mat'];
pathToModFileMel = ['Modulation-MaxMelPulsePsychophysics-PulseMaxMel_3s_MaxContrast3sSegment-' num2str(params.observerAgeInYrs) '_' observerID '_' todayDate '.mat'];
pathToModFileLightFlux = ['Modulation-MaxMelPulsePsychophysics-PulseMaxLightFlux_3s_MaxContrast3sSegment-' num2str(params.observerAgeInYrs) '_' observerID '_' todayDate '.mat'];

% Load in the files
% JR Edit here
modFileLMS = load(fullfile(modulationDir, pathToModFileLMS));
modFileMel = load(fullfile(modulationDir, pathToModFileMel));
modFileLightFlux = load(fullfile(modulationDir, pathToModFileLightFlux));

startsLMS = modFileLMS.modulationObj.modulation.starts;
stopsLMS = modFileLMS.modulationObj.modulation.stops;
startsMel = modFileMel.modulationObj.modulation.starts;
stopsMel = modFileMel.modulationObj.modulation.stops;
startsLightFlux = modFileLightFlux.modulationObj.modulation.starts;
stopsLightFlux = modFileLightFlux.modulationObj.modulation.stops;

%Need to add a new label. 
% JR Edit here
stimLabels = {'MaxLMS', 'MaxMel', 'LightFlux'};
stimStarts = {startsLMS startsMel startsLightFlux};
stimStops = {stopsLMS stopsMel stopsLightFlux};
stimStartsBG = {modFileLMS.modulationObj.modulation.background.starts modFileMel.modulationObj.modulation.background.starts modFileLightFlux.modulationObj.modulation.background.starts};
stimStopsBG = {modFileLMS.modulationObj.modulation.background.stops modFileMel.modulationObj.modulation.background.stops modFileLightFlux.modulationObj.modulation.background.stops};

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
    fprintf('\tAdaption started.');
    Speak('Adaptation started', [], SpeakRateDefault);
    tic;
    mglWaitSecs(params.adaptTimeSecs);
    Speak('Adaptation complete', [], SpeakRateDefault);
    fprintf('\n\tAdaption completed.\n\t');
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