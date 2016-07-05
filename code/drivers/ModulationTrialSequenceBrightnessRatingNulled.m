function params = ModulationTrialBrightnessRating(exp)


%% Setup basic parameters for the experiment
params = initParams(exp);

% Initialize the LabJack once at the beginning of the experiment. This
% saves us 1.2 to 1.3 seconds for each initialization of the LabJack. The
% delay added by LabJack routines when actually recording is about 60 ms,
% i.e. it takes an additional 60 ms to enter and exit the recording
% routines.

% Ask for the observer age
params.observerAgeInYears = GetWithDefault('Observer age', 32);

% Load the calibration file.
cType = OLCalibrationTypes.(params.calibrationType);
params.oneLightCal = LoadCalFile(cType.CalFileName);

% Setup the cache.
params.olCache = OLCache(params.cacheDir, params.oneLightCal);

% Load the different modulation direction caches
for k = 1:length(params.cacheFileName)
    k
    % Construct the file name to load in age-specific file
    
    [~, fileName, fileSuffix] = fileparts(params.cacheFileName{k});
    params.cacheFileName{k} = fileName;
    cacheData{k} = params.olCache.load(params.cacheFileName{k});
    
end

% Load the different noise direction caches
for k = 1:length(params.cacheFileNoiseName)
    
    % Construct the file name to load in age-specific file
    
    [~, fileName, fileSuffix] = fileparts(params.cacheFileNoiseName{k});
    params.cacheFileNoiseName{k} = fileName;
    cacheDataNoise{k} = params.olCache.load(params.cacheFileNoiseName{k});
    
end

% Put together the trial order
% Pre-initialize the blocks
block = struct();
block(params.nTrials).describe = '';

% Pull out and calculate the background starts and stops
bgPrimary = cacheData{1}.data(params.observerAgeInYears).backgroundPrimary;
settings = OLPrimaryToSettings(params.oneLightCal, bgPrimary);
[bgStarts, bgStops] = OLSettingsToStartsStops(params.oneLightCal, settings);

% Now, overwrite the loaded cache file with the individualized nulls
nullFile = [exp.subject '_nulling.mat'];
nullPath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/Nulling';
fprintf('>> Loading %s ...', fullfile(nullPath, nullFile));
if exist(fullfile(nullPath, nullFile), 'file')
   wtmp = load(fullfile(nullPath, nullFile));
   % The config file dictates what the first cache file is, and we know
   % that the nulling experiment started with the melanopsin null, then the
   % LMS null. We just overwrite the difference primary value in the
   % cacheData cell.
   cacheData{2}.nulledDifferencePrimary = wtmp.nullingaverages{2}.differencePrimary; % LMS
   cacheData{3}.nulledDifferencePrimary = wtmp.nullingaverages{1}.differencePrimary; % Mel
else
    error('Nulling file does not exist. Run OLNullingExperiment.');
end


% Create the starts and stops for the adaptation to the background
%  The ClimbFlag determines if a slow increase from mirrors off is used
%  at the start of the adaptation period

ClimbFlag = false;

if ClimbFlag % Define a gradual rise from mirrors off
    % We divide the adaptation period into climb and plateau presentation.
    %  This division is hard coded by the ClimbRatio
    
    ClimbRatio = 0.75; % This proportion of the adaptation period spent climbing
    
    AdaptRefreshRate = 0.1; % Update the mirror settings at this rate in seconds
    nSteps = params.trialAdaptInSecs / AdaptRefreshRate; % Number of mirror setting updates during the adaptation period
    
    % Define a profile for the climb (beta cumulative distribution function), followed by a plateau
    betaCDFClimb=betacdf(linspace(0,1,nSteps*ClimbRatio),2,2);
    fullClimb=[betaCDFClimb ones(1,nSteps-round(nSteps*ClimbRatio))];
    
    % Build the starts and stops
    primariesAdaptPeriod = bgPrimary * fullClimb;
    settingsAdaptPeriod = OLPrimaryToSettings(params.oneLightCal, primariesAdaptPeriod);
    [startsAdaptPeriod, stopsAdaptPeriod] = OLSettingsToStartsStops(params.oneLightCal, settingsAdaptPeriod);
    
