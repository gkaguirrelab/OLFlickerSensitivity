BASE_PATH = '/Data/Imaging/Protocols/TTFMRFlickerY/Subjects/';
BOLD_DIR = '/BOLD';
FWHM = '0';

%% Main modulations -- GKA
INPUT_FILES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6' 'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5'  'varcope6'};

%% Anatomical prep. We'll assume this has been run for all of the later commands.
FEATRun2MNIAnatomicalPrep(BASE_PATH, 'G042514A');

%% LMDirected.
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_LMDirected_A.feat', ...
    'G042514A', 'G042514A', FWHM, INPUT_FILES);
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_LMDirected_B.feat', ...
    'G042514A', 'G042514A', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'G042514A';
FEAT_DIRS = {'TTFMRFlickerY_LMDirected_A.feat' 'TTFMRFlickerY_LMDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
glmDirs = CombineRunsFFXGLM_vol(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_LMDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_LMDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(glmDirs, [], 'beta.mgh', outDir, {'LMDirected'}, [2 4 8 16 32 64], [1], 'LGN', 5, 13);


%% LMinusMDirected.
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_LMinusMDirected_A.feat', ...
    'G042514A', 'G042514A', FWHM, INPUT_FILES);
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_LMinusMDirected_B.feat', ...
    'G042514A', 'G042514A', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'G042514A';
FEAT_DIRS = {'TTFMRFlickerY_LMinusMDirected_A.feat' 'TTFMRFlickerY_LMinusMDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
glmDirs = CombineRunsFFXGLM_vol(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_LMinusMDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_LMinusMDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(glmDirs, [], 'beta.mgh', outDir, {'LMinusMDirected'}, [2 4 8 16 32 64], [1], 'LGN', 5, 13);

%% SDirected.
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_SDirected_A.feat', ...
    'G042514A', 'G042514A', FWHM, INPUT_FILES);
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_SDirected_B.feat', ...
    'G042514A', 'G042514A', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'G042514A';
FEAT_DIRS = {'TTFMRFlickerY_SDirected_A.feat' 'TTFMRFlickerY_SDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
glmDirs = CombineRunsFFXGLM_vol(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_SDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_SDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(glmDirs, [], 'beta.mgh', outDir, {'SDirected'}, [2 4 8 16 32 64], [1], 'LGN', 5, 13);

%% MelanopsinDirected.
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_MelanopsinDirected_A.feat', ...
    'G042514A', 'G042514A', FWHM, INPUT_FILES);
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_MelanopsinDirected_B.feat', ...
    'G042514A', 'G042514A', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'G042514A';
FEAT_DIRS = {'TTFMRFlickerY_MelanopsinDirected_A.feat' 'TTFMRFlickerY_MelanopsinDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
glmDirs = CombineRunsFFXGLM_vol(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_MelanopsinDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_MelanopsinDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(glmDirs, [], 'beta.mgh', outDir, {'MelanopsinDirected'}, [2 4 8 16 32 64], [1], 'LGN', 5, 13);

