function params = MRITicklerSequence(exp)
% params = MRITicklerSequence(exp)

fprintf('\n* Creating keyboard listener\n');
mglListener('init');

%% Setup basic parameters for the experiment
params = initParams(exp);

%% Run the trial loop.
params = trialLoop(params, exp);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%% SUBFUNCTIONS FOR PROGRAM LOGIC %%%%%%%%%%%%%%%%%%%%%%%%
%
% Contains:
%       - initParams(...)
%       - tmglGetSecsrialLoop(...)

function params = initParams(exp)
% params = initParams(exp)
% Initialize the parameters

% Load the config file for this condition.
cfgFile = ConfigFile(exp.configFileName);

% Convert all the ConfigFile parameters into simple struct values.
params = convertToStruct(cfgFile);
params.ticklerLabels = allwords(params.ticklerLabels,',');
end

function params = trialLoop(params, exp)
% [params, responseStruct] = trialLoop(params, cacheData, exp)
% This function runs the experiment loop

%% Store out the primaries from the cacheData into a cell.  The length of
% cacheData corresponds to the number of different stimuli that are being
% shown

% Set up the tone;
t = linspace(0, 1, 10000);
y1 = sin(330*2*pi*t);
y2 = sin(400*2*pi*t);

% Message to print out
fprintf('\n* Waiting for t...\n');

%% Code to wait for 't' -- the go-signal from the scanner
triggerReceived = false;
while ~triggerReceived
    key = mglGetKeyEvent;
    % If a key was pressed, get the key and exit.
    if ~isempty(key)
        keyPress = key.charCode;
        if (strcmp(keyPress,'t'))
            triggerReceived = true;
        end
    end
end
mglListener('quit');
fprintf('  * t received.\n');
tBlockStart = mglGetSecs;

fprintf('- Starting trials.\n');

% Iterate over trials
for trial = 1:params.nTrials
    fprintf('* Start trial %i/%i: Tickler %s\n', trial, params.nTrials, params.ticklerLabels{trial});
    if params.ticklerState(trial) == 0
        sound(y1, 20000);
    else
        sound(y2, 20000);
    end
    tTrialStart(trial) = mglGetSecs;
    mglWaitSecs(params.trialDuration(trial));
    tTrialEnd(trial) = mglGetSecs;
end

fprintf('- Done with block.\n');
tBlockEnd = mglGetSecs;

% Put the timing information into a struct
responseStruct.tBlockStart = tBlockStart;
responseStruct.tBlockEnd = tBlockEnd;
responseStruct.tTrialStart = tTrialStart;
responseStruct.tTrialEnd = tTrialEnd;

% Tack data that we want for later analysis onto params structure.  It then
% gets passed back to the calling routine and saved in our standard place.
params.responseStruct = responseStruct;

end