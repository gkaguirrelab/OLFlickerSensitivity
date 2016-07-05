function OLDemoPedestal(observerAgeYrs, mode)

%% Housekeeping
% If no age is passed, assume 32.
if ~exist('observerAgeYrs', 'var')
    observerAgeYrs = 32;
end

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

fs = 20000;
durSecs = 0.01;
t = linspace(0, durSecs, durSecs*fs);
yHint = [sin(880*2*pi*t)];

switch mode
    case 'prep'
        nConditions = 5;
        contrastLevelsPedestal = [0 -0.4 0.4 -0.4 0.4];
        directionsPedestal = {'LMDirected' 'LMDirected' 'LMDirected' 'MelanopsinDirectedLegacy' 'MelanopsinDirectedLegacy'};
        contrastLevelsFlicker = 0:0.005:0.08;
        
        %% Calibration
        % Load the appropriate calibration file. We are using Box B, long cable A,
        % eye piece 2, calibrated beginning October 2014.
        [~, cals] = LoadCalFile('OLBoxALongCableCEyePiece1BeamsplitterProjectorOn');
        cal = cals{end};
        
        %% Parameters
        % Set up the directions and parameters for the modulation.
        directionFlicker = 'LMSDirected';                % Flicker direction (L+M)
        
        % We are setting up the pedestal as a square wave between 0 and 1 with a period of 2
        % seconds (i.e. 0.5 Hz). The flicker riding on top of this is running at 4
        % Hz.
        frequencyFlicker = 4;                           % Flicker frequency
        frequencyMask = 1/2;                        % Pedestal frequency (Hz)
        
        % Lower-level parameters
        dt = 1/50;                                      % Refresh rate of the OL
        t = 0:dt:(1/frequencyMask-dt);              % Time vector
        maxContrast = 0.5;                             % Max contrast.
        
        %% Cache
        % Gather some information.
        baseDir = fileparts(fileparts(which('OLDemo')));
        cacheDir = fullfile(baseDir, 'cache', 'stimuli');
        
        % Set up the cache.
        olCache = OLCache(cacheDir, cal);
        
        % Load the cache data.
        cacheDataFlicker = olCache.load(['Cache-' directionFlicker]);
        
        for d = 1:nConditions
            % Get the pdedestal
            directionPedestal = directionsPedestal{d}; % Pedestal direction (Mel)
            cacheDataPedestal = olCache.load(['Cache-' directionPedestal]);
            
            % Set up the waveforms. This vector serves both to turn on the pedestal
            % and to mask the high-frequency waveform of the flicker.
            waveformPedestal = ones(1, length(t));
            flickerMask = square(2*pi*frequencyMask*t-pi);
            flickerMask(flickerMask < 0) = 0;
            waveformFlicker = square(2*pi*frequencyFlicker*t) .* flickerMask;
            
            % Pull out the primary settings from the cache file
            backgroundPedestal = cacheDataPedestal.data(observerAgeYrs).backgroundPrimary;
            differencePedestal = cacheDataPedestal.data(observerAgeYrs).differencePrimary;
            differenceFlicker = cacheDataFlicker.data(observerAgeYrs).differencePrimary;
            
            for c = 1:length(contrastLevelsFlicker)
                %% Contrast
                contrastPedestal = contrastLevelsPedestal(d);
                contrastPedestal = contrastPedestal/maxContrast; % Normalize by max contrast.
                contrastFlicker = contrastLevelsFlicker(c);
                contrastFlicker = contrastFlicker/maxContrast;
                
                
                %% Generate the stimuli
                % Construct the waveform
                for i = 1:length(t)
                    waveformPrimary(:, i) = backgroundPedestal + contrastPedestal*differencePedestal*waveformPedestal(i) + contrastFlicker*differenceFlicker*waveformFlicker(i);
                end
                
                % Check if we are out of gamut
                if any(any(waveformPrimary < 0)) || any(any(waveformPrimary > 1))
                    error('Out of gamut. Fix the contrast');
                end
                
                % Get the starts and stops.
                tic;
                for i = 1:length(t);
                    % Convert to settings and starts/stops
                    waveformSettings(:, i) = OLPrimaryToSettings(cal, waveformPrimary(:, i));
                    
                    tic;
                    [starts(:, i), stops(:, i)] = OLSettingsToStartsStops(cal, waveformSettings(:, i));
                    
                end
                
                % Save out into a structure.
                mod{d, c}.primary = waveformPrimary;
                mod{d, c}.settings = waveformSettings;
                mod{d, c}.starts = starts;
                mod{d, c}.stops = stops;
                mod{d, c}.directionPedestal = directionsPedestal{d};
                mod{d, c}.directionFlicker = directionFlicker;
                mod{d, c}.contrastPedestal = contrastLevelsPedestal(d);
                mod{d, c}.contrastFlicker = contrastLevelsFlicker(c);
                mod{d, c}.condition = ['bg' directionsPedestal{d} '_flicker' directionFlicker];
                mod{d, c}.observerAgeYrs = observerAgeYrs;
                fprintf('%g/%g, %g/%g\n', d, nConditions, c, length(contrastLevelsFlicker));
            end
        end
        
        save(fullfile(baseDir, 'cache', 'modulations', ['MelConeThreshPilot-' num2str(observerAgeYrs)]), 'mod');
    case 'exptPedestalStaircase2IFC'
        % Get observer name
        subjID = GetWithDefault('Observer name?', 'A000000A');
        
        %% Parameters
        % Set some parameters
        %theBackgroundOrder = [5 4 5 4];
        theBackgrounds = [4 5 5 4 5 4];
        adaptDurationSecs = 240;
        nDecisionsPerBackground = 20;
        dt = 1/50;
        
        baseDir = fileparts(fileparts(which('OLDemo')));
        outDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/PsychophysicsMelConeThreshPilot';
        if ~isdir(outDir);
            mkdir(outDir);
        end
        outFile = [subjID '.csv'];
        outFileMat = [subjID '.mat'];
        
        %% Try loading the file
        modFileToLoad = fullfile(baseDir, 'cache', 'modulations', ['MelConeThreshPilot-' num2str(observerAgeYrs) '.mat']);
        if ~exist(modFileToLoad, 'file')
            error('Modulation file does not exist. Run prep mode')
        else
            load(modFileToLoad)
        end
        
        fprintf('*** Modulation ready');
        ol = OneLight;
        
        input('\n> Press enter to start, any key to stop waveform');
        
        % Open output file
        fid = fopen(fullfile(outDir, outFile), 'a');
        
        %% Adjust starts/stops
        for i = 1:size(mod, 1)
            for j = 1:size(mod, 2)
                %mod{i, j}.starts = mod{i, j}.starts(end:-1:1, :);
                %mod{i, j}.stops = mod{i, j}.stops(end:-1:1, :);
            end
        end
        
        % Set up mgl listener
        mglListener('eatKeys', [3 4]);
        
        for b = theBackgroundOrder % Iterate over the backgrounds
            %% First, set the adapting background and wait.
            sound(yAdapt, fs);
            system('say Hit key to begin adaptation to background.');
            mglGetKeyEvent;
            keepGoing = true;
            while keepGoing
                % If we're using keyboard mode, check for a keypress.
                tmp = mglGetKeyEvent;
                if ~isempty(tmp);
                    break;
                end
            end
            
            system('say Start of adaptation');
            ol.setMirrors(mod{b, 1}.starts(:, 1), mod{b, 1}.stops(:,1));
            WaitSecs(adaptDurationSecs);
            system('say End of adaptation. Hit any key to continue.');
            mglGetKeyEvent;
            keepGoing = true;
            while keepGoing
                % If we're using keyboard mode, check for a keypress.
                tmp = mglGetKeyEvent;
                if ~isempty(tmp);
                    break;
                end
            end
            
            % Pre-define the stimuli
            contrastOrder = [];
            contrastStep = 0.005;
            maxContrast = 0.04;
            minContrast = contrastStep;
            contrastLevels = 0:contrastStep:maxContrast;
            nContrastLevels = length(contrastLevels);
            contrastSteps = 2:9;
            nContrastLevels = length(contrastSteps);
            %theIntervals = [1*ones(1, nContrastLevels) 2*ones(1, nContrastLevels)];
            
            %contrastSteps = repmat(contrastSteps, 1, nDecisionsPerBackground);
            %intervals = repmat(theIntervals, 1, nDecisionsPerBackground/2);
            
            % Shuffle the trials
            %[contrastSteps, trialOrder] = Shuffle(contrastSteps);
            %i%ntervals = intervals(trialOrder)
            
            % Do practice trials
            system('say We will start with practice trials.');
            
            pause(1.5);
            
            nPracticeTrials = 4;
            intervals = [2 1 2 2];
            for i = 1:nPracticeTrials
                intval = intervals(i);
                if intval == 2
                    starts1 = mod{b, 9}.starts(:, 1:25);
                    stops1 = mod{b, 9}.stops(:, 1:25);
                    
                    starts2 = mod{b, 9}.starts(:, 51:75);
                    stops2 = mod{b, 9}.stops(:, 51:75);
                elseif intval == 1
                    starts2 = mod{b, 9}.starts(:, 1:25);
                    stops2 = mod{b, 9}.stops(:, 1:25);
                    
                    starts1 = mod{b, 9}.starts(:, 51:75);
                    stops1 = mod{b, 9}.stops(:, 51:75);
                end
                
                ol.setMirrors(mod{b,1}.starts(:, 1), mod{b,1}.stops(:, 1));
                sound(yHint, fs);
                OLFlickerStartsStopsMethAdj(ol, starts1, stops1, dt, 1, true);
                sound(yHint, fs);
                %i = mod(i-1, nDirections)+1;
                OLFlickerStartsStopsMethAdj(ol, starts2, stops2, dt, 1, true);
                ol.setMirrors(mod{b,1}.starts(:, 1), mod{b,1}.stops(:, 1));
                sound(yHint, fs);
                %i = i+1;
                % Get the key
                keepGoing = true;
                while keepGoing
                    % If we're using keyboard mode, check for a keypress.
                    tmp = mglGetKeyEvent;
                    if ~isempty(tmp);
                        key = tmp;
                        if (str2num(key.charCode) == 3)
                            decision = 1;
                            
                            
                            % Recode the response
                            response = (decision == intval);
                            
                            
                            % Abort and save out.
                            keepGoing = false;
                            
                        end
                        
                        if (str2num(key.charCode) == 4)
                            decision = 2;
                            
                            
                            % Recode the response
                            response = (decision == intval);
                            
                            
                            % Abort and save out.
                            keepGoing = false;
                        end
                        if decision == intval
                            sound(yLimitUp, fs);
                        else
                            sound(yLimitDown, fs);
                        end
                        pause(0.5);
                    end
                    
                end
                
                
            end
            system('say End of practice trials.');
            system('say Hit key to start the real experiment');
            mglGetKeyEvent;
            keepGoing = true;
            while keepGoing
                % If we're using keyboard mode, check for a keypress.
                tmp = mglGetKeyEvent;
                if ~isempty(tmp);
                    break;
                end
            end
            system('say Starting now.');
            pause(3)
            
            %% From psychofitTutorial.m
            %% Set up the staircase.
            % The code below runs three interleaved staircases.
            %   For 'quest', three different criterion percent correct values are used.
            %   For 'standard', three different up/down rules are used.
            % The use of 3 is hard-coded, in the sense that the vector lengths of the
            % criterion/up-down vectors must match this number.
            numTrialsPerStaircase = 40;
            
            staircaseType = 'standard';
            % Initialize staircases.  Initialization is slightly different for 'standard'
            % and 'quest' versions.  All parameters other than 'MaxValue' and 'MinValue'
            % are required, and this is enforced by the class constructor function.
            nInterleavedStaircases = 2;
            for k = 1:nInterleavedStaircases
                stepSizes = [4*contrastStep 2*contrastStep contrastStep];
                nUps = [3 2];
                nDowns = [1 1];
                initialGuess = contrastStep+contrastStep*(round(maxContrast*rand(1)/contrastStep)-1);
                st{k} = Staircase(staircaseType,initialGuess, ...
                    'StepSizes', stepSizes, 'NUp', nUps(k), 'NDown', nDowns(k), ...
                    'MaxValue', maxContrast, 'MinValue', minContrast);
                
                % Set up a vector which tells us which interval we are in
                theIntervals{k} = Shuffle([1*ones(1, numTrialsPerStaircase) 2*ones(1, numTrialsPerStaircase)]);
            end
            
            % Set up the break trials
            nTrials = nInterleavedStaircases*numTrialsPerStaircase;
            
            breakStep = 25;
            breakTrials = 0:breakStep:nTrials;
            breakTrials(1) = [];
            
            counter = 1;
            % Run interleaved staircases
            for i = 1:numTrialsPerStaircase
                order = Shuffle(1:nInterleavedStaircases);
                for k = 1:nInterleavedStaircases
                    % Get the contrast
                    testContrast = getCurrentValue(st{order(k)});
                    
                    % Assemble the information needed for the trial
                    % Find the index of the test contrast in our contrast
                    % vector.
                    [~, c] = min(abs(contrastLevels - testContrast));
                    intval = theIntervals{k}(i);
                    
                    if intval == 2
                        starts1 = mod{b, c}.starts(:, 1:25);
                        stops1 = mod{b, c}.stops(:, 1:25);
                        
                        starts2 = mod{b, c}.starts(:, 51:75);
                        stops2 = mod{b, c}.stops(:, 51:75);
                    elseif intval == 1
                        starts2 = mod{b, c}.starts(:, 1:25);
                        stops2 = mod{b, c}.stops(:, 1:25);
                        
                        starts1 = mod{b, c}.starts(:, 51:75);
                        stops1 = mod{b, c}.stops(:, 51:75);
                    end
                    
                    ol.setMirrors(mod{b,1}.starts(:, 1), mod{b,1}.stops(:, 1));
                    sound(yHint, fs);
                    OLFlickerStartsStopsMethAdj(ol, starts1, stops1, dt, 1, true);
                    sound(yHint, fs);
                    %i = mod(i-1, nDirections)+1;
                    OLFlickerStartsStopsMethAdj(ol, starts2, stops2, dt, 1, true);
                    ol.setMirrors(mod{b,1}.starts(:, 1), mod{b,1}.stops(:, 1));
                    sound(yHint, fs);
                    
                    %i = i+1;
                    % Get the key
                    keepGoing = true;
                    while keepGoing
                        % If we're using keyboard mode, check for a keypress.
                        tmp = mglGetKeyEvent;
                        if ~isempty(tmp);
                            key = tmp;
                            if (str2num(key.charCode) == 3)
                                decision = 1;
                                
                                
                                % Recode the response
                                response = (decision == intval);
                                
                                
                                % Abort and save out.
                                keepGoing = false;
                                fprintf(fid, '%s,%s,%s,%f,%f,%g,%g,%g\n', datestr(now), mod{b, c}.directionPedestal, mod{b, c}.directionFlicker, mod{b, c}.contrastPedestal, mod{b, c}.contrastFlicker, decision, intval, response);
                                fprintf('%s | %s | %s | Contrast: %f | Interval: %g | Decision: %g | Correct? %g\n', datestr(now), mod{b, c}.directionPedestal, mod{b, c}.directionFlicker, mod{b, c}.contrastFlicker, decision, intval, response);
                                
                                
                            end
                            
                            if (str2num(key.charCode) == 4)
                                decision = 2;
                                
                                
                                % Recode the response
                                response = (decision == intval);
                                
                                
                                % Abort and save out.
                                keepGoing = false;
                                fprintf(fid, '%s,%s,%s,%f,%f,%g,%g,%g\n', datestr(now), mod{b, c}.directionPedestal, mod{b, c}.directionFlicker, mod{b, c}.contrastPedestal, mod{b, c}.contrastFlicker, decision, intval, response);
                                fprintf('%s | %s | %s | Contrast: %f | Interval: %g | Decision: %g | Correct? %g\n', datestr(now), mod{b, c}.directionPedestal, mod{b, c}.directionFlicker, mod{b, c}.contrastFlicker, decision, intval, response);
                                
                            end
                            if decision == intval
                                sound(yLimitUp, fs);
                            else
                                sound(yLimitDown, fs);
                            end
                            pause(0.5);
                        end
                        
                    end
                    
                    % Update. 1 = correct; 0 = incorrect
                    st{order(k)} = updateForTrial(st{order(k)},testContrast,response);
                    
                    % Update the counter
                    counter = counter+1;
                    
                    % Force a break
                    if any(breakTrials == counter)
                        system('say Please take a break now.')
                        system(['say You have finished ' num2str(counter) ' out of ' num2str(numTrialsPerStaircase*nInterleavedStaircases) ' trials for this background.']);
                        mglGetKeyEvent;
                        keepGoing = true;
                        while keepGoing
                            % If we're using keyboard mode, check for a keypress.
                            tmp = mglGetKeyEvent;
                            if ~isempty(tmp);
                                break;
                            end
                        end
                        
                    end
                    
                end
            end
            system('say End of this background.');
            
        end
        
        fclose(fid);
        
        save(outFileMat);
        
        sound(yStart, fs);
        system('say You are free now. But come back soon.');
        
        
    case 'exptStaircase2IFC'
        % Get observer name
        subjID = GetWithDefault('Observer name?', 'A000000A');
        
        %% Parameters
        % Set some parameters
        theBackgroundOrder = [1 5 4];
        adaptDurationSecs = 60;
        adaptNRepeats = 4;
        nDecisionsPerBackground = 20;
        dt = 1/50;
        
        baseDir = fileparts(fileparts(which('OLDemo')));
        outDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/PsychophysicsMelConeThreshPilot';
        if ~isdir(outDir);
            mkdir(outDir);
        end
        outFile = [subjID '.csv'];
        outFileMat = [subjID '.mat'];
        
        %% Try loading the file
        modFileToLoad = fullfile(baseDir, 'cache', 'modulations', ['MelConeThreshPilot-' num2str(observerAgeYrs) '.mat']);
        if ~exist(modFileToLoad, 'file')
            error('Modulation file does not exist. Run prep mode')
        else
            load(modFileToLoad)
        end
        
        fprintf('*** Modulation ready');
        ol = OneLight;
        
        input('\n> Press enter to start, any key to stop waveform');
        
        % Open output file
        fid = fopen(fullfile(outDir, outFile), 'a');
        
        %% Adjust starts/stops
        for i = 1:size(mod, 1)
            for j = 1:size(mod, 2)
                %mod{i, j}.starts = mod{i, j}.starts(end:-1:1, :);
                %mod{i, j}.stops = mod{i, j}.stops(end:-1:1, :);
            end
        end
        
        % Set up mgl listener
        mglListener('eatKeys', [3 4]);
        
        for b = theBackgroundOrder % Iterate over the backgrounds
            %% First, set the adapting background and wait.
            sound(yAdapt, fs);
            system('say Hit key to begin adaptation to background.');
            mglGetKeyEvent;
            keepGoing = true;
            while keepGoing
                % If we're using keyboard mode, check for a keypress.
                tmp = mglGetKeyEvent;
                if ~isempty(tmp);
                    break;
                end
            end
            
            system('say Start of adaptation');
            for j = 1:adaptNRepeats
                ol.setMirrors(mod{b, 1}.starts(:, 1), mod{b, 1}.stops(:,1));
                                WaitSecs(adaptDurationSecs);
                system(['say Finished ' num2str(j*adaptDurationSecs) ' seconds of ' num2str(adaptNRepeats*adaptDurationSecs) ' seconds of adaptation.']);

                
            end
            system('say End of adaptation. Hit any key to continue.');
            mglGetKeyEvent;
            keepGoing = true;
            while keepGoing
                % If we're using keyboard mode, check for a keypress.
                tmp = mglGetKeyEvent;
                if ~isempty(tmp);
                    break;
                end
            end
            
            % Pre-define the stimuli
            contrastOrder = [];
            contrastStep = 0.005;
            maxContrast = 0.04;
            minContrast = contrastStep;
            contrastLevels = 0:contrastStep:maxContrast;
            nContrastLevels = length(contrastLevels);
            contrastSteps = 2:9;
            nContrastLevels = length(contrastSteps);
            %theIntervals = [1*ones(1, nContrastLevels) 2*ones(1, nContrastLevels)];
            
            %contrastSteps = repmat(contrastSteps, 1, nDecisionsPerBackground);
            %intervals = repmat(theIntervals, 1, nDecisionsPerBackground/2);
            
            % Shuffle the trials
            %[contrastSteps, trialOrder] = Shuffle(contrastSteps);
            %i%ntervals = intervals(trialOrder)
            
            % Do practice trials
            system('say We will start with practice trials.');
            
            pause(1.5);
            
            nPracticeTrials = 4;
            intervals = [2 1 1 2];%ones(1, nPracticeTrials);%[2 1 2 2];
            for i = 1:nPracticeTrials
                intval = intervals(i);
                if intval == 2
                    starts1 = mod{b, 9}.starts(:, 1:25);
                    stops1 = mod{b, 9}.stops(:, 1:25);
                    
                    starts2 = mod{b, 9}.starts(:, 51:75);
                    stops2 = mod{b, 9}.stops(:, 51:75);
                elseif intval == 1
                    starts2 = mod{b, 9}.starts(:, 1:25);
                    stops2 = mod{b, 9}.stops(:, 1:25);
                    
                    starts1 = mod{b, 9}.starts(:, 51:75);
                    stops1 = mod{b, 9}.stops(:, 51:75);
                end
                
                ol.setMirrors(mod{b,1}.starts(:, 1), mod{b,1}.stops(:, 1));
                sound(yHint, fs);
                OLFlickerStartsStopsMethAdj(ol, starts1, stops1, dt, 1, true);
                sound(yHint, fs);
                %i = mod(i-1, nDirections)+1;
                OLFlickerStartsStopsMethAdj(ol, starts2, stops2, dt, 1, true);
                ol.setMirrors(mod{b,1}.starts(:, 1), mod{b,1}.stops(:, 1));
                sound(yHint, fs);
                %i = i+1;
                % Get the key
                keepGoing = true;
                while keepGoing
                    % If we're using keyboard mode, check for a keypress.
                    tmp = mglGetKeyEvent;
                    if ~isempty(tmp);
                        key = tmp;
                        if (str2num(key.charCode) == 3)
                            decision = 1;
                            
                            
                            % Recode the response
                            response = (decision == intval);
                            
                            
                            % Abort and save out.
                            keepGoing = false;
                            
                        end
                        
                        if (str2num(key.charCode) == 4)
                            decision = 2;
                            
                            
                            % Recode the response
                            response = (decision == intval);
                            
                            
                            % Abort and save out.
                            keepGoing = false;
                        end
                        if decision == intval
                            sound(yLimitUp, fs);
                        else
                            sound(yLimitDown, fs);
                        end
                        pause(0.5);
                    end
                    
                end
                
                
            end
            system('say End of practice trials.');
            system('say Hit key to start the real experiment');
            mglGetKeyEvent;
            keepGoing = true;
            while keepGoing
                % If we're using keyboard mode, check for a keypress.
                tmp = mglGetKeyEvent;
                if ~isempty(tmp);
                    break;
                end
            end
            system('say Starting now.');
            pause(3)
            
            %% From psychofitTutorial.m
            %% Set up the staircase.
            % The code below runs three interleaved staircases.
            %   For 'quest', three different criterion percent correct values are used.
            %   For 'standard', three different up/down rules are used.
            % The use of 3 is hard-coded, in the sense that the vector lengths of the
            % criterion/up-down vectors must match this number.
            numTrialsPerStaircase = 40;
            
            staircaseType = 'standard';
            % Initialize staircases.  Initialization is slightly different for 'standard'
            % and 'quest' versions.  All parameters other than 'MaxValue' and 'MinValue'
            % are required, and this is enforced by the class constructor function.
            nInterleavedStaircases = 2;
            for k = 1:nInterleavedStaircases
                stepSizes = [4*contrastStep 2*contrastStep contrastStep];
                nUps = [3 2];
                nDowns = [1 1];
                initialGuess = contrastStep+contrastStep*(round(maxContrast*rand(1)/contrastStep)-1);
                st{k} = Staircase(staircaseType,initialGuess, ...
                    'StepSizes', stepSizes, 'NUp', nUps(k), 'NDown', nDowns(k), ...
                    'MaxValue', maxContrast, 'MinValue', minContrast);
                
                % Set up a vector which tells us which interval we are in
                theIntervals{k} = Shuffle([1*ones(1, numTrialsPerStaircase) 2*ones(1, numTrialsPerStaircase)]);
            end
            
            % Set up the break trials
            nTrials = nInterleavedStaircases*numTrialsPerStaircase;
            
            breakStep = 10;
            breakTrials = 0:breakStep:nTrials;
            breakTrials(1) = [];
            
            counter = 1;
            % Run interleaved staircases
            for i = 1:numTrialsPerStaircase
                order = Shuffle(1:nInterleavedStaircases);
                for k = 1:nInterleavedStaircases
                    % Get the contrast
                    testContrast = getCurrentValue(st{order(k)});
                    
                    % Assemble the information needed for the trial
                    % Find the index of the test contrast in our contrast
                    % vector.
                    [~, c] = min(abs(contrastLevels - testContrast));
                    intval = theIntervals{k}(i);
                    
                    if intval == 2
                        starts1 = mod{b, c}.starts(:, 1:25);
                        stops1 = mod{b, c}.stops(:, 1:25);
                        
                        starts2 = mod{b, c}.starts(:, 51:75);
                        stops2 = mod{b, c}.stops(:, 51:75);
                    elseif intval == 1
                        starts2 = mod{b, c}.starts(:, 1:25);
                        stops2 = mod{b, c}.stops(:, 1:25);
                        
                        starts1 = mod{b, c}.starts(:, 51:75);
                        stops1 = mod{b, c}.stops(:, 51:75);
                    end
                    
                    ol.setMirrors(mod{b,1}.starts(:, 1), mod{b,1}.stops(:, 1));
                    sound(yHint, fs);
                    OLFlickerStartsStopsMethAdj(ol, starts1, stops1, dt, 1, true);
                    sound(yHint, fs);
                    %i = mod(i-1, nDirections)+1;
                    OLFlickerStartsStopsMethAdj(ol, starts2, stops2, dt, 1, true);
                    ol.setMirrors(mod{b,1}.starts(:, 1), mod{b,1}.stops(:, 1));
                    sound(yHint, fs);
                    
                    %i = i+1;
                    % Get the key
                    keepGoing = true;
                    while keepGoing
                        % If we're using keyboard mode, check for a keypress.
                        tmp = mglGetKeyEvent;
                        if ~isempty(tmp);
                            key = tmp;
                            if (str2num(key.charCode) == 3)
                                decision = 1;
                                
                                
                                % Recode the response
                                response = (decision == intval);
                                
                                
                                % Abort and save out.
                                keepGoing = false;
                                fprintf(fid, '%s,%s,%s,%f,%f,%g,%g,%g\n', datestr(now), mod{b, c}.directionPedestal, mod{b, c}.directionFlicker, mod{b, c}.contrastPedestal, mod{b, c}.contrastFlicker, decision, intval, response);
                                fprintf('%s | %s | %s | Contrast: %f | Interval: %g | Decision: %g | Correct? %g\n', datestr(now), mod{b, c}.directionPedestal, mod{b, c}.directionFlicker, mod{b, c}.contrastFlicker, decision, intval, response);
                                
                                
                            end
                            
                            if (str2num(key.charCode) == 4)
                                decision = 2;
                                
                                
                                % Recode the response
                                response = (decision == intval);
                                
                                
                                % Abort and save out.
                                keepGoing = false;
                                fprintf(fid, '%s,%s,%s,%f,%f,%g,%g,%g\n', datestr(now), mod{b, c}.directionPedestal, mod{b, c}.directionFlicker, mod{b, c}.contrastPedestal, mod{b, c}.contrastFlicker, decision, intval, response);
                                fprintf('%s | %s | %s | Contrast: %f | Interval: %g | Decision: %g | Correct? %g\n', datestr(now), mod{b, c}.directionPedestal, mod{b, c}.directionFlicker, mod{b, c}.contrastFlicker, decision, intval, response);
                                
                            end
                            if decision == intval
                                sound(yLimitUp, fs);
                            else
                                sound(yLimitDown, fs);
                            end
                            pause(0.5);
                        end
                        
                    end
                    
                    % Update. 1 = correct; 0 = incorrect
                    st{order(k)} = updateForTrial(st{order(k)},testContrast,response);
                    
                    % Update the counter
                    counter = counter+1;
                    
                    % Force a break
                    if any(breakTrials == counter)
                        system('say Please take a break now.')
                        system(['say You have finished ' num2str(counter) ' out of ' num2str(numTrialsPerStaircase*nInterleavedStaircases) ' trials for this background.']);
                        mglGetKeyEvent;
                        keepGoing = true;
                        while keepGoing
                            % If we're using keyboard mode, check for a keypress.
                            tmp = mglGetKeyEvent;
                            if ~isempty(tmp);
                                break;
                            end
                        end
                        
                    end
                    
                end
            end
            system('say End of this background.');
            
        end
        
        fclose(fid);
        
        save(outFileMat);
        
        sound(yStart, fs);
        system('say You are free now. But come back soon.');
        
    case 'exptStaircase'
        % Get observer name
        subjID = GetWithDefault('Observer name?', 'A000000A');
        
        %% Parameters
        % Set some parameters
        theBackgroundOrder = [4     2     3     5];
        adaptDurationSecs = 2%240;
        nDecisionsPerBackground = 20;
        dt = 1/50;
        
        baseDir = fileparts(fileparts(which('OLDemo')));
        outDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/PsychophysicsMelConeThreshPilot';
        if ~isdir(outDir);
            mkdir(outDir);
        end
        outFile = [subjID '.csv'];
        outFileMat = [subjID '.mat'];
        
        %% Try loading the file
        modFileToLoad = fullfile(baseDir, 'cache', 'modulations', ['MelConeThreshPilot-' num2str(observerAgeYrs) '.mat']);
        if ~exist(modFileToLoad, 'file')
            error('Modulation file does not exist. Run prep mode')
        else
            load(modFileToLoad)
        end
        
        fprintf('*** Modulation ready');
        ol = OneLight;
        
        input('\n> Press enter to start, any key to stop waveform');
        
        % Open output file
        fid = fopen(fullfile(outDir, outFile), 'a');
        
        %% Adjust starts/stops
        for i = 1:size(mod, 1)
            for j = 1:size(mod, 2)
                %mod{i, j}.starts = mod{i, j}.starts(end:-1:1, :);
                %mod{i, j}.stops = mod{i, j}.stops(end:-1:1, :);
            end
        end
        
        % Set up mgl listener
        mglListener('eatKeys', [3 4]);
        
        for b = [ 2     3     5] % Iterate over the backgrounds
            %% First, set the adapting background and wait.
            sound(yAdapt, fs);
            system('say Hit key to begin adaptation to background.');
            mglGetKeyEvent;
            keepGoing = true;
            while keepGoing
                % If we're using keyboard mode, check for a keypress.
                tmp = mglGetKeyEvent;
                if ~isempty(tmp);
                    break;
                end
            end
            
            system('say Start of adaptation');
            ol.setMirrors(mod{b, 1}.starts(:, 1), mod{b, 1}.stops(:,1));
            WaitSecs(adaptDurationSecs);
            system('say End of adaptation. Hit any key to continue.');
            mglGetKeyEvent;
            keepGoing = true;
            while keepGoing
                % If we're using keyboard mode, check for a keypress.
                tmp = mglGetKeyEvent;
                if ~isempty(tmp);
                    break;
                end
            end
            
            % Pre-define the stimuli
            contrastOrder = [];
            contrastStep = 0.005;
            maxContrast = 0.04;
            minContrast = contrastStep;
            contrastLevels = 0:contrastStep:maxContrast;
            nContrastLevels = length(contrastLevels);
            contrastSteps = 2:9;
            nContrastLevels = length(contrastSteps);
            %theIntervals = [1*ones(1, nContrastLevels) 2*ones(1, nContrastLevels)];
            
            %contrastSteps = repmat(contrastSteps, 1, nDecisionsPerBackground);
            %intervals = repmat(theIntervals, 1, nDecisionsPerBackground/2);
            
            % Shuffle the trials
            %[contrastSteps, trialOrder] = Shuffle(contrastSteps);
            %i%ntervals = intervals(trialOrder)
            
            % Do practice trials
            system('say We will start with practice trials.');
            
            pause(3);
            
            nPracticeTrials = 40;
            intervals = ones(1, nPracticeTrials);
            for i = 1:nPracticeTrials
                intval = intervals(i);
                if intval == 2
                    
                    starts = mod{b, 9}.starts;
                    stops = mod{b, 9}.stops;
                elseif intval == 1
                    starts = mod{b, 9}.starts(:, end:-1:1);
                    stops = mod{b, 9}.stops(:, end:-1:1);
                end
                
                sound(yHint, fs);
                
                % Do a trial
                
                
                %i = mod(i-1, nDirections)+1;
                OLFlickerStartsStopsMethAdj(ol, starts, stops, dt, 1, true);
                sound(yHint, fs);
                %i = i+1;
                % Get the key
                keepGoing = true;
                while keepGoing
                    % If we're using keyboard mode, check for a keypress.
                    tmp = mglGetKeyEvent;
                    if ~isempty(tmp);
                        key = tmp;
                        if (str2num(key.charCode) == 3)
                            decision = 1;
                            
                            
                            % Recode the response
                            response = (decision == intval);
                            
                            
                            % Abort and save out.
                            keepGoing = false;
                            
                        end
                        
                        if (str2num(key.charCode) == 4)
                            decision = 2;
                            
                            
                            % Recode the response
                            response = (decision == intval);
                            
                            
                            % Abort and save out.
                            keepGoing = false;
                        end
                        if decision == intval
                            sound(yLimitUp, fs);
                        else
                            sound(yLimitDown, fs);
                        end
                        pause(0.5);
                    end
                    
                end
                
                
            end
            system('say End of practice trials.');
            system('say Hit key to start the real experiment');
            mglGetKeyEvent;
            keepGoing = true;
            while keepGoing
                % If we're using keyboard mode, check for a keypress.
                tmp = mglGetKeyEvent;
                if ~isempty(tmp);
                    break;
                end
            end
            system('say Starting now.');
            pause(3)
            
            %% From psychofitTutorial.m
            %% Set up the staircase.
            % The code below runs three interleaved staircases.
            %   For 'quest', three different criterion percent correct values are used.
            %   For 'standard', three different up/down rules are used.
            % The use of 3 is hard-coded, in the sense that the vector lengths of the
            % criterion/up-down vectors must match this number.
            numTrialsPerStaircase = 40;
            
            staircaseType = 'standard';
            % Initialize staircases.  Initialization is slightly different for 'standard'
            % and 'quest' versions.  All parameters other than 'MaxValue' and 'MinValue'
            % are required, and this is enforced by the class constructor function.
            nInterleavedStaircases = 2;
            for k = 1:nInterleavedStaircases
                stepSizes = [4*contrastStep 2*contrastStep contrastStep];
                nUps = [3 2];
                nDowns = [1 1];
                initialGuess = contrastStep+contrastStep*(round(maxContrast*rand(1)/contrastStep)-1);
                st{k} = Staircase(staircaseType,initialGuess, ...
                    'StepSizes', stepSizes, 'NUp', nUps(k), 'NDown', nDowns(k), ...
                    'MaxValue', maxContrast, 'MinValue', minContrast);
                
                % Set up a vector which tells us which interval we are in
                theIntervals{k} = Shuffle([1*ones(1, numTrialsPerStaircase) 2*ones(1, numTrialsPerStaircase)]);
            end
            
            % Set up the break trials
            nTrials = nInterleavedStaircases*numTrialsPerStaircase;
            
            breakStep = 10;
            breakTrials = 0:breakStep:nTrials;
            breakTrials(1) = [];
            
            counter = 1;
            % Run interleaved staircases
            for i = 1:numTrialsPerStaircase
                order = Shuffle(1:nInterleavedStaircases);
                for k = 1:nInterleavedStaircases
                    % Get the contrast
                    testContrast = getCurrentValue(st{order(k)});
                    
                    % Assemble the information needed for the trial
                    % Find the index of the test contrast in our contrast
                    % vector.
                    [~, c] = min(abs(contrastLevels - testContrast));
                    intval = theIntervals{k}(i);
                    
                    if intval == 2
                        
                        starts = mod{b, c}.starts;
                        stops = mod{b, c}.stops;
                    elseif intval == 1
                        starts = mod{b, c}.starts(:, end:-1:1);
                        stops = mod{b, c}.stops(:, end:-1:1);
                    end
                    sound(yHint, fs);
                    
                    % Do a trial
                    
                    
                    %i = mod(i-1, nDirections)+1;
                    OLFlickerStartsStopsMethAdj(ol, starts, stops, dt, 1, true);
                    sound(yHint, fs);
                    %i = i+1;
                    % Get the key
                    keepGoing = true;
                    while keepGoing
                        % If we're using keyboard mode, check for a keypress.
                        tmp = mglGetKeyEvent;
                        if ~isempty(tmp);
                            key = tmp;
                            if (str2num(key.charCode) == 3)
                                decision = 1;
                                
                                
                                % Recode the response
                                response = (decision == intval);
                                
                                
                                % Abort and save out.
                                keepGoing = false;
                                fprintf(fid, '%s,%s,%s,%f,%f,%g,%g,%g\n', datestr(now), mod{b, c}.directionPedestal, mod{b, c}.directionFlicker, mod{b, c}.contrastPedestal, mod{b, c}.contrastFlicker, decision, intval, response);
                                fprintf('%s | %s | %s | Contrast: %f | Interval: %g | Decision: %g | Correct? %g\n', datestr(now), mod{b, c}.directionPedestal, mod{b, c}.directionFlicker, mod{b, c}.contrastFlicker, decision, intval, response);
                                
                                
                            end
                            
                            if (str2num(key.charCode) == 4)
                                decision = 2;
                                
                                
                                % Recode the response
                                response = (decision == intval);
                                
                                
                                % Abort and save out.
                                keepGoing = false;
                                fprintf(fid, '%s,%s,%s,%f,%f,%g,%g,%g\n', datestr(now), mod{b, c}.directionPedestal, mod{b, c}.directionFlicker, mod{b, c}.contrastPedestal, mod{b, c}.contrastFlicker, decision, intval, response);
                                fprintf('%s | %s | %s | Contrast: %f | Interval: %g | Decision: %g | Correct? %g\n', datestr(now), mod{b, c}.directionPedestal, mod{b, c}.directionFlicker, mod{b, c}.contrastFlicker, decision, intval, response);
                                
                            end
                            if decision == intval
                                sound(yLimitUp, fs);
                            else
                                sound(yLimitDown, fs);
                            end
                            pause(0.5);
                        end
                        
                    end
                    
                    % Update. 1 = correct; 0 = incorrect
                    st{order(k)} = updateForTrial(st{order(k)},testContrast,response);
                    
                    % Update the counter
                    counter = counter+1;
                    
                    % Force a break
                    if any(breakTrials == counter)
                        system('say Please take a break now.')
                        system(['say You have finished ' num2str(counter) ' out of ' num2str(numTrialsPerStaircase*nInterleavedStaircases) ' trials for this background.']);
                        mglGetKeyEvent;
                        keepGoing = true;
                        while keepGoing
                            % If we're using keyboard mode, check for a keypress.
                            tmp = mglGetKeyEvent;
                            if ~isempty(tmp);
                                break;
                            end
                        end
                        
                    end
                    
                end
            end
            system('say End of this background.');
            
        end
        
        fclose(fid);
        
        save(outFileMat);
        
        sound(yStart, fs);
        system('say You are free now. But come back soon.');
    case 'exptAdj'
        % Get observer name
        subjID = GetWithDefault('Observer name?', 'A000000A');
        
        %% Parameters
        % Set some parameters
        theBackgroundOrder = [2 3 1 5 4 4 5 1 3 2];
        adaptDurationSecs = 1;
        nDecisionsPerBackground = 10;
        dt = 1/100;
        
        baseDir = fileparts(fileparts(which('OLDemo')));
        outDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/PsychophysicsMelConeThreshPilot';
        if ~isdir(outDir);
            mkdir(outDir);
        end
        outFile = [subjID '.csv'];
        
        %% Try loading the file
        modFileToLoad = fullfile(baseDir, 'cache', 'modulations', ['MelConeThreshPilot-' num2str(observerAgeYrs) '.mat']);
        if ~exist(modFileToLoad, 'file')
            error('Modulation file does not exist. Run prep mode')
        else
            load(modFileToLoad)
        end
        
        fprintf('*** Modulation ready');
        ol = OneLight;
        
        input('\n> Press enter to start, any key to stop waveform');
        
        % Open output file
        fid = fopen(fullfile(outDir, outFile), 'a');
        
        %% Adjust starts/stops
        for i = 1:size(mod, 1)
            for j = 1:size(mod, 2)
                %mod{i, j}.starts = mod{i, j}.starts(end:-1:1, :);
                %mod{i, j}.stops = mod{i, j}.stops(end:-1:1, :);
            end
        end
        
        for b = 1:length(theBackgroundOrder)
            %% First, set the adapting background and wait.
            sound(yAdapt, fs);
            ol.setMirrors(mod{b, 1}.starts(:, 1), mod{b, 1}.stops(:,1));
            WaitSecs(adaptDurationSecs);
            
            for i = 1:nDecisionsPerBackground
                
                % Pick a random contrast level
                c = randi(length(mod));
                
                sound(yStart, fs);
                
                keepGoing = true;
                while keepGoing
                    fprintf('%s | %s | %s | Contrast: %f\n', datestr(now), mod{b, c}.directionPedestal, mod{b, c}.directionFlicker, mod{b, c}.contrastFlicker);
                    %i = mod(i-1, nDirections)+1;
                    [~, ~, key] = OLFlickerStartsStopsMethAdj(ol, mod{b, c}.starts, mod{b, c}.stops, dt, Inf, true);
                    %i = i+1;
                    
                    if (str2num(key.charCode) == 6) | (str2num(key.charCode) == 1)
                        
                        % Abort and save out.
                        keepGoing = false;
                        fprintf(fid, '%s,%s,%s,%f,%f\n', datestr(now), mod{b, c}.directionPedestal, mod{b, c}.directionFlicker, mod{b, c}.contrastPedestal, mod{b, c}.contrastFlicker);
                        fprintf('%s | %s | %s | FINAL CONTRAST: %f\n', datestr(now), mod{b, c}.directionPedestal, mod{b, c}.directionFlicker, mod{b, c}.contrastFlicker);
                    end
                    if (str2num(key.charCode) == 4)
                        % small step down
                        c = c-1;
                        if c < 1
                            c = 1;
                            sound(yLimitDown, fs);
                        else
                            sound(yChangeDown, fs);
                        end
                    end
                    if (str2num(key.charCode) == 5)
                        % small step up
                        c = c+1;
                        if c > length(mod)
                            c = length(mod);
                            sound(yLimitUp, fs);
                        else
                            sound(yChangeUp, fs);
                        end
                    end
                    if (str2num(key.charCode) == 3)
                        % large step down
                        c = c-5;
                        if c < 1
                            c = 1;
                            sound(yLimitDown, fs);
                        else
                            sound(yChangeDown, fs);
                        end
                    end
                    if (str2num(key.charCode) == 2)
                        % large step up
                        c = c+5;
                        if c > length(mod)
                            c = length(mod);
                            sound(yLimitUp, fs);
                        else
                            sound(yChangeUp, fs);
                        end
                    end
                end
                
            end
            
        end
        fclose(fid);
end


end