else % Go straight to background
    AdaptRefreshRate = params.trialAdaptInSecs; % Update the mirror settings at this rate in seconds
    nSteps = params.trialAdaptInSecs / AdaptRefreshRate; % Number of mirror setting updates during the adaptation period
    fullClimb=ones(1,nSteps);
    
    % Build the starts and stops
    primariesAdaptPeriod = bgPrimary * fullClimb;
    settingsAdaptPeriod = OLPrimaryToSettings(params.oneLightCal, primariesAdaptPeriod);
    [startsAdaptPeriod, stopsAdaptPeriod] = OLSettingsToStartsStops(params.oneLightCal, settingsAdaptPeriod);
end


% Pull and calculate the starts and stops for each trial
for k = 1:params.nTrials
    fprintf('- Preconfiguring trial %i/%i...', k, params.nTrials);
    
    % Assemble the starts and stops. This will be a linear combination of
    % the contrast called for on the LMS and Melanopsin directions. Note
    % that negative contrast values will be called for.
    
    trialPrimary = bgPrimary + params.trialSeqLMSContrast(k)*cacheData{2}.nulledDifferencePrimary + params.trialSeqMelContrast(k)*cacheData{3}.nulledDifferencePrimary;
    settings = OLPrimaryToSettings(params.oneLightCal, trialPrimary);
    [trialStarts{k}, trialStops{k}] = OLSettingsToStartsStops(params.oneLightCal, settings);
    
    fprintf('\n');
    
    % Make the ramp on that precedes each trial
    
    timeStep = 1/20;
    rampDurationSec = 0.5;
    nWindowed = rampDurationSec/timeStep;
    powerLevels = ones(1, nWindowed);
    t = 0:timeStep:rampDurationSec-timeStep;
    
    % Cosine window the modulation
    cosineWindow = ((cos(pi + linspace(0, 1, nWindowed)*pi)+1)/2);
    powerLevels(1:nWindowed) = cosineWindow.*powerLevels(1:nWindowed);
    
    % Set the power levels for the noise. For now, we'll just make a random
    % vector the size of nWindon, Gaussian noise, zero mean, 0.5 SD.
    tmp1 = random('unif', -1, 1, [1 nWindowed]); %sin(2*pi*tf1*t);
    tmp2 = random('unif', -1, 1, [1 nWindowed]);
    tmp3 = random('unif', -1, 1, [1 nWindowed]);
    tmp0 = gausswin(nWindowed, 3.5);
    noise1 = tmp0 .* tmp1';
    noise2 = tmp0 .* tmp2';
    noise3 = tmp0 .* tmp3';
    
    % Define the modulation primary
    for j = 1:nWindowed
        primaries(:, j) = bgPrimary +powerLevels(j)*((params.trialSeqLMSContrast(k)*cacheData{2}.nulledDifferencePrimary ...
            + params.trialSeqMelContrast(k)*cacheData{3}.nulledDifferencePrimary)) ...
            + noise1(j) * cacheDataNoise{1}.data(params.observerAgeInYears).differencePrimary ...
            + noise2(j) * cacheDataNoise{2}.data(params.observerAgeInYears).differencePrimary ...
            + noise3(j) * cacheDataNoise{3}.data(params.observerAgeInYears).differencePrimary;
        
        % Add noise.
        settings(:, j) = OLPrimaryToSettings(params.oneLightCal, primaries(:, j));
        [trialStartsDynamic1{k}(:, j), trialStopsDynamic1{k}(:, j)] = OLSettingsToStartsStops(params.oneLightCal, settings(:, j));
        
    end
    
    % Do the same thing in reverse
    powerLevels = powerLevels(end:-1:1);
    for j = 1:nWindowed
        primaries(:, j) = bgPrimary+powerLevels(j)*((params.trialSeqLMSContrast(k)*cacheData{2}.nulledDifferencePrimary ...
            + params.trialSeqMelContrast(k)*cacheData{3}.nulledDifferencePrimary)) ...
            + noise1(j) * cacheDataNoise{1}.data(params.observerAgeInYears).differencePrimary ...
            + noise2(j) * cacheDataNoise{2}.data(params.observerAgeInYears).differencePrimary ...
            + noise3(j) * cacheDataNoise{3}.data(params.observerAgeInYears).differencePrimary;
        
        % Add noise.
        settings(:, j) = OLPrimaryToSettings(params.oneLightCal, primaries(:, j));
        [trialStartsDynamic2{k}(:, j), trialStopsDynamic2{k}(:, j)] = OLSettingsToStartsStops(params.oneLightCal, settings(:, j));
        
    end
    
