%% Experiment
% Initialize OneLight
ol = OneLight;
OLAllMirrorsOn;
OLAllMirrorsOff;

%% Nulling
observerID = 'D081115B';
observerAgeInYrs = 55;
nullExptForThreshold(observerID, observerAgeInYrs, 'OLBoxCShortCableAEyePiece3BeamsplitterOn');

%% Preparation
thresholdExptNull(observerID, 'prep');

%% Preparation
thresholdExptNull(observerID, 'exptPedestalStaircase2IFC');