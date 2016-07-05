function MelanopsinStepsFovealControlShortDuration_DoNullingAndMakeModulation(nullingID, observerAgeInYrs, theBaseCalTypeShort, modType, nullingFrequencyHz, keyAssignment)
% MelLightDependence_DoNullingAndMakeModulation(subjectID, observerAgeInYrs, theBaseCalTypeShort, modType, nullingFrequencyHz)
%
% 9/24/15   ms  Wrote it as a wrapper.

if isempty(nullingFrequencyHz)
    nullingFrequencyHz = 25; % Hz
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extract some parameters
theCalTypeNulling = ['OL' theBaseCalTypeShort];
clc;

% Select the protocol
availableProtocols = {'MelanopsinStepsShortDuration', 'MelanopsinStepsFovealControl'};
keepPrompting = true;
while keepPrompting
    % Show the available cache types.
    fprintf('\n*** Available protocols: ***\n\n');
    for i = 1:length(availableProtocols)
        fprintf('%d - %s\n', i, availableProtocols{i});
        
    end
    fprintf('\n');
    protocolIndex = GetInput('Select the protocol', 'number', 1);
    
    % Check the selection.
    if protocolIndex >= 1 && protocolIndex <= length(availableProtocols)
        keepPrompting = false;
    else
        fprintf('\n* Invalid selection\n');
    end
end
whichProtocol = availableProtocols{protocolIndex};

[~, userID] = system('whoami');
userID = strtrim(userID);
dataParentDir = ['/Users/' userID '/Dropbox (Aguirre-Brainard Lab)/MELA_data/'];
protocolDir = fullfile(dataParentDir, whichProtocol, nullingID);

switch modType
    case 'demo'
        %% Training
        fprintf('*** STARTING DEMO ***');
        commandwindow;
        OLFlickerNulling(nullingID, observerAgeInYrs, theCalTypeNulling, nullingFrequencyHz, true, modType, keyAssignment, whichProtocol, false);
    case 'screening'
        %% Screening
        fprintf('*** STARTING SCREENING ***');
        commandwindow;
        OLFlickerNulling(nullingID, observerAgeInYrs, theCalTypeNulling, nullingFrequencyHz, true, modType, keyAssignment, whichProtocol, false);
    case 'nulling'
        %% Nulling
        fprintf('*** STARTING NULLING ***');
        commandwindow;
        OLFlickerNulling(nullingID, observerAgeInYrs, theCalTypeNulling, nullingFrequencyHz, false, modType, keyAssignment, whichProtocol, false);
    case 'nulling_foveal'
        %% Nulling
        fprintf('*** STARTING NULLING ***');
        commandwindow;
        OLFlickerNulling(nullingID, observerAgeInYrs, theCalTypeNulling, nullingFrequencyHz, false, 'nulling', keyAssignment, whichProtocol, true);
    case 'validation'
        OLFlickerNulling_Validate(nullingID, whichProtocol);
    case 'foveal_control_modulations_generation'
        fprintf('*** MAKING MODULATIONS ***');
        OLMakeModulations('Modulation-Background-60s.cfg', observerAgeInYrs, theBaseCalTypeShort, nullingID, protocolDir) % Background.
        OLMakeModulations('Modulation-MelanopsinDirectedPenumbralIgnoreNulledFoveal-45sPositivePulse5_5sConeNoise.cfg', observerAgeInYrs, theBaseCalTypeShort, nullingID, protocolDir) % Nulled Melanopsin.
        OLMakeModulations('Modulation-LMSDirectedNulledFoveal-45sPositivePulse5_5sConeNoise.cfg', observerAgeInYrs, theBaseCalTypeShort, nullingID, protocolDir) % Nulled LMS.
        OLMakeModulations('Modulation-ConeNoiseOnly-45s.cfg', observerAgeInYrs, theBaseCalTypeShort, nullingID, protocolDir) % Nulled LMS.
        fprintf('\n *** MODULATIONS ARE GENERATED ***\n');
    case 'short_duration_modulations_generation'
        fprintf('*** MAKING MODULATIONS ***');
        OLMakeModulations('Modulation-Background-60s.cfg', observerAgeInYrs, theBaseCalTypeShort, nullingID, protocolDir) % Background.
        OLMakeModulations('Modulation-ConeNoiseOnly-45s.cfg', observerAgeInYrs, theBaseCalTypeShort, nullingID, protocolDir) % Cone noise only.
        OLMakeModulations('Modulation-MelanopsinDirectedPenumbralIgnoreNulled-45sPositivePulse1_5sConeNoise.cfg', observerAgeInYrs, theBaseCalTypeShort, nullingID, protocolDir) % Nulled Melanopsin.
        OLMakeModulations('Modulation-LMSDirectedNulled-45sPositivePulse1_5sConeNoise.cfg', observerAgeInYrs, theBaseCalTypeShort, nullingID, protocolDir) % Nulled LMS.
        fprintf('\n *** MODULATIONS ARE GENERATED ***\n');
    case '5_5_duration_modulations_generation'
        fprintf('*** MAKING MODULATIONS ***');
        OLMakeModulations('Modulation-Background-60s.cfg', observerAgeInYrs, theBaseCalTypeShort, nullingID, protocolDir) % Background.
        OLMakeModulations('Modulation-ConeNoiseOnly-45s.cfg', observerAgeInYrs, theBaseCalTypeShort, nullingID, protocolDir) % Cone noise only.
        OLMakeModulations('Modulation-MelanopsinDirectedPenumbralIgnoreNulled-45sPositivePulse5_5sConeNoise.cfg', observerAgeInYrs, theBaseCalTypeShort, nullingID, protocolDir) % Nulled Melanopsin.
        OLMakeModulations('Modulation-LMSDirectedNulled-45sPositivePulse5_5sConeNoise.cfg', observerAgeInYrs, theBaseCalTypeShort, nullingID, protocolDir) % Nulled LMS.
        fprintf('\n *** MODULATIONS ARE GENERATED ***\n');
end

