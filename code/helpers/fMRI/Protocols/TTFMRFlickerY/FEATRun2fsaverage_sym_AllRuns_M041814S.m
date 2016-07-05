BASE_PATH = '/Data/Imaging/Protocols/TTFMRFlickerY/Subjects/';
BOLD_DIR = '/BOLD';
FWHM = '0';

%% Main modulations -- GKA
INPUT_FILES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6' 'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5'  'varcope6'};


%% LMDirected. Note that in this data set, LMDirected was in session 'a',
% and LMinusMDirected was all in session 'b' (both runs). In all other
% modulations, the two 'A' and 'B' protocols were run in the 'a' and 'b sessions.
% FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_LMDirected_A.feat', ...
%     'M111913S-TTFMRFlicker', 'M041814S', 'M041814S', FWHM, INPUT_FILES);
% FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_LMDirected_B.feat', ...
%     'M111913S-TTFMRFlicker', 'M041814S', 'M041814S', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M041814S';
FEAT_DIRS = {'TTFMRFlickerY_LMDirected_A.feat' 'TTFMRFlickerY_LMDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_LMDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_LMDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'LMDirected'}, [2 4 8 16 32 64], [1], 'Cortex', 5, 13);


%% LMinusMDirected
% FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_LMinusMDirected_A.feat', ...
%     'M111913S-TTFMRFlicker', 'M041814S', 'M041814S', FWHM, INPUT_FILES);
% FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_LMinusMDirected_B.feat', ...
%     'M111913S-TTFMRFlicker', 'M041814S', 'M041814S', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M041814S';
FEAT_DIRS = {'TTFMRFlickerY_LMinusMDirected_A.feat' 'TTFMRFlickerY_LMinusMDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_LMinusMDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_LMinusMDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'LMinusMDirected'}, [2 4 8 16 32 64], [1], 'Cortex', 5, 13);

%% SDirected
% FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_SDirected_A.feat', ...
%     'M111913S-TTFMRFlicker', 'M041814S', 'M041814S', FWHM, INPUT_FILES);
% FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_SDirected_B.feat', ...
%     'M111913S-TTFMRFlicker', 'M041814S', 'M041814S', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M041814S';
FEAT_DIRS = {'TTFMRFlickerY_SDirected_A.feat' 'TTFMRFlickerY_SDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_SDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_SDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'SDirected'}, [2 4 8 16 32 64], [1], 'Cortex', 5, 13);


%% MelanopsinDirected
% FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_MelanopsinDirected_A.feat', ...
%     'M111913S-TTFMRFlicker', 'M041814S', 'M041814S', FWHM, INPUT_FILES);
% FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_MelanopsinDirected_B.feat', ...
%     'M111913S-TTFMRFlicker', 'M041814S', 'M041814S', FWHM, INPUT_FILES);
% FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_MelanopsinDirected_C.feat', ...
%     'M111913S-TTFMRFlicker', 'M041814S', 'M041814S', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M041814S';
FEAT_DIRS = {'TTFMRFlickerY_MelanopsinDirected_A.feat' 'TTFMRFlickerY_MelanopsinDirected_B.feat' 'TTFMRFlickerY_MelanopsinDirected_C.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_MelanopsinDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_MelanopsinDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'MelanopsinDirected'}, [2 4 8 16 32 64], [1], 'Cortex', 5, 13);