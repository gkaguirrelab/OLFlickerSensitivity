function params = ModulationTrialSequenceMR(exp)
% params = MRITrialSequence(exp)

%% Setup basic parameters for the experiment
params = initParams(exp);

% Ask for the observer age
params.observerAgeInYears = GetWithDefault('Observer age', 32);

modulationPath = getpref('OneLight', 'modulationPath');

%% Put together the trial order
for i = 1:length(params.cacheFileName)
    % Construct the file name to load in age-specific file
    
    %modulationData{i} = LoadCalFile(params.cacheFileName{i}, [], [params.cacheDir '/modulations/']);
    [~, fileName, fileSuffix] = fileparts(params.cacheFileName{i});
    params.cacheFileName{i} = [fileName '-' num2str(params.observerAgeInYears) '_' params.obsID '_' datestr(now, 'mmddyy') fileSuffix];
    try
        modulationData{i} = load(fullfile(modulationPath, params.cacheFileName{i}));
    catch
        error('ERROR: Cache file for observer with specific age could not be found');
    end
    
    % Check if we're using the most recent version of the cache file in the
    % modulation files. If not, prompt user to recompute.
    
    % Get the date of the cache used the modulation file
    tmpParams = modulationData{i}.modulationObj.describe(1).params;
    
    % Load in the cache file so that we know what date the most recent cache is
    %tmpParams.olCache = OLCache(tmpParams.cacheDir, tmpParams.oneLightCal);
    
    %tmpCacheData = tmpParams.olCache.load(tmpParams.cacheFileName{1});
    
    % Compare the dates. If they don't match up, we have a more recent
    % cache file than we use in the modulation file. Tell experimenter to
    % re-generate the modulation files
    %if ~strcmp(tmpCacheData.date, tmpParams.cacheDate{1})
    %    error('ERROR: Date of most recent cache file available and cache file used in modulation pre-cache are not consistent. Please regenerate modulation waveforms using OLFlickerComputeModulationWaveforms!')
    %end
end

% Put together the trial order
% Pre-initialize the blocks
block = struct();
block(params.nTrials).describe = '';

% Debug
%params.nTrials = 5;

for i = 1:params.nTrials
    fprintf('- Preconfiguring trial %i/%i...', i, params.nTrials);
    block(i).data = modulationData{params.theDirections(i)}.modulationObj.modulation(params.theFrequencyIndices(i), params.thePhaseIndices(i), params.theContrastRelMaxIndices(i));
    block(i).describe = modulationData{params.theDirections(i)}.modulationObj.describe;
    
    % Check if the 'attentionTask' flag is set. If it is, set up the task
    % (brief stimulus offset).
    block(i).attentionTask.flag = params.attentionTask(i);
    
    block(i).direction = block(i).data.direction;
    block(i).carrierFrequencyHz = block(i).describe.theFrequenciesHz(params.theFrequencyIndices(i));
    
    % We pull out the background.
    block(i).data.startsBG = block(i).data.starts(:, 1);
    block(i).data.stopsBG = block(i).data.stops(:, 1);
    
    fprintf('Done\n');
end

% Play a sound
t = linspace(0, 1, 10000);
y = sin(330*2*pi*t);
sound(y, 20000);

% Get rid of modulationData struct
clear modulationData;

%% Create the OneLight object.
% This makes sure we are talking to OneLight.
ol = OneLight;

% Make sure our input and output pattern buffers are setup right.
%ol.InputPatternBuffer = 0;
%ol.OutputPatternBuffer = 0;

