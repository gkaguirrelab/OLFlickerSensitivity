% Set up a demo
cal = OLGetCalibrationStructure;
%
intensities = linspace(0, 1, 10);
paramsLabel = 'intensity';
nParamsValsB = length(intensities);
dt = 1/15;
bgVals =  0*ones(cal.describe.numWavelengthBands, 1);
[bgStarts bgStops]= OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, bgVals));
wls = SToWls([380 2 201]);
bgScale = 0.2;

%% Set up monochromatic primaries
% Make momochromatic spds and scale them
lambda = 0.01;

% Here, generate monochromatic primaries
wl1 = 430;
wl2 = 490;
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

% Some buffer
primary1 = primary1*0.98;
primary2 = primary2*0.98;
frequency = 1/dt;

bgPrimary = bgScale*ones(size(cal.computed.pr650M, 2), 1);
bgSpd = OLPrimaryToSpd(cal, bgPrimary);

for m = 1:nParamsValsB
    fprintf('%g/%g\n', m, nParamsValsB);
    primaryVals1 = bgPrimary + (1-bgScale)*intensities(m)*primary1;
    [primaryStarts1(:, m) primaryStops1(:, m)] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, primaryVals1));
    spd1s(:, m) = OLPrimaryToSpd(cal, primaryVals1);
    
    primaryVals2 = bgPrimary + (1-bgScale)*intensities(m)*primary2;
    [primaryStarts2(:, m) primaryStops1(:, m)] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, primaryVals2));
    spds2(:, m) = OLPrimaryToSpd(cal, primaryVals2);
end


end


expt = OLExperimentObj('2ifc', ...
    'olRefreshRate', 1/dt, ...
    'interval1_olStarts', primaryStarts1, ...
    'interval1_olStops', primaryStops1, ...
    'interval1_paramsValues', {wl1b+peakShifts intensities}, ...
    'interval1_paramsCurrIndex', [1 1], ...
    'interval1_isFlicker', true, ...
    'interval1_paramsLabel', paramsLabel, ...
    
'interval1_olStarts', primaryStarts2, ...
    'interval1_olStops', primaryStops2, ...
    'interval1_paramsValues', {wl2b+peakShifts intensities}, ...
    'interval1_paramsCurrIndex', [1 1], ...
    'interval1_isFlicker', true, ...
    'interval1_paramsLabel', paramsLabel, ...
    
'bg_olStarts', bgStarts, ...
    'bg_olStops', bgStops, ...
    'isi', 0);

% Initialize the OneLight
ol = OneLight;

%% Run the trial
while true
    
    
    if ~isempty(keyEvent)
        switch keyEvent.charCode
            case '1'
                dIdx = -1;
            case '2'
                dIdx = 1;
            case '4'
                dIdx = -5;
            case '5'
                dIdx = 5;
            otherwise
                dIdx = 0;
        end
        
        % Make sure that we're not outside of the range, and only then
        % update the counter
        if ~(getCurrentParamsIndex(expt, 1)+dIdx > nParamsVals) && ~(getCurrentParamsIndex(expt, 1)+dIdx < 1)
            expt = updateParamsIndex(expt, getCurrentParamsIndex(expt, 1)+dIdx, []);
        end
    end
    
    plot(wls, spd1(:, getCurrentParamsIndex(expt, 1)), '-k'); hold on
    plot(wls, spd2(:, getCurrentParamsIndex(expt, 1)), '-r');
    plot(wls, bgSpd, '--k');
    hold off;
    drawnow;
    pbaspect([1 1 1]);
end
%
% 1 =  440
% 6 = 490
% a = wl-1
% b = wl+1
% w = intensity+1
% d = intensity-1