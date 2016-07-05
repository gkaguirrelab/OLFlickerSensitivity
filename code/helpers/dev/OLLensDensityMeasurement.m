function lensDen = OLLensDensityMeasurement
% lensDen = OLLensDensityMeasurement
%
% 4/7/15    ms      Started writing this.
lambda = 0.01;

% Load in cal and cache
calibrationType = 'BoxCLongCableBEyePiece1_ND06';
cal = LoadCalFile(OLCalibrationTypes.(calibrationType).CalFileName);

% Define wavelength spacing
S = [380 2 201]; wls = SToWls(S);


testWls = 470:490;
for m = 1:length(testWls)
    % Make momochromatic spds and scale them
    wl1 = 430; wl2 = 495;
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
    spdr2 = (max(spdr1)/max(spdr2)) * spdr2;
    primary2 = (max(spdr1)/max(spdr2)) * primary2;
    
    plot(wls, spdr1); hold on;
    plot(wls, spdr2);
    
    % Conver to starts/stops
    settings1 = OLPrimaryToSettings(cal, 0.99*primary1);
    [starts1,stops1] = OLSettingsToStartsStops(cal, settings1);
    
    settings2 = OLPrimaryToSettings(cal, 0.99*primary2);
    [starts2,stops2] = OLSettingsToStartsStops(cal, settings2);
    
    fprintf('\n***%g', wl2);
    ol = OneLight;
    for i = 1:10
        ol.setMirrors(starts2, stops2);
        mglWaitSecs(0.5);
                ol.setMirrors(starts1, stops1);
        mglWaitSecs(0.1);
    end
    pause
    
end