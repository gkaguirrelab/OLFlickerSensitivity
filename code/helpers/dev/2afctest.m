% Set up a demo
cal = OLGetCalibrationStructure;


% Set up some parameters
params.nConditions    = 5;
params.nRepetitions   = 2;
params.nTrials        = (params.nConditions*(params.nConditions-1))*params.nRepetitions;
params.paramsIndices1 = 1:params.nConditions;
params.paramsIndices2 = params.nConditions:-1:1;

% Determine the 'unique' stimulus matrix
[b2,b1] = ndgrid(1:params.nConditions); % generalization
q = b1~=b2;
% q = ~eye(N) ; % they are all on the diagonal
stimMatrix = [b1(q) b2(q)];
stimOrder = repmat(stimMatrix, params.nRepetitions, 1);

% Shuffle the indices
trialSeq = Shuffle(1:params.nTrials);

%% Prepare the stimuli
contrasts = linspace(0, 0.48, params.nConditions);
nParamsVals = length(contrasts);
dt = 1/64;
bgVals =  0.5*ones(cal.describe.numWavelengthBands, 1);
[bgStarts bgStops]= OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, bgVals));

% Iterate
for k = 1:nParamsVals
    primaryVals1 = repmat(0.5+contrasts(k)*sin(2*pi*16*(0:dt:1-dt)), cal.describe.numWavelengthBands, 1);
    for i = 1:size(primaryVals1, 2)
        [primaryStarts1{k}(:, i) primaryStops1{k}(:, i)] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, primaryVals1(:, i)));
        
    end
end

% Copy over, since they will be the same
primaryStarts2 = primaryStarts1;
primaryStops2 = primaryStops1;

paramsLabel = 'contrast';

%% Create the experiment object
expt = OLExperimentObj('2ifc', ...
    'olRefreshRate', 1/dt, ...
    'interval1_olStarts', primaryStarts1, ...
    'interval1_olStops', primaryStops1, ...
    'interval1_paramsValues', contrasts, ...
    'interval1_paramsCurrIndex', 1, ...
    'interval1_paramsLabel', paramsLabel, ...
    'interval1_isFlicker', true, ...
    'interval1_duration', [], ...
    'interval2_olStarts', primaryStarts2, ...
    'interval2_olStops', primaryStops2, ...
    'interval2_paramsValues', contrasts, ...
    'interval2_paramsCurrIndex', 1, ...
    'interval1_paramsLabel', paramsLabel, ...
    'interval2_isFlicker', true, ...
    'interval2_duration', [], ...
    'bg_olStarts', bgStarts, ...
    'bg_olStops', bgStops, ...
    'isi', 0.5);

% Initialize the OneLight
ol = OneLight;

%% Run the trial
pause;
respMatrix = zeros(params.nConditions, params.nConditions);
for i = 1:params.nTrials
    expt = updateParamsIndex(expt, stimOrder(trialSeq(i), 1), stimOrder(trialSeq(i), 2));
    fprintf('*** Current parameter value (%s): %.2f vs. %.2f ...', getParamsLabel(expt, 1), getCurrentParamsValue(expt, 1), getCurrentParamsValue(expt, 2));
    expt = doTrial(expt, ol);
    
    % Wait for a key press here
    keepRunning = true;
    while keepRunning
        keyEvent = mglGetKeyEvent;
        if ~isempty(keyEvent)
            if strcmp(keyEvent.charCode, '1')
                intChosen = 1;
                keepRunning = false;
            elseif strcmp(keyEvent.charCode, '2')
                intChosen = 2;
                keepRunning = false;
            end
        end
    end
    fprintf(' chose interval %g\n', intChosen);
    
    exp.response(i) = intChosen;
    exp.interval1(i) = getCurrentParamsValue(expt, 1);
    exp.interval2(i) = getCurrentParamsValue(expt, 2);
    exp.index1(i) = getCurrentParamsIndex(expt, 1);
    exp.index2(i) = getCurrentParamsIndex(expt, 2);
    
    respMatrix(exp.index1(i), exp.index2(i)) = respMatrix(exp.index1(i), exp.index2(i))+1;
end



