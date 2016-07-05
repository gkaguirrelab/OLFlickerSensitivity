% Get the calibrations tructure
cal = OLGetCalibrationStructure;
% Set up some parameters
intensities = 0:0.02:1;
nParamsValsB = length(intensities);
wls = SToWls([380 2 201]);
bgScale = 0;

%% Obtain the best estimate of the tritan pair
[tritanShortWl tritanShortEnergy tritanLongWl tritanLongEnergy] = GetTritanPairs([], [], [], []);
longToShortRatio = tritanLongEnergy/tritanShortEnergy;

%% Set up monochromatic primaries
% Make momochromatic spds and scale them
lambda = 0.01;
peakShift = [-10:1:10];
nParamsValsA = length(peakShift);
wl1b = tritanShortWl;
wl2b = round(tritanLongWl); % Round this up

INVERSE_CALC = true;
PRE_CALC = false;
if ~PRE_CALC
    for k = 1:nParamsValsA
        
        if INVERSE_CALC
            
            % Here, generate monochromatic primaries
            wl1(k) = wl1b+peakShift(k);
            wl2(k) = wl2b+peakShift(k);
            fullWidthHalfMax = 16;
            spd1 = OLMakeMonochromaticSpd(cal, wl1(k), fullWidthHalfMax);
            spd2 = OLMakeMonochromaticSpd(cal, wl2(k), fullWidthHalfMax);
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
            
            spdr1_fwhm(k) = fwhm(wls, spdr1, 0);
            spdr2_fwhm(k) = fwhm(wls, spdr2, 0);
        else
            [~, i] = max(cal.computed.pr650M)
            wlsTmp = wls(i);
            [~, wl1_idx] = min(abs(wlsTmp-440));
            [~, wl2_idx] = min(abs(wlsTmp-494));
            
            wl1(k) = wlsTmp(wl1_idx+peakShift(k));
            wl2(k) = wlsTmp(wl2_idx+peakShift(k));
            
            primary1 = zeros(cal.describe.numWavelengthBands, 1);
            primary1(wl1_idx+peakShift(k)) = 1;
            primary2 = zeros(cal.describe.numWavelengthBands, 1);
            primary2(wl2_idx+peakShift(k)) = 1;
            
        end
        
        % Some buffer
        primary1 = primary1*0.98;
        primary2 = primary2*0.98;
        
        longWlBG = true;
        if longWlBG
            % Find the primary index corresponding to 540 nm
            [~, wl1_idx] = min(abs(wlsTmp-550));
            bgPrimary = zeros(size(cal.computed.pr650M, 2), 1);
            bgPrimary(wl1_idx:end) = 1;
        end
        %bgPrimary = ones(size(cal.computed.pr650M, 2), 1);
        bgSpd = OLPrimaryToSpd(cal, bgPrimary);
        
        for m = 1:nParamsValsB
            fprintf('%g/%g - %g/%g\n', k, nParamsValsA, m, nParamsValsB);
            primaryVals1 = (1-bgScale)*intensities(m)*primary1;
            [primaryStarts1{k}(:, m) primaryStops1{k}(:, m)] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, primaryVals1));
            spds1{k}(:, m) = OLPrimaryToSpd(cal, primaryVals1);
            
            primaryVals2 = (1-bgScale)*intensities(m)*primary2;
            [primaryStarts2{k}(:, m) primaryStops2{k}(:, m)] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, primaryVals2));
            spds2{k}(:, m) = OLPrimaryToSpd(cal, primaryVals2);
            
            primaryVals1 = bgPrimary + (1-bgScale)*intensities(m)*primary1;
           [primaryStarts1WithBG{k}(:, m) primaryStops1WithBG{k}(:, m)] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, primaryVals1));
            spds1WithBG{k}(:, m) = OLPrimaryToSpd(cal, primaryVals1);
            
            primaryVals2 = bgPrimary + (1-bgScale)*intensities(m)*primary2;
            [primaryStarts2WithBG{k}(:, m) primaryStops2WithBG{k}(:, m)] = OLSettingsToStartsStops(cal, OLPrimaryToSettings(cal, primaryVals2));
            spds2WithBG{k}(:, m) = OLPrimaryToSpd(cal, primaryVals2);
        end
        
        
    end
    save data.mat
else
    load data.mat
end
% Check that we reached the target for the FWHM
if INVERSE_CALC
    fprintf('Max. wl\tFWHM\n');
    for i = 1:length(spdr1_fwhm)
        fprintf('%g\t%.2f\n', wl1(i), spdr1_fwhm(i));
    end
    
    fprintf('Max. wl\tFWHM\n');
    for i = 1:length(spdr1_fwhm)
        fprintf('%g\t%.2f\n', wl2(i), spdr2_fwhm(i));
    end
    
end

