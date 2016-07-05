BASE_PATH = '/Data/Imaging/Protocols/TTFMRFlickerYs/Subjects/';
BOLD_DIR = '/BOLD';
FWHM = '0';

%% Main modulations -- GKA
INPUT_FILES = {'cope1' 'cope2' 'cope3'  'varcope1' 'varcope2' 'varcope3' };

%% Anatomical prep. We'll assume this has been run for all of the later commands.
FEATRun2MNIAnatomicalPrep(BASE_PATH, 'L042714L');

%% LMDirected.
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerYs_sLMDirected_A.feat', ...
    'L042714L', 'L042714L', FWHM, INPUT_FILES);
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerYs_sLMDirected_B.feat', ...
    'L042714L', 'L042714L', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'L042714L';
FEAT_DIRS = {'TTFMRFlickerYs_sLMDirected_A.feat' 'TTFMRFlickerYs_sLMDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' }; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' };
glmDirs = CombineRunsFFXGLM_vol(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sLMDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sLMDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(glmDirs, [], 'beta.mgh', outDir, {'LMDirected'}, [0.5 1 2], [1], 'LGN', 5, 13);


%% LMinusMDirected.
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerYs_sLMinusMDirected_A.feat', ...
    'L042714L', 'L042714L', FWHM, INPUT_FILES);
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerYs_sLMinusMDirected_B.feat', ...
    'L042714L', 'L042714L', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'L042714L';
FEAT_DIRS = {'TTFMRFlickerYs_sLMinusMDirected_A.feat' 'TTFMRFlickerYs_sLMinusMDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' }; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' };
glmDirs = CombineRunsFFXGLM_vol(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sLMinusMDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sLMinusMDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(glmDirs, [], 'beta.mgh', outDir, {'LMinusMDirected'}, [0.5 1 2], [1], 'LGN', 5, 13);

%% SDirected.
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerYs_sSDirected_A.feat', ...
    'L042714L', 'L042714L', FWHM, INPUT_FILES);
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerYs_sSDirected_B.feat', ...
    'L042714L', 'L042714L', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'L042714L';
FEAT_DIRS = {'TTFMRFlickerYs_sSDirected_A.feat' 'TTFMRFlickerYs_sSDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' }; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' };
glmDirs = CombineRunsFFXGLM_vol(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sSDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sSDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(glmDirs, [], 'beta.mgh', outDir, {'SDirected'}, [0.5 1 2], [1], 'LGN', 5, 13);

%% MelanopsinDirected.
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerYs_sMelanopsinDirected_A.feat', ...
    'L042714L', 'L042714L', FWHM, INPUT_FILES);
FEATRun2MNI(BASE_PATH, BOLD_DIR, 'TTFMRFlickerYs_sMelanopsinDirected_B.feat', ...
    'L042714L', 'L042714L', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'L042714L';
FEAT_DIRS = {'TTFMRFlickerYs_sMelanopsinDirected_A.feat' 'TTFMRFlickerYs_sMelanopsinDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' }; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' };
glmDirs = CombineRunsFFXGLM_vol(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sMelanopsinDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sMelanopsinDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(glmDirs, [], 'beta.mgh', outDir, {'MelanopsinDirected'}, [0.5 1 2], [1], 'LGN', 5, 13);

