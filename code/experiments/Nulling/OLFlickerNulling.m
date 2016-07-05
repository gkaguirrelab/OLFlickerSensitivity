function OLFlickerNulling(nullingID, observerAgeInYrs, calType, nullingFrequencyHz, debugMode, exptMode, keyAssignment, protocolDataDir, FOVEAL_STIMULATION)
% OLFlickerNulling
%
% This program allows the observer to null L-M, S and LMS for
% modulations implemented on the OneLight. The nulling values are saved
% out.
%
% Usage:
%   nullExpt('X000000X', 32, 'OLBoxCLongCableCEyePiece3BeamsplitterOn', 30);
%
% 4/7/15    ms   Wrote it, commented.
% 4/7/15    ams and gka
%           Made modifications:
%               1. Subjects first null flicker, then L-M, then S
%              2. Subjects OLcalTypes.reiterate through these three nulling
%               experiments with weights continuously updated until they
%               make no changes to any of the three weights
% 4/12/15   ms   Introduced gamut limit testing.


%% Blank slate
%addpath(genpath('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity'));

% Get a time stamp
timestamp = datestr(now);

if isempty(FOVEAL_STIMULATION)
    FOVEAL_STIMULATION = false;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set some parameters
params.pulseDur = 0.5;              % seconds
params.pulsePre = 0.25;             % seconds
params.pulsePost = params.pulsePre;

% Define how many times the observer is supposed to do the matching, in
% order: LMS, L-M, S
% params.nNulling = 4;

% Scale factors according to which the primaries are scale. scalarPrimary
% is the the coefficient by which the to-be-nulled modulation will be
% scaled. The contrast available has to be multiplied by scalarPrimary to
% get the available contrast. We found that 0.8 works for nulling
% chromaticity for LMSDirected and MelanopsinDirectedLegacy, and nulling
% luminance for MelanopsinDirectedLegacy.
params.scalarPrimary = 0.7241;

% Perform nulling for both positive and negative arms of the stimuli.
params.modulationArms = [1 -1];

% We have designed the cache files to contain primary settings that
% correspond to a certain amount of contrast. We define these here. These
% are not magic numbers but numbers that the experimenter has dialed into
% the program 'OLPrepareStimuliNulling'.
params.maxContrastPrimary = 0.58;    % 60% for both MelanopsinDirected and LMSDirected stimuli
params.maxContrastLMS = 0.58;        % 60% for LMS
params.maxContrastLMinusM = 0.10;   % 10% for L-M
params.maxContrastS = 0.10;          % 10% for S

% Decide on nulling gamut
params.maxNullingContrastGamutLMS = 0.10;
params.maxNullingContrastGamutLMinusM = 0.10;
params.maxNullingContrastGamutS = 0.10;

% Decide on the contrast steps
params.contrastStepSmallLMS = 0.005;
params.contrastStepSmallLMinusM = 0.00250;
params.contrastStepSmallS = 0.02;

params.contrastStepLargeLMS = 0.02;
params.contrastStepLargeLMinusM = 0.01;
params.contrastStepLargeS = 0.04;

% We define the step sizes. We calculate the scale factor
% of each contrast step according to the maximum contrast we just
% calculated.
params.weightForContrastStepSmallLMS = (params.contrastStepSmallLMS/params.maxNullingContrastGamutLMS)*(params.maxNullingContrastGamutLMS/params.maxContrastLMS);
params.weightForContrastStepSmallLMinusM = (params.contrastStepSmallLMinusM/params.maxNullingContrastGamutLMinusM)*(params.maxNullingContrastGamutLMinusM/params.maxContrastLMinusM);
params.weightForContrastStepSmallS = (params.contrastStepSmallS/params.maxNullingContrastGamutS)*(params.maxNullingContrastGamutS/params.maxContrastS);

params.weightForContrastStepLargeLMS = (params.contrastStepLargeLMS/params.maxNullingContrastGamutLMS)*(params.maxNullingContrastGamutLMS/params.maxContrastLMS);
params.weightForContrastStepLargeLMinusM = (params.contrastStepLargeLMinusM/params.maxNullingContrastGamutLMinusM)*(params.maxNullingContrastGamutLMinusM/params.maxContrastLMinusM);
params.weightForContrastStepLargeS = (params.contrastStepLargeS/params.maxNullingContrastGamutS)*(params.maxNullingContrastGamutS/params.maxContrastS);

