%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up parameters
nullingID = 'J012216R';
observerAgeInYrs = 26;
theBaseCalTypeShort = 'BoxDRandomizedLongCableAEyePiece2_ND10';
nullingFrequencyHz = 25;

%% Determine key assignment <- ONLY RUN THIS ONCE PER SUBJECT
if rand > 0.5
    keyAssignment = 0;
else
    keyAssignment = 1;
end

%% ND1.0
% Run this cell for nulling and modulation generation at ND1.0
OLDarkTimer;
NDval = 'ND10';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEMO
MelanopsinStepsFovealControlShortDuration_Wrapper(nullingID, observerAgeInYrs, ...
    theBaseCalTypeShort, 'demo', nullingFrequencyHz, keyAssignment);

%% SCREENING
MelanopsinStepsFovealControlShortDuration_Wrapper(nullingID, observerAgeInYrs, ...
    theBaseCalTypeShort, 'screening', nullingFrequencyHz, keyAssignment);

%% DARK ADAPTATION
OLDarkTimer;

%% NULLING
MelanopsinStepsFovealControlShortDuration_Wrapper(nullingID, observerAgeInYrs, ...
    theBaseCalTypeShort, 'nulling', nullingFrequencyHz, keyAssignment);

%% MAKE MODULATIONS
MelanopsinStepsFovealControlShortDuration_Wrapper('G012216A', 46, ...
    theBaseCalTypeShort, 'short_duration_modulations_generation', [], []);
MelanopsinStepsFovealControlShortDuration_Wrapper('J012216R', 26, ...
    theBaseCalTypeShort, 'short_duration_modulations_generation', [], []);
MelanopsinStepsFovealControlShortDuration_Wrapper('M012216S', 28, ...
    theBaseCalTypeShort, 'short_duration_modulations_generation', [], []);


%% MAKE MODULATIONS
MelanopsinStepsFovealControlShortDuration_Wrapper('G012216A', 46, ...
    theBaseCalTypeShort, '5_5_duration_modulations_generation', [], []);
MelanopsinStepsFovealControlShortDuration_Wrapper('J012216R', 26, ...
    theBaseCalTypeShort, '5_5_duration_modulations_generation', [], []);
MelanopsinStepsFovealControlShortDuration_Wrapper('M012216S', 28, ...
    theBaseCalTypeShort, '5_5_duration_modulations_generation', [], []);


%% NULLING (FOVEAL)
MelanopsinStepsFovealControlShortDuration_Wrapper(['J012216R_foveal'], 26, ...
    theBaseCalTypeShort, 'nulling_foveal', nullingFrequencyHz, keyAssignment);

%% MAKE MODULATIONS (FOVEAL)
MelanopsinStepsFovealControlShortDuration_Wrapper(['J012216R_foveal'], 26, ...
    theBaseCalTypeShort, 'foveal_control_modulations_generation', [], []);
MelanopsinStepsFovealControlShortDuration_Wrapper(['G012216A_foveal'], 46, ...
    theBaseCalTypeShort, 'foveal_control_modulations_generation', [], []);
MelanopsinStepsFovealControlShortDuration_Wrapper(['M012216S_foveal'], 28, ...
    theBaseCalTypeShort, 'foveal_control_modulations_generation', [], []);

%% VALIDATE
MelanopsinStepsFovealControlShortDuration_Wrapper(nullingID, [], ...
    [], 'validation', [], []);

%% VALIDATE (FOVEWAL)
MelanopsinStepsFovealControlShortDuration_Wrapper([nullingID '_foveal'], [], ...
    [], 'validation', [], []);