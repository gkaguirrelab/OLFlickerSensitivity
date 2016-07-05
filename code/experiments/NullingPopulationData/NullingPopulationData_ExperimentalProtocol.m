%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Run this for every subject, with 'nullingID' and 'observerAgeInYrs' adjusted for the observer.
theBaseCalTypeShort = 'BoxDRandomizedLongCableAEyePiece2_ND10';
nullingID = 'MELA_0039';      % <------------- ADJUST OBSERVER ID
observerAgeInYrs = 32;              % <------------- ADJUST AGE
nullingFrequencyHz = 25; % 25 Hz

%% Determine key assignment <- ONLY RUN THIS ONCE PER SUBJECT
if rand > 0.5
    keyAssignment = 0;
else
    keyAssignment = 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% DEMO
NullingPopulationData_DoNulling(nullingID, observerAgeInYrs, ...
    theBaseCalTypeShort, 'demo', nullingFrequencyHz, keyAssignment);

%% SCREENING
NullingPopulationData_DoNulling(nullingID, observerAgeInYrs, ...
    theBaseCalTypeShort, 'screening', nullingFrequencyHz, keyAssignment);

%% DARK ADAPTATION
OLDarkTimer;


%% NULLING RUN 1
NullingPopulationData_DoNulling(nullingID, observerAgeInYrs, ...
    theBaseCalTypeShort, 'nulling', nullingFrequencyHz, keyAssignment);

%% NULLING RUN 2
NullingPopulationData_DoNulling(nullingID, observerAgeInYrs, ...
    theBaseCalTypeShort, 'nulling', nullingFrequencyHz, keyAssignment);

%% VALIDATE
NullingPopulationData_DoNulling('MELA_0039', [], ...
    [], 'validation', [], []);