% Initialize the OneLight
ol = OneLight;
%% Set up some sounds
fs = 20000;
durSecs = 0.08;
t = linspace(0, durSecs, durSecs*fs);
ySound = [sin(880*2*pi*t)];
yLimit = [sin(440*2*pi*t) zeros(1, 1000) sin(440*2*pi*t) zeros(1, 1000) sin(440*2*pi*t)];
durSecs = 0.01;
t = linspace(0, durSecs, durSecs*fs);
yHint = [sin(880*2*pi*t)];


while true
%% Run the trial
interval1_initParams1 = find(peakShift == 0);
interval1_initParams2 = length(intensities);
interval2_initParams1 = find(peakShift == 0);
[~, interval2_initParams2] = min(abs(intensities-longToShortRatio)); % Set to predicted value

interval1_currIndex1 = interval1_initParams1;
interval1_currIndex2 = interval1_initParams2;
interval2_currIndex1 = interval2_initParams1;
interval2_currIndex2 = interval2_initParams2;

bgFlag = false;
initialAdjustment = true;
while initialAdjustment
    interval1 = true;
    interval2 = true;
    sound(ySound, fs)
    fprintf('Interval 1: %g, %.2f, bg flag: %g\n', wl1(interval1_currIndex1), intensities(interval1_currIndex2), double(bgFlag));
    while interval1
        %% Interval1
        if bgFlag
            ol.setMirrors(primaryStarts1WithBG{interval1_currIndex1}(:, interval1_currIndex2), primaryStops1WithBG{interval1_currIndex1}(:, interval1_currIndex2));
        elseif ~bgFlag
            ol.setMirrors(primaryStarts1{interval1_currIndex1}(:, interval1_currIndex2), primaryStops1{interval1_currIndex1}(:, interval1_currIndex2));
        end
        
        keyEvent = mglGetKeyEvent;
        if ~isempty(keyEvent)
            switch keyEvent.charCode
                case '1'
                    interval1 = false;
                case 'a'
                    sound(yHint, fs);
                    interval1_currIndex1 = interval1_currIndex1-1;
                    if interval1_currIndex1 == 0
                        interval1_currIndex1 = 1;
                        sound(yLimit, fs);
                    end
                    fprintf('Interval 1: %g, %.2f\n', wl1(interval1_currIndex1), intensities(interval1_currIndex2));
                case 'd'
                    sound(yHint, fs);
                    interval1_currIndex1 = interval1_currIndex1+1;
                    if interval1_currIndex1 > nParamsValsA
                        interval1_currIndex1 = nParamsValsA;
                        sound(yLimit, fs);
                    end
                    fprintf('Interval 1: %g, %.2f\n', wl1(interval1_currIndex1), intensities(interval1_currIndex2));
                case 's'
                    sound(yHint, fs);
                    interval1_currIndex2 = interval1_currIndex2-1;
                    if interval1_currIndex2 == 0
                        interval1_currIndex2 = 1;
                        sound(yLimit, fs);
                    end
                    fprintf('Interval 1: %g, %.2f\n', wl1(interval1_currIndex1), intensities(interval1_currIndex2));
                case 'w'
                    sound(yHint, fs);
                    interval1_currIndex2 = interval1_currIndex2+1;
                    if interval1_currIndex2 > nParamsValsB
                        interval1_currIndex2 = nParamsValsB;
                        sound(yLimit, fs);
                    end
                    fprintf('Interval 1: %g, %.2f\n', wl1(interval1_currIndex1), intensities(interval1_currIndex2));
                case '6'
                    bgFlag = ~bgFlag;
                case '4'
                    initialAdjustment = false;
                    interval1 = false;
                    interval2 = false;
            end
        end
        if bgFlag
            plot(wls, spds1WithBG{interval1_currIndex1}(:, interval1_currIndex2), '-k'); hold on
            pbaspect([1 1 1]); ylim([0 0.09]); drawnow;
        elseif ~bgFlag
            plot(wls, spds1{interval1_currIndex1}(:, interval1_currIndex2), '-k'); hold on
            pbaspect([1 1 1]); ylim([0 0.09]);drawnow;
        end
        
    end
    %% Interval2
    sound(ySound, fs)
    fprintf('Interval 2: %g, %.2f, bg flag: %g\n', wl2(interval2_currIndex1), intensities(interval2_currIndex2), double(bgFlag));
    while interval2
        %% Interval1
        if bgFlag
            ol.setMirrors(primaryStarts2WithBG{interval2_currIndex1}(:, interval2_currIndex2), primaryStops2WithBG{interval2_currIndex1}(:, interval2_currIndex2));
        elseif ~bgFlag
            ol.setMirrors(primaryStarts2{interval2_currIndex1}(:, interval2_currIndex2), primaryStops2{interval2_currIndex1}(:, interval2_currIndex2));
        end
        
        
        keyEvent = mglGetKeyEvent;
        if ~isempty(keyEvent)
            switch keyEvent.charCode
                case '1'
                    interval2 = false;
                case 'a'
                    sound(yHint, fs);
                    interval2_currIndex1 = interval2_currIndex1-1;
                    if interval2_currIndex1 == 0
                        interval2_currIndex1 = 1;
                        sound(yLimit, fs);
                    end
                    fprintf('Interval 2: %g, %.2f\n', wl2(interval2_currIndex1), intensities(interval2_currIndex2));
                case 'd'
                    sound(yHint, fs);
                    interval2_currIndex1 = interval2_currIndex1+1;
                    if interval2_currIndex1 > nParamsValsA
                        interval2_currIndex1 = nParamsValsA;
                        sound(yLimit, fs);
                    end
                    fprintf('Interval 2: %g, %.2f\n', wl2(interval2_currIndex1), intensities(interval2_currIndex2));
                case 's'
                    sound(yHint, fs);
                    interval2_currIndex2 = interval2_currIndex2-1;
                    if interval2_currIndex2 == 0
                        interval2_currIndex2 = 1;
                        sound(yLimit, fs);
                    end
                    fprintf('Interval 2: %g, %.2f\n', wl2(interval2_currIndex1), intensities(interval2_currIndex2));
                case 'w'
                    sound(yHint, fs);
                    interval2_currIndex2 = interval2_currIndex2+1;
                    if interval2_currIndex2 > nParamsValsB
                        interval2_currIndex2 = nParamsValsB;
                        sound(yLimit, fs);
                    end
                    fprintf('Interval 2: %g, %.2f\n', wl2(interval2_currIndex1), intensities(interval2_currIndex2));
                case '6'
                    bgFlag = ~bgFlag;
                case '4'
                    initialAdjustment = false;
                    interval1 = false;
                    interval2 = false;
            end
        end
        
        if bgFlag
            plot(wls, spds2WithBG{interval2_currIndex1}(:, interval2_currIndex2), '-k'); hold on
            pbaspect([1 1 1]); ylim([0 0.09]);drawnow;
        elseif ~bgFlag
            plot(wls, spds2{interval2_currIndex1}(:, interval2_currIndex2), '-k'); hold on
            pbaspect([1 1 1]); ylim([0 0.09]);drawnow;
        end
        
    end
    hold off;
    
