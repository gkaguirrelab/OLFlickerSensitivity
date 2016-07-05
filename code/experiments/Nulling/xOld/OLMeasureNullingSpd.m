function OLMeasureNullingSpd(dataFile)
% OLMeasureNullingSpd(dataFile)
%
% Measures spectra obtained seen by an observer at the end of nulling
%
% 4/20/15   ms      Wrote it.

%% Set some parameters and open the OneLight
ol = OneLight;
od = [];
nAverage = 1;
prWhichMeter = 5;
meterToggle = [1 0];
S = [380 2 201];
CMCheckInit(5);

%% Load the data file and pull out the relevant data
tmp = load(dataFile);

%% Background primary
backgroundPrimary = tmp.nulling{1, 1}.backgroundPrimary;
backgroundSettings = OLPrimaryToSettings(tmp.cal, backgroundPrimary);
[backgroundStarts,backgroundStops] = OLSettingsToStartsStops(tmp.cal, backgroundSettings);
backgroundPredictedSpd = OLPrimaryToSpd(tmp.cal, backgroundPrimary);

% Take measurement
bgMeas = OLTakeMeasurement(ol, od, backgroundStarts, backgroundStops, S, meterToggle, prWhichMeter, nAverage);

%% Modulation spectra
% For each iteration, measure the modulation spectra
for p = 1:size(tmp.nulling, 1)
    for r = 1:size(tmp.nulling, 2)
        %% Unnulled spectra
        modulationPrimaryRaw = backgroundPrimary + tmp.nulling{p, r}.modulationArm*tmp.nulling{p, r}.params.scalarPrimary*tmp.nulling{p, r}.primaryNulling;
        modulationSettingsRaw = OLPrimaryToSettings(tmp.cal, modulationPrimaryRaw);
        [modulationStartsRaw,modulationStopsRaw] = OLSettingsToStartsStops(tmp.cal, modulationSettingsRaw);
        
        % Take measurement
        meas = OLTakeMeasurement(ol, od, modulationStartsRaw, modulationStopsRaw, S, meterToggle, prWhichMeter, nAverage);
        
        tmp.nulling{p, r}.meas.modulationRaw.primary = modulationPrimaryRaw;
        tmp.nulling{p, r}.meas.modulationRaw.settings = modulationSettingsRaw;
        tmp.nulling{p, r}.meas.modulationRaw.starts = modulationStartsRaw;
        tmp.nulling{p, r}.meas.modulationRaw.stops = modulationStopsRaw;
        tmp.nulling{p, r}.meas.modulationRaw.pr670 = meas.pr650;
        tmp.nulling{p, r}.meas.modulationRaw.predictedSpd = OLPrimaryToSpd(tmp.cal, modulationPrimaryRaw);
        
        %% Nulled spectra
        modulationPrimary = backgroundPrimary + tmp.nulling{p, r}.modulationPrimarySigned;
        modulationSettings = OLPrimaryToSettings(tmp.cal, modulationPrimary);
        [modulationStarts,modulationStops] = OLSettingsToStartsStops(tmp.cal, modulationSettings);
        
        % Take measurement
        meas = OLTakeMeasurement(ol, od, modulationStarts, modulationStops, S, meterToggle, prWhichMeter, nAverage);
        
        % Assign everything
        tmp.nulling{p, r}.meas.modulation.primary = modulationPrimary;
        tmp.nulling{p, r}.meas.modulation.settings = modulationSettings;
        tmp.nulling{p, r}.meas.modulation.starts = modulationStarts;
        tmp.nulling{p, r}.meas.modulation.stops = modulationStops;
        tmp.nulling{p, r}.meas.modulation.pr670 = meas.pr650;
        tmp.nulling{p, r}.meas.modulation.predictedSpd = OLPrimaryToSpd(tmp.cal, modulationPrimary);
        
        %% Asign the background as well
        tmp.nulling{p, r}.meas.background.primary = backgroundPrimary;
        tmp.nulling{p, r}.meas.background.settings = backgroundSettings;
        tmp.nulling{p, r}.meas.background.starts = backgroundStarts;
        tmp.nulling{p, r}.meas.background.stops = backgroundStops;
        tmp.nulling{p, r}.meas.background.pr670 = bgMeas.pr650;
        tmp.nulling{p, r}.meas.background.predictedSpd = backgroundPredictedSpd;
    end
