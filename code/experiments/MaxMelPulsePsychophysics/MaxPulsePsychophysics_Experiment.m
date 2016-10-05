%% Rating task
function MaxPulsePsychophysics_Program
% MaxPulsePsychophysics_Program
%
% Simple program to run a rating task on MaxMel/MaxLMS pulses
%
% 7/7/16    ms      Wrote it.
SpeakRateDefault = getpref('OneLight', 'SpeakRateDefault');

% Adaptation time
params.adaptTimeSecs = 2; % 5 minutes
params.frameDurationSecs = 1/64;
params.observerID = GetWithDefault('> <strong>Enter the observer name</strong>', 'HERO_xxx1');
params.observerAgeInYrs = GetWithDefault('> <strong>Enter the observer age?</strong>', 20);

protocol = 'MaxPulsePsychophysics';
dataPath = getpref('OneLight', 'dataPath');
savePath = fullfile(dataPath, protocol, params.observerID, datestr(now, 'mmddyy'), 'MatFiles');
saveFileCSV = [params.observerID '-' protocol '.csv'];
saveFileMAT = [params.observerID '-' protocol '.mat'];

if ~exist(savePath)
   mkdir(savePath); 
end

% Assemble the modulations
modulationDir = fullfile(getpref('OneLight', 'modulationPath'));
pathToModFileLMS = ['Modulation-MaxMelPulsePsychophysics-PulseMaxLMS_3s_MaxContrast3sSegment-' num2str(params.observerAgeInYrs) '_' observerID '_' todayDate '.mat'];
pathToModFileMel = ['Modulation-MaxMelPulsePsychophysics-PulseMaxMel_3s_MaxContrast3sSegment-' num2str(params.observerAgeInYrs) '_' observerID '_' todayDate '.mat'];

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

% Perceptual dimensions
perceptualDimensions = {'cool or warm', 'blurred or sharp', 'calming or alerting', 'dull or glowing'};

% Experimental stage
params.NStimuli = 2;
params.NRepeats = 2;
params.NPerceptualDimensions = length(perceptualDimensions);

% Wait for button press
Speak('Press key to start experiment', [], SpeakRateDefault);
WaitForKeyPress;
fprintf('* <strong>Experiment started</strong>\n');

% Open the OneLight
ol = OneLight;

% Open the file to save to
f = fopen(fullfile(savePath, saveFileCSV), 'w');

trialNum = 1;
for is = 1:params.NStimuli
    % Set to background
    ol.setMirrors(stimStartsBG{is}', stimStopsBG{is}');
    
    % Adapt to background for 5 minutes
    Speak(sprintf('Adapt to background for %g minutes. Press key to start adaptation', params.adaptTimeSecs/60), [], SpeakRateDefault);
    WaitForKeyPress;
    fprintf('\tAdaption started.');
    Speak('Adaptation started', [], SpeakRateDefault);
    tic;
    mglWaitSecs(params.adaptTimeSecs);
    Speak('Adaptation complete', [], SpeakRateDefault);
    fprintf('\n\tAdaption completed.\n\t');
    toc;
    
    for js = 1:params.NRepeats
        for ps = 1:params.NPerceptualDimensions
            fprintf('\n* <strong>Trial %g</strong>\n', trialNum);
            fprintf('\t- Stimulus: <strong>%s</strong>\n', stimLabels{is});
            fprintf('\t- Dimension: <strong>%s</strong>\n', perceptualDimensions{ps});
            fprintf('\t- Repeat: <strong>%g</strong>\n', js);
            Speak(['For this stimulus, judge ' perceptualDimensions{ps} '. Press key to start.'], [], 200);
            WaitForKeyPress;
            
            fprintf('* Showing stimulus...')
            modulationFlickerStartsStops(ol, stimStarts{is}, stimStops{is}, params.frameDurationSecs, 1);
            fprintf('Done.\n')
            
            % Show the stimulus
            Speak('Answer?', [], SpeakRateDefault);
            
            perceptualRating(trialNum) = GetInput('> Subject rating');
            fprintf('* <strong>Response</strong>: %g\n\n', perceptualRating(trialNum))
            
            % Save the data
            fprintf(f, '%g,%s,%s,%g,%.3f\n', trialNum, stimLabels{is}, perceptualDimensions{ps}, js, perceptualRating(trialNum));
            
            % Save the for this trial
            data(trialNum).trialNum = trialNum;
            data(trialNum).stimLabel = stimLabels{is};
            data(trialNum).stimRepeat = js;
            data(trialNum).perceptualDimension = perceptualDimensions{ps};
            data(trialNum).response = perceptualRating(trialNum);
            
            trialNum = trialNum + 1;
        end
    end
end

% Save the data as in the end
save(fullfile(savePath, saveFileMAT), 'data', 'params');
fprintf('* Data saved.\n');