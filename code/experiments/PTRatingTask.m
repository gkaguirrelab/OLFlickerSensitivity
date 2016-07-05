function PTRatingTask(mode, observerAgeYrs)


%% Housekeeping
% If no age is passed, assume 32.
if ~exist('observerAgeYrs', 'var')
    observerAgeYrs = 32;
end


switch mode
    case 'prep'
        WINDOW_FLAG = false;
        
        % Define the directions
        directions = {'LMDirected' 'LMPenumbraDirected' 'LMOpenFieldDirected' 'SDirected' 'SPenumbraDirected' 'SOpenFieldDirected' 'MelanopsinDirected' 'MelanopsinDirectedLegacy' 'Background'}
        nConditions = length(directions);
        
        % Define the contrast levels for each direction
        contrastRelMax = [0.05/0.45 1 1 0.2/0.45 1 1 1 0.2/0.45 0];
        
        % Define parameters that are common amongst all
        timeStep = 1/256;
        durationSecs = 2;
        cosineWindowSecs = 0.25;
        timeVector = 0:timeStep:durationSecs-timeStep;
        
        % Define the frequencies
        frequenciesHz = [1 2 4 8 16 32 64];
        nFrequencies = length(frequenciesHz);
        
        %% Calibration
        % Load the appropriate calibration file.
        [~, cals] = LoadCalFile('OLBoxBLongCableBEyePiece2');
        cal = cals{end};
        
        %% Cache
        % Gather some information.
        baseDir = fileparts(fileparts(which('PTRatingTask')));
        cacheDir = fullfile(baseDir, 'cache', 'stimuli');
        
        % Set up the cache.
        olCache = OLCache(cacheDir, cal);
        
        % Iterate over conditions
        for d = 1:nConditions
            % Get the pedesttal
            direction = directions{d}; % Flicker direction
            if strcmp(direction, 'Background')
                cacheData = olCache.load(['Cache-LMDirected']); % Load L+M directed if we want the background. Could be any direction since the BG is typically the same.
            else
                cacheData = olCache.load(['Cache-' direction]);
            end
            
            % Pull out the primary settings from the cache file
            backgroundPrimary = cacheData.data(observerAgeYrs).backgroundPrimary;
            differencePrimary = cacheData.data(observerAgeYrs).differencePrimary;
            
            for f = 1:nFrequencies
                
                waveform = [];
                %% Set some parameters
                waveform.direction = direction;
                waveform.timeStep = timeStep;
                waveform.durationSecs = durationSecs;
                waveform.cal = cal;
                waveform.t = timeVector;
                
                % Pick out the contrast
                waveform.theContrastRelMax = contrastRelMax(d);
                
                % Set up the waveform
                waveform.modulationWaveform = 'sin';
                waveform.thePhaseRad = 0;
                waveform.modulationMode = 'FM';
                
                % Define the window
                if WINDOW_FLAG
                waveform.window.cosineWindowIn = true;
                waveform.window.cosineWindowOut = true;
                waveform.window.cosineDurationSecs = cosineWindowSecs;
                waveform.window.nWindowed = waveform.window.cosineDurationSecs/waveform.timeStep;
                waveform.window.type = 'cosine';
                else
                  waveform.window.type = 'none';  
                end
                
                % Pick out the frequency
                waveform.theFrequencyHz = frequenciesHz(f);
                
                
                fprintf('> Generating %g Hz (%g/%g) for direction %s (%g/%g) ...', waveform.theFrequencyHz, f, nFrequencies, direction, d, nConditions);
                mod(d, f) = OLMakeWaveform(waveform, waveform.cal, backgroundPrimary, differencePrimary, 'full');
                fprintf('DONE.\n');
                
            end
        end
        
        if WINDOW_FLAG
        save(fullfile(baseDir, 'cache', 'modulations', ['PTRatingTask-' num2str(observerAgeYrs)]), 'mod');
        else
         save(fullfile(baseDir, 'cache', 'modulations', ['PTRatingTask-NoWindow-' num2str(observerAgeYrs)]), 'mod');   
        end
        
    case 'expt'
        %% Set up sounds
        fs = 20000;
        durSecs = 0.01;
        t = linspace(0, durSecs, durSecs*fs);
        yStart = [sin(880*2*pi*t)];
        yStop = [sin(440*2*pi*t)];
        %sound(yStart, fs);
        
        %% Set up experimental parameters
        timeStep = 1/256;
        nDirections = 6;
        nFrequencies = 7;
        nRepetitions = 5;
        nCatchTrials = ceil(0.1*nRepetitions*nDirections*nFrequencies);
        
        % Contrast the trial sequence
        dirPerTrials = repmat([1:6], 1, nFrequencies*nRepetitions);
        freqPerTrials = repmat(1:nFrequencies, nDirections*nRepetitions, 1);
        freqPerTrials = freqPerTrials(:)';
        
        % Special case for the 'background' catch trials. This is direction
        % 5 in the array, see the 'prep' code above. Freqyuency doesn't
        % matter.
        bgIdx = 9;
        tmpDir = bgIdx*ones(1, nCatchTrials);
        tmpFreq = ones(1, nCatchTrials);
        
        % Assemble all trials now
        dirPerTrials = [dirPerTrials tmpDir];
        freqPerTrials = [freqPerTrials tmpFreq];
        
        % How many trials?
        nTrials = length(dirPerTrials);
        
        % Set up a randomized order
        trialOrder = Shuffle(1:nTrials);
        
        % Get observer name
        subjID = GetWithDefault('Observer name?', 'A000000A');
        
        baseDir = fileparts(fileparts(which('PTRatingTask')));
        outDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/PTRatingTask';
        if ~isdir(outDir);
            mkdir(outDir);
        end
        outFile = [subjID '.csv'];
        outFileMat = [subjID '.mat'];
        
        %% Try loading the file
        modFileToLoad = fullfile(baseDir, 'cache', 'modulations', ['PTRatingTask-' num2str(observerAgeYrs) '.mat']);
        if ~exist(modFileToLoad, 'file')
            error('Modulation file does not exist. Run prep mode')
        else
            load(modFileToLoad)
        end
        
        fprintf('*** Modulations ready');
        ol = OneLight;
        ol.setMirrors(mod(1,1).startsBG, mod(1,1).stopsBG);
        
        input('\n> Press enter to start, any key to stop waveform');
        
        % Open output file
        fid = fopen(fullfile(outDir, outFile), 'a');
        
        
        input('');
        % Iterate over the trials
        for t = 1:nTrials
            trialStamp = datestr(now);
            
            % Which trial are we at?
            trial = trialOrder(t);
            
            d = dirPerTrials(trial);
            f = freqPerTrials(trial);
            
            fprintf('\n> %s, ********* Trial %g/%g', trialStamp, t, nTrials);
            fprintf('\n> Direction:\t%s', mod(d, f).direction);
            fprintf('\n> Frequency:\t%g', mod(d, f).theFrequencyHz);
            
            % Pull out the starts and stops
            starts = mod(d, f).starts;
            stops = mod(d, f).stops;
            
            % Mark the beginning of the trial
            sound(yStart, fs);
            
            % Show the modulation
            OLFlickerStartsStopsDemo(ol, starts', stops', timeStep, 1, false);
            
            % Mark the end of the trial
            sound(yStop, fs);
            
            % Ask the observer
            %seeYesNo = 1;%GetInput('Did the observer see it [1 = yes, 0 = no]');
            ratingVal = GetInput('Rating value [0 = no PT, 1 = just barely see PT, 2  = clearly see PT, 3 = strongly see PT]');
            
            fprintf(fid, '%s,%s,%g,%g\n', trialStamp, mod(d, f).direction, mod(d, f).theFrequencyHz, ratingVal);
            
            fprintf('\n> %s, ********* TRIAL END\n', datestr(now));
            pause(1);
        end
        
        
        fclose(fid);
        
        system('say End of Experiment');
        
    case 'demo'
         timeStep = 1/256;
        directions = {'LMDirected' 'LMPenumbraDirected' 'LMOpenFieldDirected' 'SDirected' 'SPenumbraDirected' 'SOpenFieldDirected' 'MelanopsinDirected' 'MelanopsinDirectedLegacy' 'Background'};
        nDirections = length(directions);
        frequenciesHz = [1 2 4 8 16 32 64];
        nFrequencies = length(frequenciesHz);
        
        %% Try loading the file
        
        baseDir = fileparts(fileparts(which('PTRatingTask')));
        modFileToLoad = fullfile(baseDir, 'cache', 'modulations', ['PTRatingTask-NoWindow-' num2str(observerAgeYrs) '.mat']);
        if ~exist(modFileToLoad, 'file')
            error('Modulation file does not exist. Run prep mode')
        else
            load(modFileToLoad)
        end
        
        fprintf('*** Modulations ready');
        ol = OneLight;
        ol.setMirrors(mod(1,1).startsBG, mod(1,1).stopsBG);
        
        
        while true
            % Now have the user select a direction
            keepPrompting = true;
            while keepPrompting
                % Show the available cache types.
                fprintf('\n*** Available directions ***\n\n');
                for i = 1:nDirections
                    fprintf('%d - %s\n', i, directions{i});
                end
                fprintf('\n');
                
                d = GetInput('Select a direction', 'number', 1);
                
                % Check the selection.
                if d >= 1 && d <= nDirections
                    keepPrompting = false;
                else
                    fprintf('\n* Invalid selection\n');
                end
            end
            
            
            % Now have the user select a frequency
            keepPrompting = true;
            while keepPrompting
                % Show the available cache types.
                fprintf('\n*** Available frequencies ***\n\n');
                for i = 1:nFrequencies
                    fprintf('%d - %g\n', i, frequenciesHz(i));
                end
                fprintf('\n');
                
                f = GetInput('Select a frequency', 'number', 1);
                
                % Check the selection.
                if f >= 1 && f <= nFrequencies
                    keepPrompting = false;
                else
                    fprintf('\n* Invalid selection\n');
                end
            end
            
            fprintf('\n> Direction:\t%s', mod(d, f).direction);
            fprintf('\n> Frequency:\t%g', mod(d, f).theFrequencyHz);
            
            % Pull out the starts and stops
            starts = mod(d, f).starts;
            stops = mod(d, f).stops;
            
            % Show the modulation
            OLFlickerStartsStopsDemo(ol, starts', stops', timeStep, Inf, true);
        end
        
    case 'analyze'
        subjIDs = {'DHB', 'GKA', 'MS'};
        %subjIDs = {'G112414A' 'D112414B' 'M112414S'};
        
        for s = 1:length(subjIDs)
            subjID = subjIDs{s};
            figure;
            
            % Get observer name
            %subjID = GetWithDefault('Observer name?', 'DHB');
            
            baseDir = fileparts(fileparts(which('PTRatingTask')));
            outDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/PTRatingTask';
            outFile = [subjID '.csv'];
            
            % Read in the CSV
            %keyboard
            C = csvimport(fullfile(outDir, outFile), 'noHeader', true);
            
            directions = C(:, 2);
            frequencies = cell2mat(C(:, 3));
            responses = cell2mat(C(:, 4));
            
            % Iterate over the directions
            [uniqueBackgroundLabels, backgroundLabelsInd, backgroundLabelsNum] = unique(directions);
            
            % Aggregate the data
            [xcon, ycon] = consolidator([backgroundLabelsNum frequencies], responses, 'mean')
            
            xcon_s{s} = xcon;
            ycon_s{s} = ycon;
            
            [~, ycon_std] = consolidator([backgroundLabelsNum frequencies], responses, 'std');
            nReps = 5;
            ycon_sem = ycon_std/nReps;
            
            
            theColors = [0 0 0 ; 1 0 0 ; 0.5 0.5 0 ; 0 0.5 0.5 ; 0 0 1 ; 0 0 0.5 ; 0 0.5 1];
            
            c = 1;
            figure(s);
            % Plot the data
            for i = 2:length(uniqueBackgroundLabels)
                idx = find(xcon(:, 1) == i);
                h(c) = plot(log2(xcon(idx, 2)), ycon(idx, :), 'Marker', 'o', 'Color', theColors(i, :), 'MarkerFaceColor', theColors(i, :)); hold on;
                errorbar(log2(xcon(idx, 2)), ycon(idx, :), ycon_sem(idx, :), 'Color', theColors(i, :));
                
                c = c+1;
            end
            
            % Also add the background
            idx = 1;
            h(c) = plot(-1, ycon(idx, :), 'Marker', 'o', 'Color', theColors(idx, :), 'MarkerFaceColor', theColors(idx, :)); hold on;
            errorbar(-1, ycon(idx, :), ycon_sem(idx, :), 'Color', theColors(idx, :));
            
            set(gca, 'XTick', [0 1 2 3 4 5 6], 'XTickLabel', 2.^[0 1 2 3 4 5 6]);
            
            pbaspect([1 1 1]);
            xlabel('Frequency [Hz]');
            ylabel('Mean rating [0-3]');
            ylim([-0.05 3.1]);
            xlim([-2 7]);
            title({subjID ; '+/-1 SEM'});
            
            legend(h, {uniqueBackgroundLabels{2:length(uniqueBackgroundLabels)} 'Background'}, 'Location', 'NorthWest'); legend boxoff;
            %% Save plots
            set(gcf, 'Color', [1 1 1]);
            set(gcf, 'InvertHardCopy', 'off');
            set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 15 and height 6.
            set(gcf, 'PaperSize', [5 5]); %Set the paper to have width 15 and height 6.
            
            saveas(gcf, fullfile(outDir, [outFile '.pdf']), 'pdf');
        end
        
        %keyboard
        avg_resp = mean([ycon_s{:}], 2)
        sem_resp = std([ycon_s{:}], [], 2)/sqrt(length(subjIDs));
        
        figure;
        c = 1;
        for i = 2:length(uniqueBackgroundLabels)
            idx = find(xcon(:, 1) == i)
            h(c) = plot(log2(xcon(idx, 2)), avg_resp(idx, :), 'Marker', 'o', 'Color', theColors(i, :), 'MarkerFaceColor', theColors(i, :)); hold on;
            errorbar(log2(xcon(idx, 2)), avg_resp(idx, :), sem_resp(idx, :), 'Color', theColors(i, :));
            
            c = c+1;
        end
        set(gca, 'XTick', [0 1 2 3 4 5 6], 'XTickLabel', 2.^[0 1 2 3 4 5 6]);
        
        % Also add the background
        idx = 1;
        h(c) = plot(-1, ycon(idx, :), 'Marker', 'o', 'Color', theColors(idx, :), 'MarkerFaceColor', theColors(idx, :)); hold on;
        errorbar(-1, ycon(idx, :), ycon_sem(idx, :), 'Color', theColors(idx, :));
        
        pbaspect([1 1 1]);
        xlabel('Frequency [Hz]');
        ylabel('Mean rating [0-3]');
        ylim([-0.05 3.1]);
        xlim([-2 7]);
        title('Subject average +/-1 SEM');
        
        legend(h, {uniqueBackgroundLabels{2:length(uniqueBackgroundLabels)} 'Background'}, 'Location', 'NorthWest'); legend boxoff;
        
        %% Save plots
        set(gcf, 'Color', [1 1 1]);
        set(gcf, 'InvertHardCopy', 'off');
        set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 15 and height 6.
        set(gcf, 'PaperSize', [5 5]); %Set the paper to have width 15 and height 6.
        
        
        saveas(gcf, fullfile(outDir, ['subjAvg.pdf']), 'pdf');
end
