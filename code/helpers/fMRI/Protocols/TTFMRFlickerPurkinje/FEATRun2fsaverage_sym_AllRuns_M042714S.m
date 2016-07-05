BASE_PATH = '/Data/Imaging/Protocols/TTFMRFlickerPurkinje/Subjects/';
BOLD_DIR = '/BOLD';
FWHM = '0';

INPUT_FILES = {'cope1' 'cope2' 'cope3' 'varcope1' 'varcope2' 'varcope3'};

%% LMDirectedScaled (0.5-2 Hz)
%FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerPurkinje_sLMDirectedScaled_A.feat', ...
    %'M111913S-TTFMRFlicker', 'M042714S', 'M042714S', FWHM, INPUT_FILES);
%FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerPurkinje_sLMDirectedScaled_B.feat', ...
    %'M111913S-TTFMRFlicker', 'M042714S', 'M042714S', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M042714S';
FEAT_DIRS = {'TTFMRFlickerPurkinje_sLMDirectedScaled_A.feat' 'TTFMRFlickerPurkinje_sLMDirectedScaled_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerPurkinje_sLMDirectedScaled_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerPurkinje_sLMDirectedScaled_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'sLMDirectedScaled'}, [0.5 1 2], [1], 'Cortex', 5, 13);

%% Main modulations
INPUT_FILES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6' 'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5'  'varcope6'};

%% LMDirectedScaled (2-64 Hz)
%FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerPurkinje_LMDirectedScaled_A.feat', ...
    %'M111913S-TTFMRFlicker', 'M042714S', 'M042714S', FWHM, INPUT_FILES);
%FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerPurkinje_LMDirectedScaled_B.feat', ...
    %'M111913S-TTFMRFlicker', 'M042714S', 'M042714S', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M042714S';
FEAT_DIRS = {'TTFMRFlickerPurkinje_LMDirectedScaled_A.feat' 'TTFMRFlickerPurkinje_LMDirectedScaled_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerPurkinje_LMDirectedScaled_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerPurkinje_LMDirectedScaled_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'LMDirectedScaled'}, [2 4 8 16 32 64], [1], 'Cortex', 5, 13);

%% LMPenumbraDirectedScaled (2-64 Hz)
%FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerPurkinje_LMPenumbraDirected_A.feat', ...
    %'M111913S-TTFMRFlicker', 'M042714S', 'M042714S', FWHM, INPUT_FILES);
%FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, 'TTFMRFlickerPurkinje_LMPenumbraDirected_B.feat', ...
    %'M111913S-TTFMRFlicker', 'M042714S', 'M042714S', FWHM, INPUT_FILES);
% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M042714S';
FEAT_DIRS = {'TTFMRFlickerPurkinje_LMPenumbraDirected_A.feat' 'TTFMRFlickerPurkinje_LMPenumbraDirected_B.feat'}; nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerPurkinje_LMPenumbraDirected_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerPurkinje_LMPenumbraDirected_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'LMPenumbraDirected'}, [2 4 8 16 32 64], [1], 'Cortex', 5, 13);