params.weightForContrastStepsSmall = [NaN NaN params.weightForContrastStepSmallLMS params.weightForContrastStepSmallLMinusM params.weightForContrastStepSmallS];
params.weightForContrastStepsLarge = [NaN NaN params.weightForContrastStepLargeLMS params.weightForContrastStepLargeLMinusM params.weightForContrastStepLargeS];

weight_gamut = [NaN NaN (params.maxNullingContrastGamutLMS/params.maxContrastLMS) (params.maxNullingContrastGamutLMinusM/params.maxContrastLMinusM) (params.maxNullingContrastGamutS/params.maxContrastS)];

% Our best guess of an appropriate nulling weight, different for the Mel
% and LMS stimuli. As of 4/10/2015, determined by the median of contrasts
% added by seven subjects to positive Mel and LMS arms according to AnalyzeNulling.m
params.nullingStartWeights = {[0, 0, 0], [0, 0, 0], [0, 0, 0], [0, 0, 0]};

% Set up the cal files
cal = LoadCalFile(calType);

baseDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/';
cacheDir = fullfile(baseDir, 'cache', 'stimuli');

% Set up the cache.
olCache = OLCache(cacheDir, cal);

% Load the cache data.
if FOVEAL_STIMULATION
    cacheMelanopsin = olCache.load(['Cache-MelanopsinDirectedPenumbralIgnoreFoveal'])      % Not penumbral cone silenced
    cacheLMinusM = olCache.load(['Cache-LMinusMDirectedFoveal'])                  % L-M
    cacheSDirected = olCache.load(['Cache-SConeDirectedFoveal'])                      % S
    cacheLMSDirected = olCache.load(['Cache-LMSDirectedFoveal'])                  % LMS
else
    cacheMelanopsin = olCache.load(['Cache-MelanopsinDirectedPenumbralIgnore'])      % Not penumbral cone silenced
    cacheLMinusM = olCache.load(['Cache-LMinusMDirected'])                  % L-M
    cacheSDirected = olCache.load(['Cache-SConeDirected'])                      % S
    cacheLMSDirected = olCache.load(['Cache-LMSDirected'])                  % LMS
end

% Background primary
backgroundPrimary = cacheMelanopsin.data(observerAgeInYrs).backgroundPrimary;
backgroundSettings = OLPrimaryToSettings(cal, backgroundPrimary);
[backgroundStarts,backgroundStops] = OLSettingsToStartsStops(cal, backgroundSettings);

%%%%%%%%%%%%%%%%%% DETERMINE WHICH KEY MAPPING WE USE %%%%%%%%%%%%%%%%%%%%%
if keyAssignment == 1
    params.leftKeyPolarity = -1;
    params.rightKeyPolarity = 1;
elseif keyAssignment == 0
    params.leftKeyPolarity = 1;
    params.rightKeyPolarity = -1;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up sounds
fs = 8192;
durSecs = 0.05;
t = linspace(0, durSecs, durSecs*fs);
sounds{1} = [sin(880*2*pi*t) zeros(1, 1000) sin(880*2*pi*t) zeros(1, 1000) sin(880*2*pi*t)];

durSecs = 0.01;
t = linspace(0, durSecs, durSecs*fs);
sounds{2} = [sin(1000*2*pi*t)];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize the OneLight
ol = OneLight;
ol.setMirrors(backgroundStarts, backgroundStops);

mglGetKeyEvent;

if debugMode
    system('say -r 210 No adaptation.');
else
    system('say -r 210 Adapt to background for five minutes');
    mglWaitSecs(60);
    system('say -r 210 4 minutes left.');
    mglWaitSecs(60);
    system('say -r 210 3 minutes left.');
    mglWaitSecs(60);
    system('say -r 210 2 minutes left.');
    mglWaitSecs(60);
    system('say -r 210 1 minute left.');
    mglWaitSecs(60);
    system('say -r 210 Adaptation complete. The experiment begins now.');
end

system('say -r 210 Press enter to continue.');
pause;

% Make sure that no key presses come to the MATLAB console
mglListener(7, ['z' '1' '2' '5' '6']);


