%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare for the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
theCalType = 'BoxDRandomizedLongCableAEyePiece2_ND06_Warmup';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Correct the spectrum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
theCalType = 'BoxDRandomizedLongCableAEyePiece2_ND06_Warmup';
spectroRadiometerOBJ = [];
spectroRadiometerOBJWillShutdownAfterMeasurement = false;
theDirections = {'MelanopsinDirectedSuperMaxMel' 'LMSDirectedSuperMaxLMS'};
cacheDir = getpref('OneLight', 'cachePath');
materialsPath = getpref('OneLight', 'materialsPath');
%OLWarmUpOOC;


while true
    if mod(10, c)
        powerLevels = [0 0.2 0.4 0.6 0.8 1.0]
    else
        powerLevels = [0 1.0];
    end
    WaitSecs(2);
    for d = 1:length(theDirections)
        [~, ~, validationPath{d}, spectroRadiometerOBJ] = OLValidateCacheFileOOC(...
            fullfile(cacheDir, 'stimuli', ['Cache-' theDirections{d} '.mat']), ...
            'igdalova@mail.med.upenn.edu', ...
            'PR-670', spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement, ...
            'FullOnMeas', false, ...
            'CalStateMeas', true, ...
            'DarkMeas', false, ...
            'ReducedPowerLevels', false, ...
            'selectedCalType', theCalType, ...
            'CALCULATE_SPLATTER', false, ...
            'powerLevels', powerLevels, ...
            'pr670sensitivityMode', 'STANDARD', ...
            'outDir', fullfile(materialsPath, 'PIPRMaxPulse', datestr(now, 'mmddyy')));
        close all;
    end
    c = c+1;
end
%end
if (~isempty(spectroRadiometerOBJ))
    spectroRadiometerOBJ.shutDown();
    spectroRadiometerOBJ = [];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the modulations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make the mod
%%
theCalType = 'BoxDRandomizedLongCableAEyePiece2_ND06_Warmup';
for o = [20:60]
    observerAgeInYrs = o;
    % LMS
    OLMakeModulations('Modulation-PIPRMaxPulse-BackgroundLMS_45sSegment.cfg', observerAgeInYrs, theCalType, [], []);
    OLMakeModulations('Modulation-PIPRMaxPulse-PulseMaxLMS_3s_MaxContrast17sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Attention task
    
    % Mel
    OLMakeModulations('Modulation-PIPRMaxPulse-BackgroundMel_45sSegment.cfg', observerAgeInYrs, theCalType, [], []);
    OLMakeModulations('Modulation-PIPRMaxPulse-PulseMaxMel_3s_MaxContrast17sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Attention task
    
    % PIPR
    OLMakeModulations('Modulation-PIPRMaxPulse-BackgroundPIPR_45sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Background.
    OLMakeModulations('Modulation-PIPRMaxPulse-PulsePIPRBlue_3s_MaxContrast17sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Blue PIPR
    OLMakeModulations('Modulation-PIPRMaxPulse-PulsePIPRRed_3s_MaxContrast17sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Red PIPR
end

%while true
%for i = 1:5
% for theLearningRate = [0.5 0.6 0.7 0.8 0.9 1.0]
%     WaitSecs(2);
%     for d = 1:length(theDirections)
%         [~, ~, validationPath{d}, spectroRadiometerOBJ] = OLCorrectCacheFileOOC(...
%             fullfile(cacheDir, 'stimuli', ['Cache-' theDirections{d} '.mat']), ...
%             'igdalova@mail.med.upenn.edu', ...
%             'PR-670', spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement, ...
%             'FullOnMeas', false, ...
%             'CalStateMeas', true, ...
%             'DarkMeas', false, ...
%             'ReducedPowerLevels', false, ...
%             'selectedCalType', theCalType, ...
%             'CALCULATE_SPLATTER', false, ...
%             'lambda', theLearningRate, ...
%             'powerLevels', [0 1.0000], ...
%             'outDir', fullfile(materialsPath, 'PIPRMaxPulse', datestr(now, 'mmddyy'), num2str(theLearningRate)));
%         close all;
%     end
% end
c = 1;