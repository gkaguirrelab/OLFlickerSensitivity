function hfpExpt(observerID, observerAgeInYrs, calType);
%
% Usage: hfpExpt('X000000X', 32, 'OLBoxCLongCableCEyePiece3BeamsplitterOff')

% Set up a demo
clc; close all;

addpath(genpath('/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/code'));
dataPath = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/data/HFP';
mkdir(dataPath);

% Load the pre-cached data or generate it.
theFileName = [calType '-MonochromaticPrimaries.mat'];
if exist(theFileName, 'file')
    % Load
    fprintf('> Found pre-cached primaries, loading.\n');
    load(theFileName);
else
    % Generate
    fprintf('> Couldn''t find pre-cached primaries, generating them now.\n');
    hfpPrep(calType);
end

dt = 1/32;
paramsLabel = 'contrast';

% Make the sequence
nPrimaries = length(refPrimaryVals);
theRefVector = 1:nPrimaries;
theTestVector = 1:3;
c = 1; % Counter variable
for ii = 1:length(theRefVector)
    for jj = 1:length(theTestVector)
        refIdcs(c) = theRefVector(ii);
        testIdcs(c) = theTestVector(jj);
        c = c+1;
    end
end
nComparisons = length(refIdcs);
theOrder = Shuffle(1:nComparisons);

for o = 1:length(theOrder)
    % Pull out the reference and test indices
    refIdx = refIdcs(o);
    testIdx = testIdcs(o);
    
    % Assemble the ref and test lights
    for k = 1:nIntensities
        theStarts{k} = [refPrimaryStarts{refIdx}(:, idxUnitIntensity) refPrimaryStarts{testIdx}(:, k)];
        theStops{k} = [refPrimaryStops{refIdx}(:, idxUnitIntensity) refPrimaryStops{testIdx}(:, k)];
    end
    
    % Set up the OLExperimentObj object
    expt = OLExperimentObj('adjustment', ...
        'olRefreshRate', 1/dt, ...
        'interval1_olStarts', theStarts, ...
        'interval1_olStops', theStops, ...
        'interval1_paramsValues', intensities, ...
        'interval1_paramsCurrIndex', 1+(rand > 0.5)*(nIntensities-1), ... % Random starting from top or bottom
        'interval1_isFlicker', true, ...
        'bg_olStarts', zeros(1, 1024), ...
        'bg_olStops', zeros(1, 1024), ...
        'isi', 0);
    
    % Initialize the OneLight
    ol = OneLight;
    mglListener('quit');
    
    %% Run the trial
    system('say Start matching');
    keepRunning = true;
    while keepRunning
        %fprintf('*** Current parameter value: %.2f\n', getCurrentParamsValue(expt, 1));
        [expt, keyEvent] = doTrial(expt, ol);
        
        if ~isempty(keyEvent)
            switch keyEvent.charCode
                case '6'
                    dIdx = 1;
                case '1'
                    dIdx = -1;
                case '5'
                    dIdx = 5;
                case '2'
                    dIdx = -5;
                case 'z'
                    keepRunning = false;
            end
            
            % Make sure that we're not outside of the range, and only then
            % update the counter
            if ~(getCurrentParamsIndex(expt, 1)+dIdx > nParamsVals) && ~(getCurrentParamsIndex(expt, 1)+dIdx < 1)
                expt = updateParamsIndex(expt, getCurrentParamsIndex(expt, 1)+dIdx, []);
            end
        end
    end
    
    matchIntensityRatio = getCurrentParamsValue(expt, 1);
    matchIndex = getCurrentParamsIndex(expt, 1);
    OLAllMirrorsOff;
    system('say Found match');
    
    data.matchIntensityRatio = matchIntensityRatio;
    data.ambientSpd = cal.computed.pr650MeanDark;
    data.spdr1 = OLPrimaryToSpd(cal, primaryVals1{end}(:, 1))-cal.computed.pr650MeanDark; % Without the ambient
    data.spdr2 = OLPrimaryToSpd(cal, primaryVals1{end}(:, 2))-cal.computed.pr650MeanDark; % Without the ambient
    data.spdr1Match = OLPrimaryToSpd(cal, primaryVals1{matchIndex}(:, 1));
    data.spdr2Match = OLPrimaryToSpd(cal, primaryVals1{matchIndex}(:, 2));
    data.wl1 = wl1;
    data.wl2 = wl2;
    data.primary1 = primary1;
    data.primary2 = primary2;
    data.primaryStarts1 = primaryStarts1;
    data.primaryStops1 = primaryStops1;
    data.intensities = intensities;
    data.cal = cal;
    data.timeStamp = datestr(now, 30);
    outFile = ['Match-' num2str(wl1) '-' num2str(wl2) '-' observerID];
    save(fullfile(dataPath, outFile), 'data');
end