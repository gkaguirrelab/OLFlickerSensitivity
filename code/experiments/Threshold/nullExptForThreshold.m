function nullExptForThreshold(observerID, observerAgeInYrs, calType)
% OLNullingExperiment
%
% This program allows the observer to null L-M, S and LMS for
% modulations implemented on the OneLight. The nulling values are saved
% out.
%
% Usage:
%   nullExpt('X000000X', 32, 'OLBoxCLongCableCEyePiece3BeamsplitterOn');
%
% 4/7/15    ms   Wrote it, commented.
% 4/7/15    ams and gka
%           Made modifications:
%               1. Subjects first null flicker, then L-M, then S
%               2. Subjects OLcalTypes.reiterate through these three nulling
%               experiments with weights continuously updated until they
%               make no changes to any of the three weights
% 4/12/15   ms   Introduced gamut limit testing.


%% Blank slate
%addpath(genpath('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity'));
clc;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define anonymous functions to check if we are in gamut
OLIsPrimaryInGamut = @(x) (~(any(x > 1) | any(x < 0)));
OLIsSettingsInGamut = @(x) (~any(isnan(x)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set some parameters
params.pulseDur = 0.5;              % seconds
params.pulsePre = 0.25;             % seconds
params.pulsePost = params.pulsePre;

% Define how many times the observer is supposed to do the matching, in
% order: LMS, L-M, S
% params.nNulling = 4;

% Our best guess of an appropriate nulling weight, different for the Mel
% and LMS stimuli. As of 4/10/2015, determined by the median of contrasts
% added by seven subjects to positive Mel and LMS arms according to AnalyzeNulling.m
params.nullingStartWeights = {[-0.2, -0.2, 0], [0, 0.42, 0]};
% The initial deflection for the first nulling of each stimulus. For the
% luminance flicker, we set it to the far end of our allowed range.
params.initialDeflectionWeights = {[-0.2, 0, 0], [0, -0.4, 0]}; 

% Define the directions which are to be nulled.
params.nullingDirections = {'MelanopsinDirectedLegacy' 'LMSDirected'};

% Define the frequency for which we do luminance nulling. This is
% typically a high frequency. We set this to 40 Hz for the
% Melanopsin direction and leave it empty for LMSDirected, since we do not
% want to null luminance there.
params.nullingLuminanceFrequency = {[30], []};

% Scale factors according to which the primaries are scale. scalarPrimary
% is the the coefficient by which the to-be-nulled modulation will be
% scaled. The contrast available has to be multiplied by scalarPrimary to
% get the available contrast. We found that 0.8 works for nulling
% chromaticity for LMSDirected and MelanopsinDirected, and nulling
% luminance for MelanopsinDirected.
params.scalarPrimary = .8;

% Perform nulling for both positive and negative arms of the stimuli.
params.modulationArms = [1 -1];

% We have designed the cache files to contain primary settings that
% correspond to a certain amount of contrast. We define these here. These
% are not magic numbers but numbers that the experimenter has dialed into
% the program 'OLPrepareStimuliNulling'.
params.maxContrastPrimary = 0.2;    % 40% for both MelanopsinDirected and LMSDirected stimuli
params.maxContrastLMS = 0.2;        % 40% for LMS
params.maxContrastLMinusM = 0.12;   % 12% for L-M
params.maxContrastS = 0.2;          % 40% for S

% Now, we decide the gamut of the nulling. We will never want to, or be
% able to, add 40% contrast on LMS or so to create a null, so we scale
% these here. We also calculate how much contrast we have available now
% after scaling. We need this number to calculate the step size for
% adjustment.
params.scalarLMS = 0.5; % =10% LMS contrast
params.maxContrastScaledLMS = params.scalarLMS*params.maxContrastLMS;
params.scalarLMinusM = 0.25; % =4.8% L-M contrast
params.maxContrastScaledLMinusM = params.scalarLMinusM*params.maxContrastLMinusM;
params.scalarS = 0.5; % =5% S contrast
params.maxContrastScaledS = params.scalarS*params.maxContrastS;

% We define the step sizes. We calculate the scale factor
% of each contrast step according to the maximum contrast we just
% calculated.
params.contrastStepSmall = 0.005; % 0.5%
params.contrastStepSmallLMS = params.contrastStepSmall/params.maxContrastScaledLMS; % 0.5%
params.contrastStepSmallLMinusM = 0.5*params.contrastStepSmall/params.maxContrastScaledLMinusM; % 0.25%
params.contrastStepSmallS = 2*params.contrastStepSmall/params.maxContrastScaledS; % 1%

params.contrastStepLarge = 0.01; % 1%
params.contrastStepLargeLMS = params.contrastStepLarge/params.maxContrastScaledLMS; % 1%
params.contrastStepLargeLMinusM = 0.5*params.contrastStepLarge/params.maxContrastScaledLMinusM; % 0.5%
params.contrastStepLargeS = 2*params.contrastStepLarge/params.maxContrastScaledS; % 2%

% Set up the cal files
cal = LoadCalFile(calType);

baseDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/';
cacheDir = fullfile(baseDir, 'cache', 'stimuli');

% Set up the cache.
olCache = OLCache(cacheDir, cal);

% Load the cache data.
cacheMelanopsin = olCache.load(['Cache-MelanopsinDirected']);            % Penumbral cone silenced
cacheLMinusM = olCache.load(['Cache-LMinusMDirected']);                  % L-M
cacheSDirected = olCache.load(['Cache-SDirected']);                      % S
cacheLMSDirected = olCache.load(['Cache-LMSDirected']);                  % LMS

% Background primary
backgroundPrimary = cacheMelanopsin.data(observerAgeInYrs).backgroundPrimary;
backgroundSettings = OLPrimaryToSettings(cal, backgroundPrimary);
[backgroundStarts,backgroundStops] = OLSettingsToStartsStops(cal, backgroundSettings);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up %%sounds
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize the OneLight
ol = OneLight;
ol.setMirrors(backgroundStarts, backgroundStops);
system('say Press key to begin');
fprintf('Press any key to start experiment\n');

pause;
mglGetKeyEvent;

system('say Adapt to background for 5 minutes');
mglWaitSecs(60);
system('say 4 minutes left.');
mglWaitSecs(60);
system('say 3 minutes left.');
mglWaitSecs(60);
system('say 2 minutes left.');
mglWaitSecs(60);
system('say 1 minutes left.');
mglWaitSecs(60);
system('say Adaptation complete. The experiment begins now.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Iterate over the positive and negative arms of each modulation
for r = 1:length(params.modulationArms)
    % Iterate over the directions we want to null
    for p = 1:length(params.nullingDirections)
        % The w variables will hold the estimated nulling parameters for each
        % subject as they are iteratively refined as we pass through nulling
        % attempts
        
        % Set the initial weights: positive for the positive arm, negative
        % for the negative arm
        w1 = params.nullingStartWeights{p}(1)*params.modulationArms(r);
        w2 = params.nullingStartWeights{p}(2)*params.modulationArms(r);
        w3 = params.nullingStartWeights{p}(3)*params.modulationArms(r);
        
        % Set a while loop to allow subject to continue until they null no more
        NotDoneNulling = true;
        WeightsThusFar = [0 0 0; w1 w2 w3];
        
        tic;
        fprintf('\n==================================================================\n>> Stage %g: Nulling for %s ....\n', p, params.nullingDirections{p});
        system('say new stimulus.');
        
        % Define the primary values that we want to add in or subtract
        cacheTmp = olCache.load(['Cache-' params.nullingDirections{p}]);
        nulling{p, r}.primaryNulling = cacheTmp.data(observerAgeInYrs).differencePrimary;
        nulling{p, r}.primaryLMinusM = cacheLMinusM.data(observerAgeInYrs).differencePrimary;
        nulling{p, r}.primaryS = cacheSDirected.data(observerAgeInYrs).differencePrimary;
        nulling{p, r}.primaryLMS = cacheLMSDirected.data(observerAgeInYrs).differencePrimary;
        
        while NotDoneNulling
            %% First phase: Flicker photometry
            % Detect if this is the first run through this nulling cycle,
            % and if so, add a deflection
            if size(WeightsThusFar,1) == 2
                w1 = params.nullingStartWeights{p}(1)*params.modulationArms(r) + params.initialDeflectionWeights{p}(1)*params.modulationArms(r);
            end
            
            for q = 1:length(params.nullingLuminanceFrequency{p})
                system('say Null the flicker.');
                sound(yStart, fs);
                fprintf('>> [%s] Luminance adjustment [%g Hz]', params.nullingDirections{p}, params.nullingLuminanceFrequency{p}(q));
                
                keepRunning = true;
                while keepRunning
                    
                    modulationPrimaryNow = backgroundPrimary + params.modulationArms(r)*params.scalarPrimary*nulling{p, r}.primaryNulling + ...
                        w1*params.scalarLMS*nulling{p, r}.primaryLMS + ...
                        w2*params.scalarLMinusM*nulling{p, r}.primaryLMinusM + ...
                        w3*params.scalarS*nulling{p, r}.primaryS;
                    modulationSettings = OLPrimaryToSettings(cal, modulationPrimaryNow);
                    [modulationStartsPos,modulationStopsPos] = OLSettingsToStartsStops(cal, modulationSettings);
                    
                    % sound
                    sound(yChangeUp, fs);
                    % Flicker. We discover the duration of each arm of the flicker
                    % and # of iterations from params.nullingLuminanceFrequency{p}
                    for j = 1:params.nullingLuminanceFrequency{p}(q)
                        ol.setMirrors(backgroundStarts, backgroundStops);
                        mglWaitSecs(1/(params.nullingLuminanceFrequency{p}(q)*2));
                        ol.setMirrors(modulationStartsPos, modulationStopsPos);
                        mglWaitSecs(1/(params.nullingLuminanceFrequency{p}(q)*2));
                    end
                    
                    % Go back to background
                    ol.setMirrors(backgroundStarts, backgroundStops);
                    sound(yChangeDown, fs);
                    
                    % Get the key
                    t0 = mglGetSecs;
                    checkKb = true;
                    while checkKb
                        
                        if mglGetSecs-t0 > 1
                            checkKb= false;
                        end
                        tmp = mglGetKeyEvent;
                        if ~isempty(tmp);
                            w1o = w1; % Save this in case we're out of gamut and need to revert
                            key = tmp;
                            if (str2num(key.charCode) == 1)
                                w1 = w1 - params.contrastStepSmallLMS; checkKb = false; sound(yHint, fs);
                            end
                            if (str2num(key.charCode) == 6)
                                w1 = w1 + params.contrastStepSmallLMS; checkKb = false; sound(yHint, fs);
                            end
                            if (str2num(key.charCode) == 2)
                                w1 = w1 - params.contrastStepLargeLMS; checkKb = false; sound(yHint, fs);
                            end
                            if (str2num(key.charCode) == 5)
                                w1 = w1 + params.contrastStepLargeLMS; checkKb = false; sound(yHint, fs);
                            end
                            if (strcmp(key.charCode, 'z'))
                                keepRunning = false; checkKb = false;
                            end
                        end
                        if w1 > 1
                            w1 = 1; sound(yLimitDown, fs);
                        elseif w1 < -1
                            w1 = -1; sound(yLimitDown, fs);
                        end
                        
                        %% Test if we are hitting the gamut limit.
                        % We first save out the weights in the variable 'tmp',
                        % and test if it is in the gamut with the in-line
                        % function OLIsPrimaryInGamut.
                        tmp = backgroundPrimary + params.modulationArms(r)*params.scalarPrimary*nulling{p, r}.primaryNulling + ...
                            w1*params.scalarLMS*nulling{p, r}.primaryLMS + ...
                            w2*params.scalarLMinusM*nulling{p, r}.primaryLMinusM + ...
                            w3*params.scalarS*nulling{p, r}.primaryS;
                        if ~OLIsPrimaryInGamut(tmp)
                            w1 = w1o; % Revert this to what it was
                            % Make a sound if we reach the gamut
                            sound(yLimitDown, fs);
                            fprintf('\n*** GAMUT LIMIT***\n');
                        end
                        
                        
                    end
                end
                fprintf('... done\n');
                fprintf('   -- Contrast [LMS, L-M, S]: [%.3f | %.3f | %.3f]\n', w1*params.maxContrastScaledLMS, w2*params.maxContrastScaledLMinusM, w3*params.maxContrastScaledS);
            end
            
            %% Second phase, L-M
            system('say Match the color red to green.');
            sound(yStart, fs);
            fprintf('>> [%s] Red-green adjustment', params.nullingDirections{p});
            
            % Detect if this is the first run through this nulling cycle,
            % and if so, add a deflection
            if size(WeightsThusFar,1) == 2
                w2 = params.nullingStartWeights{p}(2)*params.modulationArms(r) + params.initialDeflectionWeights{p}(2)*params.modulationArms(r);
            end
            
            keepRunning = true;
            while keepRunning
                modulationPrimaryNow = backgroundPrimary + params.modulationArms(r)*params.scalarPrimary*nulling{p, r}.primaryNulling + ...
                    w1*params.scalarLMS*nulling{p, r}.primaryLMS + ...
                    w2*params.scalarLMinusM*nulling{p, r}.primaryLMinusM + ...
                    w3*params.scalarS*nulling{p, r}.primaryS;
                modulationSettings = OLPrimaryToSettings(cal, modulationPrimaryNow);
                [modulationStartsPos,modulationStopsPos] = OLSettingsToStartsStops(cal, modulationSettings);
                
                % Show the pulse
                sound(yChangeUp, fs);
                ol.setMirrors(backgroundStarts, backgroundStops);
                ol.setMirrors(modulationStartsPos, modulationStopsPos);
                mglWaitSecs(params.pulseDur);
                ol.setMirrors(backgroundStarts, backgroundStops);
                sound(yChangeDown, fs);
                
                % Get the key
                t0 = mglGetSecs;
                checkKb = true;
                while checkKb
                    w2o = w2;
                    if mglGetSecs-t0 > 1
                        checkKb= false;
                    end
                    tmp = mglGetKeyEvent;
                    if ~isempty(tmp);
                        key = tmp;
                        if (str2num(key.charCode) == 1)
                            w2 = w2 - params.contrastStepSmallLMinusM; checkKb = false; sound(yHint, fs);
                        end
                        if (str2num(key.charCode) == 6)
                            w2 = w2 + params.contrastStepSmallLMinusM; checkKb = false; sound(yHint, fs);
                        end
                        if (str2num(key.charCode) == 2)
                            w2 = w2 - params.contrastStepLargeLMinusM; checkKb = false; sound(yHint, fs);
                        end
                        if (str2num(key.charCode) == 5)
                            w2 = w2 + params.contrastStepLargeLMinusM; checkKb = false; sound(yHint, fs);
                        end
                        if (strcmp(key.charCode, 'z'))
                            keepRunning = false; checkKb = false;
                        end
                    end
                    
                    if w2 > 1
                        w2 = 1; sound(yLimitDown, fs);
                    elseif w2 < -1
                        w2 = -1; sound(yLimitDown, fs);
                    end
                    
                    %% Test if we are hitting the gamut limit.
                    % We first save out the weights in the variable 'tmp',
                    % and test if it is in the gamut with the in-line
                    % function OLIsPrimaryInGamut.
                    tmp = backgroundPrimary + params.modulationArms(r)*params.scalarPrimary*nulling{p, r}.primaryNulling + ...
                        w1*params.scalarLMS*nulling{p, r}.primaryLMS + ...
                        w2*params.scalarLMinusM*nulling{p, r}.primaryLMinusM + ...
                        w3*params.scalarS*nulling{p, r}.primaryS;
                    if ~OLIsPrimaryInGamut(tmp)
                        w2 = w2o; % Revert this to what it was
                        % Make a sound if we reach the gamut
                        sound(yLimitDown, fs);
                        fprintf('\n*** GAMUT LIMIT***\n');
                    end
                    
                end
            end
            fprintf('... done\n');
            fprintf('   -- Contrast [LMS, L-M, S]: [%.3f | %.3f | %.3f]\n', w1*params.maxContrastScaledLMS, w2*params.maxContrastScaledLMinusM, w3*params.maxContrastScaledS);
            
            DO_S_CONE_NULLING = false;
            if DO_S_CONE_NULLING
                %% Third round, S
                
                system('say match the color yellow to blue.');
                sound(yStart, fs);
                fprintf('>> [%s] Blue-yellow adjustment', params.nullingDirections{p});
                
                % Detect if this is the first run through this nulling cycle,
                % and if so, add a deflection
                if size(WeightsThusFar,1) == 2
                    w3 = params.nullingStartWeights{p}(3)*params.modulationArms(r) + params.initialDeflectionWeights{p}(3)*params.modulationArms(r);
                end
                
                keepRunning = true;
                while keepRunning
                    
                    % Pull out the relevant modulationPrimary
                    
                    modulationPrimaryNow = backgroundPrimary + params.modulationArms(r)*params.scalarPrimary*nulling{p, r}.primaryNulling + ...
                        w1*params.scalarLMS*nulling{p, r}.primaryLMS + ...
                        w2*params.scalarLMinusM*nulling{p, r}.primaryLMinusM + ...
                        w3*params.scalarS*nulling{p, r}.primaryS;
                    modulationSettings = OLPrimaryToSettings(cal, modulationPrimaryNow);
                    [modulationStartsPos,modulationStopsPos] = OLSettingsToStartsStops(cal, modulationSettings);
                    
                    % Show the pulse
                    sound(yChangeUp, fs);
                    ol.setMirrors(backgroundStarts, backgroundStops);
                    ol.setMirrors(modulationStartsPos, modulationStopsPos);
                    mglWaitSecs(params.pulseDur);
                    ol.setMirrors(backgroundStarts, backgroundStops);
                    sound(yChangeDown, fs);
                    
                    % Get the key
                    t0 = mglGetSecs;
                    checkKb = true;
                    while checkKb
                        
                        if mglGetSecs-t0 > 1
                            checkKb= false;
                        end
                        tmp = mglGetKeyEvent;
                        if ~isempty(tmp);
                            key = tmp;
                            if (str2num(key.charCode) == 1)
                                w3 = w3 - params.contrastStepSmallS; checkKb = false; sound(yHint, fs);
                            end
                            if (str2num(key.charCode) == 6)
                                w3 = w3 + params.contrastStepSmallS; checkKb = false; sound(yHint, fs);
                            end
                            if (str2num(key.charCode) == 2)
                                w3 = w3 - params.contrastStepLargeS; checkKb = false; sound(yHint, fs);
                            end
                            if (str2num(key.charCode) == 5)
                                w3 = w3 + params.contrastStepLargeS; checkKb = false; sound(yHint, fs);
                            end
                            if (strcmp(key.charCode, 'z'))
                                keepRunning = false; checkKb = false;
                            end
                        end
                        if w3 > 1
                            w3 = 1; sound(yLimitDown, fs);
                        elseif w3 < -1
                            w3 = -1; sound(yLimitDown, fs);
                        end
                    end
                end
                fprintf(' ... done\n');
                fprintf('   -- Contrast [LMS, L-M, S]: [%.3f | %.3f | %.3f]\n', w1*params.maxContrastScaledLMS, w2*params.maxContrastScaledLMinusM, w3*params.maxContrastScaledS);
            end
            
            % Add the weights to the running tracker
            WeightsThusFar = [WeightsThusFar; w1 w2 w3];
            
            % If all the weights are no different from last time, wrap up the nulling
            if WeightsThusFar(size(WeightsThusFar,1), :) == WeightsThusFar((size(WeightsThusFar,1)-1), :)
                NotDoneNulling = false;
                system('say Nulling complete.');
            else
                system('say Repeating nulling.');
            end
            
        end % While loop for done with attempting to null
        
        %% Save out the nulling results
        nulling{p, r}.modulationArm = params.modulationArms(r);
        nulling{p, r}.direction = params.nullingDirections{p};
        nulling{p, r}.w1 = w1; nulling{p, r}.w2 = w2; nulling{p, r}.w3 = w3;
        nulling{p, r}.weights = WeightsThusFar;
        nulling{p, r}.LMScontrastadded = w1*params.maxContrastScaledLMS;
        nulling{p, r}.LMinusMcontrastadded = w2*params.maxContrastScaledLMinusM;
        nulling{p, r}.Scontrastadded = w3*params.maxContrastScaledS;
        
        % This is the modulation seen by the observer at the end of
        % nulling.
        nulling{p, r}.modulationPrimarySigned = params.modulationArms(r)*params.scalarPrimary*nulling{p, r}.primaryNulling + ...
            w1*params.scalarLMS*nulling{p, r}.primaryLMS + ...
            w2*params.scalarLMinusM*nulling{p, r}.primaryLMinusM + ...
            w3*params.scalarS*nulling{p, r}.primaryS;
        nulling{p, r}.nulledResidualPrimary =  w1*params.scalarLMS*nulling{p, r}.primaryLMS + ...
            w2*params.scalarLMinusM*nulling{p, r}.primaryLMinusM + ...
            w3*params.scalarS*nulling{p, r}.primaryS;
        
        % Save information about the observer 
        nulling{p, r}.observerAgeInYrs = observerAgeInYrs;
        nulling{p, r}.observerID = observerID;
        nulling{p, r}.params = params;
        toc; fprintf('\n')
        
        T_receptors = cacheMelanopsin.data(observerAgeInYrs).describe.T_receptors(1:5, :);
        photoreceptorClasses = cacheMelanopsin.data(observerAgeInYrs).describe.photoreceptors;
        nulling{p, r}.T_receptors = T_receptors;
        nulling{p, r}.photoreceptorClasses = photoreceptorClasses;
        nulling{p, r}.observerAgeInYrs = observerAgeInYrs;
        nulling{p, r}.observerID = observerID;
        nulling{p, r}.params = params;
        
        %% Calculate the contrast of our 'physiologically silent' modulation.
        backgroundSpd = OLPrimaryToSpd(cal, backgroundPrimary);
        modulationSpdNew = OLPrimaryToSpd(cal, backgroundPrimary + nulling{p, r}.modulationPrimarySigned);
        modulationSpd = OLPrimaryToSpd(cal, backgroundPrimary + params.modulationArms(r)*params.scalarPrimary*nulling{p, r}.primaryNulling);
        
        %% Compute and report constrasts
        backgroundReceptorsNew = T_receptors * backgroundSpd;
        modulationReceptorsNew = T_receptors * modulationSpdNew;
        
        backgroundReceptors = T_receptors * backgroundSpd;
        modulationReceptors = T_receptors * modulationSpd;
        
        fprintf('>> Stage %g: Nulling for %s ... done.\n', p, params.nullingDirections{p});
        
        for j = 1:size(T_receptors,1)
            fprintf('   - %s: %.2f [%.2f]\n',photoreceptorClasses{j},(modulationReceptorsNew(j)-backgroundReceptorsNew(j))/backgroundReceptorsNew(j), (modulationReceptors(j)-backgroundReceptors(j))/backgroundReceptors(j));
        end
        
        %% Get the contrasts
        nulling{p, r}.contrastOld = (modulationReceptors-backgroundReceptors)./backgroundReceptors;
        nulling{p, r}.contrastNew = (modulationReceptorsNew-backgroundReceptorsNew)./backgroundReceptorsNew;
        nulling{p, r}.backgroundSpd = backgroundSpd;
        nulling{p, r}.modulationSpdOld = modulationSpd;
        nulling{p, r}.modulationSpdNew = modulationSpdNew;
        nulling{p, r}.backgroundPrimary = backgroundPrimary;
    end % Loops over modulation directions (Mel and LMS)  
    
end % Loops over modulation arms (positive and negative contrast for the main modulation (Mel or LMS))

% Save out the average of the positive and negative arms to be used in the
% brightness perception and pupil experiments. To do so we multiply
% the negative modulation by -1, i.e. by params.modulationArms. This
% reflects it about the background to be averaged with the positive arm.

for p = 1:length(params.nullingDirections)    
    nullingaverages{p}.differencePrimary = mean([params.modulationArms(1)*nulling{p, 1}.modulationPrimarySigned, params.modulationArms(2)*nulling{p, 2}.modulationPrimarySigned], 2);
    nullingaverages{p}.direction = params.nullingDirections(p);
    nullingaverages{p}.nulledResidualPrimary = mean([params.modulationArms(1)*nulling{p, 1}.nulledResidualPrimary params.modulationArms(2)*nulling{p, 2}.nulledResidualPrimary], 2);
end

% We also want to save the cache
cache.cacheMelanopsin = cacheMelanopsin;
cache.cacheLMinusM = cacheLMinusM;
cache.cacheSDirected = cacheSDirected;
cache.cacheLMSDirected = cacheLMSDirected;
cache.cal = cal;

%% Saving out
saveOutFile = [observerID '_nulling'];
outPath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/Nulling';
fprintf('>> Saving to %s ...', fullfile(outPath, saveOutFile));

mkdir(outPath);
save(fullfile(outPath, saveOutFile), 'nulling', 'nullingaverages', 'cache', 'cal');
fprintf('done\n');
fprintf('\n==============================DONE================================\n');