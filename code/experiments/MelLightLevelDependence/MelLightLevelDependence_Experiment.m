%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Set up parameters
subjectID = 'M100915S';
observerAgeInYrs = 28;
theBaseCalTypeShort = 'BoxAShortCableCEyePiece2';

% %% ND2.0
% % Run this cell for nulling and modulation generation at ND2.0
% NDval = 'ND20';
% MelLightDependence_DoNullingAndMakeModulation(subjectID, observerAgeInYrs, theBaseCalTypeShort, NDval)
% 
% %% ND1.0
% % Run this cell for nulling and modulation generation at ND1.0
% NDval = 'ND10';
% MelLightDependence_DoNullingAndMakeModulation(subjectID, observerAgeInYrs, theBaseCalTypeShort, NDval)
% 
% %% ND0.0
% % Run this cell for nulling and modulation generation at ND0.0
% NDval = 'ND00';
% MelLightDependence_DoNullingAndMakeModulation(subjectID, observerAgeInYrs, theBaseCalTypeShort, NDval)
% 
% %% Intermediate light levels
% %% ND1.5
% % Run this cell for nulling and modulation generation at ND1.5
% 
% NDval = 'ND15';
% MelLightDependence_DoNullingAndMakeModulation(subjectID, observerAgeInYrs, theBaseCalTypeShort, NDval)
% 
% %% ND0.5
% % Run this cell for nulling and modulation generation at ND0.5
% NDval = 'ND05';
% MelLightDependence_DoNullingAndMakeModulation(subjectID, observerAgeInYrs, theBaseCalTypeShort, NDval)

%% Redo experiments at ND1.0 and ND1.5 with positive and negative steps
%% ND1.5
OLDarkTimer;
NDval = 'ND15';
MelLightDependence_DoNullingAndMakeModulation(subjectID, observerAgeInYrs, theBaseCalTypeShort, NDval, 'standard')

%% ND1.0
NDval = 'ND10';
MelLightDependence_DoNullingAndMakeModulation(subjectID, observerAgeInYrs, theBaseCalTypeShort, NDval, 'standard')


%% Cone noise
theBaseCalTypeShort = 'BoxAShortCableCEyePiece2';
NDval = 'ND10';
nullingID = 'M100915S'; observerAgeInYrs = 28;
MelLightDependence_DoNullingAndMakeModulation(nullingID, observerAgeInYrs, theBaseCalTypeShort, NDval, 'conenoise')

theBaseCalTypeShort = 'BoxAShortCableCEyePiece2';
NDval = 'ND10';
nullingID = 'J100715R'; observerAgeInYrs = 26;
MelLightDependence_DoNullingAndMakeModulation(nullingID, observerAgeInYrs, theBaseCalTypeShort, NDval, 'conenoise')

theBaseCalTypeShort = 'BoxAShortCableCEyePiece2';
NDval = 'ND10';
nullingID = 'G100815A'; observerAgeInYrs = 45;
MelLightDependence_DoNullingAndMakeModulation(nullingID, observerAgeInYrs, theBaseCalTypeShort, NDval, 'conenoise')

%% USE THIS FOR DHB
theBaseCalTypeShort = 'BoxAShortCableCEyePiece2';
NDval = 'ND10';
nullingID = 'D102615B'; observerAgeInYrs = 55;
MelLightDependence_DoNullingAndMakeModulation(nullingID, observerAgeInYrs, theBaseCalTypeShort, NDval, 'conenoise')

%% Cone noise CRF
theBaseCalTypeShort = 'BoxAShortCableCEyePiece2';
NDval = 'ND10';
nullingID = 'M100915S'; observerAgeInYrs = 28;
MelLightDependence_DoNullingAndMakeModulation(nullingID, observerAgeInYrs, theBaseCalTypeShort, NDval, 'conenoisecrf')

theBaseCalTypeShort = 'BoxAShortCableCEyePiece2';
NDval = 'ND10';
nullingID = 'J100715R'; observerAgeInYrs = 26;
MelLightDependence_DoNullingAndMakeModulation(nullingID, observerAgeInYrs, theBaseCalTypeShort, NDval, 'conenoisecrf')

theBaseCalTypeShort = 'BoxAShortCableCEyePiece2';
NDval = 'ND10';
nullingID = 'G100815A'; observerAgeInYrs = 45;
MelLightDependence_DoNullingAndMakeModulation(nullingID, observerAgeInYrs, theBaseCalTypeShort, NDval, 'conenoisecrf')


%% Double pulse
theBaseCalTypeShort = 'BoxAShortCableCEyePiece2';
NDval = 'ND10';
nullingID = 'M100915S'; observerAgeInYrs = 28;
MelLightDependence_DoNullingAndMakeModulation(nullingID, observerAgeInYrs, theBaseCalTypeShort, NDval, 'doublepulse')

theBaseCalTypeShort = 'BoxAShortCableCEyePiece2';
NDval = 'ND10';
nullingID = 'J100715R'; observerAgeInYrs = 26;
MelLightDependence_DoNullingAndMakeModulation(nullingID, observerAgeInYrs, theBaseCalTypeShort, NDval, 'doublepulse')

theBaseCalTypeShort = 'BoxAShortCableCEyePiece2';
NDval = 'ND10';
nullingID = 'G100815A'; observerAgeInYrs = 45;
MelLightDependence_DoNullingAndMakeModulation(nullingID, observerAgeInYrs, theBaseCalTypeShort, NDval, 'doublepulse')

%% Test different nulling frequencies
theBaseCalTypeShort = 'BoxAShortCableCEyePiece2';
NDval = 'ND10';
nullingFrequencyHz = 25;     % 25 Hz
nullingID = 'J111615Rx25Hz'; 
observerAgeInYrs = 26;
MelLightDependence_DoNullingAndMakeModulation(nullingID, observerAgeInYrs, theBaseCalTypeShort, NDval, 'nulling', nullingFrequencyHz)

%% Test nullExptModified script
theBaseCalTypeShort = 'BoxAShortCableCEyePiece2';
NDval = 'ND10';
nullingID = 'J100715R'; 
observerAgeInYrs = 26;
nullingFrequencyHz = 25;     % 25 Hz
modType = 'nulling';
MelLightDependence_DoNullingAndMakeModulation(nullingID, observerAgeInYrs, theBaseCalTypeShort, NDval, modType, nullingFrequencyHz)

