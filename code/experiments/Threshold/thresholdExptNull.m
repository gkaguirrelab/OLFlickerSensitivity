function thresholdExptNull(observerID, mode)
% thresholdExptNull(observerID, mode)
%
% Usage:
%       thresholdExptNull('X000000X', 'prep')
%       thresholdExptNull('X000000X', 'exptPedestalStaircase2IFC')
%
%
% 7/10/15   ms      Wrote it based on earlier threshold code.
% 7/22/15   ms      Fixed some issues with defining contrast levels, etc.

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
        %% Parameters
        % Set up the directions and parameters for the modulation.
        directionFlicker = 'LMSDirected';                % Flicker direction (L+M)
        
        % We are setting up the pedestal as a square wave between 0 and 1 with a period of 2
        % seconds (i.e. 0.5 Hz). The flicker riding on top of this is running at 4
        % Hz.
        frequencyFlicker = 4;                       % Flicker frequency
        frequencyMask = 1/2;                        % Pedestal frequency (Hz)
        
        % Lower-level parameters
        dt = 1/48;                                  % Refresh rate of the OL
        t = 0:dt:(1/frequencyMask-dt);              % Time vector
        maxContrast = 0.32;                          % Max contrast.
        contrastScalar = 0.8; % Amount that the background gets scaled.
        contrastLevelsPedestal = [-0.32 0.32 -0.32 0.32];
        directionsPedestal = {'LMSDirected' 'LMSDirected' 'MelanopsinDirectedLegacy' 'MelanopsinDirectedLegacy'};
        contrastLevelsFlicker = 0:0.0025:0.05;
        nConditions = length(directionsPedestal);
        
        %% Load the nulled modulations
        nullBasePath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/Nulling/';
        nullFile = fullfile(nullBasePath, [observerID '_nulling.mat']);
        if exist(nullFile, 'file')
            load(nullFile);
        else
            error(['>>> Nulling not performed on subject ' observerID '!']);
        end
        
        %% Pull out the data from the cached nulling data
        baseDir = fileparts(fileparts(fileparts(which(mfilename))));
        
        % Find the corresponding indices in the nulling vector
        for d = 1:nConditions
            for n = 1:length({nulling{:}})
                if (sign(nulling{n}.modulationArm) == sign(contrastLevelsPedestal(d))) && strcmp(nulling{n}.direction, directionsPedestal{d})
                    theIdx(d) = n;
                end
                if (sign(nulling{n}.modulationArm) == 1) && strcmp(nulling{n}.direction, 'LMSDirected')
                    flickerIdx = n;
                end
            end
        end
        
        % Make waveforms
        for d = 1:nConditions
            % Get the pdedestal
            directionPedestal = directionsPedestal{d}; % Pedestal direction (Mel)
            
            % Set up the waveforms. This vector serves both to turn on the pedestal
            % and to mask the high-frequency waveform of the flicker.
            waveformPedestal = ones(1, length(t));
            flickerMask = square(2*pi*frequencyMask*t-pi);
            flickerMask(flickerMask < 0) = 0;
            waveformFlicker = square(2*pi*frequencyFlicker*t) .* flickerMask;
            
            % Pull out the primary settings from the cache file
            backgroundPedestal = nulling{theIdx(d)}.backgroundPrimary;
            differencePedestal = nulling{theIdx(d)}.modulationPrimarySigned;
            differenceFlicker = nulling{flickerIdx}.modulationPrimarySigned;
            
            for c = 1:length(contrastLevelsFlicker)
                %% Contrast
                contrastFlicker = contrastLevelsFlicker(c);
                contrastFlicker = contrastFlicker/maxContrast;
                
                %% Generate the stimuli
                % Construct the waveform
                for i = 1:length(t)
                    waveformPrimary(:, i) = backgroundPedestal + contrastScalar*differencePedestal*waveformPedestal(i) + contrastFlicker*differenceFlicker*waveformFlicker(i);
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
                mod{d, c}.contrastPedestal = contrastScalar*contrastLevelsPedestal(d);
                mod{d, c}.contrastFlicker = contrastLevelsFlicker(c);
                mod{d, c}.condition = ['bg' directionsPedestal{d} '_flicker' directionFlicker];
                fprintf('Progress: %g/%g, %g/%g\n', d, nConditions, c, length(contrastLevelsFlicker));
            end
        end
        save(fullfile(baseDir, 'cache', 'modulations', ['MelConeThreshold-' observerID]), 'mod');
    case 'exptPedestalStaircase2IFC'
        
        %% Parameters
        % Set some parameters
        %theBackgroundOrder = [5 4 5 4];
        theBackgrounds = Shuffle([1:4]);
        adaptDurationSecs = 0;
        nDecisionsPerBackground = 20;
        dt = 1/48;
        
        baseDir = fileparts(fileparts(fileparts(which(mfilename))));
        addpath(genpath(baseDir));
        outDir = fullfile(baseDir, 'data', 'PsychophysicsMelConeThreshold');
        if ~isdir(outDir);
            mkdir(outDir);
        end
        outFile = [observerID '.csv'];
        outFileMat = [observerID '.mat'];
        
        %% Try loading the file
        modFileToLoad = fullfile(baseDir, 'cache', 'modulations', ['MelConeThreshold-' observerID '.mat']);
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
        
        for b = theBackgrounds % Iterate over the backgrounds
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
            
            ol.setMirrors(mod{b, 1}.starts(:, 1), mod{b, 1}.stops(:,1));
            system('say Adapt to background for five minutes');
            mglWaitSecs(60);
            system('say 4 minutes left.');
            mglWaitSecs(60);
            system('say 3 minutes left.');
            mglWaitSecs(60);
            system('say 2 minutes left.');
            mglWaitSecs(60);
            system('say 1 minutes left.');
            mglWaitSecs(60);
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
            contrastStep = 0.0025;
            maxContrast = 0.05;
            minContrast = contrastStep;
            contrastLevels = 0:contrastStep:maxContrast;
            nContrastLevels = length(contrastLevels);
            contrastSteps = 2:21;
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
                        if (str2num(key.charCode) == 1)
                            decision = 1;
                            
                            % Recode the response
                            response = (decision == intval);
                            
                            % Abort and save out.
                            keepGoing = false;
                        end
                        
                        if (str2num(key.charCode) == 6)
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
                            if (str2num(key.charCode) == 1)
                                decision = 1;
                                
                                % Recode the response
                                response = (decision == intval);
                                
                                % Abort and save out.
                                keepGoing = false;
                                fprintf(fid, '%s,%s,%s,%f,%f,%g,%g,%g\n', datestr(now), mod{b, c}.directionPedestal, mod{b, c}.directionFlicker, mod{b, c}.contrastPedestal, mod{b, c}.contrastFlicker, decision, intval, response);
                                fprintf('%s | %s | %s | Contrast: %f | Interval: %g | Decision: %g | Correct? %g\n', datestr(now), mod{b, c}.directionPedestal, mod{b, c}.directionFlicker, mod{b, c}.contrastFlicker, decision, intval, response);
                                
                            end
                            
                            if (str2num(key.charCode) == 6)
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
            
            % Save out the stair case record
            staircaseRecord(b).st = st;
            
        end
        
        fclose(fid);
        
        save(outFileMat);
        
        sound(yStart, fs);
        system('say You are free now. But come back soon.');
        
        
end


end