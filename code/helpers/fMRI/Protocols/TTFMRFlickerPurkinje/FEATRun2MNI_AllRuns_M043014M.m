BASE_PATH = '/Data/Imaging/Protocols/TTFMRFlickerPurkinje/Subjects/';
BOLD_DIR = '/BOLD';
FWHM = '0';

INPUT_FILES = {'cope1' 'cope2' 'cope3' 'varcope1' 'varcope2' 'varcope3'};

%% Anatomical prep. We'll assume this has been run for all of the later commands.
FEATRun2MNIAnatomicalPrep(BASE_PATH, 'M043014M');

%% LMDirectedScaled (0.5-2 Hz)
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerPurkinje_sLMDirectedScaled_A.feat', ...
    'M043014M', 'M043014M', FWHM, INPUT_FILES);
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerPurkinje_sLMDirectedScaled_B.feat', ...
    'M043014M', 'M043014M', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M043014M';
FEAT_DIRS = {'TTFMRFlickerPurkinje_sLMDirectedScaled_A.feat' 'TTFMRFlickerPurkinje_sLMDirectedScaled_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3'};
glmDirs = CombineRunsFFXGLM_vol(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerPurkinje_sLMDirectedScaled_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerPurkinje_sLMDirectedScaled_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(glmDirs, [], 'beta.mgh', outDir, {'sLMDirectedScaled'}, [0.5 1 2], [1], 'LGN', 5, 13);

INPUT_FILES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6' 'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
%% LMDirectedScaled (2-64 Hz).
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerPurkinje_LMDirectedScaled_A.feat', ...
    'M043014M', 'M043014M', FWHM, INPUT_FILES);
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerPurkinje_LMDirectedScaled_B.feat', ...
    'M043014M', 'M043014M', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M043014M';
FEAT_DIRS = {'TTFMRFlickerPurkinje_LMDirectedScaled_A.feat' 'TTFMRFlickerPurkinje_LMDirectedScaled_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
glmDirs = CombineRunsFFXGLM_vol(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerPurkinje_LMDirectedScaled_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerPurkinje_LMDirectedScaled_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(glmDirs, [], 'beta.mgh', outDir, {'LMDirectedScaled'}, [2 4 8 16 32 64], [1], 'LGN', 5, 13);

%% LMPenumbraDirected (2-64 Hz).
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerPurkinje_LMPenumbraDirected_A.feat', ...
    'M043014M', 'M043014M', FWHM, INPUT_FILES);
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerPurkinje_LMPenumbraDirected_B.feat', ...
    'M043014M', 'M043014M', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M043014M';
FEAT_DIRS = {'TTFMRFlickerPurkinje_LMPenumbraDirected_A.feat' 'TTFMRFlickerPurkinje_LMPenumbraDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
glmDirs = CombineRunsFFXGLM_vol(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerPurkinje_LMPenumbraDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerPurkinje_LMPenumbraDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(glmDirs, [], 'beta.mgh', outDir, {'LMPenumbraDirected'}, [2 4 8 16 32 64], [1], 'LGN', 5, 13);
