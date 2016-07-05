
%cal = OLGetCalibrationStructure;
S = [380 2 201];

B_primary = cal.computed.pr650M;

for i = 420:600;
theWl = i;
targetFWHM = 20;

% Figure out which primary corresponds to this.
[~, i] = max((B_primary)); wls = SToWls(S);
thePrimaryWls = wls(i);
[~, thePrimaryIndex] = min(abs(thePrimaryWls-theWl));

%% Generate a monochromatic spd with the properties above
[~, monochromaticSpdPrimary] = OLSpdToPrimary(cal, OLMakeMonochromaticSpd(cal, theWl, targetFWHM), 0);

% Normalize
monochromaticSpdPrimary = monochromaticSpdPrimary/max(monochromaticSpdPrimary);

monochromaticSpdSettings = OLPrimaryToSettings(cal, monochromaticSpdPrimary);

[starts, stops] = OLSettingsToStartsStops(cal, monochromaticSpdSettings);


ol = OneLight;

ol.setMirrors(starts, stops);
%pause(0.2);
end