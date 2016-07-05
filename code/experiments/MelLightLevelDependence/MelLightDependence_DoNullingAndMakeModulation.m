function MelLightDependence_DoNullingAndMakeModulation(subjectID, observerAgeInYrs, theBaseCalTypeShort, NDval, modType, nullingFrequencyHz)
% MelLightDependence_DoNullingAndMakeModulation(subjectID, observerAgeInYrs, theBaseCalTypeShort, NDval, modType, nullingFrequencyHz)
%
% 9/24/15   ms  Wrote it as a wrapper.

if isempty(NDval);
    NDval = GetWithDefault('Enter ND value in default ND notation', 'ND20');
end

if isempty(nullingFrequencyHz)
   nullingFrequencyHz = 30; % Hz 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Extract some parameters
theBaseCalType = ['OL' theBaseCalTypeShort];
if strcmp(NDval, 'ND00')
    theCalType = [theBaseCalType];
else
    theCalType = [theBaseCalType '_' NDval];
end
theCalTypeNulling = theCalType;
nullingID = [subjectID 'x' NDval];
clc;


%% Make the modulation files
if strcmp(NDval, 'ND00')
    theCalType = [theBaseCalTypeShort];
else
    theCalType = [theBaseCalTypeShort '_' NDval];
end
switch modType
    case 'nulling'
        %% Nulling
        fprintf('*** STARTING NULLING ***');
        nullExpt(nullingID, observerAgeInYrs, theCalTypeNulling, nullingFrequencyHz, true);
        
    case 'standard'
        fprintf('*** MAKING MODULATIONS ***');
        OLMakeModulations('Modulation-MelanopsinDirectedPenumbralIgnoreNulled-45sPositivePulse5s.cfg', observerAgeInYrs, theCalType, nullingID) % Nulled Melanopsin.
        OLMakeModulations('Modulation-MelanopsinDirectedPenumbralIgnoreNulled-45sNegativePulse5s.cfg', observerAgeInYrs, theCalType, nullingID) % Nulled Melanopsin
        OLMakeModulations('Modulation-LMSDirectedNulled-45sPositivePulse5s.cfg', observerAgeInYrs, theCalType, nullingID); % Nulled LMS
        OLMakeModulations('Modulation-LMSDirectedNulled-45sNegativePulse5s.cfg', observerAgeInYrs, theCalType, nullingID); % Nulled LMS
        OLMakeModulations('Modulation-Background-60s.cfg', observerAgeInYrs, theCalType, nullingID) % Background 60s
        fprintf('\n *** MODULATIONS ARE GENERATED ***\n');
    case 'conenoise'
        fprintf('*** MAKING MODULATIONS ***');
        OLMakeModulations('Modulation-MelanopsinDirectedPenumbralIgnoreNulled-45sPositivePulse5sConeNoise.cfg', observerAgeInYrs, theCalType, nullingID) % Nulled Melanopsin.
        OLMakeModulations('Modulation-MelanopsinDirectedPenumbralIgnoreNulled-45sNegativePulse5sConeNoise.cfg', observerAgeInYrs, theCalType, nullingID) % Nulled Melanopsin.
        OLMakeModulations('Modulation-LMSDirectedNulled-45sPositivePulse5sConeNoise.cfg', observerAgeInYrs, theCalType, nullingID) % Nulled LMS.
        OLMakeModulations('Modulation-LMSDirectedNulled-45sNegativePulse5sConeNoise.cfg', observerAgeInYrs, theCalType, nullingID) % Nulled LMS.
        fprintf('\n *** MODULATIONS ARE GENERATED ***\n');
        
    case 'conenoisecrf'
        fprintf('*** MAKING MODULATIONS ***');
        OLMakeModulations('Modulation-MelanopsinDirectedPenumbralIgnoreNulled-45sPositivePulse5sConeNoiseCRF.cfg', observerAgeInYrs, theCalType, nullingID) % Nulled Melanopsin.
        OLMakeModulations('Modulation-MelanopsinDirectedPenumbralIgnoreNulled-45sNegativePulse5sConeNoiseCRF.cfg', observerAgeInYrs, theCalType, nullingID) % Nulled Melanopsin.
        OLMakeModulations('Modulation-LMSDirectedNulled-45sPositivePulse5sConeNoiseCRF.cfg', observerAgeInYrs, theCalType, nullingID) % Nulled LMS.
        OLMakeModulations('Modulation-LMSDirectedNulled-45sNegativePulse5sConeNoiseCRF.cfg', observerAgeInYrs, theCalType, nullingID) % Nulled LMS.
        fprintf('\n *** MODULATIONS ARE GENERATED ***\n');
        
    case 'doublepulse'
        fprintf('*** MAKING MODULATIONS ***');
        OLMakeModulations('Modulation-LMSStepMelanopsinPenumbralIgnoreStepPulse-50sNegativeStepPulse.cfg', observerAgeInYrs, theCalType, nullingID) % Nulled Melanopsin.
        OLMakeModulations('Modulation-LMSStepMelanopsinPenumbralIgnoreStepPulse-50sPositiveStepPulse.cfg', observerAgeInYrs, theCalType, nullingID) % Nulled Melanopsin.
        fprintf('\n *** MODULATIONS ARE GENERATED ***\n');
end