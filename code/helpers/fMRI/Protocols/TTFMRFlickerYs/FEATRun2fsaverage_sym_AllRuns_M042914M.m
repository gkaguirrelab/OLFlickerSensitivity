BASE_PATH = '/Data/Imaging/Protocols/TTFMRFlickerYs/Subjects/';
BOLD_DIR = '/BOLD';
FWHM = '0';

%% Main modulations -- GKA
INPUT_FILES = {'cope1' 'cope2' 'cope3' 'varcope1' 'varcope2' 'varcope3'};


%% LMDirected. Note that in this data set, LMDirected was in session 'a',
% and LMinusMDirected was all in session 'b' (both runs). In all other
% modulations, the two 'A' and 'B' protocols were run in the 'a' and 'b sessions.
%FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerYs_sLMDirected_A.feat', ...
    %'M111913M-TTFMRFlicker', 'M042914M', 'M042914M', FWHM, INPUT_FILES);
%FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerYs_sLMDirected_B.feat', ...
    %'M111913M-TTFMRFlicker', 'M042914M', 'M042914M', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M042914M';
FEAT_DIRS = {'TTFMRFlickerYs_sLMDirected_A.feat' 'TTFMRFlickerYs_sLMDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sLMDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sLMDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'LMDirected'}, [0.5 1 2], [1], 'Cortex', 5, 13);


%% LMinusMDirected
%FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerYs_sLMinusMDirected_A.feat', ...
    %'M111913M-TTFMRFlicker', 'M042914M', 'M042914M', FWHM, INPUT_FILES);
%FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerYs_sLMinusMDirected_B.feat', ...
    %'M111913M-TTFMRFlicker', 'M042914M', 'M042914M', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M042914M';
FEAT_DIRS = {'TTFMRFlickerYs_sLMinusMDirected_A.feat' 'TTFMRFlickerYs_sLMinusMDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sLMinusMDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sLMinusMDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'LMinusMDirected'}, [0.5 1 2], [1], 'Cortex', 5, 13);

%% SDirected
%FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerYs_sSDirected_A.feat', ...
    %'M111913M-TTFMRFlicker', 'M042914M', 'M042914M', FWHM, INPUT_FILES);
%FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerYs_sSDirected_B.feat', ...
    %'M111913M-TTFMRFlicker', 'M042914M', 'M042914M', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M042914M';
FEAT_DIRS = {'TTFMRFlickerYs_sSDirected_A.feat' 'TTFMRFlickerYs_sSDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sSDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sSDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'SDirected'}, [0.5 1 2], [1], 'Cortex', 5, 13);


%% MelanopsinDirected
%FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerYs_sMelanopsinDirected_A.feat', ...
    %'M111913M-TTFMRFlicker', 'M042914M', 'M042914M', FWHM, INPUT_FILES);
%FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerYs_sMelanopsinDirected_B.feat', ...
    %'M111913M-TTFMRFlicker', 'M042914M', 'M042914M', FWHM, INPUT_FILES);
%FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerYs_sMelanopsinDirected_C.feat', ...
    %'M111913M-TTFMRFlicker', 'M042914M', 'M042914M', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M042914M';
FEAT_DIRS = {'TTFMRFlickerYs_sMelanopsinDirected_A.feat' 'TTFMRFlickerYs_sMelanopsinDirected_B.feat' 'TTFMRFlickerYs_sMelanopsinDirected_C.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sMelanopsinDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sMelanopsinDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'MelanopsinDirected'}, [0.5 1 2], [1], 'Cortex', 5, 13);