%% Go to the subject's data directory and determine which iteration of the protocol we are in
[~, userID] = system('whoami');
userID = strtrim(userID);
dataParentDir = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/'];
switch exptMode
    case 'screening'
        subjectDataDir = fullfile(dataParentDir, protocolDataDir, nullingID, 'screening');
    case 'nulling'
        subjectDataDir = fullfile(dataParentDir, protocolDataDir, nullingID);
end
    
switch exptMode
    case {'screening' 'nulling'}
        if ~isdir(subjectDataDir)
            mkdir(subjectDataDir)
        end
        
        % Find the largest iteration number in the data filenames.
        iter = 0;
        d = dir(subjectDataDir);
        for i = 3:length(d)
            s = textscan(d(i).name, '%s%s%s', 'Delimiter', '-');
            if ~isempty(s{3})
                % Get rid of the .mat part.
                n = strtok(s{3}, '.');
                
                val = str2double(n);
                if ~isnan(val) && val > iter
                    iter = val;
                end
            end
        end
        iter = iter + 1;
        
        saveFileName = sprintf('%s/%s-%s-%d.mat', subjectDataDir, ...
            nullingID, exptMode, iter);
end

switch exptMode
    case 'demo'
        %% screening nulling
        % Set up the screening nulling
        params.weights_screening = [+1 0 (params.maxNullingContrastGamutLMS/params.maxContrastLMS)  0  0 ; ... % LMS screening +
            +1 0 0 (params.maxContrastLMinusM/params.maxContrastLMinusM)  0 ; ...                        % L-M screening +
            +1 0 0  0 (params.maxContrastS/params.maxContrastS) ; ...                        % S screening   +
            +1 0 -(params.maxNullingContrastGamutLMS/params.maxContrastLMS)  0  0 ; ...                        % LMS screening -
            +1 0 0 -(params.maxContrastLMinusM/params.maxContrastLMinusM)  0 ; ...                        % L-M screening -
            +1 0 0 0 -(params.maxContrastS/params.maxContrastS)];                            % S screening   -
        params.nRepeatsPerNull_screening = 6;
        params.nullingLuminanceFrequency_screening = [nullingFrequencyHz 0 0 nullingFrequencyHz 0 0];
        params.nullingColorFrequency_screening = [0 1 1 0 1 1];
        params.nullingModes_screening = {{'LMS'} ; {'LMinusM'} ; {'S'} ; {'LMS'} ; {'LMinusM'} ; {'S'}};
        
        % Prepare the nullimg primaries
        null_screening.primaryLMinusM = cacheLMinusM.data(observerAgeInYrs).differencePrimary;
        null_screening.primaryS = cacheSDirected.data(observerAgeInYrs).differencePrimary;
        null_screening.primaryLMS = cacheLMSDirected.data(observerAgeInYrs).differencePrimary;
        
        % Define the primary values that we want to add in or subtract
        primaries_screening = [backgroundPrimary backgroundPrimary null_screening.primaryLMS null_screening.primaryLMinusM null_screening.primaryS];
        
        for o = [1 2 3 1 2 3]
            system('say Demo.');
            theIdx = o;
            % The w variables will hold the estimated nulling parameters for each
            % subject as they are iteratively refined as we pass through nulling
            % attempts
            weights_screening = params.weights_screening(theIdx, :);
            
            % Set a while loop to allow subject to continue until they null no more
            NotDoneNulling = true;
            WeightsThusFar = [1 0 0 0 0; weights_screening];
            
            fprintf('\n==================================================================\n');
            tic;
            smallAdjustmentMade = false;
            while NotDoneNulling
                for k = 1:length(params.nullingModes_screening{theIdx})
                    switch params.nullingModes_screening{theIdx}{k}
                        case 'LMS'
                            indexWhichWeightToChange = 3; % Update LMS
                            nullingMode = 'flicker';
                            message = 'Match the flicker to the background';
                            theFrequency = params.nullingLuminanceFrequency_screening(theIdx);
                        case 'LMinusM'
                            indexWhichWeightToChange = 4; % Update L-M
                            nullingMode = 'step';
                            message = 'Match the color to the background';
                            theFrequency = params.nullingColorFrequency_screening(theIdx);
                        case 'S'
                            indexWhichWeightToChange = 5; % Update S
                            nullingMode = 'step';
                            message = 'Match the color to the background';
                            theFrequency = params.nullingColorFrequency_screening(theIdx);
                    end
                    keepRunning = true;
                    system(['say ' message]);
                    while keepRunning
                        [weights_screening, keepRunning, smallAdjustmentMade0] = OLFlickerNulling_DoNull(ol, cal, primaries_screening, weights_screening, weight_gamut, params, theFrequency, nullingMode, indexWhichWeightToChange, backgroundStarts, backgroundStops, sounds);
                        % Pull out the weights
                        w1 = weights_screening(3); w2 = weights_screening(4); w3 = weights_screening(5);
                        
                        fprintf('   -- Contrast [LMS, L-M, S]: [%.2f%s | %.2f%s | %.2f%s]\n', 100*w1*params.maxContrastLMS, '%', 100*w2*params.maxContrastLMinusM, '%', 100*w3*params.maxContrastS, '%');
                        if smallAdjustmentMade0 == true
                            smallAdjustmentMade = true;
                        end
                    end
                end
                
                
                if (keepRunning == false) && (smallAdjustmentMade == true)
                    NotDoneNulling = false;
                elseif (keepRunning == false) && (smallAdjustmentMade == false)
                    system(['say Please use small step size']);
                    NotDoneNulling = true;
                end
                
            end % While loop for done with attempting to null
        end
        
        system('say -r 210 Demo finished.');
    case 'screening'
        [buzzer, Fs] = audioread('buzzer.wav', [2000 6000]);
        buzzerplayer = audioplayer(buzzer, Fs);
        system('say -r 210 Testing');
        %% screening nulling
        % Set up the screening nulling
        params.weights_screening = [+1 0 (params.maxNullingContrastGamutLMS/params.maxContrastLMS)  0  0 ; ... % LMS screening +
            +1 0 0 (params.maxContrastLMinusM/params.maxContrastLMinusM)  0 ; ...                        % L-M screening +
            +1 0 0  0 (params.maxContrastS/params.maxContrastS) ; ...                        % S screening   +
            +1 0 -(params.maxNullingContrastGamutLMS/params.maxContrastLMS)  0  0 ; ...                        % LMS screening -
            +1 0 0 -(params.maxContrastLMinusM/params.maxContrastLMinusM)  0 ; ...                        % L-M screening -
            +1 0 0 0 -(params.maxContrastS/params.maxContrastS)];                            % S screening   -
        params.nRepeatsPerNull_screening = 6;
        params.nullingLuminanceFrequency_screening = [nullingFrequencyHz 0 0 nullingFrequencyHz 0 0];
        params.nullingColorFrequency_screening = [0 1 1 0 1 1];
        params.nullingModes_screening = {{'LMS'} ; {'LMinusM'} ; {'S'} ; {'LMS'} ; {'LMinusM'} ; {'S'}};
        
        % Prepare the nullimg primaries
        null_screening.primaryLMinusM = cacheLMinusM.data(observerAgeInYrs).differencePrimary;
        null_screening.primaryS = cacheSDirected.data(observerAgeInYrs).differencePrimary;
        null_screening.primaryLMS = cacheLMSDirected.data(observerAgeInYrs).differencePrimary;
        
        % Define the primary values that we want to add in or subtract
        primaries_screening = [backgroundPrimary backgroundPrimary null_screening.primaryLMS null_screening.primaryLMinusM null_screening.primaryS];
        
        % Create the sequences
        screeningIndices = [2 5 1 4 3 6];
        contrastCriteria = [NaN NaN 2*params.contrastStepSmallLMS+eps 2*params.contrastStepSmallLMinusM+eps 2*params.contrastStepSmallS+eps];
        maxContrastForCriterion = [NaN NaN params.maxContrastLMS params.maxContrastLMinusM params.maxContrastS];
        nMaxRepeats = 5;
        
        for o = 1:length(screeningIndices)
            tic;
            system(['say -r 210 Trial ' num2str(o) ' of ' num2str(length(screeningIndices))]);
            
            theIdx = screeningIndices(o);
            nulledSuccessfully = false;
            theCounter = 0;
            contrasts_full = [];
            while ~nulledSuccessfully
                theCounter = theCounter + 1;
                % The w variables will hold the estimated nulling parameters for each
                % subject as they are iteratively refined as we pass through nulling
                % attempts
                weights_screening = params.weights_screening(theIdx, :);
                
                % Set a while loop to allow subject to continue until they null no more
                NotDoneNulling = true;
                WeightsThusFar = [1 0 0 0 0; weights_screening];
                
                fprintf('\n==Repeat %g of max. %g==\n', theCounter, nMaxRepeats);
                
                smallAdjustmentMade = false;
                while NotDoneNulling
                    for k = 1:length(params.nullingModes_screening{theIdx})
                        switch params.nullingModes_screening{theIdx}{k}
                            case 'LMS'
                                indexWhichWeightToChange = 3; % Update LMS
                                nullingMode = 'flicker';
                                message = 'Match the flicker to the background';
                                theFrequency = params.nullingLuminanceFrequency_screening(theIdx);
                            case 'LMinusM'
                                indexWhichWeightToChange = 4; % Update L-M
                                nullingMode = 'step';
                                message = 'Match the color to the background';
                                theFrequency = params.nullingColorFrequency_screening(theIdx);
                            case 'S'
                                indexWhichWeightToChange = 5; % Update S
                                nullingMode = 'step';
                                message = 'Match the color to the background';
                                theFrequency = params.nullingColorFrequency_screening(theIdx);
                        end
                        keepRunning = true;
                        system(['say -r 210 ' message]);
                        while keepRunning
                            [weights_screening, keepRunning, smallAdjustmentMade0] = OLFlickerNulling_DoNull(ol, cal, primaries_screening, weights_screening, weight_gamut, params, theFrequency, nullingMode, indexWhichWeightToChange, backgroundStarts, backgroundStops, sounds);
                            % Pull out the weights
                            w1 = weights_screening(3); w2 = weights_screening(4); w3 = weights_screening(5);
                            
                            fprintf('   -- Contrast [LMS, L-M, S]: [%.2f%s | %.2f%s | %.2f%s]\n', 100*w1*params.maxContrastLMS, '%', 100*w2*params.maxContrastLMinusM, '%', 100*w3*params.maxContrastS, '%');
                            if smallAdjustmentMade0 == true
                                smallAdjustmentMade = true;
                            end
                        end
                    end
                    
                    if (keepRunning == false) && (smallAdjustmentMade == true)
                        NotDoneNulling = false;
                    elseif (keepRunning == false) && (smallAdjustmentMade == false)
                        system(['say -r 210 Please use small step size']);
                        NotDoneNulling = true;
                    end
                end
                numberOfTries = theCounter;
                contrasts_full = [contrasts_full ; [w1*params.maxContrastLMS w2*params.maxContrastLMinusM w3*params.maxContrastS]];
                if (abs(weights_screening(indexWhichWeightToChange)*maxContrastForCriterion(indexWhichWeightToChange)) < contrastCriteria(indexWhichWeightToChange))
                    nulledSuccessfully = true;
                    system('say -r 210 Nulling successful');
                else
                    if numberOfTries == nMaxRepeats
                        system('say -r 210 Finished testing');
                        
                        % Save out
                        nulling_screening{o}.contrasts_full = contrasts_full;
                        nulling_screening{o}.nTries = numberOfTries;
                        nulling_screening{o}.length_nulling = toc;
                        nulling_screening{o}.weights = weights_screening;
                        nulling_screening{o}.WeightsThusFar = WeightsThusFar;
                        nulling_screening{o}.primaries_raw = primaries_screening;
                        nulling_screening{o}.primaries = primaries_screening*weights_screening';
                        nulling_screening{o}.primaries_orig = primaries_screening*params.weights_screening(1, :)';
                        nulling_screening{o}.contrasts = [w1*params.maxContrastLMS w2*params.maxContrastLMinusM w3*params.maxContrastS];
                        nulling_screening{o}.order = theIdx;
                        
                        T_receptors = cacheMelanopsin.data(observerAgeInYrs).describe.T_receptors(1:5, :);
                        photoreceptorClasses = cacheMelanopsin.data(observerAgeInYrs).describe.photoreceptors;
                        nulling_screening{o}.T_receptors = T_receptors;
                        nulling_txraining{o}.photoreceptorClasses = photoreceptorClasses;
                        nulling_screening{o}.observerAgeInYrs = observerAgeInYrs;
                        nulling_screening{o}.nullingID = nullingID;
                        nulling_screening{o}.params = params;
                        nulling_screening{o}.nullingModes = params.nullingModes_screening{theIdx};
                        
                        %% Calculate the contrast of our 'physiologically silent' modulation.
                        nulling_screening{o}.backgroundSpd = OLPrimaryToSpd(cal, backgroundPrimary);
                        nulling_screening{o}.modulationSpd = OLPrimaryToSpd(cal, nulling_screening{o}.primaries);
                        nulling_screening{o}.modulationSpd_orig = OLPrimaryToSpd(cal, nulling_screening{o}.primaries_orig);
                        
                        %% Compute and report constrasts
                        backgroundReceptors = T_receptors * nulling_screening{o}.backgroundSpd;
                        modulationReceptors = T_receptors * nulling_screening{o}.modulationSpd;
                        modulationReceptors_orig = T_receptors * nulling_screening{o}.modulationSpd_orig;
                        
                        %% Get the contrasts
                        nulling_screening{o}.contrast_orig = (modulationReceptors_orig-backgroundReceptors)./backgroundReceptors;
                        nulling_screening{o}.contrast_calc = (modulationReceptors-backgroundReceptors)./backgroundReceptors;
                        
                        fprintf('>> Saving to %s ...', saveFileName);
                        save(saveFileName, 'nulling_screening');
                        fprintf('done\n');
                        fprintf('\n==============================DONE================================\n');
                        
                        return;
                    else
                        nulledSuccessfully = false;
                        playblocking(buzzerplayer);
                        system('say -r 210 Please try again');
                    end
                end
            end
            % Save out
            nulling_screening{o}.contrasts_full = contrasts_full;
            nulling_screening{o}.nTries = numberOfTries;
            nulling_screening{o}.length_nulling = toc;
            nulling_screening{o}.weights = weights_screening;
            nulling_screening{o}.WeightsThusFar = WeightsThusFar;
            nulling_screening{o}.primaries_raw = primaries_screening;
            nulling_screening{o}.primaries = primaries_screening*weights_screening';
            nulling_screening{o}.primaries_orig = primaries_screening*params.weights_screening(1, :)';
            nulling_screening{o}.contrasts = [w1*params.maxContrastLMS w2*params.maxContrastLMinusM w3*params.maxContrastS];
            nulling_screening{o}.order = theIdx;
            
            T_receptors = cacheMelanopsin.data(observerAgeInYrs).describe.T_receptors(1:5, :);
            photoreceptorClasses = cacheMelanopsin.data(observerAgeInYrs).describe.photoreceptors;
            nulling_screening{o}.T_receptors = T_receptors;
            nulling_txraining{o}.photoreceptorClasses = photoreceptorClasses;
            nulling_screening{o}.observerAgeInYrs = observerAgeInYrs;
            nulling_screening{o}.nullingID = nullingID;
            nulling_screening{o}.params = params;
            nulling_screening{o}.nullingModes = params.nullingModes_screening{theIdx};
            
            %% Calculate the contrast of our 'physiologically silent' modulation.
            nulling_screening{o}.backgroundSpd = OLPrimaryToSpd(cal, backgroundPrimary);
            nulling_screening{o}.modulationSpd = OLPrimaryToSpd(cal, nulling_screening{o}.primaries);
            nulling_screening{o}.modulationSpd_orig = OLPrimaryToSpd(cal, nulling_screening{o}.primaries_orig);
            
            %% Compute and report constrasts
            backgroundReceptors = T_receptors * nulling_screening{o}.backgroundSpd;
            modulationReceptors = T_receptors * nulling_screening{o}.modulationSpd;
            modulationReceptors_orig = T_receptors * nulling_screening{o}.modulationSpd_orig;
            
            %% Get the contrasts
            nulling_screening{o}.contrast_orig = (modulationReceptors_orig-backgroundReceptors)./backgroundReceptors;
            nulling_screening{o}.contrast_calc = (modulationReceptors-backgroundReceptors)./backgroundReceptors;
            
        end

        %% Saving out
        fprintf('>> Saving to %s ...', saveFileName);
        save(saveFileName, 'nulling_screening', 'timestamp');
        fprintf('done\n');
        fprintf('\n==============================DONE================================\n');
        
        system('say -r 210 Screening finished.');
        
    case 'nulling'
        %% Experimental nulling
        % Set up the real null
        params.nullingDirections = {'MelanopsinDirectedPenumbralIgnore', 'LMSDirected' 'MelanopsinDirectedPenumbralIgnore', 'LMSDirected'};
        params.weights = [+1 +1 params.nullingStartWeights{1}(1) params.nullingStartWeights{1}(2) params.nullingStartWeights{1}(3) ; ...  % Melanopsin+
            +1 +1 params.nullingStartWeights{2}(1) params.nullingStartWeights{2}(2) params.nullingStartWeights{2}(3) ; ...                 % LMS+
            +1 -1 params.nullingStartWeights{3}(1) params.nullingStartWeights{3}(2) params.nullingStartWeights{3}(3) ; ...                 % Melanopsin-
            +1 -1 params.nullingStartWeights{4}(1) params.nullingStartWeights{4}(2) params.nullingStartWeights{4}(3)];                     % LMS-
        params.nullingLuminanceFrequency = [nullingFrequencyHz nullingFrequencyHz nullingFrequencyHz nullingFrequencyHz];
        params.nullingColorFrequency = [1 1 1 1];
        DO_S = false;
        if DO_S
            params.nullingModes = {{'LMS', 'LMinusM', 'S'} ; {'LMinusM', 'S'} ; {'LMS' 'LMinusM', 'S'} ; {'LMinusM', 'S'}};
        else
            params.nullingModes = {{'LMS', 'LMinusM'} ; {'LMinusM'} ; {'LMS' 'LMinusM'} ; {'LMinusM'}};
        end
        % Prepare the nullimg primaries
        for p = 1:length(params.nullingDirections)
            cacheTmp = olCache.load(['Cache-' params.nullingDirections{p}]);
            nulling{p}.primaryNulling = cacheTmp.data(observerAgeInYrs).differencePrimary;
            nulling{p}.primaryLMinusM = cacheLMinusM.data(observerAgeInYrs).differencePrimary;
            nulling{p}.primaryS = cacheSDirected.data(observerAgeInYrs).differencePrimary;
            nulling{p}.primaryLMS = cacheLMSDirected.data(observerAgeInYrs).differencePrimary;
        end
        
        % Iterate over the directions we want to null
        for p = 1:length(params.nullingDirections)
            % The w variables will hold the estimated nulling parameters for each
            % subject as they are iteratively refined as we pass through nulling
            % attempts
            
            % Set a while loop to allow subject to continue until they null no more
            NotDoneNulling = true;
            WeightsThusFar = [1 1 0 0 0; params.weights(p, :)];
            
            fprintf('\n==================================================================\n>> Stage %g: Nulling for %s ....\n', p, params.nullingDirections{p});
            system(['say -r 210 Stimulus ' num2str(p)  'of ' num2str(length(params.nullingDirections)) '.']);
            
            % Define the primary values that we want to add in or subtract
            primaries = [backgroundPrimary params.scalarPrimary*nulling{p}.primaryNulling nulling{p}.primaryLMS nulling{p}.primaryLMinusM nulling{p}.primaryS];
            
            weights = params.weights(p, :);
            tic;
            while NotDoneNulling
                for k = 1:length(params.nullingModes{p})
                    switch params.nullingModes{p}{k}
                        case 'LMS'
                            indexWhichWeightToChange = 3; % Update LMS
                            nullingMode = 'flicker';
                            message = 'Match the flicker to the background';
                            theFrequency = params.nullingLuminanceFrequency(p);
                        case 'LMinusM'
                            indexWhichWeightToChange = 4; % Update L-M
                            nullingMode = 'step';
                            message = 'Match the color to the background';
                            theFrequency = params.nullingColorFrequency(p);
                        case 'S'
                            indexWhichWeightToChange = 5; % Update S
                            nullingMode = 'step';
                            message = 'Match the color to the background';
                            theFrequency = params.nullingColorFrequency(p);
                    end
                    
                    keepRunning = true;
                    system(['say -r 210 ' message]);
                    while keepRunning
                        [weights, keepRunning] = OLFlickerNulling_DoNull(ol, cal, primaries, weights, weight_gamut, params, theFrequency, nullingMode, indexWhichWeightToChange, backgroundStarts, backgroundStops, sounds);
                        % Pull out the weights
                        w1 = weights(3); w2 = weights(4); w3 = weights(5);
                        
                        fprintf('   -- Contrast [LMS, L-M, S]: [%.2f%s | %.2f%s | %.2f%s]\n', 100*w1*params.maxContrastLMS, '%', 100*w2*params.maxContrastLMinusM, '%', 100*w3*params.maxContrastS, '%');
                    end
                end
                
                % Add the weights to the running tracker
                WeightsThusFar = [WeightsThusFar ; weights];
                
                % If all the weights are no different from last time, wrap up the nulling
                if WeightsThusFar(size(WeightsThusFar,1), :) == WeightsThusFar((size(WeightsThusFar,1)-1), :)
                    NotDoneNulling = false;
                    system('say -r 210 Nulling finished.');
                    fprintf('... done\n');
                else
                    system('say -r 210 Repeating nulling until you make no change.');
                end
                
            end % While loop for done with attempting to null
            
            % Save out
            nulling{p}.length_nulling = toc;
            nulling{p}.weights = weights;
            nulling{p}.WeightsThusFar = WeightsThusFar;
            nulling{p}.primaries_raw = primaries;
            nulling{p}.primaries = primaries*weights';
            nulling{p}.primaries_orig = primaries*params.weights(1, :)';
            nulling{p}.diffPrimary = primaries(:, 2:end)*weights(2:end)';
            nulling{p}.diffPrimarySigned = weights(2)*(primaries(:, 2:end)*weights(2:end)');
            nulling{p}.contrasts = [w1*params.maxContrastLMS w2*params.maxContrastLMinusM w3*params.maxContrastS];
            
            T_receptors = cacheMelanopsin.data(observerAgeInYrs).describe.T_receptors(1:5, :);
            photoreceptorClasses = cacheMelanopsin.data(observerAgeInYrs).describe.photoreceptors;
            nulling{p}.T_receptors = T_receptors;
            nulling{p}.photoreceptorClasses = photoreceptorClasses;
            nulling{p}.observerAgeInYrs = observerAgeInYrs;
            nulling{p}.nullingID = nullingID;
            nulling{p}.params = params;
            
            %% Calculate the contrast of our 'physiologically silent' modulation.
            nulling{p}.backgroundSpd = OLPrimaryToSpd(cal, backgroundPrimary);
            nulling{p}.modulationSpd = OLPrimaryToSpd(cal, nulling{p}.primaries);
            nulling{p}.modulationSpd_orig = OLPrimaryToSpd(cal, nulling{p}.primaries_orig);
            
            %% Compute and report constrasts
            backgroundReceptors = T_receptors * nulling{p}.backgroundSpd;
            modulationReceptors = T_receptors * nulling{p}.modulationSpd;
            modulationReceptors_orig = T_receptors * nulling{p}.modulationSpd_orig;
            
            %% Get the contrasts
            nulling{p}.contrast_orig = (modulationReceptors_orig-backgroundReceptors)./backgroundReceptors;
            nulling{p}.contrast_calc = (modulationReceptors-backgroundReceptors)./backgroundReceptors;
        end
        
        % Extract the nulling averages
        nullingaverages{1}.backgroundPrimary = nulling{1}.primaries_raw(:, 1);
        nullingaverages{1}.differencePrimary = mean([nulling{1}.diffPrimarySigned nulling{3}.diffPrimarySigned], 2)
        nullingaverages{1}.direction = params.nullingDirections(1);
        nullingaverages{2}.backgroundPrimary = nulling{2}.primaries_raw(:, 1);
        nullingaverages{2}.differencePrimary = mean([nulling{2}.diffPrimarySigned nulling{4}.diffPrimarySigned], 2)
        nullingaverages{2}.direction = params.nullingDirections(2);
        
        % We also want to save the cache
        cache.cacheMelanopsin = cacheMelanopsin;
        cache.cacheLMinusM = cacheLMinusM;
        cache.cacheSDirected = cacheSDirected;
        cache.cacheLMSDirected = cacheLMSDirected;
        cache.cal = cal;
        
        %% Saving out
        fprintf('>> Saving to %s ...', saveFileName);
        save(saveFileName, 'nulling', 'nullingaverages', 'cache', 'cal', 'timestamp');
        
        fprintf('done\n');
        fprintf('\n==============================DONE================================\n');
        system('say -r 210 All nulling finished.');
end