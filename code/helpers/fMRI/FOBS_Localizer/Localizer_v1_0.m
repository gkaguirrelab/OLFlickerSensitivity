function Localizer_v1_0(paramsFile)
%Localizer_v1_0: Run the Functional Localizer (aka FOBS Localizer)
%           Localizer_v1_0(paramsFile)
%
%   Localizer_v1_0([paramsFile]) initializes the Functional Localizer, in
%   which a sequence of images is presented to the subject in a block
%   design. Subject's task is to press a button whenever there is a
%   stimulus repetition (1-back task).
%   The stimuli presented are all image files inside the directories
%   specified in the paramsFile.
%
%
%   Inputs
%   -------
%   [paramsFile] (optional):
%           Path to a file that contain the experimental parameters. If
%           nothing is entered, the file ./Config/params.cfg will be used.
%
%
%   Outputs
%   -------
%   ./Data/[subjID]/[subjID]-[iteration].mat
%           this file will store all experimental info, experiment
%           parameters, stimuli used, and data collected
%
%   Examples
%   -------
%    i) Localizer_v1_0('./protocols.txt')
%   ii) Localizer_v1_0
%
%   _______________________________________________
%   by Marcelo G Mattar (08/03/2012)
%   mattar@sas.upenn.edu


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DIRECTORY INFORMATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get directory information
% IMPORTANT! The Data and StimSet directories should be on the same level as the Experiment directory!
expInfo.dir.currDir = pwd;  % Current directory path
expInfo.dir.baseDir = fileparts(which(mfilename)); % Code directory path.
expInfo.dir.stimDir = sprintf('%s/StimSet', expInfo.dir.baseDir); % StimSet directory path
expInfo.dir.dataDir = sprintf('%s/Data', expInfo.dir.baseDir); % Data directory path
expInfo.dir.configDir = sprintf('%s/Config', expInfo.dir.baseDir); % Config directory path

% Create ./Data directory in case it doesn't exist yet
if ~exist(expInfo.dir.dataDir, 'dir')
	mkdir(expInfo.dir.dataDir);
end

% Dynamically add the program code to the path if it isn't already on it.
if isempty(strfind(path, expInfo.dir.baseDir))
	fprintf('- Adding Experiment directory dynamically to the path...');
	addpath(RemoveSVNPaths(genpath(expInfo.dir.baseDir)), '-end');
	fprintf('Done\n');
end
if isempty(strfind(path, expInfo.dir.stimDir))
	fprintf('- Adding StimSet directory dynamically to the path...');
	addpath(RemoveSVNPaths(genpath(expInfo.dir.stimDir)), '-end');
	fprintf('Done\n');
end
if isempty(strfind(path, expInfo.dir.configDir))
	fprintf('- Adding StimSet directory dynamically to the path...');
	addpath(RemoveSVNPaths(genpath(expInfo.dir.configDir)), '-end');
	fprintf('Done\n');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% CHECK INPUTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 1
    paramsFile = sprintf('%s/params.cfg', expInfo.dir.configDir);
end

if ~exist(paramsFile,'file')
    error('You must either specify a file with the protocols to be loaded, or there should be one located in the ./config directory named ProtocolList.cfg');
end

% Check how many devices are connected
if length(GetKeyboardIndices()) == 1
    fprintf('\n***** WARNING!!! There is only one keyboard connected. *****\n');
    fprintf('***** Perhaps you forgot to re-start MATLAB after pluging in the MRI-trigger USB? *****\n');
end

% Save the parameters file.
expInfo.paramsFile = paramsFile;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MAIN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try

    % Store the date/time when the experiment starts.
    expInfo.experimentTimeNow = now;
    expInfo.experimentTimeDateString = datestr(expInfo.experimentTimeNow);
    
    % Get subject information
    expInfo = getSubjInfo(expInfo);

    % Setup basic parameters for the experiment.
	params = initParams(expInfo);
    
    % Get subject information
    params = generateSequence(expInfo,params);
    
    % Display relevant information
    display(sprintf('\nSaving directory: %s', expInfo.dir.subjectDataDir))
    display(sprintf('Filename: %s', expInfo.saveFileName))
    
    % Make sure this is the correct protocol and check number of expected TRs
    fprintf('\nExpecting %d trials, or %d %ds-TRs.\n- Press any key to continue.\n\n',params.sequence.numTrials,params.sequence.numTRs,params.timing.TRDuration/1000);
    KbWait(-3,2);
    
	% Setup the display.
	[window, params] = initDisplay(params);
    
	% Load the stimuli.
    stimSet = loadStimuli(params);
    
	data = experimentLoop(expInfo, params, stimSet, window);

    % Save the experimental data 'params' along with the experimental setup
    % data 'exp'.
    save(expInfo.saveFileName, 'expInfo', 'params', 'data');
    fprintf('\n- Data saved to %s\n\n', expInfo.saveFileName);
    
    % Print concluding message and close the screen
    fprintf('\nLocalizer scan is complete, with %d %ds-TRs.\n\n',params.sequence.numTRs,params.timing.TRDuration/1000);
    GiveBackTheScreen;

