function OLFlickerNulling_Validate(nullingID, whichProtocol)
% OLMeasureNullingSpd(dataFile)
%
% Measures spectra obtained seen by an observer at the end of nulling
%
% 4/20/15   ms      Wrote it.
commandwindow;
%% Set some parameters and open the OneLight
ol = OneLight;
od = [];
nAverage = 1;
prWhichMeter = 5;
meterToggle = [1 0];
S = [380 2 201];
CMCheckInit(5);

% Get the data
dataParentDir = '/Users/pupillab/Dropbox (Aguirre-Brainard Lab)/MELA_data/';
protocolDataDir = whichProtocol;
d = dir([fullfile(dataParentDir, protocolDataDir) '/' nullingID '/*nulling*.mat']);
fprintf('\n');
for i = 1:length(d)
    fprintf('=== Validating session %g of %g ===', i, length(d));
    %% Load the data file and pull out the relevant data
    dataFile = fullfile(dataParentDir, protocolDataDir, nullingID, d(i).name);
    tmp = load(dataFile);
    
    %% Background primary
    backgroundPrimary = tmp.nulling{1}.primaries_raw(:, 1);
    backgroundSettings = OLPrimaryToSettings(tmp.cal, backgroundPrimary);
    [backgroundStarts,backgroundStops] = OLSettingsToStartsStops(tmp.cal, backgroundSettings);
    backgroundPredictedSpd = OLPrimaryToSpd(tmp.cal, backgroundPrimary);
    
    % Take measurement
    bgMeas1 = OLTakeMeasurement(ol, od, backgroundStarts, backgroundStops, S, meterToggle, prWhichMeter, nAverage);
    
    %% Modulation spectra
    % For each iteration, measure the modulation spectra
    for p = 1:length(tmp.nulling)
        %% Unnulled spectra
        modulationPrimaryRaw = tmp.nulling{p}.primaries_orig;
        modulationSettingsRaw = OLPrimaryToSettings(tmp.cal, modulationPrimaryRaw);
        [modulationStartsRaw,modulationStopsRaw] = OLSettingsToStartsStops(tmp.cal, modulationSettingsRaw);
        
        % Take measurement
        meas = OLTakeMeasurement(ol, od, modulationStartsRaw, modulationStopsRaw, S, meterToggle, prWhichMeter, nAverage);
        
        tmp.nulling{p}.meas.modulationRaw.primary = modulationPrimaryRaw;
        tmp.nulling{p}.meas.modulationRaw.settings = modulationSettingsRaw;
        tmp.nulling{p}.meas.modulationRaw.starts = modulationStartsRaw;
        tmp.nulling{p}.meas.modulationRaw.stops = modulationStopsRaw;
        tmp.nulling{p}.meas.modulationRaw.pr670 = meas.pr650;
        tmp.nulling{p}.meas.modulationRaw.predictedSpd = OLPrimaryToSpd(tmp.cal, modulationPrimaryRaw);
        
        %% Nulled spectra
        modulationPrimary = tmp.nulling{p}.primaries;
        modulationSettings = OLPrimaryToSettings(tmp.cal, modulationPrimary);
        [modulationStarts,modulationStops] = OLSettingsToStartsStops(tmp.cal, modulationSettings);
        
        % Take measurement
        meas = OLTakeMeasurement(ol, od, modulationStarts, modulationStops, S, meterToggle, prWhichMeter, nAverage);
        
        % Assign everything
        tmp.nulling{p}.meas.modulation.primary = modulationPrimary;
        tmp.nulling{p}.meas.modulation.settings = modulationSettings;
        tmp.nulling{p}.meas.modulation.starts = modulationStarts;
        tmp.nulling{p}.meas.modulation.stops = modulationStops;
        tmp.nulling{p}.meas.modulation.pr670 = meas.pr650;
        tmp.nulling{p}.meas.modulation.predictedSpd = OLPrimaryToSpd(tmp.cal, modulationPrimary);
        
        %% Asign the background as well
        tmp.nulling{p}.meas.background.primary = backgroundPrimary;
        tmp.nulling{p}.meas.background.settings = backgroundSettings;
        tmp.nulling{p}.meas.background.starts = backgroundStarts;
        tmp.nulling{p}.meas.background.stops = backgroundStops;
        tmp.nulling{p}.meas.background.pr670 = bgMeas1.pr650;
        tmp.nulling{p}.meas.background.predictedSpd = backgroundPredictedSpd;
    end
    
    %% Average spectra
    for o = 1:length(tmp.nullingaverages)
        %% Do it for both arms
        modulationPrimary = backgroundPrimary + tmp.nullingaverages{1}.differencePrimary;
        modulationSettings = OLPrimaryToSettings(tmp.cal, modulationPrimary);
        [modulationStarts,modulationStops] = OLSettingsToStartsStops(tmp.cal, modulationSettings);
        
        % Take measurement
        meas = OLTakeMeasurement(ol, od, modulationStarts, modulationStops, S, meterToggle, prWhichMeter, nAverage);
        
        % Assign everything
        tmp.nullingaveragesval{o, 1}.meas.modulation.primary = modulationPrimary;
        tmp.nullingaveragesval{o, 1}.meas.modulation.settings = modulationSettings;
        tmp.nullingaveragesval{o, 1}.meas.modulation.starts = modulationStarts;
        tmp.nullingaveragesval{o, 1}.meas.modulation.stops = modulationStops;
        tmp.nullingaveragesval{o, 1}.meas.modulation.pr670 = meas.pr650;
        tmp.nullingaveragesval{o, 1}.meas.modulation.predictedSpd = OLPrimaryToSpd(tmp.cal, modulationPrimary);
        
        tmp.nullingaveragesval{o, 1}.meas.background.primary = backgroundPrimary;
        tmp.nullingaveragesval{o, 1}.meas.background.settings = backgroundSettings;
        tmp.nullingaveragesval{o, 1}.meas.background.starts = backgroundStarts;
        tmp.nullingaveragesval{o, 1}.meas.background.stops = backgroundStops;
        tmp.nullingaveragesval{o, 1}.meas.background.pr670 = bgMeas1.pr650;
        tmp.nullingaveragesval{o, 1}.meas.background.predictedSpd = backgroundPredictedSpd;
        
        modulationPrimary = backgroundPrimary - tmp.nullingaverages{1}.differencePrimary;
        modulationSettings = OLPrimaryToSettings(tmp.cal, modulationPrimary);
        [modulationStarts,modulationStops] = OLSettingsToStartsStops(tmp.cal, modulationSettings);
        
        % Take measurement
        meas = OLTakeMeasurement(ol, od, modulationStarts, modulationStops, S, meterToggle, prWhichMeter, nAverage);
        
        % Assign everything
        tmp.nullingaveragesval{o, 2}.meas.modulation.primary = modulationPrimary;
        tmp.nullingaveragesval{o, 2}.meas.modulation.settings = modulationSettings;
        tmp.nullingaveragesval{o, 2}.meas.modulation.starts = modulationStarts;
        tmp.nullingaveragesval{o, 2}.meas.modulation.stops = modulationStops;
        tmp.nullingaveragesval{o, 2}.meas.modulation.pr670 = meas.pr650;
        tmp.nullingaveragesval{o, 2}.meas.modulation.predictedSpd = OLPrimaryToSpd(tmp.cal, modulationPrimary);
        
        tmp.nullingaveragesval{o, 2}.meas.background.primary = backgroundPrimary;
        tmp.nullingaveragesval{o, 2}.meas.background.settings = backgroundSettings;
        tmp.nullingaveragesval{o, 2}.meas.background.starts = backgroundStarts;
        tmp.nullingaveragesval{o, 2}.meas.background.stops = backgroundStops;
        tmp.nullingaveragesval{o, 2}.meas.background.pr670 = bgMeas1.pr650;
        tmp.nullingaveragesval{o, 2}.meas.background.predictedSpd = backgroundPredictedSpd;
    end
    
    bgMeas2 = OLTakeMeasurement(ol, od, backgroundStarts, backgroundStops, S, meterToggle, prWhichMeter, nAverage);
    
    nulling = tmp.nulling;
    nullingaverages = tmp.nullingaverages;
    nullingaveragesval = tmp.nullingaveragesval;
    cal = tmp.cal;
    cache = tmp.cache;
    
    %% Saving out
    valDir = fullfile(fullfile(dataParentDir, protocolDataDir, nullingID), 'validation');
    if ~isdir(valDir)
        mkdir(valDir);
    end
    [~, fileName, fileExt] = fileparts(dataFile);
    saveOutFile = fullfile(valDir, [fileName '_validation' fileExt]);
    fprintf('\n>> Saving to %s ...', saveOutFile);
    save(saveOutFile, 'nulling', 'nullingaverages', 'nullingaveragesval', 'cache', 'cal', 'bgMeas1', 'bgMeas2');
    fprintf('done\n');
    
end
fprintf('\n==============================DONE================================\n');
