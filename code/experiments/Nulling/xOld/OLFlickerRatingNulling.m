function FlickerRatingNulling
% FlickerRatingNulling
% 
% Developed as an alternative way to null the luminance splatter of our
% Mel-directed stimulus. In this experiment, the subject is asked to
% provide a rating on a scale of 1-10 of how much flicker he/she observes
% for the Mel-directed stimulus with different amounts of LMS contrast, so
% that we can identify a zero-point to use for that subject's nulling.
%
% 2015-04-13    ams created the script.

%% Set some parameters

% Enter observer ID
observerID = GetWithDefault('Enter observer ID', 'MelBright_C0xx');

% Enter observer age
observerAge = GetWithDefault('Enter observer age', 32);

% The number of contrast steps (must be an odd number)
params.contrastSteps = 11; 

% We have designed the cache files to contain primary settings that
% correspond to a certain amount of contrast. In the case of LMS contrast, this maximum is 40%. We define these here. These
% are not magic numbers but numbers that the experimenter has dialed into
% the program 'OLPrepareStimuliNulling'. 
params.maxContrastLMS = 0.4;
params.maxContrastMel = 0.4;

% The max contrast to show.
params.maxFlickerContrast = GetWithDefault('Enter maximum LMS flicker contrast', 0.08);

% Scale the Mel stimulus (we have lately been using 0.8, for 32% contrast)
params.MelScale = 0.8;

% We will iterate over the positive and negative arms of the Mel stimulus
params.modulationArms = [1 -1];

% The proportion of the max LMS contrast that the entered max flicker
% contrast represents
params.maxScaledContrast = params.maxFlickerContrast/params.maxContrastLMS;

% The number of times to present each stimulus (i.e. number of blocks)
params.nRepeats = 5;

% The frequency of the flicker
params.nullingFrequency = 40;

% The duration fo the flicker (seconds)
params.flickerDur = 1;


%% Load in cal and cache
calibrationType = 'BoxALongCableCEyePiece2';
cal = LoadCalFile(OLCalibrationTypes.(calibrationType).CalFileName);

baseDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/';
cacheDir = fullfile(baseDir, 'cache', 'stimuli');

% Set up the cache.
olCache = OLCache(cacheDir, cal);

% Load the cache data.
cacheMelanopsin = olCache.load(['Cache-MelanopsinDirected']);            % Penumbral cone silenced
cacheMelanopsinLegacy = olCache.load(['Cache-MelanopsinDirectedLegacy']);   % Penumbral cone not silenced
cacheLMinusM = olCache.load(['Cache-LMinusMDirected']);                  % L-M
cacheSDirected = olCache.load(['Cache-SDirected']);                      % S
cacheLMSDirected = olCache.load(['Cache-LMSDirected']);                  % LMS

% Background primary
backgroundPrimary = cacheMelanopsin.data(observerAge).backgroundPrimary;
backgroundSettings = OLPrimaryToSettings(cal, backgroundPrimary);
[backgroundStarts,backgroundStops] = OLSettingsToStartsStops(cal, backgroundSettings);


%% Set up sounds
fs = 20000;
durSecs = 0.1;
t = linspace(0, durSecs, durSecs*fs);
yAdapt = sin(660*2*pi*linspace(0, 3*durSecs, 3*durSecs*fs));
yStart = [sin(440*2*pi*t) zeros(1, 1000) sin(660*2*pi*t) zeros(1, 1000) sin(880*2*pi*t)];
yLimitUp = [sin(880*2*pi*t) zeros(1, 1000) sin(880*2*pi*t) zeros(1, 1000) sin(880*2*pi*t)];
yLimitDown = [sin(440*2*pi*t) zeros(1, 1000) sin(440*2*pi*t) zeros(1, 1000) sin(440*2*pi*t)];
yChangeUp = [sin(880*2*pi*t)];
yChangeDown = [sin(440*2*pi*t)];
durSecs = 0.01;
t = linspace(0, durSecs, durSecs*fs);
yHint = [sin(880*2*pi*t)];

%% Initialize the OneLight
ol = OneLight;
ol.setMirrors(backgroundStarts, backgroundStops);
%system('say Press key to begin');
fprintf('Press any key to start experiment\n');

pause;
mglGetKeyEvent;

%% Generate the set of stimuli

% Randomly order the different contrast steps to create a block, then
% iterate this process and concatenate the blocks of trials
TrialSetIntegers = [];
for i = 1:params.nRepeats % How many blocks
    ThisBlock = randperm(params.contrastSteps);
    TrialSetIntegers = [TrialSetIntegers ThisBlock];
end

% Center the stimuli around zero and scale to the contrasts

params.TrialSetScaled = (TrialSetIntegers - median(TrialSetIntegers))*params.maxScaledContrast/((params.contrastSteps-1)/2);

%% Present each stimulus and acquire a rating from the subject

for k = 1:length(params.modulationArms)
    
    for i = 1:length(params.TrialSetScaled)
        
        % Set the modulation starts and stops as the background plus the Mel stimulus plus some LMS directed contrast
        
        tmp = backgroundPrimary + params.TrialSetScaled(i)*cacheLMSDirected.data(observerAge).differencePrimary + params.MelScale*params.modulationArms(k)*cacheMelanopsinLegacy.data(observerAge).differencePrimary ;
        modulationPrimaryNow = tmp;
        modulationSettings = OLPrimaryToSettings(cal, modulationPrimaryNow);
        [modulationStartsPos,modulationStopsPos] = OLSettingsToStartsStops(cal, modulationSettings);
        
        % Sound
        sound(yChangeUp, fs);
        % Flicker
        for j = 1:(params.nullingFrequency*params.flickerDur)
            ol.setMirrors(backgroundStarts, backgroundStops);
            mglWaitSecs(1/(params.nullingFrequency*2));
            ol.setMirrors(modulationStartsPos, modulationStopsPos);
            mglWaitSecs(1/(params.nullingFrequency*2));
        end
        
        % Go back to background
        ol.setMirrors(backgroundStarts, backgroundStops);
        sound(yChangeDown, fs);
        
        % Get a rating
        
        ratingVal = GetInput('Rating value [0 - 10]');
        
        % Save the data from this trial
        
        dataStruct(i,k).modulationArm = params.modulationArms(k);
        dataStruct(i,k).flickerContrast = params.TrialSetScaled(i).*params.maxContrastLMS;
        dataStruct(i,k).rating = ratingVal;
        
    end
    
end

% Add the resulting data to the parameter struct

params.dataStruct = dataStruct;

%% Save out

saveOutFile = [observerID '_FlickerRatingNulling'];
outPath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/Nulling/FlickerRatingNulling';
fprintf('>> Saving to %s ...', fullfile(outPath, saveOutFile));

mkdir(outPath);
save(fullfile(outPath, saveOutFile), 'params');
fprintf('done\n');
fprintf('\n==============================DONE================================\n');
    





