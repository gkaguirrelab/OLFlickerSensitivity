function TestOLExpAdjustment(observerID, observerAgeInYrs, wlPair, reverseOrder);

% Set up a demo
clc; close all;

switch wlPair
    case 'short'
        wl1 = 430; wl2 = 494;
    case 'long'
        wl1 = 640; wl2 = 550;
end
% observerID = GetWithDefault('Enter observer ID', 'xx');
% observerAgeInYrs = GetWithDefault('Enter observer age in years', 32);
% 
% wlPair = GetWithDefault('Select wl pair [short, long]', 'short');
% switch wlPair
%     case 'short'
%         wl1 = 430; wl2 = 494;
%     case 'long'
%         wl1 = 640; wl2 = 550;
% end

addpath(genpath('/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/code'));
dataPath = '/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/data/LensMatching';
mkdir(dataPath);


mglListener('quit');
cal = LoadCalFile('OLBoxCLongCableCEyePiece3BeamsplitterOff')
%
intensities = 0:0.005:1;
%intensities = [ 0 1];
nParamsVals = length(intensities);
dt = 1/64;
bgVals =  0.5*ones(cal.describe.numWavelengthBands, 1);
[bgStarts bgStops]= OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, bgVals));

%% Set up monochromatic primaries
% Make momochromatic spds and scale them
% Check if we already have pre-cached primary settings
theFile = [num2str(wl1) '-' num2str(wl2) '.mat'];
if exist(theFile, 'file')
    load(theFile)
else
    
    lambda = 0.01;
    
    fullWidthHalfMax = 20;
    spd1 = OLMakeMonochromaticSpd(cal, wl1, fullWidthHalfMax);
    spd2 = OLMakeMonochromaticSpd(cal, wl2, fullWidthHalfMax);
    [maxSpd1, scaleFactor1] = OLFindMaxSpectrum(cal, spd1, lambda);
    [maxSpd2, scaleFactor2] = OLFindMaxSpectrum(cal, spd2, lambda);
    
    % Convert into device primaries
    primary1 = OLSpdToPrimary(cal, maxSpd1, lambda);
    primary2 = OLSpdToPrimary(cal, maxSpd2, lambda);
    
    % The resulting primaries are in 'extended' form, so we need to collapse
    % them. We also need to remove the last n and the first m primaries.
    primary1 = primary1(1:cal.describe.bandWidth:cal.describe.numColMirrors);
    primary1(end-cal.describe.nLongPrimariesSkip+1:end) = [];
    primary1(1:cal.describe.nShortPrimariesSkip) = [];
    primary2 = primary2(1:cal.describe.bandWidth:cal.describe.numColMirrors);
    primary2(end-cal.describe.nLongPrimariesSkip+1:end) = [];
    primary2(1:cal.describe.nShortPrimariesSkip) = [];
    spdr1 = OLPrimaryToSpd(cal, primary1);
    spdr2 = OLPrimaryToSpd(cal, primary2);
    
    % We want to scale the longer wavelength primary to be the same height as
    % the short wavelength primary
    primary2 = (max(spdr1)/max(spdr2)) * primary2;
    spdr2 = (max(spdr1)/max(spdr2)) * spdr2;
    
    % Some buffer
    primary1 = primary1*0.98;
    primary2 = primary2*0.98;
    
    
    for k = 1:nParamsVals
        primaryVals1{k} = [primary1 intensities(k)*primary2];
        for i = 1:size(primaryVals1{k}, 2)
            [primaryStarts1{k}(:, i) primaryStops1{k}(:, i)] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, primaryVals1{k}(:, i)));
        end
    end
    
    primaryStarts2 = primaryStarts1;
    primaryStops2 = primaryStops1;
    save(theFile, 'primaryVals1', 'primaryStarts1', 'primaryStops1', 'spdr1', 'spdr2', 'primary1', 'primary2');
end

paramsLabel = 'contrast';

if reverseOrder
   startIndex = length(intensities);
else
    startIndex = 1;
end

expt = OLExperimentObj('adjustment', ...
    'olRefreshRate', 1/dt, ...
    'interval1_olStarts', primaryStarts1, ...
    'interval1_olStops', primaryStops1, ...
    'interval1_paramsValues', intensities, ...
    'interval1_paramsCurrIndex', startIndex, ...
    'interval1_isFlicker', true, ...
    'bg_olStarts', bgStarts, ...
    'bg_olStops', bgStops, ...
    'isi', 0);

% Initialize the OneLight
ol = OneLight;

%% Run the trial
system('say Start matching');
keepRunning = true;
while keepRunning
    fprintf('*** Current parameter value: %.2f\n', getCurrentParamsValue(expt, 1));
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