end

% Carry over the parameters to the params struct.
params.ramp.dt = timeStep;
params.ramp.nSamples = nWindowed;
params.trialStartsDynamic1 = trialStartsDynamic1;
params.trialStopsDynamic1 = trialStopsDynamic1;
params.trialStartsDynamic2 = trialStartsDynamic2;
params.trialStopsDynamic2 = trialStopsDynamic2;
params.trialStarts = trialStarts;
params.trialStops = trialStops;
params.bgStarts = bgStarts;
params.bgStops = bgStops;
params.startsAdaptPeriod = startsAdaptPeriod;
params.stopsAdaptPeriod = stopsAdaptPeriod;
params.AdaptRefreshRate = AdaptRefreshRate;

%% Create the OneLight object.
% This makes sure we are talking to OneLight.
ol = OneLight;

% Make sure our input and output pattern buffers are setup right.
ol.InputPatternBuffer = 0;
ol.OutputPatternBuffer = 0;

ol.setMirrors(params.bgStarts', params.bgStops');

fprintf('\n* Creating keyboard listener\n');
mglListener('init');

%% Run the trial loop.
params = trialLoop(params, exp);

% Toss the OLCache and OneLight objects because they are really only
% ephemeral.

params = rmfield(params, {'olCache'});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% SUBFUNCTIONS FOR PROGRAM LOGIC %%%%%%%%%%%%%%%%%%%%%%%%
%
% Contains:
%       - initParams(...)
%       - trialLoop(...)

    function params = initParams(exp)
        % params = initParams(exp)
        % Initialize the parameters
        
        % Much with the paths a little bit.
        [~, tmp, suff] = fileparts(exp.configFileName);
        exp.configFileName = fullfile(exp.configFileDir, [tmp, suff]);
        
        % Load the config file for this condition.
        cfgFile = ConfigFile(exp.configFileName);
        
        % Convert all the ConfigFile parameters into simple struct values.
        params = convertToStruct(cfgFile);
        params.cacheDir = fullfile(exp.baseDir, 'cache', 'stimuli');
        
        % Load the calibration file.
        cType = OLCalibrationTypes.(params.calibrationType);
        params.oneLightCal = LoadCalFile(cType.CalFileName);
        
        % Setup the cache.
        params.olCache = OLCache(params.cacheDir, params.oneLightCal);
        
        file_names = allwords(params.cacheFiles,',');
        for i = 1:length(file_names)
            % Create the cache file name.
            [~, params.cacheFileName{i}] = fileparts(file_names{i});
        end
        
        
        file_names = allwords(params.cacheFilesNoise,',');
        for i = 1:length(file_names)
            % Create the cache file name.
            [~, params.cacheFileNoiseName{i}] = fileparts(file_names{i});
        end
        
    end

    function params = trialLoop(params, exp)
        
        % This function runs the experiment loop
        
        %% Store out the primaries from the cacheData into a cell.  The length of
        % cacheData corresponds to the number of different stimuli that are being
        % shown
        
        % Set the mirrors to the first element of the adaptation mirror
        % vector.
        
        fprintf('- Setting mirrors to adaptation start point.\n');
        ol.setMirrors(params.startsAdaptPeriod(1, :)', params.stopsAdaptPeriod(1, :)');
        
        % Initialize events variable
        events = struct();
        events(params.nTrials).buffer = '';
        
        %% Conduct the adaptation process
        
        % Wait for a key press to start adaptation
        
        fprintf('* Press any key to start adaptation period\n')
        triggerReceived = false;
        mglGetKeyEvent;
        while ~triggerReceived
            key = mglGetKeyEvent;
            % If a key was pressed, get the key and exit.
            if ~isempty(key)
                keyPress = key.charCode;
                triggerReceived = true;
                fprintf('  * Key received. Starting adaptation period ...\n');
                tBlockStart = mglGetSecs;
            end
        end
        
        % Flush our keyboard queue.
        mglGetKeyEvent;
        
        % Alert the participant to the start of adaptation
        system('say Begin adaptation.');
        
        % Submit the climb and plateau mirror settings to TrialSequenceFlickerStartsStops
        % Note that the mirror setting matrices are transposed here before
        % passing to TrialSequenceFlickerStartsStops. Ideally, this should
        % be set properly when these matrices were first created.
        TrialSequenceFlickerStartsStops(ol, params.startsAdaptPeriod', params.stopsAdaptPeriod', params.AdaptRefreshRate, 1);
        
        % Alert the operator to the end of adaptation
        fprintf('end!\n');
        system('say End adaptation.');
        
        %% Prepare for trial execution
        
        % Alert the operator
        fprintf('- Starting trials.\n');
        
        % Identify and possibly create the directory to store the rating
        % data from the experiment across subjects. Define a base file name
        % for this subject.
        
        subjID=exp.subject;
        baseDir = fileparts(fileparts(which('BrightnessRatingTask')));
        outDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/BrightnessRatingTask';
        if ~isdir(outDir);
            mkdir(outDir);
        end
        outFile = [subjID '.csv'];
        outFileMat = [subjID '.mat'];
        
        %% Set up sounds
        fs = 20000;
        durSecs = 0.1;
        t = linspace(0, durSecs, durSecs*fs);
        yAdapt = sin(660*2*pi*linspace(0, 3*durSecs, 3*durSecs*fs));
        yStart = [sin(880*2*pi*t)];
        yStop = [sin(440*2*pi*t)];
        
        fs = 20000;
        durSecs = 0.01;
        t = linspace(0, durSecs, durSecs*fs);
        yHint = [sin(880*2*pi*t)];
        
        % Open output file
        fid = fopen(fullfile(outDir, outFile), 'a');
        
        % Wait for a key press to start the run of trials
        
        fprintf('* Press any key to start rating trials\n')
        triggerReceived = false;
        mglGetKeyEvent;
        while ~triggerReceived
            key = mglGetKeyEvent;
            % If a key was pressed, get the key and exit.
            if ~isempty(key)
                keyPress = key.charCode;
                triggerReceived = true;
                fprintf('  * Key received. Rating experiment starting\n');
                tBlockStart = mglGetSecs;
            end
        end
        
        % Flush our keyboard queue.
        mglGetKeyEvent;
        
        % Iterate over trials
        
        for trial = 1:params.nTrials
            
            % Report to the screen the current trial number
            
            trialStamp = datestr(now);
            fprintf('\n> %s, ********* Trial %g/%g', trialStamp, trial, params.nTrials);
            
            % Play start sound to indicate trial start
            
            sound(yStart, fs);
            
            % Get time stamps
            events(trial).tTrialStart = mglGetSecs;
            
            % Iterate through the dynamic vector
            TrialSequenceFlickerStartsStops(ol, params.trialStartsDynamic1{trial}, params.trialStopsDynamic1{trial}, params.ramp.dt, 1);
            
            % set the mirrors for the current trial
            ol.setMirrors(params.trialStarts{trial}', params.trialStops{trial}');
            % The presentation of the spectrum for the trial is complete.
            % Now time to ramp back down to background
            
            % Iterate through the dynamic vector
            TrialSequenceFlickerStartsStops(ol, params.trialStartsDynamic2{trial}, params.trialStopsDynamic2{trial}, params.ramp.dt, 1);
            
            % Done recording, set the mirrors to the background
            ol.setMirrors(params.bgStarts', params.bgStops');
            
            % Get the time stamp for the end of trial
            
            events(trial).tTrialEnd = mglGetSecs;
            
            % Mark the end of the trial
            
            sound(yStop, fs);
            
            % Ask the observer to provide a rating of brightness
            
            ratingVal = GetInput('Rating value [0 - 100]');
            
            fprintf(fid, '%s,%g,%g,%g\n', trialStamp, params.trialSeqLMSContrast(trial), params.trialSeqMelContrast(trial), ratingVal);
            
            % Assign the time stamps and data to the dataStruct
            dataStruct(trial).rating = ratingVal;
            dataStruct(trial).MelRelContrast = params.trialSeqMelContrast(trial);
            dataStruct(trial).LMSRelContrast = params.trialSeqLMSContrast(trial);
            
        end
        tBlockEnd = mglGetSecs;
        
        % Set settings back to background
        ol.setMirrors(params.bgStarts', params.bgStops');
        
        ListenChar(0);
        
        % Put the event information in the struct
        responseStruct.events = events;
        responseStruct.tBlockStart = tBlockStart;
        responseStruct.tBlockEnd = tBlockEnd;
        
        fprintf('Total duration: %f s\n', responseStruct.tBlockEnd-responseStruct.tBlockStart);
        
        % Tack data that we want for later analysis onto params structure.  It then
        % gets passed back to the calling routine and saved in our standard place.
        params.responseStruct = responseStruct;
        params.dataStruct = dataStruct;
        
        fclose(fid);

        
        system('say End of Experiment');
        
    end

    function TrialSequenceFlickerStartsStops(ol, starts, stops, frameDurationSecs, numIterations)
        
        % OLFlicker - Flickers the OneLight.
        %
        % Syntax:
        % keyPress = OLFlicker(ol, stops, frameDurationSecs, numIterations)
        %
        % Description:
        % Flickers the OneLight using the passed stops matrix until a key is
        % pressed or the number of iterations is reached.
        %
        % Input:
        % ol (OneLight) - The OneLight object.
        % stops (1024xN) - The normalized [0,1] mirror stops to loop through.
        % frameDurationSecs (scalar) - The duration to hold each setting until the
        %     next one is loaded.
        % numIterations (scalar) - The number of iterations to loop through the
        %     stops.  Passing Inf causes the function to loop forever.
        %
        % Output:
        % keyPress (char|empty) - If in continuous mode, the key the user pressed
        %     to end the script.  In regular mode, this will always be empty.
        
        % Counters to keep track of which of the stops to display and which
        % iteration we're on.
        iterationCount = 0;
        setCount = 0;
        
        numstops = size(starts, 2);
        
        t = zeros(1, numstops);
        i = 0;
        
        % This is the time of the stops change.  It gets updated everytime
        % we apply new mirror stops.
        mileStone = mglGetSecs + frameDurationSecs;
        
        
        keyEvents = [];
        
        while iterationCount < numIterations
            if mglGetSecs >= mileStone;
                i = i + 1;
                
                % Update the time of our next switch.
                mileStone = mileStone + frameDurationSecs;
                
                % Update our stops counter.
                setCount = mod(setCount + 1, numstops);
                
                % If we've reached the end of the stops list, iterate the
                % counter that keeps track of how many times we've gone through
                % the list.
                if setCount == 0
                    iterationCount = iterationCount + 1;
                    setCount = numstops;
                end
                
                % Send over the new stops.
                t(i) = mglGetSecs;
                counter(i) = setCount;
                ol.setMirrors(starts(:, i)', stops(:, i)');
            end
        end
        %toc;
    end

end
