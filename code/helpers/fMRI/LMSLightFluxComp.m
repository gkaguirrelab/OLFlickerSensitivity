
load('/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/code/cache/modulations/Modulation-MelanopsinDirectedLegacyNulled-45sWindowedFrequencyModulation-M081815S.mat')

load('/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/code/cache/modulations/Modulation-LMSDirectedNulled-45sWindowedFrequencyModulation-M081815S.mat')
modPrimaryLMS = modulationObj.modulation(1).modulationPrimary;

load('/Users/Shared/MATLAB/Experiments/OneLight/OLFlickerSensitivity/code/cache/modulations/Modulation-LightFlux-45sWindowedFrequencyModulation-M081815S.mat')
modPrimaryLightFlux = (modulationObj.modulation(1).theContrastRelMax*(modulationObj.modulation(1).modulationPrimary-0.5))+0.5;

[startsLightFlux, stopsLightFlux] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, modPrimaryLightFlux));
[startsLMS, stopsLMS] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, modPrimaryLMS));

theFrequency = 16;
while true
    ol.setMirrors(startsLightFlux, stopsLightFlux);
    mglWaitSecs(1/(theFrequency*0.5));
    ol.setMirrors(startsLMS, stopsLMS);
    mglWaitSecs(1/(theFrequency*0.5));
end