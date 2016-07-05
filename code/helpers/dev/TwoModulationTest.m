ol = OneLight

backgroundPrimary = BoxALongCableCEyePiece2{end}.data(32).modulationPrimarySignedNegative;
modulationPrimary = BoxALongCableCEyePiece2{end}.data(32).modulationPrimarySignedPositive;

[starts1, stops1] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, backgroundPrimary));
[starts2, stops2] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, modulationPrimary));

theFrequency = 4;
while true
    ol.setMirrors(starts1, stops1);
    mglWaitSecs(1/(2*theFrequency));
    ol.setMirrors(starts2, stops2);
    mglWaitSecs(1/(2*theFrequency));
end