fprintf('\t SETTING MIRRORS TO BACKGROUND ...');
ol.setMirrors(block(1).data.startsBG,  block(1).data.stopsBG); % Use first trial
fprintf('done.\n');
params = [];

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
        params.cacheDir = fullfile(exp.baseDir, 'cache');
        
        % Load the calibration file.
        cType = OLCalibrationTypes.(params.calibrationType);
        params.oneLightCal = LoadCalFile(cType.CalFileName);
        
        % Setup the cache.
        params.olCache = OLCache(params.cacheDir, params.oneLightCal);
        
        file_names = allwords(params.modulationFiles,',');
        for i = 1:length(file_names)
            % Create the cache file name.
            [~, params.cacheFileName{i}] = fileparts(file_names{i});
        end
        
    end

    function params = trialLoop(params, exp)
        % [params, responseStruct] = trialLoop(params, cacheData, exp)
        % This function runs the experiment loop
        
        %% Store out the primaries from the cacheData into a cell.  The length of
        % cacheData corresponds to the number of different stimuli that are being
        % shown
        
        % Set the background to the 'idle' background appropriate for this
        % trial.
        fprintf('- Setting mirrors to background, waiting for t.\n');
        
        % Initialize events variable
        events = struct();
        events(params.nTrials).buffer = '';
        
        % Suppress keypresses going to the Matlab window.
        ListenChar(2);
        
        %% Code to wait for 't' -- the go-signal from the scanner
        triggerReceived = false;
        while ~triggerReceived
            key = mglGetKeyEvent;
            % If a key was pressed, get the key and exit.
            if ~isempty(key)
                keyPress = key.charCode;
                if (strcmp(keyPress,'t'))
                    tBlockStart = mglGetSecs;
                    triggerReceived = true;
                    fprintf('  * t received.\n');
                end
            end
        end
        
        % Flush our keyboard queue.
        mglGetKeyEvent;
        
        % Stop receiving t
        fprintf('- Starting trials.\n');
        
        % Iterate over trials
        for trial = 1:params.nTrials
            %if params.waitForKeyPress
            %    ListenChar(0);
            %    pause;
            %end
            fprintf('* Start trial %i/%i - %s, %i Hz.\n', trial, params.nTrials, block(trial).direction, block(trial).carrierFrequencyHz);
            % Launch into OLPDFlickerSettings.
            events(trial).tTrialStart = mglGetSecs;
            [events(trial).buffer, events(trial).t,  events(trial).counter] = ModulationTrialSequenceFlickerStartsStops(trial, params.timeStep, 1, params.checkKB);
            events(trial).tTrialEnd = mglGetSecs;
            events(trial).attentionTask = block(trial).attentionTask;
            events(trial).describe = block(trial).describe;
        end
        tBlockEnd = mglGetSecs;
        
        fprintf('- Done with block.\n');
        ListenChar(0);
        
        % Turn all mirrors off
        %ol.setAll(false);
        
        % Put the event information in the struct
        responseStruct.events = events;
        responseStruct.tBlockStart = tBlockStart;
        responseStruct.tBlockEnd = tBlockEnd;
        
        fprintf('Total duration: %f s\n', responseStruct.tBlockEnd-responseStruct.tBlockStart);
        
        % Tack data that we want for later analysis onto params structure.  It then
        % gets passed back to the calling routine and saved in our standard place.
        params.responseStruct = responseStruct;
        
    end

    function [keyEvents, t, counter] = ModulationTrialSequenceFlickerStartsStops(trial, frameDurationSecs, numIterations, checkKB)
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
        tic;
        %starts = block(trial).data.starts';
        %stops = block(trial).data.stops';
        
        %keyPress = [];
        
        % Flag whether we're checking the keyboard during the flicker loop.
        %checkKB = isinf(numIterations);
        
        % Counters to keep track of which of the stops to display and which
        % iteration we're on.
        iterationCount = 0;
        setCount = 0;
        
        numstops = size(block(trial).data.starts, 2);
        
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
                ol.setMirrors(block(trial).data.starts(:, setCount), block(trial).data.stops(:, setCount));
            end
            
            % If we're using keyboard mode, check for a keypress.
            if checkKB
                tmp = mglGetKeyEvent;
                if ~isempty(tmp) && ~strcmp(tmp.charCode, 't'); % We only want non-t key presses
                    keyEvents = [keyEvents tmp];
                end
            end
        end
        toc;
    end
end

