theSubjects = {'G042614A' 'M042714S' 'M043014M'};

%% Set some parameters
BASE_PATH = '/Data/Imaging/Protocols/TTFMRFlickerPurkinje/Subjects/';
BOLD_DIR = '/BOLD/';
FWHM = '0';
INPUT_FILE_PREFIX = 'stats';


%% Iterate over subjects

for s = 1:length(theSubjects)
    SUBJECT_FSL = theSubjects{s};
    
    % Combine
    INPUT_FILE_PREFIX = 'stats';
    
    %% LMDirected (L+M)
    FEAT_DIRS = {'TTFMRFlickerPurkinje_LMDirectedScaled_A.feat' 'TTFMRFlickerPurkinje_LMDirectedScaled_B.feat'};
    nRuns = length(FEAT_DIRS);
    COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'};
    nCopes = length(COPES);
    VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
    
    glmDirs = CombineRunsFFXGLMxhemis(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerPurkinje_LMDirectedScaled_xrun', ...
        INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, {SUBJECT_FSL SUBJECT_FSL});
    
    %% L+MPenumbra
    FEAT_DIRS = {'TTFMRFlickerPurkinje_LMPenumbraDirected_A.feat' 'TTFMRFlickerPurkinje_LMPenumbraDirected_B.feat'};
    nRuns = length(FEAT_DIRS);
    COPES = {'cope1' 'cope2' 'cope3' 'cope4' 'cope5' 'cope6'};
    nCopes = length(COPES);
    VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4' 'varcope5' 'varcope6'};
    
    glmDirs = CombineRunsFFXGLMxhemis(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerPurkinje_LMPenumbraDirected_xrun', ...
        INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, {SUBJECT_FSL SUBJECT_FSL});

        %% sLMDirected (slow L+M)
    FEAT_DIRS = {'TTFMRFlickerPurkinje_sLMDirected_A.feat' 'TTFMRFlickerPurkinje_sLMDirected_B.feat'};
    nRuns = length(FEAT_DIRS);
    COPES = {'cope1' 'cope2' 'cope3'};
    nCopes = length(COPES);
    VARCOPES = {'varcope1' 'varcope2' 'varcope3'};
    
    glmDirs = CombineRunsFFXGLMxhemis(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerPurkinje_sLMDirectedScaled_xrun', ...
        INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, {SUBJECT_FSL SUBJECT_FSL});

    
end






theSubjects = {'G042614A' 'M042914S' 'M042914M'};

%% Set some parameters
BASE_PATH = '/Data/Imaging/Protocols/TTFMRFlickerYs/Subjects/';
BOLD_DIR = '/BOLD/';
FWHM = '0';
INPUT_FILE_PREFIX = 'stats';


%% Iterate over subjects

for s = 1:length(theSubjects)
    SUBJECT_FSL = theSubjects{s};
    
    % Combine
    INPUT_FILE_PREFIX = 'stats';
    
        %% sLMDirected (slow L+M)
    FEAT_DIRS = {'TTFMRFlickerYs_sLMDirected_A.feat' 'TTFMRFlickerYs_sLMDirected_B.feat'};
    nRuns = length(FEAT_DIRS);
    COPES = {'cope1' 'cope2' 'cope3'};
    nCopes = length(COPES);
    VARCOPES = {'varcope1' 'varcope2' 'varcope3'};
    
    glmDirs = CombineRunsFFXGLMxhemis(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sLMDirected_xrun', ...
        INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, {SUBJECT_FSL SUBJECT_FSL});

          %% sLMinusMDirected (slow L-M)
    FEAT_DIRS = {'TTFMRFlickerYs_sLMinusMDirected_A.feat' 'TTFMRFlickerYs_sLMinusMDirected_B.feat'};
    nRuns = length(FEAT_DIRS);
    COPES = {'cope1' 'cope2' 'cope3'};
    nCopes = length(COPES);
    VARCOPES = {'varcope1' 'varcope2' 'varcope3'};
    
    glmDirs = CombineRunsFFXGLMxhemis(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sLMinusMDirected_xrun', ...
        INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, {SUBJECT_FSL SUBJECT_FSL});  
 
    
          %% sSDirected (slow S)
    FEAT_DIRS = {'TTFMRFlickerYs_sSDirected_A.feat' 'TTFMRFlickerYs_sSDirected_B.feat'};
    nRuns = length(FEAT_DIRS);
    COPES = {'cope1' 'cope2' 'cope3'};
    nCopes = length(COPES);
    VARCOPES = {'varcope1' 'varcope2' 'varcope3'};
    
    glmDirs = CombineRunsFFXGLMxhemis(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sSMDirected_xrun', ...
        INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, {SUBJECT_FSL SUBJECT_FSL});  
    
    
          %% sMelanopsinDirected
    FEAT_DIRS = {'TTFMRFlickerYs_sMelanopsinDirected_A.feat' 'TTFMRFlickerYs_sMelanopsinDirected_B.feat' 'TTFMRFlickerYs_sMelanopsinDirected_C.feat'};
    nRuns = length(FEAT_DIRS);
    COPES = {'cope1' 'cope2' 'cope3'};
    nCopes = length(COPES);
    VARCOPES = {'varcope1' 'varcope2' 'varcope3'};
    
    glmDirs = CombineRunsFFXGLMxhemis(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'TTFMRFlickerYs_sMelanopsinDirected_xrun', ...
        INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, {SUBJECT_FSL SUBJECT_FSL SUBJECT_FSL});  
    
end