end

system('say Starting fast flicker');
flickerAdjustment = true;
% Now, fast flicker
while flickerAdjustment
    if bgFlag
        ol.setMirrors(primaryStarts2WithBG{interval2_currIndex1}(:, interval2_currIndex2), primaryStops2WithBG{interval2_currIndex1}(:, interval2_currIndex2));
        mglWaitSecs(1/36);
        ol.setMirrors(primaryStarts1WithBG{interval1_currIndex1}(:, interval1_currIndex2), primaryStops1WithBG{interval1_currIndex1}(:, interval1_currIndex2));
        mglWaitSecs(1/36);
    elseif ~bgFlag
        ol.setMirrors(primaryStarts2{interval2_currIndex1}(:, interval2_currIndex2), primaryStops2{interval2_currIndex1}(:, interval2_currIndex2));
        mglWaitSecs(1/36);
        ol.setMirrors(primaryStarts1{interval1_currIndex1}(:, interval1_currIndex2), primaryStops1{interval1_currIndex1}(:, interval1_currIndex2));
        mglWaitSecs(1/36);
    end
    
    keyEvent = mglGetKeyEvent;
    if ~isempty(keyEvent)
        switch keyEvent.charCode
            case '1'
                interval2 = false;
            case 'a'
                %sound(yHint, fs);
                interval2_currIndex1 = interval2_currIndex1-1;
                if interval2_currIndex1 == 0
                    interval2_currIndex1 = 1;
                    sound(yLimit, fs);
                end
                fprintf('Interval 2: %g, %.2f\n', wl2(interval2_currIndex1), intensities(interval2_currIndex2));
            case 'd'
                %sound(yHint, fs);
                interval2_currIndex1 = interval2_currIndex1+1;
                if interval2_currIndex1 > nParamsValsA
                    interval2_currIndex1 = nParamsValsA;
                    sound(yLimit, fs);
                end
                fprintf('Interval 2: %g, %.2f\n', wl2(interval2_currIndex1), intensities(interval2_currIndex2));
            case 's'
                %sound(yHint, fs);
                interval2_currIndex2 = interval2_currIndex2-1;
                if interval2_currIndex2 == 0
                    interval2_currIndex2 = 1;
                    sound(yLimit, fs);
                end
                fprintf('Interval 2: %g, %.2f\n', wl2(interval2_currIndex1), intensities(interval2_currIndex2));
            case 'w'
                %sound(yHint, fs);
                interval2_currIndex2 = interval2_currIndex2+1;
                if interval2_currIndex2 > nParamsValsB
                    interval2_currIndex2 = nParamsValsB;
                    sound(yLimit, fs);
                end
                fprintf('Interval 2: %g, %.2f\n', wl2(interval2_currIndex1), intensities(interval2_currIndex2));
            case '6'
                bgFlag = ~bgFlag;
            case '4'
                flickerAdjustment = false;
        end
    end
end

end
%
% 1 =  440
% 6 = 490
% a = wl-1
% b = wl+1
% w = intensities+1
% d = intensities-1