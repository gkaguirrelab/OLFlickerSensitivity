%% Run all analysis
% Add everything to the path
addpath(genpath(pwd));

%% TTFMRFlickerY
cd /Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/helpers/fMRI/Protocols/TTFMRFlickerY
% Cortex
%FEATRun2fsaverage_sym_AllRuns_M041814S;
%FEATRun2fsaverage_sym_AllRuns_M041714M;
%FEATRun2fsaverage_sym_AllRuns_L041714L;
%FEATRun2fsaverage_sym_AllRuns_G042514A;

% LGN
FEATRun2MNI_AllRuns_M041814S;
FEATRun2MNI_AllRuns_M041714M;
FEATRun2MNI_AllRuns_L041714L;
FEATRun2MNI_AllRuns_G042514A;

%% TTFMRFlickerYs
cd /Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/helpers/fMRI/Protocols/TTFMRFlickerYs
% Cortex
%FEATRun2fsaverage_sym_AllRuns_M042914S;
%FEATRun2fsaverage_sym_AllRuns_M042914M;
%FEATRun2fsaverage_sym_AllRuns_L042714L;
%FEATRun2fsaverage_sym_AllRuns_G042614A;

% LGN
FEATRun2MNI_AllRuns_M042914S;
FEATRun2MNI_AllRuns_M042914M;
FEATRun2MNI_AllRuns_L042714L;
FEATRun2MNI_AllRuns_G042614A;

%% TTFMRFlickerPurkinje
cd /Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/helpers/fMRI/Protocols/TTFMRFlickerPurkinje
% Cortex
%FEATRun2fsaverage_sym_AllRuns_M043014M;
%FEATRun2fsaverage_sym_AllRuns_M042714S;
%FEATRun2fsaverage_sym_AllRuns_L043014L; **
FEATRun2fsaverage_sym_AllRuns_G042614A;

% LGN
FEATRun2MNI_AllRuns_M043014M;
FEATRun2MNI_AllRuns_M042714S;
FEATRun2MNI_AllRuns_L043014L; %*
FEATRun2MNI_AllRuns_G042614A;