%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the modulations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make the mod
%%
theCalType = 'BoxDRandomizedLongCableAEyePiece2_ND06';
for o = [20:60] 
    observerAgeInYrs = o;
    % LMS
    OLMakeModulations('Modulation-PIPRMaxPulse-PulseMaxLMS_3s_MaxContrast3sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Attention task
    
    % Mel
    OLMakeModulations('Modulation-PIPRMaxPulse-PulseMaxMel_3s_MaxContrast3sSegment.cfg', observerAgeInYrs, theCalType, [], []); % Attention task
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate the validate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
theCalType = 'BoxDRandomizedLongCableAEyePiece2_ND06';
for i = 1:5
    theDirections = {'MelanopsinDirectedSuperMaxMel' 'LMSDirectedSuperMaxLMS'}% 'PIPRRed' 'PIPRBlue'}; ' 
    cacheDir = getpref('OneLight', 'cachePath');
    spectroRadiometerOBJ = [];
    spectroRadiometerOBJWillShutdownAfterMeasurement = false;
    
    WaitSecs(2);
    for d = 1:length(theDirections)
        [~, ~, validationPath{d}, spectroRadiometerOBJ] = OLValidateCacheFileOOC(...
            fullfile(cacheDir, 'stimuli', ['Cache-' theDirections{d} '.mat']), ...
            'mspits@sas.upenn.edu', ...
            'PR-670', spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement, ...
            'FullOnMeas', false, ...
            'WigglyMeas', true, ...
            'ReducedPowerLevels', false, ...
            'selectedCalType', theCalType, ...
            'CALCULATE_SPLATTER', false, ...
            'powerLevels', [0 1.0000]);
        close all;
    end
end
