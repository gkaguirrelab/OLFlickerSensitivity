%% Rating task
function MaxPulsePsychophysics_Program

observerAgeInYrs = GetWithDefault('What is the observer age?', 20);

% Assemble the modulations
modulationDir = fullfile(getpref('OneLight', 'modulationPath'));
pathToModFileLMS = ['Modulation-PIPRMaxPulse-PulseMaxLMS_3s_MaxContrast3sSegment-' num2str(observerAgeInYrs) '.mat'];
pathToModFileMel = ['Modulation-PIPRMaxPulse-PulseMaxLMS_3s_MaxContrast3sSegment-' num2str(observerAgeInYrs) '.mat'];

% Load in the files
modFileLMS = load(fullfile(modulationDir, pathToModFileLMS));
modFileMel = load(fullfile(modulationDir, pathToModFileMel));

startsLMS = modFileLMS.modulationObj.modulation.starts;
stopsLMS = modFileLMS.modulationObj.modulation.stops;
startsMel = modFileMel.modulationObj.modulation.starts;
stopsMel = modFileMel.modulationObj.modulation.stops;

% Perceptual dimensions
perceptualDimensions = {'cool or warm', 'blurred-sharp', 'calming-alerting', 'dull-glowing'};

% Experimental stage
NStimuli = 2;
NRepeats = 2;
NPerceptualDimensions = length(perceptualDimensions);

% Wait for button press
Speak('Press key to start experiment');
WaitForKeyPress;

for is = 1:NStimuli
    for js = 1:NRepeats
        for ps = 1:NPerceptualDimensions
            Speak(['For this stimulus, judge ' perceptualDimensions{ps}]);
            WaitForKeyPress;
        end
    end
end
