BASE_PATH = '/Data/Imaging/Protocols/TTFMRFlickerX/Subjects/';
BOLD_DIR = '/BOLD/vol_smoothing_3mm/sandbox/';
FWHM = '5';

%% Main modulations -- GKA
INPUT_FILES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6' 'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5'  'varcope6'};

% Isochromatic
FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerX_Isochromatic_A.feat', ...
    'L111513L-TTFMRFlicker', 'L031614L', 'L031614La', FWHM, INPUT_FILES);
FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerX_Isochromatic_B.feat', ...
    'L111513L-TTFMRFlicker', 'L031614L', 'L031614Lb', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'L031614L';
FEAT_DIRS = {'TTFMRFlickerX_Isochromatic_A.feat' 'TTFMRFlickerX_Isochromatic_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerX_Isochromatic_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerX_Isochromatic_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'Isochromatic'}, [2 4 8 16 32 64], [1], 'Cortex', 5, 13);


%% LMDirected. Note that in this data set, LMDirected was in session 'a',
% and LMinusMDirected was all in session 'b' (both runs). In all other
% modulations, the two 'A' and 'B' protocols were run in the 'a' and 'b sessions.
FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerX_LMDirected_A.feat', ...
    'L111513L-TTFMRFlicker', 'L031614L', 'L031614La', FWHM, INPUT_FILES);
FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerX_LMDirected_B.feat', ...
    'L111513L-TTFMRFlicker', 'L031614L', 'L031614La', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'L031614L';
FEAT_DIRS = {'TTFMRFlickerX_LMDirected_A.feat' 'TTFMRFlickerX_LMDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerX_LMDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerX_LMDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'LMDirected'}, [2 4 8 16 32 64], [1], 'Cortex', 5, 13);


%% LMinusMDirected
FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerX_LMinusMDirected_A.feat', ...
    'L111513L-TTFMRFlicker', 'L031614L', 'L031614Lb', FWHM, INPUT_FILES);
FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerX_LMinusMDirected_B.feat', ...
    'L111513L-TTFMRFlicker', 'L031614L', 'L031614Lb', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'L031614L';
FEAT_DIRS = {'TTFMRFlickerX_LMinusMDirected_A.feat' 'TTFMRFlickerX_LMinusMDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerX_LMinusMDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerX_LMinusMDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'LMinusMDirected'}, [2 4 8 16 32 64], [1], 'Cortex', 5, 13);

%% SDirected
FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerX_SDirected_A.feat', ...
    'L111513L-TTFMRFlicker', 'L031614L', 'L031614La', FWHM, INPUT_FILES);
FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerX_SDirected_B.feat', ...
    'L111513L-TTFMRFlicker', 'L031614L', 'L031614Lb', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'L031614L';
FEAT_DIRS = {'TTFMRFlickerX_SDirected_A.feat' 'TTFMRFlickerX_SDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerX_SDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerX_SDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'SDirected'}, [2 4 8 16 32 64], [1], 'Cortex', 5, 13);


%% MelanopsinDirected
FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerX_MelanopsinDirected_A.feat', ...
    'L111513L-TTFMRFlicker', 'L031614L', 'L031614La', FWHM, INPUT_FILES);
FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerX_MelanopsinDirected_B.feat', ...
    'L111513L-TTFMRFlicker', 'L031614L', 'L031614Lb', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'L031614L';
FEAT_DIRS = {'TTFMRFlickerX_MelanopsinDirected_A.feat' 'TTFMRFlickerX_MelanopsinDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerX_MelanopsinDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerX_MelanopsinDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'MelanopsinDirected'}, [2 4 8 16 32 64], [1], 'Cortex', 5, 13);

%% Control modulations -- GKA
INPUT_FILES = {'cope1' 'cope2' 'cope3' 'cope4' 'varcope1' 'varcope2' 'varcope3' 'varcope4'};

nRuns = 6;
% Iterate over the runs
for i = 1:nRuns
    FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, ['TTFMRFlickerC1_' num2str(i) '.feat'], ...
        'L111513L-TTFMRFlicker', 'L031614L', 'L031614La', FWHM, INPUT_FILES);
    FEAT_DIRS{i} = ['TTFMRFlickerC1_' num2str(i) '.feat'];
end
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'L031614L';
nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerC1_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerC1_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'MelanopsinDirectedRobust' 'MelanopsinDirectedEquivContrastRobust' 'RodDirected' 'OmniSilent'}, [8], [1], 'Cortex', 5, 13);