end

%% Average spectra
for p = 1:size(tmp.nulling, 1)
    for r = 1:size(tmp.nulling, 2)
        %% Do it for both arms
        modulationPrimary = backgroundPrimary + tmp.nulling{p, r}.modulationArm * tmp.nullingaverages{p}.differencePrimary;
        modulationSettings = OLPrimaryToSettings(tmp.cal, modulationPrimary);
        [modulationStarts,modulationStops] = OLSettingsToStartsStops(tmp.cal, modulationSettings);
        
        % Take measurement
        meas = OLTakeMeasurement(ol, od, modulationStarts, modulationStops, S, meterToggle, prWhichMeter, nAverage);
        
        % Assign everything
        tmp.nullingval{p, r}.meas.modulation.primary = modulationPrimary;
        tmp.nullingval{p, r}.meas.modulation.settings = modulationSettings;
        tmp.nullingval{p, r}.meas.modulation.starts = modulationStarts;
        tmp.nullingval{p, r}.meas.modulation.stops = modulationStops;
        tmp.nullingval{p, r}.meas.modulation.pr670 = meas.pr650;
        tmp.nullingval{p, r}.meas.modulation.predictedSpd = OLPrimaryToSpd(tmp.cal, modulationPrimary);
        
        tmp.nullingval{p, r}.meas.background.primary = backgroundPrimary;
        tmp.nullingval{p, r}.meas.background.settings = backgroundSettings;
        tmp.nullingval{p, r}.meas.background.starts = backgroundStarts;
        tmp.nullingval{p, r}.meas.background.stops = backgroundStops;
        tmp.nullingval{p, r}.meas.background.pr670 = bgMeas.pr650;
        tmp.nullingval{p, r}.meas.background.predictedSpd = backgroundPredictedSpd;
        
        
        %% Do it for residuals as well arms
        modulationPrimary = backgroundPrimary + tmp.nulling{p, r}.modulationArm * tmp.nullingaverages{p}.nulledResidualPrimary;
        modulationSettings = OLPrimaryToSettings(tmp.cal, modulationPrimary);
        [modulationStarts,modulationStops] = OLSettingsToStartsStops(tmp.cal, modulationSettings);
        
        % Take measurement
        meas = OLTakeMeasurement(ol, od, modulationStarts, modulationStops, S, meterToggle, prWhichMeter, nAverage);
        
        % Assign everything
        tmp.nullingvalresidual{p, r}.meas.modulation.primary = modulationPrimary;
        tmp.nullingvalresidual{p, r}.meas.modulation.settings = modulationSettings;
        tmp.nullingvalresidual{p, r}.meas.modulation.starts = modulationStarts;
        tmp.nullingvalresidual{p, r}.meas.modulation.stops = modulationStops;
        tmp.nullingvalresidual{p, r}.meas.modulation.pr670 = meas.pr650;
        tmp.nullingvalresidual{p, r}.meas.modulation.predictedSpd = OLPrimaryToSpd(tmp.cal, modulationPrimary);
        
        tmp.nullingvalresidual{p, r}.meas.background.primary = backgroundPrimary;
        tmp.nullingvalresidual{p, r}.meas.background.settings = backgroundSettings;
        tmp.nullingvalresidual{p, r}.meas.background.starts = backgroundStarts;
        tmp.nullingvalresidual{p, r}.meas.background.stops = backgroundStops;
        tmp.nullingvalresidual{p, r}.meas.background.pr670 = bgMeas.pr650;
        tmp.nullingvalresidual{p, r}.meas.background.predictedSpd = backgroundPredictedSpd;
        
    end
end

nulling = tmp.nulling;
nullingaverages = tmp.nullingaverages;
nullingvalresidual = tmp.nullingvalresidual;
nullingval = tmp.nullingval;
cal = tmp.cal;
cache = tmp.cache;

%% Saving out
[~, fileName, fileExt] = fileparts(dataFile);
saveOutFile = [fileName '_meas' fileExt];
fprintf('>> Saving to %s ...', saveOutFile);
save(saveOutFile, 'nulling', 'nullingaverages', 'nullingval', 'nullingvalresidual', 'cache', 'cal');
fprintf('done\n');
fprintf('\n==============================DONE================================\n');