BASE_PATH = '/Data/Imaging/Protocols/TTFMRFlickerX/Subjects/';
BOLD_DIR = '/BOLD/';
FWHM = '0';


%% Control modulations -- GKA -- BRIGHT LIGHT
INPUT_FILES = {'cope1' 'cope2' 'cope3' 'cope4' 'varcope1' 'varcope2' 'varcope3' 'varcope4'};

nRuns = 6;
% Iterate over the runs
for i = 5:8
    FEATRun2fsaverage_sym(BASE_PATH, BOLD_DIR, ['TTFMRFlickerC1_' num2str(i) '.feat'], ...
        'G111513A-TTFMRFlicker', 'G040414A', 'G040414A', FWHM, INPUT_FILES);
    FEAT_DIRS{i} = ['TTFMRFlickerC1_' num2str(i) '.feat'];
end
%% Combine
INPUT_FILE_PREFIX = 'stats'; SUBJECT_FSL = 'G040414A';
nRuns = length(FEAT_DIRS);
COPES = {'cope1' 'cope2' 'cope3' 'cope4'}; nCopes = length(COPES);
VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4'};
[lhGlmDirs rhGlmDirs] = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerC1_xrun.feat', ...
    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
% Analyze the results in the ROIs
outDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerC1_xrun.feat', INPUT_FILE_PREFIX);
AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, 'osgm/gamma.mgh', outDir, {'MelanopsinDirectedRobust' 'MelanopsinDirectedEquivV3_avg_mean = mean(V3_avg);ContrastRobust' 'RodDirected' 'OmniSilent'}, [8], [1], 'Cortex', 5, 13);