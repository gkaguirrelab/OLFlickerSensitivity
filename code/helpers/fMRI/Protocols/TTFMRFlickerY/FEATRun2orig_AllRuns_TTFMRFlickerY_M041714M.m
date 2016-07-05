BASE_PATH = '/Data/Imaging/Protocols/TTFMRFlickerY/Subjects/';
BOLD_DIR = '/BOLD';
FWHM = '0';

%% Main modulations -- GKA
INPUT_FILES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6' 'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5'  'varcope6'};
FS_SUBJECT = 'M111913M-TTFMRFlicker';

%% LMDirected. Note that in this data set, LMDirected was in session 'a',
% and LMinusMDirected was all in session 'b' (both runs). In all other
% modulations, the two 'A' and 'B' protocols were run in the 'a' and 'b sessions.
FEATRun2orig(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_LMDirected_A.feat', ...
    FS_SUBJECT, 'M041714M', 'M041714M', FWHM, INPUT_FILES);
FEATRun2orig(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_LMDirected_B.feat', ...
    FS_SUBJECT, 'M041714M', 'M041714M', FWHM, INPUT_FILES);

% % Combine
% INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M041714M';
% FEAT_DIRS = {'TTFMRFlickerY_LMDirected_A.feat' 'TTFMRFlickerY_LMDirected_B.feat'}; nRuns = length(FEAT_DIRS);
% COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
% VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
% glmDirs = CombineRunsFFXGLM_vol(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_LMDirected_xrun.feat', ...
%     INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% % Propagate to surface
% orig2fsaverage_sym(glmDirs, 'beta.mgh', FS_SUBJECT);
% 
% % Analyze the results in the ROIs
% outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_LMDirected_xrun.feat', INPUT_FILE_PREFIX);
% AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'LMDirected'}, [2 4 8 16 32 64], [1], 'Cortex', 5, 13);


%% LMinusMDirected
FEATRun2orig(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_LMinusMDirected_A.feat', ...
    FS_SUBJECT, 'M041714M', 'M041714M', FWHM, INPUT_FILES);
FEATRun2orig(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_LMinusMDirected_B.feat', ...
    FS_SUBJECT, 'M041714M', 'M041714M', FWHM, INPUT_FILES);
% % Combine
% INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M041714M';
% FEAT_DIRS = {'TTFMRFlickerY_LMinusMDirected_A.feat' 'TTFMRFlickerY_LMinusMDirected_B.feat'}; nRuns = length(FEAT_DIRS);
% COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
% VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
% [lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_LMinusMDirected_xrun.feat', ...
%     INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% % Analyze the results in the ROIs
% outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_LMinusMDirected_xrun.feat', INPUT_FILE_PREFIX);
% AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'LMinusMDirected'}, [2 4 8 16 32 64], [1], 'Cortex', 5, 13);

%% SDirected
FEATRun2orig(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_SDirected_A.feat', ...
    FS_SUBJECT, 'M041714M', 'M041714M', FWHM, INPUT_FILES);
FEATRun2orig(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_SDirected_B.feat', ...
    FS_SUBJECT, 'M041714M', 'M041714M', FWHM, INPUT_FILES);
% % Combine
% INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M041714M';
% FEAT_DIRS = {'TTFMRFlickerY_SDirected_A.feat' 'TTFMRFlickerY_SDirected_B.feat'}; nRuns = length(FEAT_DIRS);
% COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
% VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
% [lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_SDirected_xrun.feat', ...
%     INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% % Analyze the results in the ROIs
% outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_SDirected_xrun.feat', INPUT_FILE_PREFIX);
% AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'SDirected'}, [2 4 8 16 32 64], [1], 'Cortex', 5, 13);


%% MelanopsinDirected
FEATRun2orig(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_MelanopsinDirected_A.feat', ...
    FS_SUBJECT, 'M041714M', 'M041714M', FWHM, INPUT_FILES);
FEATRun2orig(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_MelanopsinDirected_B.feat', ...
    FS_SUBJECT, 'M041714M', 'M041714M', FWHM, INPUT_FILES);
FEATRun2orig(BASE_PATH, BOLD_DIR, 'TTFMRFlickerY_MelanopsinDirected_C.feat', ...
    FS_SUBJECT, 'M041714M', 'M041714M', FWHM, INPUT_FILES);
% % Combine
% INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'M041714M';
% FEAT_DIRS = {'TTFMRFlickerY_MelanopsinDirected_A.feat' 'TTFMRFlickerY_MelanopsinDirected_B.feat' 'TTFMRFlickerY_MelanopsinDirected_C.feat'}; nRuns = length(FEAT_DIRS);
% COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'}; nCopes = length(COPES);
% VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
% [lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_MelanopsinDirected_xrun.feat', ...
%     INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% % Analyze the results in the ROIs
% outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_MelanopsinDirected_xrun.feat', INPUT_FILE_PREFIX);
% AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'beta.mgh', outDir, {'MelanopsinDirected'}, [2 4 8 16 32 64], [1], 'Cortex', 5, 13);