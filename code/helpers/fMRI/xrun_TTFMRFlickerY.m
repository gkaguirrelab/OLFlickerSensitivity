theSubjects = {'G042514A' 'M041714M' 'M041814S'};

%% Set some parameters
BASE_PATH = '/Data/Imaging/Protocols/TTFMRFlickerY/Subjects/';
BOLD_DIR = '/BOLD/';
FWHM = '0';
INPUT_FILE_PREFIX = 'stats';


%% Iterate over subjects

for s = 1:length(theSubjects)
    SUBJECT_FSL = theSubjects{s};
    
    % Combine
    INPUT_FILE_PREFIX = 'stats';
    
    %% LMDirected (L+M)
    FEAT_DIRS = {'TTFMRFlickerY_LMDirected_A.feat' 'TTFMRFlickerY_LMDirected_B.feat'};
    nRuns = length(FEAT_DIRS);
    COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'};
    nCopes = length(COPES);
    VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
    
    glmDirs = CombineRunsFFXGLMxhemis(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_LMDirected_xrun', ...
        INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, {SUBJECT_FSL SUBJECT_FSL});
    
    %% LMinusMDirected (L-M)
    FEAT_DIRS = {'TTFMRFlickerY_LMinusMDirected_A.feat' 'TTFMRFlickerY_LMinusMDirected_B.feat'};
    nRuns = length(FEAT_DIRS);
    COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'};
    nCopes = length(COPES);
    VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
    
    glmDirs = CombineRunsFFXGLMxhemis(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_LMinusMDirected_xrun', ...
        INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, {SUBJECT_FSL SUBJECT_FSL});
    
    %% SDirected (S)
    FEAT_DIRS = {'TTFMRFlickerY_SDirected_A.feat' 'TTFMRFlickerY_SDirected_B.feat'};
    nRuns = length(FEAT_DIRS);
    COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'};
    nCopes = length(COPES);
    VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
    
    glmDirs = CombineRunsFFXGLMxhemis(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_SDirected_xrun', ...
        INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes,{SUBJECT_FSL SUBJECT_FSL});
    
    %% MelanopsinDirected
    FEAT_DIRS = {'TTFMRFlickerY_MelanopsinDirected_A.feat' 'TTFMRFlickerY_MelanopsinDirected_B.feat' 'TTFMRFlickerY_MelanopsinDirected_C.feat'};
    nRuns = length(FEAT_DIRS);
    COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'};
    nCopes = length(COPES);
    VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
    
    glmDirs = CombineRunsFFXGLMxhemis(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerY_MelanopsinDirected_xrun', ...
        INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, {SUBJECT_FSL SUBJECT_FSL SUBJECT_FSL});
    
end







