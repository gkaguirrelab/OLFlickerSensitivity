function MakeCovariatesFSL(basePath, subjID, protocol)
% MakeCovariatesFSL(basePath, subjID, protocol)
%
% Wrapper that makes covariates base on data output files.
%
% Input:    basePath - base path of data (without protocol)
%           subjID - subject ID
%           protocol - protocol used in data

% Construct the data directory. This is expected to be
% basePath/protocol/subjID, e.g.
% .../SustainedResponse/G100813A, etc.
theDataDir = fullfile(basePath, protocol, subjID);

% List all the files
theFiles = dir(fullfile(theDataDir, ['*' protocol '*.mat']));

if length(theFiles) == 0
    fprintf('*** NO FILES FOUND ***');
end

% Iterate over each of the files to get the covariates
for f = 1:length(theFiles)
    MakeCovariateFiles(fullfile(theDataDir, theFiles(f).name), subjID, protocol)
end


function MakeCovariateFiles(filePath, subjID, protocol)
% MakeCovariateFiles(filePath, subjID, protocol)
%
% Makes covariates based on data files
%
% Input:    filePath - full path
%           protocol - protocol used in data
%
% Available protocols:
%   - SSMRI-Pilot
%   - SSMRI-SustainedResponse

switch protocol
    case 'Pilot'
        % Define directions
        directions = {'Background', 'Isochromatic', 'MelanopsinDirected'};
        
        % Extract the time stamps of each block
        load(filePath);
        
        % Output prefix
        [fileDir, fileName] = fileparts(filePath);
        
        % Normalize with respect to block start ('t')
        startTrials = params.responseStruct.tTrialStart - params.responseStruct.tBlockStart;
        endTrials = params.responseStruct.tTrialEnd - params.responseStruct.tBlockStart;
        
        % Extract the trial order
        trialOrder = {params.cacheFileName{params.directionTrials}};
        
        % Get rid of the 'SSMRI' prefix.
        trialOrder = cellfun(@(t) t(7:end), trialOrder, 'UniformOutput', false);
        
        % Make a 'covariates' folder
        covDir = fullfile(fileDir, 'covariates');
        if ~exist(covDir);
            mkdir(covDir);
        end
        
        % Construct melanopsin covariate
        ind = find(ismember(trialOrder,'MelanopsinDirected'));
        covariates = [startTrials(ind)' (endTrials(ind)-startTrials(ind))' ones(size(startTrials(ind)'))];
        dlmwrite(fullfile(covDir, [fileName '-cov_MelanopsinDirected.csv']), covariates, '\t');
        
        % Construct isochromatic covariate
        ind = find(ismember(trialOrder,'Isochromatic'));
        covariates = [startTrials(ind)' (endTrials(ind)-startTrials(ind))' ones(size(startTrials(ind)'))];
        dlmwrite(fullfile(covDir, [fileName '-cov_Isochromatic.csv']), covariates, '\t');
    case 'SustainedResponse'
        % Define directions
        directions = {'SSMRI-Background', 'SSMRI-Isochromatic', 'SSMRI-MelanopsinDirected'};
        
        % Extract the time stamps of each block
        load(filePath);
        
        % Output prefix
        [fileDir, fileName] = fileparts(filePath);
        
        % Normalize with respect to block start ('t')
        startTrials = params.responseStruct.tTrialStart - params.responseStruct.tBlockStart;
        endTrials = params.responseStruct.tTrialEnd - params.responseStruct.tBlockStart;
        
        % Extract the trial order
        trialOrder = {params.cacheFileName{params.directionTrials}};
        
        % Get rid of the 'SSMRI' prefix.
        trialOrder = cellfun(@(t) t(7:end), trialOrder, 'UniformOutput', false);
        
        % Make a 'covariates' folder
        covDir = fullfile(fileDir, 'covariates');
        if ~isdir(covDir);
            mkdir(covDir);
        end
        
        %% Construct isochromatic covariate
        ind = find(ismember(trialOrder,'Isochromatic'));
        covariates = [startTrials(ind)' (endTrials(ind)-startTrials(ind))' ones(size(startTrials(ind)'))];
        dlmwrite(fullfile(covDir, [fileName '-cov_Isochromatic.csv']), covariates, '\t');
        
        % Check if wer're running a melanopsin or LM directed modulation
        % baed on the file name of the pre-cache file
        if ~isempty(strfind(params.preCacheFile, 'Mel'))
            %% Construct melanopsin DC covariate
            ind = find(ismember(trialOrder,'MelanopsinDirected'));
            covariates = [startTrials(ind)' (endTrials(ind)-startTrials(ind))' ones(size(startTrials(ind)'))];
            dlmwrite(fullfile(covDir, [fileName '-cov_MelanopsinDirected-DC.csv']), covariates, '\t');
            
            % Construct the sine for melanopsin (f)
            deltaT = 1;
            timeVector = startTrials(ind):deltaT:endTrials(ind);
            timeVectorNormalized = timeVector - timeVector(1);
            signalVector = sin(2*pi*params.frequencyTrials(ind)*timeVectorNormalized + deg2rad(params.phase(ind))); % Remove the phase
            covariates = [timeVector' repmat(deltaT, 1, length(timeVector))' signalVector'];
            dlmwrite(fullfile(covDir, [fileName '-cov_MelanopsinDirected-Sine.csv']), covariates, '\t');
            
            % Construct the cosine for melanopsin (f)
            deltaT = 1;
            timeVector = startTrials(ind):deltaT:endTrials(ind);
            timeVectorNormalized = timeVector - timeVector(1);
            signalVector = cos(2*pi*params.frequencyTrials(ind)*timeVectorNormalized + deg2rad(params.phase(ind))); % Remove the phase
            covariates = [timeVector' repmat(deltaT, 1, length(timeVector))' signalVector'];
            dlmwrite(fullfile(covDir, [fileName '-cov_MelanopsinDirected-Cosine.csv']), covariates, '\t');
            
            % Construct the sine for melanopsin (2f)
            deltaT = 1;
            timeVector = startTrials(ind):deltaT:endTrials(ind);
            timeVectorNormalized = timeVector - timeVector(1);
            signalVector = sin(2*pi*2*params.frequencyTrials(ind)*timeVectorNormalized + deg2rad(params.phase(ind))); % Remove the phase
            covariates = [timeVector' repmat(deltaT, 1, length(timeVector))' signalVector'];
            dlmwrite(fullfile(covDir, [fileName '-cov_MelanopsinDirected-SineHarmonic.csv']), covariates, '\t');
            
            % Construct the cosine for melanopsin (2f)
            deltaT = 1;
            timeVector = startTrials(ind):deltaT:endTrials(ind);
            timeVectorNormalized = timeVector - timeVector(1);
            signalVector = cos(2*pi*2*params.frequencyTrials(ind)*timeVectorNormalized + deg2rad(params.phase(ind))); % Remove the phase
            covariates = [timeVector' repmat(deltaT, 1, length(timeVector))' signalVector'];
            dlmwrite(fullfile(covDir, [fileName '-cov_MelanopsinDirected-CosineHarmonic.csv']), covariates, '\t');
        elseif ~isempty(strfind(params.preCacheFile, 'LMDirected'))
            %% Construct L+M DC covariate
            ind = find(ismember(trialOrder,'LMDirected'));
            covariates = [startTrials(ind)' (endTrials(ind)-startTrials(ind))' ones(size(startTrials(ind)'))];
            dlmwrite(fullfile(covDir, [fileName '-cov_LMDirected-DC.csv']), covariates, '\t');
            
            % Construct the sine for L+M (f)
            deltaT = 1;
            timeVector = startTrials(ind):deltaT:endTrials(ind);
            timeVectorNormalized = timeVector - timeVector(1);
            signalVector = sin(2*pi*params.frequencyTrials(ind)*timeVectorNormalized + deg2rad(params.phase(ind))); % Remove the phase
            covariates = [timeVector' repmat(deltaT, 1, length(timeVector))' signalVector'];
            dlmwrite(fullfile(covDir, [fileName '-cov_LMDirected-Sine.csv']), covariates, '\t');
            
            % Construct the cosine for L+M (f)
            deltaT = 1;
            timeVector = startTrials(ind):deltaT:endTrials(ind);
            timeVectorNormalized = timeVector - timeVector(1);
            signalVector = cos(2*pi*params.frequencyTrials(ind)*timeVectorNormalized + deg2rad(params.phase(ind))); % Remove the phase
            covariates = [timeVector' repmat(deltaT, 1, length(timeVector))' signalVector'];
            dlmwrite(fullfile(covDir, [fileName '-cov_LMDirected-Cosine.csv']), covariates, '\t');
            
            % Construct the sine for L+M (2f)
            deltaT = 1;
            timeVector = startTrials(ind):deltaT:endTrials(ind);
            timeVectorNormalized = timeVector - timeVector(1);
            signalVector = sin(2*pi*2*params.frequencyTrials(ind)*timeVectorNormalized + deg2rad(params.phase(ind))); % Remove the phase
            covariates = [timeVector' repmat(deltaT, 1, length(timeVector))' signalVector'];
            dlmwrite(fullfile(covDir, [fileName '-cov_LMDirected-SineHarmonic.csv']), covariates, '\t');
            
            % Construct the cosine for L+M (2f)
            deltaT = 1;
            timeVector = startTrials(ind):deltaT:endTrials(ind);
            timeVectorNormalized = timeVector - timeVector(1);
            signalVector = cos(2*pi*2*params.frequencyTrials(ind)*timeVectorNormalized + deg2rad(params.phase(ind))); % Remove the phase
            covariates = [timeVector' repmat(deltaT, 1, length(timeVector))' signalVector'];
            dlmwrite(fullfile(covDir, [fileName '-cov_LMDirected-CosineHarmonic.csv']), covariates, '\t');
        end
    case 'TicklerLocalizer'
        % In the Tickler protocol, we have 7m24s runs, with 30s off, 30s on
        % (with off leading). This was timed by hand during the experiment.
        % We are constructing this here.
        %
        % To start with, the tickler has a delay between hitting the on
        % switch and the device actually turning. We have measured this
        % (2/11/14) to be
        onsetDelaySecs = 2;
        
        % There is similarly a delay when turning it off, which we have
        % measured (2/11/14).
        offsetDelaySecs = 2;
        
        % There are six periods in which the tickler was turned on:
        % 0:30-1:00
        % 1:30-2:00
        % 2:30-3:00
        % 3:30-4:00
        % 4:30-5:00
        % 6:30-7:00
        %
        % And there are 14 total periods.
        %
        % The delay between the onset of each period is 60 s.
        delayBetweenPeriodSecs = 60;
        durationSecs = 30;
        nPeriods = floor((7*60+24)/30);
        c = 1;
        for i = 2:2:nPeriods
            % Correct for the onset delay by adding onsetDelays in startTrials
            startTrials(c) = (i-1)*durationSecs+onsetDelaySecs;
            % Correct for offset delay by adding offsetDelays in durations
            durationTrials(c) = (durationSecs+offsetDelaySecs-onsetDelaySecs);
            c = c+1;
        end
        
        % Output prefix
        [~, subjID] = fileparts(filePath);
        
        % Make a 'covariates' folder
        covDir = fullfile(filePath, 'covariates');
        if ~exist(covDir);
            mkdir(covDir);
        end
        covariates = [startTrials' durationTrials' ones(size(startTrials'))];
        dlmwrite(fullfile(covDir, [subjID '-cov.csv']), covariates, '\t');
        
    case 'TTFMRFlicker'
        % Define directions
        theFrequenciesHz = [0, 1, 2, 4, 8, 16];
        
        % Extract the time stamps of each block
        load(filePath);
        
        % Output prefix
        [fileDir, fileName] = fileparts(filePath);
        
        % Make a 'covariates' folder
        covDir = fullfile(fileDir, 'covariates');
        if ~exist(covDir);
            mkdir(covDir);
        end
        
        % Remove the TRs associated with the first trial to burn
        params.theFrequencyIndices(1) = -1;

        
        
        % Iterate over the frequencies to produce box car; the first
        % frequency is 0 Hz (= background), so we skip that.
        for f = 2:length(theFrequenciesHz)
            startTrials = [params.responseStruct.events(params.theFrequencyIndices == f).tTrialStart] - params.responseStruct.tBlockStart;
            endTrials = [params.responseStruct.events(params.theFrequencyIndices == f).tTrialEnd] - params.responseStruct.tBlockStart;
           
            % Construct the tickler covariate
            covariates = [startTrials' (endTrials-startTrials)' ones(size(startTrials'))];
            dlmwrite(fullfile(covDir, [fileName '-cov_' num2str(theFrequenciesHz(f)) 'Hz.csv']), covariates, '\t');
        end
        
                theDirection = allwords(params.modulationFiles, '-');
        theDirectionLabel = theDirection{2};
                fid = fopen(fullfile(covDir, [fileName '.txt']), 'w');
        fprintf(fid, '%s', theDirectionLabel);
        fclose(fid);
    case 'MTLocalizer'
        % Load the file
        load(filePath);
        
        % Output prefix
        [fileDir, fileName] = fileparts(filePath);
        
        % Figure out what the start and end events
        for i = 1:length(params.events)
            startTrials(i) = params.events(i).tTrialStart;
            endTrials(i) = params.events(i).tTrialEnd;
            val(i) = params.events(i).val;
        end
        
        % Set the first start to 0, this corresponds the receipt of the
        % first 't'.
        endTrials = endTrials - startTrials(1);
        startTrials = startTrials - startTrials(1);
        
        % Get rid of the stationary trials, as indicated by val ==1
        startTrials = startTrials(val == 1);
        endTrials = endTrials(val == 1);
        
        % Make a 'covariates' folder
        covDir = fullfile(fileDir, 'covariates');
        if ~exist(covDir);
            mkdir(covDir);
        end
        
        % Construct covariates
        covariates = [startTrials' (endTrials-startTrials)' ones(size(startTrials'))];
        dlmwrite(fullfile(covDir, [fileName '-cov.csv']), covariates, '\t');
    case 'FOBSLocalizer'
        % Load the data
        load(filePath);
        
        % Output prefix
        [fileDir, fileName] = fileparts(filePath);
        
        % Make a 'covariates' folder
        covDir = fullfile(fileDir, 'covariates');
        if ~exist(covDir);
            mkdir(covDir);
        end
        
        % Obtain the trial type and get rid of all of the repeat trials. We
        % do not particularly care about them apart from the attention
        % task. So, in the variable that holds the trial type, we replace *
        % at position i with the letter at position i-1.
        theTrialType = params.sequence.trialType;
        theIndices = strfind(theTrialType, '*');
        theTrialType(theIndices) = theTrialType(theIndices-1);
        
        % Figure out when the block type changes. We do that by comparing i
        % with i-1.
        c = 1;
        for i = 2:length(theTrialType)
            if ~strcmp(theTrialType(i), theTrialType(i-1));
                theBlockOnsetIndex(c) = i;
                c = c+1;
            end
        end
        
        % Retrieve the trial types
        theBlockType = theTrialType(theBlockOnsetIndex);
        
        % Normalize time with the scan start
        t0 = data.timing.scanStart;
        theBlockOnsetTimes = data.timing.trialOnset(theBlockOnsetIndex) - t0;
        
        % Figure out the durations of each block
        for i = 1:length(theBlockOnsetTimes)-1
            theBlockDurations(i) = theBlockOnsetTimes(i+1)-theBlockOnsetTimes(i);
        end
        
        % Get rid of the '-' blocks.
        c = 1;
        for i = 1:length(theBlockType)
            if ~strcmp(theBlockType(i), '-')
                theBlockTypeTmp(c) = theBlockType(i);
                theBlockOnsetTimesTmp(c) = theBlockOnsetTimes(i);
                theBlockDurationsTmp(c) = theBlockDurations(i);
                c = c+1;
            end
        end
        theBlockType = theBlockTypeTmp;
        theBlockOnsetTimes = theBlockOnsetTimesTmp;
        theBlockDurations = theBlockDurationsTmp;
        
        % Iterate over the unique block types
        theUniqueBlockTypes = unique(theBlockType);
        
        % Save out the stuff for each block type
        for i = 1:length(theUniqueBlockTypes)
            theIndices = strfind(theBlockType, theUniqueBlockTypes(i));
            covariates = [theBlockOnsetTimes(theIndices)' theBlockDurations(theIndices)' ones(length(theIndices), 1)];
            dlmwrite(fullfile(covDir, [fileName '-' theUniqueBlockTypes(i) '-cov.csv']), covariates, '\t');
        end
    case {'TTFMRFlickerX', 'TTFMRFlickerY', 'TTFMRFlickerYs', 'TTFMRFlickerPurkinje', 'TTFMRFlickerLMS'}
        % Load the data
        load(filePath);
        
        % Output prefix
        [fileDir, fileName] = fileparts(filePath);
        
        % Extract direction
        theDirection = allwords(params.modulationFiles, '-');
        theDirectionLabel = theDirection{2};
        
        nSegments = length(params.responseStruct.events);
        
        WITHSPIKES = false;
        if WITHSPIKES
            % Also load in the file which gives the path to the spike file
            fid = fopen(fullfile(fileDir, [fileName '.spikes']));
            tmp = textscan(fid, '%s');
            locationSpikeFile = char(tmp{1});
            
            % Set up some parameters
            trInSecs = 3;
            nTRs = 196;
            trTimesStart = 0:trInSecs:((nTRs-1)*trInSecs);
            trTimesEnd = trInSecs:trInSecs:(nTRs*trInSecs);
            M = dlmread(locationSpikeFile, ' ');
            M = sum(M, 2);
            
            % Extract and flag the spikes
            theSpikes = find(M);
            
            
            for i = 1:nSegments
                for j = 1:length(theSpikes)
                    spikeOn(i, j) = (round(params.responseStruct.events(i).tTrialStart-params.responseStruct.tBlockStart) <= trTimesStart(theSpikes(j))) &&  ((trTimesStart(theSpikes(j))) <= round(params.responseStruct.events(i).tTrialEnd-params.responseStruct.tBlockStart));
                end
            end
            spike = logical(sum(spikeOn, 2))';
        else
            spike = zeros(1, nSegments);
        end
        
        % Make a 'covariates' folder
        covDir = fullfile(fileDir, 'covariates');
        if ~exist(covDir);
            mkdir(covDir);
        end
        
        % Iterate over the segments and count analyze accuracy
        nSegments = length(params.responseStruct.events);
        for i = 1:nSegments
            % Check if there was a blank in the segment
            if params.responseStruct.events(i).attentionTask.segmentFlag == 1
                attentionTaskFlag(i) = 1;
            else
                attentionTaskFlag(i) = 0;
            end
            % Check if the subject responded in the segment with a key
            % press
            if ~isempty(params.responseStruct.events(i).buffer)
                responseDetection(i) = 1;
            else
                responseDetection(i) = 0;
            end
            
            % Recode as hit rates, misses and false alarm
            if (attentionTaskFlag(i) == 1) && (responseDetection(i) == 1)
                hit(i) = 1;
            else
                hit(i) = 0;
            end
            
            if (attentionTaskFlag(i) == 1) && (responseDetection(i) == 0)
                miss(i) = 1;
            else
                miss(i) = 0;
            end
            
            if (attentionTaskFlag(i) == 0) && (responseDetection(i) == 1)
                falseAlarm(i) = 1;
            else
                falseAlarm(i) = 0;
            end
        end
        
        % Display accuracy
        fprintf('Subject %s - HR: %.2f (%g/%g) / FA: %.2f \n', exp.subject, sum(hit)/sum(attentionTaskFlag), sum(hit), sum(attentionTaskFlag), sum(falseAlarm)/sum(attentionTaskFlag));
        
        fid = fopen([exp.subject(1) exp.subject(end) '_discard.csv'], 'a');
        fprintf(fid,'%s,%g,%g\n', exp.subject, sum(attentionTaskFlag)-sum(hit),sum(attentionTaskFlag));
        fclose(fid);
        
        %% Figure out the onsets
        % Define frequencies
        switch protocol
            case 'TTFMRFlickerX'
                theFrequenciesHz = [0, 2, 4, 8, 16, 32, 64];
            case 'TTFMRFlickerYs'
                theFrequenciesHz = [0, 0.5, 1, 2];
            case 'TTFMRFlickerY'
                theFrequenciesHz = [0, 2, 4, 8, 16, 32, 64];
            case 'TTFMRFlickerPurkinje'
                switch theDirectionLabel
                    case {'LMDirectedScaled', 'LMPenumbraDirected'}
                        theFrequenciesHz = [0, 2, 4, 8, 16, 32, 64];
                    case {'sLMDirectedScaled', 'sLMPenumbraDirected'}
                        theFrequenciesHz = [0, 0.5, 1, 2];
                end
            case 'TTFMRFlickerLMS'
                switch theDirectionLabel
                    case {'LMSDirected'}
                        theFrequenciesHz = [0, 2, 4, 8, 16, 32, 64];
                    case {'sLMSDirected'}
                        theFrequenciesHz = [0, 0.5, 1, 2];
                end
                
        end
        
        % Iterate over the frequencies to produce box car; the first
        % frequency is 0 Hz (= background), so we skip that.
        for f = 1:length(theFrequenciesHz)
            % Hits
            startTrials = [params.responseStruct.events((params.theFrequencyIndices == f) & ~miss & ~spike).tTrialStart] - params.responseStruct.tBlockStart;
            endTrials = [params.responseStruct.events((params.theFrequencyIndices == f) & ~miss & ~spike).tTrialEnd] - params.responseStruct.tBlockStart;
            
            % Construct the tickler covariate
            covariates = [startTrials' (endTrials-startTrials)' ones(size(startTrials'))];
            
            % In case no segments fall into the category, write out the
            % empty covariate as a 3-column vector.
            if isempty(covariates)
                covariates = [0 0 0];
            end
            dlmwrite(fullfile(covDir, [fileName '-cov_' num2str(theFrequenciesHz(f)) 'Hz_valid.csv']), covariates, '\t');
            
            % Miss
            startTrials = [params.responseStruct.events((params.theFrequencyIndices == f) & (miss | spike)).tTrialStart] - params.responseStruct.tBlockStart;
            endTrials = [params.responseStruct.events((params.theFrequencyIndices == f) & (miss | spike)).tTrialEnd] - params.responseStruct.tBlockStart;
            
            % Construct the tickler covariate
            covariates = [startTrials' (endTrials-startTrials)' ones(size(startTrials'))];
            
            % In case no segments fall into the category, write out the
            % empty covariate as a 3-column vector.
            if isempty(covariates)
                covariates = [0 0 0];
            end
            dlmwrite(fullfile(covDir, [fileName '-cov_' num2str(theFrequenciesHz(f)) 'Hz_invalid.csv']), covariates, '\t');
        end
        
        % Make the blank-spike covariates
        c = 1; % Make a counter
        for i = 1:nSegments % Iterate over the segments
            if params.responseStruct.events(i).attentionTask.segmentFlag
                onsetTime(c) = params.responseStruct.events(i).t(find(params.responseStruct.events(i).attentionTask.T == 1)) - params.responseStruct.tBlockStart;
                offsetTime(c) = params.responseStruct.events(i).t(find(params.responseStruct.events(i).attentionTask.T == -1)) - params.responseStruct.tBlockStart;
                c = c+1;
            end
        end
        
        covariates = [onsetTime' (offsetTime-onsetTime)' ones(size(onsetTime'))];
        dlmwrite(fullfile(covDir, [fileName '-cov_attentionTask.csv']), covariates, '\t');
        
        % Save the direction to the file
        fid = fopen(fullfile(covDir, [fileName '.txt']), 'w');
        fprintf(fid, '%s', theDirection{2});
        fclose(fid);
        
    case {'TTFMRFlickerLightFluxControl', 'TTFMRFlickerNulled', 'MRLightFlux' 'TTFMRFlickerNulledMelanopsinHighContrast' 'EntopticPerceptsAlphaRhythmFlicker'}
        % Load the data
        load(filePath);
        
        % Output prefix
        [fileDir, fileName] = fileparts(filePath);
        nSegments = length(params.responseStruct.events);
        
        WITHSPIKES = false;
        if WITHSPIKES
            % Also load in the file which gives the path to the spike file
            fid = fopen(fullfile(fileDir, [fileName '.spikes']));
            tmp = textscan(fid, '%s');
            locationSpikeFile = char(tmp{1});
            
            % Set up some parameters
            trInSecs = 3;
            nTRs = 196;
            trTimesStart = 0:trInSecs:((nTRs-1)*trInSecs);
            trTimesEnd = trInSecs:trInSecs:(nTRs*trInSecs);
            M = dlmread(locationSpikeFile, ' ');
            M = sum(M, 2);
            
            % Extract and flag the spikes
            theSpikes = find(M);
            
            
            for i = 1:nSegments
                for j = 1:length(theSpikes)
                    spikeOn(i, j) = (round(params.responseStruct.events(i).tTrialStart-params.responseStruct.tBlockStart) <= trTimesStart(theSpikes(j))) &&  ((trTimesStart(theSpikes(j))) <= round(params.responseStruct.events(i).tTrialEnd-params.responseStruct.tBlockStart));
                end
            end
            spike = logical(sum(spikeOn, 2))';
        else
            spike = zeros(1, nSegments);
        end
        
        % Make a 'covariates' folder
        covDir = fullfile(fileDir, 'covariates');
        if ~exist(covDir);
            mkdir(covDir);
        end
        
        % Iterate over the segments and count analyze accuracy
        for i = 1:nSegments
            % Check if there was a blank in the segment
            if params.responseStruct.events(i).attentionTask.segmentFlag == 1
                attentionTaskFlag(i) = 1;
            else
                attentionTaskFlag(i) = 0;
            end
            % Check if the subject responded in the segment with a key
            % press
            if ~isempty(params.responseStruct.events(i).buffer)
                responseDetection(i) = 1;
            else
                responseDetection(i) = 0;
            end
            
            % Recode as hit rate, misses and false alarm
            if (attentionTaskFlag(i) == 1) && (responseDetection(i) == 1)
                hit(i) = 1;
            else
                hit(i) = 0;
            end
            
            if (attentionTaskFlag(i) == 1) && (responseDetection(i) == 0)
                miss(i) = 0;
            else
                miss(i) = 0;
            end
            
            if (attentionTaskFlag(i) == 0) && (responseDetection(i) == 1)
                falseAlarm(i) = 1;
            else
                falseAlarm(i) = 0;
            end
            
        end
        
        % Display accuracy
        fprintf('Subject %s - HR: %.2f (%g/%g) / FA: %.2f \n', exp.subject, sum(hit)/sum(attentionTaskFlag), sum(hit), sum(attentionTaskFlag), sum(falseAlarm)/(nSegments-sum(attentionTaskFlag)));
        
%         %% Figure out the onsets
%         % Define directions
%         switch protocol
%             case 'TTFMRFlickerNulled'
%                 theDirections = {'Background', 'MelanopsinDirectedNulled', 'MelanopsinDirectedUnnulled', 'NulledResidualSplatter'};
%             case {'TTFMRFlickerLightFluxControl' 'MRLightFlux' 'EntopticPerceptsAlphaRhythmFlicker'}
%                 theDirections = {'Background', 'LightFlux' 'Modulation-LightFlux-12sWindowedFrequencyModulation10_0Hz-32' 'Modulation-LightFlux-12sWindowedFrequencyModulation10_0Hz-32'};
%             case {'TTFMRFlickerNulledMelanopsinHighContrast'}
%                 theDirections = {'Background' 'MelanopsinDirectedLegacyNulled' 'LMSDirectedNulled' 'LightFlux'};
%             otherwise
%                 theDirections = {'Background', 'MelanopsinDirectedEquivContrastRobust', 'MelanopsinDirectedRobust', 'RodDirected', 'OmniSilent'};
%         end
%         
%         % Find the indices of these directions in the cacheFIleNames
%         for d = 1:length(theDirections)
%             tmp = strfind(params.cacheFileName,theDirections{d});
%             theDirectionsNum(d) = find(~cellfun(@isempty,tmp));
%         end
%         
%         %% Take care of the special case of G040414A. Here, there was a bug that prevent from the correct sequence being loaded.
%         % This caused the same sequence to come up over all trials. The
%         % sequence was:
%         if strcmp(subjID, 'G040414A') || strcmp(subjID, 'M040414S');
%             fprintf('Overriding directions in file.\n');
%             params.theDirections = [4 1 5 3 1 1 4 3 3 4 2 4 5 1 3 2 1 2 5 5 2 2 3 5 4];
%         end
%         
%         % Iterate over the directions to produce box car; the first
%         % direction is background, so we skip that.
%         for d = 1:length(theDirections)
%             % Hit
%             startTrials = [params.responseStruct.events((params.theDirections == theDirectionsNum(d)) & ~miss & ~spike).tTrialStart] - params.responseStruct.tBlockStart;
%             endTrials = [params.responseStruct.events((params.theDirections == theDirectionsNum(d)) & ~miss & ~spike).tTrialEnd] - params.responseStruct.tBlockStart;
%             
%             % Construct the tickler covariate
%             covariates = [startTrials' (endTrials-startTrials)' ones(size(startTrials'))];
%             dlmwrite(fullfile(covDir, [fileName '-cov_' theDirections{d} '_valid.csv']), covariates, '\t');
%             
%             % Miss
%             startTrials = [params.responseStruct.events((params.theDirections == theDirectionsNum(d)) & (miss | spike)).tTrialStart] - params.responseStruct.tBlockStart;
%             endTrials = [params.responseStruct.events((params.theDirections == theDirectionsNum(d)) & (miss | spike)).tTrialEnd] - params.responseStruct.tBlockStart;
%             
%             % Construct the tickler covariate
%             covariates = [startTrials' (endTrials-startTrials)' ones(size(startTrials'))];
%             % In case no segments fall into the category, write out the
%             % empty covariate as a 3-column vector.
%             if isempty(covariates)
%                 covariates = [0 0 0];
%             end
%             
%             
%             dlmwrite(fullfile(covDir, [fileName '-cov_' theDirections{d} '_invalid.csv']), covariates, '\t');
%         end
%         
%         % Make the blank-spike covariates
%         c = 1; % Make a counter
%         for i = 1:nSegments % Iterate over the segments
%             if params.responseStruct.events(i).attentionTask.segmentFlag
%                 onsetTime(c) = params.responseStruct.events(i).t(find(params.responseStruct.events(i).attentionTask.T == 1)) - params.responseStruct.tBlockStart;
%                 offsetTime(c) = params.responseStruct.events(i).t(find(params.responseStruct.events(i).attentionTask.T == -1)) - params.responseStruct.tBlockStart;
%                 c = c+1;
%             end
%         end
%         
%         covariates = [onsetTime' (offsetTime-onsetTime)' ones(size(onsetTime'))];
%         dlmwrite(fullfile(covDir, [fileName '-cov_attentionTask.csv']), covariates, '\t');
end