catch exception
    GiveBackTheScreen(true);
    fprintf('\nIncomplete data. Attempted to save partial data...\n');
    fprintf('\n- Data saved to %s\n\n', expInfo.saveFileName);
     
	if strcmp(exception.message, 'abort')
		fprintf('- Aborting experiment.\n');
	else
		rethrow(exception);
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% EXPERIMENT LOOP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = experimentLoop(expInfo, params, stimSet, window)

    % Save starting time
    data.timing.expStart = GetSecs;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % INITIAL SETUP

    % Define some important variables
    data.numTrials = params.sequence.numTrials;
    data.numTRs = params.sequence.numTRs;
    data.seq = params.sequence.trialType;
    data.correctResp = (data.seq=='*');
    
    % Preallocate experimental data variables
    data.timing.stimOnsetTime = nan(1,data.numTrials);
    data.timing.stimOffsetTime = nan(1,data.numTrials);
    data.timing.stimDuration = nan(1,data.numTrials);
    data.timing.trialOnset = nan(1,data.numTrials);
    data.timing.trialDuration = nan(1,data.numTrials);
    %data.timing.maskOnsetTime = nan(1,data.numTrials);
    %data.timing.maskOffsetTime = nan(1,data.numTrials);
    
    data.timing.respTime = nan(1,data.numTrials);
    data.timing.reacTime = nan(1,data.numTrials);
    data.respKey = cell(1,data.numTrials);
    
    data.timing.TRstatus = nan(1,data.numTRs);
    data.timing.TRtime = nan(1,data.numTRs);

    % Make stimuli textures
    display('Making stimuli textures...');
    imgPtr = zeros(size(stimSet));
    for i=1:length(imgPtr)
        if ~isempty(stimSet{i,1}) % If it's not a blank
            imgPtr(i,1) = Screen('MakeTexture',window,stimSet{i,1});
        end
    end
    display('Done!');
    
    % Preload textures into VRAM to facilitate fast drawing
    Screen(window, 'PreloadTextures');

    % Create fixation cross
    FixCross = [params.screen.Xcenter-params.fixPoint.fpThickness,params.screen.Ycenter-params.fixPoint.fpSize,params.screen.Xcenter+params.fixPoint.fpThickness,params.screen.Ycenter+params.fixPoint.fpSize;params.screen.Xcenter-params.fixPoint.fpSize,params.screen.Ycenter-params.fixPoint.fpThickness,params.screen.Xcenter+params.fixPoint.fpSize,params.screen.Ycenter+params.fixPoint.fpThickness];

    % Present screen with instructions for the scan
    displayText(window, params.main.instructionFile, params.screen.lineSpacing, params.screen.fontSize, params.screen.fontColor)

    % Prepare the blank screen with fixation cross
    Screen(window,'FillRect',params.screen.bgColor);
    Screen('FillRect', window, params.fixPoint.fpColor, FixCross');
    
    % Wait for subject's input to begin experiment:
    fprintf('\nWaiting for subject''s input to begin experiment...\n- Ask subject to press any button.\n\n');
    KbStrokeWait(-3);
    Screen(window,'Flip');
    
    % Wait for the first 't'
    fprintf('Waiting for the first ''t''...\n- Ask technician to begin scan.\n\n');
    data.timing.scanStart = WaitForT;

    % Begin trials
    for trial = 1:data.numTrials
        
        % Save trial Onset time
        data.timing.trialOnset(trial) = GetSecs();
        
        % Save partial data (in case an error occurs)
        save(expInfo.saveFileName, 'expInfo', 'params', 'data');
        
        if data.seq(trial) == '-'
            fprintf('Stimulus #%d: (-Blank-)\n', trial);
        elseif data.seq(trial) == '*'
            fprintf('Stimulus #%d: (-TARGET-)\n', trial);
        else
            fprintf('Stimulus #%d: (%s) - %s\n', trial, data.seq(trial), params.sequence.fileNames{1,trial});
        end            
        %fprintf('Category: %d\n',exp.category(i));
        fprintf('----------------------------------\n');

        % If the current trial is not a blank
        if data.seq(trial) ~=  '-'
            

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % STIMULUS SCREEN PREPARATION
            
            % Prepare stimulus texture
            Screen('DrawTexture',window,imgPtr(trial,1), [], CenterRect([0 0 params.stimuli.stimDimPx(1) params.stimuli.stimDimPx(2)], params.screen.screenRect));
            
            % Prepare fixation cross
            Screen('FillRect', window, params.fixPoint.fpColor, FixCross');
            

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % STIMULUS PRESENTATION
            
            % Flip the screen
            data.timing.stimOnsetTime(trial) = Screen(window,'Flip');


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % WAIT FOR T IF trial=SyncTrial, OTHERWISE WAIT FOR TIMEOUT
            
            % If it's not a sync trial
            if mod(trial,params.sequence.numSyncTrials)~=0
                % Wait params.timing.stimDuration (stimulus presentation duration) minus half a flipInterval (to compensate for delays and refresh at the right time)
                [TRtime, respTime, respKey] = WaitForTimeoutAndListenToRespOrTR(data.timing.stimOnsetTime(trial), params.timing.stimDuration - (params.screen.flipInterval/2)*1000, ~isempty(data.respKey{trial}));
                % If a TR was received
                if ~isnan(TRtime)
                    % Finds the most likely index for the TR received
                    currentTR = max(1,round(params.sequence.numSyncTRs*((trial-1)*params.timing.trialDuration + params.timing.stimDuration)/(params.sequence.numSyncTrials*params.timing.trialDuration)));
                    % Saves TR information on the appropriate vector
                    data.timing.TRstatus(currentTR) = 1;
                    data.timing.TRtime(currentTR) = TRtime;
                end
            else % If it IS a sync trial
                % Wait params.timing.stimDuration (stimulus presentation duration) minus half a flipInterval (to compensate for delays and refresh at the right time)
                [TRtime, respTime, respKey] = WaitForTRAndListenToResp(data.timing.stimOnsetTime(trial), params.timing.stimDuration - (params.screen.flipInterval/2)*1000, ~isempty(data.respKey{trial}));
                % If a TR was received
                if ~isnan(TRtime)
                    currentTR = floor(trial/params.sequence.numSyncTrials)*params.sequence.numSyncTRs;
                    data.timing.TRstatus(currentTR) = 1;
                    data.timing.TRtime(currentTR) = TRtime;
                end
            end
            
            % If a response was received (and no other response for this trial was saved before)
            if (isnan(data.timing.respTime(trial)) && ~isnan(respTime))
                data.respKey{trial} = respKey;
                data.timing.respTime(trial) = respTime;
            end


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % BLANK SCREEN PREPARATION
            
            % Prepare the blank screen
            Screen(window,'FillRect',params.screen.bgColor);
            
            % Prepare fixation cross
            Screen('FillRect', window, params.fixPoint.fpColor, FixCross');


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % BLANK SCREEN PRESENTATION
            
            % Wait until the end of the trial
            data.timing.stimOffsetTime(trial) = Screen(window,'Flip');


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % WAIT FOR T IF trial=SyncTrial, OTHERWISE WAIT FOR TIMEOUT
            
            % If it's not a sync trial
            if mod(trial,params.sequence.numSyncTrials)~=0
                % Wait params.timing.trialDuration-params.timing.stimDuration (blank period duration minus half a flipInterval (to compensate for delays and refresh at the right time)
                %[TRtime, respTime, respKey] = WaitForTimeoutAndListenToRespOrTR(data.timing.trialOnset(trial), params.timing.trialDuration - (params.screen.flipInterval/2)*1000);
                [TRtime, respTime, respKey] = WaitForTimeoutAndListenToRespOrTR(data.timing.trialOnset(trial), params.timing.trialDuration, ~isempty(data.respKey{trial}));
                % If a TR was received
                if ~isnan(TRtime)
                    % Finds the most likely index for the TR received
                    currentTR = round(trial*params.sequence.numSyncTRs/params.sequence.numSyncTrials);
                    % Saves TR information on the appropriate vector
                    data.timing.TRstatus(currentTR) = 1;
                    data.timing.TRtime(currentTR) = TRtime;
                end
            else % If it IS a sync trial
                % Wait params.timing.trialDuration-params.timing.stimDuration (blank period duration) PLUS a timeout value, to accept late t's from the scanner (but not if it's too late!)
                [TRtime, respTime, respKey] = WaitForTRAndListenToResp(data.timing.trialOnset(trial), params.timing.trialDuration + params.timing.TRTimeout, ~isempty(data.respKey{trial}));
                % If a TR was received
                if ~isnan(TRtime)
                    currentTR = floor(trial/params.sequence.numSyncTrials)*params.sequence.numSyncTRs;
                    data.timing.TRstatus(currentTR) = 1;
                    data.timing.TRtime(currentTR) = TRtime;
                end
            end
            
            % If a response was received (and no other response for this trial was saved before)
            if (isnan(data.timing.respTime(trial)) && ~isnan(respTime))
                data.respKey{trial} = respKey;
                data.timing.respTime(trial) = respTime;
            end
            
            
        % If the current trial is a "null" trial
        elseif data.seq(trial) == '-'
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % BLANK SCREEN PREPARATION
            
            % Prepare the blank screen
            Screen(window,'FillRect',params.screen.bgColor);
            
            % Prepare fixation cross
            Screen('FillRect', window, params.fixPoint.fpColor, FixCross');


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % BLANK SCREEN PRESENTATION
            
            % Wait until the end of the trial
            Screen(window,'Flip');


            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % WAIT FOR T IF trial=SyncTrial, OTHERWISE WAIT FOR TIMEOUT
            
            % If it's not a sync trial
            if mod(trial,params.sequence.numSyncTrials)~=0
                % Wait params.timing.trialDuration minus half a flipInterval (to compensate for delays and refresh at the right time)
                %[TRtime, respTime, respKey] = WaitForTimeoutAndListenToRespOrTR(data.timing.trialOnset(trial), params.timing.trialDuration - (params.screen.flipInterval/2)*1000);
                [TRtime, respTime, respKey] = WaitForTimeoutAndListenToRespOrTR(data.timing.trialOnset(trial), params.timing.trialDuration, ~isempty(data.respKey{trial}));
                % If a TR was received
                if ~isnan(TRtime)
                    % Finds the most likely index for the TR received
                    currentTR = max(1,round(trial*params.sequence.numSyncTRs/params.sequence.numSyncTrials));
                    % Saves TR information on the appropriate vector
                    data.timing.TRstatus(currentTR) = 1;
                    data.timing.TRtime(currentTR) = TRtime;
                end
            else % If it IS a sync trial
                % Wait params.timing.stimDuration (stimulus presentation duration) PLUS a timeout value, to accept late t's from the scanner (although not too late!)
                [TRtime, respTime, respKey] = WaitForTRAndListenToResp(data.timing.trialOnset(trial), params.timing.trialDuration + params.timing.TRTimeout, ~isempty(data.respKey{trial}));
                % If a TR was received
                if ~isnan(TRtime)
                    currentTR = floor(trial/params.sequence.numSyncTrials)*params.sequence.numSyncTRs;
                    data.timing.TRstatus(currentTR) = 1;
                    data.timing.TRtime(currentTR) = TRtime;
                end
            end
            
            % If a response was received (and no other response for this trial was saved before)
            if (isnan(data.timing.respTime(trial)) && ~isnan(respTime))
                data.respKey{trial} = respKey;
                data.timing.respTime(trial) = respTime;
            end
            
        end
        
        


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % WRAP-UP TRIAL
        
        if data.seq(trial) ~= '-'
            % Calculate reaction time
            data.timing.reacTime(trial) = 1000*(data.timing.respTime(trial) - data.timing.stimOnsetTime(trial));
            % Calculate stimulus duration
            data.timing.stimDuration(trial) = data.timing.stimOffsetTime(trial)-data.timing.stimOnsetTime(trial);
        end
        % Calculate trial duration
        data.timing.trialDuration(trial) = GetSecs()-data.timing.trialOnset(trial);
        
        % Print trial summary
        if ~isnan(data.timing.stimDuration(trial))
            fprintf('Presentation duration: %6.2f ms\n', data.timing.stimDuration(trial)*1000);
        end
        if ~isnan(data.timing.trialDuration(trial))
            fprintf('Trial duration: %6.2f ms\n', data.timing.trialDuration(trial)*1000);
        end
        if ~isnan(data.timing.reacTime(trial))
            fprintf('Reaction time: %.2f ms\n', data.timing.reacTime(trial));
            
            % Make sure reaction times are being calculated properly
            if data.timing.reacTime(trial) > 2*params.timing.trialDuration
                fprintf('\n**********************************************************\n');
                fprintf('WARNING! REACTION TIMES ARE NOT BEING CALCULATED PROPERLY!\n');
                fprintf('**********************************************************\n');
            end
        end
        fprintf(progressBar(data.timing.TRstatus, data.timing.respTime, data.correctResp, trial));
        
        % Make sure experiment is synchronized with scanner
        if mod(trial,params.sequence.numSyncTrials)==0
            if ~isnan(data.timing.TRstatus(floor(trial/params.sequence.numSyncTrials)*params.sequence.numSyncTRs))
                fprintf('\n*****************************\n');
                fprintf('CORRECTLY SYNCED WITH SCANNER\n');
                fprintf('*****************************\n');
            else
                fprintf('\n*******************************\n');
                fprintf('WARNING! DID NOT SYNC PROPERLY!\n');
                fprintf('*******************************\n');
            end
        end
        
        fprintf('\n');

    end
    
    data.timing.expEnd = GetSecs;
    data.timing.expDuration = data.timing.expEnd - data.timing.expStart;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%







%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SUBJECT INFORMATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function expInfo = getSubjInfo(expInfo)

    % In the data directory, we can see the list of subjects available if the
    % protocol has been run before.  If it hasn't been run, then we will create
    % the top level data directory, then ask the user to create a subject.
    availableSubjects = {};
    % Get a list of available subjects.
    dirList = dir(expInfo.dir.dataDir);

    % Skip the first two results because they are '.' and '..'.
    for i = 3:length(dirList)
        % Filter out non directory files.  We assume all directories are
        % subject directories.
        if dirList(i).isdir
            if ~strcmp(dirList(i).name, '.svn')
                availableSubjects{end+1} = dirList(i).name; % add to the list of available subjects
            end
        end
    end

    % Display the list of available subjects and also give an option to create
    % one.
    while true
        fprintf('\n- Subject Selection\n\n');

        fprintf('0 - Create a new subject\n');

        for i = 1:length(availableSubjects)
            fprintf('%d - %s\n', i, availableSubjects{i});
        end
        fprintf('\n');

        subjectIndex = GetInput('Choose a subject number', 'number', 1);

        if subjectIndex == 0
            % Create a new subject.
            while true
                newSubjInitials = GetInput('Enter subject initials', 'string');
                if length(newSubjInitials)==2 % Check if initials were valid
                    if ismember(newSubjInitials(1),[65:90,97:122]) && ismember(newSubjInitials(2),[65:90,97:122])
                        if ~ismember(subjectId(newSubjInitials),availableSubjects)
                            newSubjID = subjectId(newSubjInitials);
                            mkdir(sprintf('%s/%s', expInfo.dir.dataDir, newSubjID));
                            availableSubjects{end+1} = newSubjID; % add to the list of available subjects
                            break
                        else
                            disp(['*** This subject already exists. Try again.' sprintf('\n')]);
                            break
                        end
                    else
                        disp(['*** Invalid subject initials. Enter two letters.' sprintf('\n')]);
                    end
                else
                    disp(['*** Invalid subject initials. Enter two letters.' sprintf('\n')]);
                end
            end
        elseif any(subjectIndex == 1:length(availableSubjects))
            % We got our subject, now setup the proper variables and get out of
            % this loop.
            expInfo.subjID = availableSubjects{subjectIndex};
            expInfo.dir.subjectDataDir = sprintf('%s/%s', expInfo.dir.dataDir, ...
                expInfo.subjID);
            break;
        else
            disp(['*** Invalid subject selected. Try again.' sprintf('\n')]);
        end
    end
    
    % Find the largest iteration number in the data filenames, to prevent
    % overwriting data
    iter = 0;
    d = dir(expInfo.dir.subjectDataDir);
    for i = 3:length(d)
        s = textscan(d(i).name, '%s%s', 'Delimiter', '-');
        if ~isempty(s{2})
            % Get rid of the .mat part.
            n = strtok(s{2}, '.');
            n = strtok(n,'run');
            n = n{1};
            val = str2double(n);
            if ~isnan(val) && val > iter
                iter = val;
            end
        end
    end
    iter = iter + 1;

    expInfo.saveFileName = sprintf('%s/%s-run%d.mat', expInfo.dir.subjectDataDir, expInfo.subjID, iter);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INITIALIZE PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function params = initParams(expInfo)
    % Load the config file for this condition.
    cfgFile = ConfigFileFOBS(expInfo.paramsFile);

    % Convert all the ConfigFile parameters into simple struct values.
    params = convertToStruct(cfgFile.Params);

    % Complete the path to instruction file
    params.main.instructionFile = sprintf('%s/%s', expInfo.dir.configDir, params.main.instructionFile);
    
    % Generate stimSet directory paths
    if isempty(strfind(params.stimuli.stimSubdirectoryNames,',')) % If there is a single directory
        params.stimuli.stimSubdirectory{1} = strtrim(params.stimuli.stimSubdirectoryNames);
    else % If there are multiple directories
        commaPosition = strfind(params.stimuli.stimSubdirectoryNames,',');
        params.stimuli.stimSubdirectory = cell(length(commaPosition)+1,1);
        params.stimuli.stimSubdirectory{1,1} = strtrim(params.stimuli.stimSubdirectoryNames(1:(commaPosition(1)-1)));
        if length(commaPosition) > 1
            for thisComma = 1:(length(commaPosition)-1)
                params.stimuli.stimSubdirectory{(thisComma+1),1} = strtrim(params.stimuli.stimSubdirectoryNames((commaPosition(thisComma)+1):(commaPosition(thisComma+1)-1)));
            end
        end
        params.stimuli.stimSubdirectory{end,1} = strtrim(params.stimuli.stimSubdirectoryNames((commaPosition(end)+1):end));
    end
    if length(params.stimuli.stimSubdirectory) ~= length(params.sequence.categoryLabels)
        error('The number of category labels specified is different than the number of subdirectories');
    end

    % Get screen information
    params.screen.screenNum  = max(Screen('screens')); % Get the number of the last screen
    params.screen.screenRect = Screen(params.screen.screenNum, 'rect'); % Get local rect coordinates of screen
    params.screen.centerRect = CenterRect([0 0 params.stimuli.stimDimPx(1) params.stimuli.stimDimPx(2)], params.screen.screenRect); % Find coordinates of a centralized rectangle for stimuli
    [params.screen.Xcenter,params.screen.Ycenter] = RectCenter(params.screen.screenRect);

    % Calculate visual angles
    params.screen.screenDimVD = (180/pi)*2*atan(params.screen.screenDimCM/(2*params.screen.screenDistanceCM)); % Screen dimensions in visual angles (degrees)
    params.stimuli.stimDimVD = (params.screen.screenDimVD).*((params.stimuli.stimDimPx)./(params.screen.screenRect(1,3:4))); % Stimuli dimensions in visual angles (degrees)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% GENERATE SEQUENCE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function params = generateSequence(expInfo, params)
    % Generate the sequence
    params.sequence.numBlocks = length(params.sequence.blockSequence);
    params.sequence.numTrials = params.sequence.numBlocks * params.sequence.trialsPerBlock;
    
    % The stimulus duration and TR duration may be different, so we'll sync up
    % with the TRs only on common multiples of the 2 times.
    params.sequence.numSyncTRs = lcm(params.timing.trialDuration, params.timing.TRDuration) / params.timing.TRDuration;
    params.sequence.numSyncTrials = lcm(params.timing.trialDuration, params.timing.TRDuration) / params.timing.trialDuration;
    params.sequence.numTRs = ceil(params.sequence.numTrials*params.sequence.numSyncTRs/params.sequence.numSyncTrials);
    
    % Check if the number of trials per block is a valid number
    if mod(params.sequence.trialsPerBlock,params.sequence.numSyncTrials) ~= 0
        fprintf('\nThe specified number of trials per block (%d) is not a multiple of the number of trials necessary to synchronize with the scanner (%d).\nProceed anyway (y/n)?\n',params.sequence.trialsPerBlock,params.sequence.numSyncTrials);
        while true
            ListenChar(2);
            % Check all keyboards and keypads (-3) status
            [keyIsDown, ~, keyCode, ~] = KbCheck(-3);
            if keyIsDown % If *any* key is down
                % If any response key is one of the keys being pressed
                if ismember([KbName('y') KbName('Y')],find(keyCode))
                    ListenChar;
                    break
                end
                if ismember([KbName('n') KbName('N')],find(keyCode))
                    ListenChar;
                    error('Aborting...');
                end
            end
        end
    end
    
    if params.sequence.targetsPerBlock >= params.sequence.trialsPerBlock
        error('The number of targets per block must be less than the number of trials per block');
    end
    
    % Pick randomly the trials that will be repeats
    params.sequence.repeatTrials = nan(params.sequence.numBlocks,params.sequence.targetsPerBlock);
    for block=1:params.sequence.numBlocks
        if params.sequence.blockSequence(block) ~= '-'
            % Select random trials to be repeated, except for the first one
            aRandomPermutation = randperm(params.sequence.trialsPerBlock-params.sequence.targetsPerBlock-1)+1;
            params.sequence.repeatTrials(block,:) = sort(aRandomPermutation(1:params.sequence.targetsPerBlock));
            % Shift the target positions accordingly
            for target=1:params.sequence.targetsPerBlock
                params.sequence.repeatTrials(block,target) = params.sequence.repeatTrials(block,target) + target;
            end
        end
    end
    
    % Generate sequence of trial types
    params.sequence.trialType = blanks(params.sequence.numTrials);
    for block=1:params.sequence.numBlocks
        for trial=1:params.sequence.trialsPerBlock
            params.sequence.trialType((block-1)*params.sequence.trialsPerBlock + trial) = params.sequence.blockSequence(block);
        end
        % Add repeats
        if params.sequence.blockSequence(block) ~= '-'
            for target=1:params.sequence.targetsPerBlock
                params.sequence.trialType((block-1)*params.sequence.trialsPerBlock + params.sequence.repeatTrials(block,target)) = '*';
            end
        end
    end
    
    % Test if all stimulus subdirectories exist
    for thisDir=1:length(params.stimuli.stimSubdirectory)
        if ~exist([expInfo.dir.stimDir '/' params.stimuli.stimSubdirectory{1}],'dir')
            error('One or more of the directories specified in the config file do not exist');
        end
    end
    
    
    numberOfFilesOfEachType = zeros(length(params.stimuli.stimSubdirectory),1);
    for thisType=1:length(params.stimuli.stimSubdirectory)
        numberOfFilesOfEachType(thisType,1) = sum(params.sequence.trialType == params.sequence.categoryLabels(thisType));
    end
    
    % Generate sequence of filenames
    params.sequence.fileIndexes = nan(1,params.sequence.numTrials);
    params.sequence.fileNames = cell(1,params.sequence.numTrials);
    for thisDir=1:length(params.stimuli.stimSubdirectory)
        allFileNamesInThisDirectory = dir([expInfo.dir.stimDir '/' params.stimuli.stimSubdirectory{thisDir}]);
        % Remove the '.' and '..' directories
        allFileNamesInThisDirectory = allFileNamesInThisDirectory(3:end);
        % Remove any other unimportant directory
        if strcmp(allFileNamesInThisDirectory(1).name,'.DS_Store');
            allFileNamesInThisDirectory = allFileNamesInThisDirectory(2:end);
        end
        if strcmp(allFileNamesInThisDirectory(1).name,'.svn');
            allFileNamesInThisDirectory = allFileNamesInThisDirectory(2:end);
        end
        availableFilesInThisDirectory = length(allFileNamesInThisDirectory);
        
        % Select randomly the files' indexes to be used
        filesToUse = zeros(numberOfFilesOfEachType(thisDir,1),1);
        if numberOfFilesOfEachType(thisDir,1) < availableFilesInThisDirectory
            thisPerm = randperm(availableFilesInThisDirectory);
            filesToUse = thisPerm(1:numberOfFilesOfEachType(thisDir,1));
        else
            thisPerm = [];
            while length(thisPerm) < numberOfFilesOfEachType(thisDir,1)
                thisPerm = [thisPerm randperm(availableFilesInThisDirectory)];
            end
            filesToUse = thisPerm(1:numberOfFilesOfEachType(thisDir,1));
        end
        
        % Generate stimuli filenames
        params.sequence.fileIndexes(params.sequence.trialType == params.sequence.categoryLabels(thisDir)) = filesToUse;
        for trial=1:params.sequence.numTrials
            if params.sequence.trialType(trial) == params.sequence.categoryLabels(thisDir)
                params.sequence.fileNames{trial} = [expInfo.dir.stimDir '/' params.stimuli.stimSubdirectory{thisDir} '/' allFileNamesInThisDirectory(filesToUse(1)).name];
                params.sequence.fileIndexes(trial) = filesToUse(1);
                % Rotate filesToUse vector
                filesToUse = [filesToUse(2:end) filesToUse(1)];
                if ~exist(params.sequence.fileNames{trial},'file')
                    error('There is something wrong with this code');
                end
            elseif params.sequence.trialType(trial) == '*' % If it's a repeat trial
                params.sequence.fileNames{trial} = params.sequence.fileNames{trial-1};
                params.sequence.fileIndexes(trial) = params.sequence.fileIndexes(trial-1);
            end
        end
    end
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% INITIALIZE DISPLAY
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [window, params] = initDisplay(params)
    % Initialize Screen
    display(sprintf('\nInitializing screen...'));
    display(sprintf('The screen dimensions are %d x %d pixels, or %2.1f x %2.1f visual degrees.',params.screen.screenRect(3),params.screen.screenRect(4),params.screen.screenDimVD(1),params.screen.screenDimVD(2)));
    display(sprintf('Stimuli dimensions are %2.1f x %2.1f visual degrees.',params.stimuli.stimDimVD(1),params.stimuli.stimDimVD(2)));

    Screen('Preference', 'SkipSyncTests', 0);
    window = Screen(params.screen.screenNum,'OpenWindow',params.screen.bgColor,params.screen.screenRect,32);
    Priority(MaxPriority(window)); % Set up window as maximum priority
    ListenChar(2); % Enable character listening; additionally any output of keypresses to Matlab windows is suppressed
    HideCursor; % Hide mouse cursor from the screen
    WaitSecs(1); % Wait for display to stabilize

    params.screen.screenFrameRate = FrameRate(params.screen.screenNum);
    params.screen.flipInterval = Screen('GetFlipInterval', window);
    Screen(window,'TextFont', 'Courier'); % Set up font type
    Screen(window,'TextSize',params.screen.fontSize); % Set up font size
    Screen(window,'DrawText','Please wait, loading...', 50, 50, [0, 0, 0]); % Draw "please wait" text
    Screen(window,'Flip'); % Display everything on the window
    FlushEvents; % Clear the buffer

    display(sprintf('Done!'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% LOAD STIMULI
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stimSet = loadStimuli(params)

    display(sprintf('\nLoading stimuli...'));
    
    % Load stimuli
    stimSet = cell(length(params.sequence.fileNames),1);
    for i=1:params.sequence.numTrials
        if ~isempty(params.sequence.fileNames{1,i})
            stimSet{i,1} = imread(params.sequence.fileNames{1,i});
        end
    end
    display('Done!');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
































































%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% AUXILIARY FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function cfStruct = convertToStruct(CFParams)
    % cfStruct = convertToStruct(CFObj)
    %
    % Description:
    % Converts all parameters contained in the ConfigFile object into a struct.
    %
    % Required Inputs:
    % CFObj (ConfigFile) - The ConfigFile object to operate on.
    %
    % Output:
    % cfStruct (struct) - Struct containing all ConfigFile items and their
    %    associated data.

    if nargin ~= 1
        error('Usage: cfStruct = convertToStruct(CFObj)');
    end

    for i = 1:length(CFParams)
        paramClass = CFParams(i).paramClass;
        paramName = CFParams(i).paramName;
        paramVal = CFParams(i).paramVal;

        cfStruct.(paramClass).(paramName) = paramVal;
    end



function GiveBackTheScreen(prej)

    if nargin == 0
        prej = false;
    end
    if prej
        fprintf('\n\nTerminated with extreme prejudice!\n');
    end
    Priority(0);
    Screen('CloseAll');
    ShowCursor;
    ListenChar;



function [TRtime, respTime, respKey] = WaitForTimeoutAndListenToRespOrTR(t0, intervalDuration, respStatus)
    %
    %t0: time when the function was called
    %intervalDuration (in ms)

    FlushEvents;

    TRtime = NaN;
    respTime = NaN;
    respKey = NaN;
    t_key = KbName('t');
    resp_key = [KbName('r'),KbName('g'),KbName('y'),KbName('b')];

    while (GetSecs()-t0) < intervalDuration/1000
        % Check all keyboards and keypads (-3) status
        [keyIsDown, secs, keyCode, ~] = KbCheck(-3);
        if keyIsDown % If *any* key is down
            % If t is one of the keys being pressed
            if isnan(TRtime) && ismember(t_key,find(keyCode))
                TRtime = secs;
                fprintf('*** T received ***\n');
            end
            % If any response key is one of the keys being pressed
            if isnan(respTime) && any(ismember(resp_key,find(keyCode))) && (respStatus==0)
                respTime = secs;
                respKey = KbName(resp_key(ismember(resp_key,find(keyCode,1))));
                fprintf('*** Key pressed: %c ***\n',respKey);
            end
            % If q is one of the keys being pressed  
            if ismember(KbName('q'),find(keyCode))
                error('Experimenter pressed q to terminate.');
            end
        end
    end
        
        

function [TRtime, respTime, respKey] = WaitForTRAndListenToResp(t0, intervalDuration, respStatus)
    %
    %t0: time when the function was called
    %intervalDuration (in ms)

    FlushEvents;

    TRtime = NaN;
    respTime = NaN;
    respKey = NaN;
    t_key = KbName('t');
    resp_key = [KbName('r'),KbName('g'),KbName('y'),KbName('b')];

    while (GetSecs()-t0) < intervalDuration/1000
        % Check all keyboards and keypads (-3) status
        [keyIsDown, secs, keyCode, ~] = KbCheck(-3);
        if keyIsDown % If *any* key is down
            % If t is one of the keys being pressed
            if ismember(t_key,find(keyCode))
                TRtime = secs;
                fprintf('*** T received ***\n');
                break
            end
            % If any response key is one of the keys being pressed
            if isnan(respTime) && any(ismember(resp_key,find(keyCode))) && (respStatus==0)
                respTime = secs;
                respKey = KbName(resp_key(ismember(resp_key,find(keyCode,1))));
                fprintf('*** Key pressed: %c ***\n',respKey);
            end
            % If q is one of the keys being pressed  
            if ismember(KbName('q'),find(keyCode))
                error('Experimenter pressed q to terminate.');
            end
        end
    end



function TRtime = WaitForT()
    %
    %t0: time when the function was called
    %intervalDuration (in ms)

    FlushEvents;

    TRtime = NaN;
    t_key = KbName('t');

    while 1
        % Check all keyboards and keypads (-3) status
        [keyIsDown, secs, keyCode, ~] = KbCheck(-3);
        if keyIsDown % If *any* key is down
            % If t is one of the keys being pressed
            if ismember(t_key,find(keyCode))
                TRtime = secs;
                fprintf('*** T received ***\n');
                break
            end
            % If q is one of the keys being pressed  
            if ismember(KbName('q'),find(keyCode))
                error('Experimenter pressed q to terminate.');
            end
        end
    end



function displayText(window, filename, linespacing, fontsize, fontcolor)
    % draws the text in file <filename> to the screen.
    % <filename> must have no empty lines.
    % Include a space if an empty line is desired
    textfid=fopen(filename);
    lCounter = 1;
    Screen(window,'TextSize',fontsize);

    while 1
        tline = fgetl(textfid);
        if ~ischar(tline), break, end

        if tline(1) ~= '.'
            Screen(window, 'DrawText',tline, 50, 50 + (lCounter-1)*linespacing, fontcolor);
        end
        lCounter = lCounter + 1;
    end
    fclose(textfid);
    Screen(window,'Flip');



function id = subjectId(initials)
    % SUBJECTID  create an Aguirre lab subject identifier
    %    id = subjectid(initials) where initials is 'AZ' and the current date
    %    is 25 December 2008 returns the string 'A122508Z'
    %
    % 2007 ddrucker@psych.upenn.edu

    initials=strtrim(initials);
    if length(initials) ~= 2
        error('Expected two letters for initials');
    end

    id = upper([initials(1) datestr(now,'mmddyy') initials(2)]);
    return


    
function data = GetInput(inputString, inputType, inputDims)
    % data = GetInput(inputString, [inputType], [inputDims])
    %
    % Description:
    % Gets user input from the command line.
    %
    % Required Input:
    % inputString (string) - The query that will be shown to the users.
    %    Example: 'Enter your selection'.
    %
    % Optional Inputs:
    % inputType (string) - Can be either 'number' or 'string'.  Defaults to
    %    'number'.
    % inputDims (integer vector) - For an inputType of 'string', this represents the
    %    limits on the size of the input string.  Defaults to [1,256].  For
    %    'number', this represents the number of elements in the inputted vector.
    %    Defaults to 1.  This value can also be -1, which implies that any input
    %    is accepted.
    %
    % Output:
    % data (string|vector) - The inputted string or vector.
    %
    % Example:
    % data = GetInput('Please Insert a Number', 'number', 2);
    % Please Insert a Number: <user input goes here>

    if nargin < 1 || nargin > 3
        error('Usage: data = GetInput(inputString, inputType, inputDims)');
    end

    % Setup some defaults.
    if nargin == 1
        inputType = 'number';
        inputDims = 1;
    end

    % Make sure inputType is valid.
    if ~any(strcmp(inputType, {'number', 'string'}))
        error('*** Invalid inputType, must choose ''number'' or ''string''');
    end

    % Make sure the input dimensions are valid
    switch inputType
        case 'number'
            if ~exist('inputDims', 'var')
                inputDims = 1;
            end

            % Make sure inputDims is a single scalar.
            if ~isscalar(inputDims)
                error('*** Invalid inputDims, must be a single scalar for type ''number''');
            end

        case 'string'
            % Setup the default string length if it wasn't specified.
            if nargin < 3
                inputDims = [1, 256];
            else
                % Make sure inputDims is a 1x2 matrix.
                if ~all(size(inputDims) == 1:2)
                    error('*** Invalid inputDims, must be of form [x,y] for type ''string''');
                end
            end
    end

    % Grab the data from the user.  Loop until the data is valid.
    inputString = [inputString, ': '];
    keepLooping = true;
    while keepLooping
        if strcmp(inputType, 'number')
            data = str2num(input(inputString, 's')); %#ok<ST2NM>

            % inputDims of -1 implies we'll take anyingthing as input.
            if inputDims == -1
                keepLooping = false;
            else
                if numel(data) == inputDims
                    keepLooping = false;
                else
                    beep;
                    fprintf('*** Invalid entry, must be a vector of length %d.\n', inputDims);
                end
            end
        else
            data = input(inputString, 's');

            lenData = length(data);
            if lenData >= inputDims(1) && lenData <= inputDims(2)
                keepLooping = false;
            else
                beep;
                fprintf('*** Invalid entry, must be a string >= %d and <= %d in length\n', inputDims(1), inputDims(2));
            end
        end
    end
    
    
    
function progressBarStr = progressBar(TRstatus, respTime, correctResp, trial)
    % Generate progress bar strings with TR status and responses given
    
    numCharPerLine = 120;
    numCharb4current = 10;
    
    % Convert TRstatus vector to a string
    TRstatusStr = num2str(~isnan(TRstatus));
    % Eliminate spaces
    TRstatusStr = TRstatusStr(TRstatusStr~=' ');
    TRstatusStr(TRstatusStr=='1') = 'T';
    TRstatusStr(TRstatusStr=='0') = '.';
    
    respStatusStr = blanks(length(respTime));
    respStatusStr(:) = '.';
    respStatusStr(find([ones(1,trial) zeros(1,length(respTime)-trial)])) = '*';
    respStatusStr(and(~isnan(respTime), correctResp)) = '!';
    respStatusStr(and((~isnan(respTime) ~= correctResp), [ones(1,trial) zeros(1,length(respTime)-trial)])) = 'X';
    respStatusStr(and((~isnan(respTime) ~= correctResp), [zeros(1,trial) ones(1,length(respTime)-trial)])) = '?';
    
    progressBarStr = sprintf(['----------------------------------\n' TRstatusStr]);
    
    if numCharPerLine < length(respTime)
        if trial <= numCharb4current
            progressBarStr = [progressBarStr '\n' respStatusStr(1:numCharPerLine)];
        elseif trial < (length(respTime) - (numCharPerLine-1))
            progressBarStr = [progressBarStr '\n' respStatusStr((trial-(numCharb4current-1)):(trial + (numCharPerLine-numCharb4current)))];
        else
            progressBarStr = [progressBarStr '\n' respStatusStr((length(respTime) - (numCharPerLine-1)):end)];
        end
    else
        progressBarStr = [progressBarStr '\n' respStatusStr];
    end
    
    progressBarStr = [progressBarStr '\n----------------------------------\n'];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
