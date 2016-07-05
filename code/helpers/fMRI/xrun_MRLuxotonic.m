theSubjects = {'M121113M'};%{'G120413A', 'M120413S' 'M120413S'};

%% Set some parameters
BASE_PATH = '/Data/Imaging/Protocols/MTFOBSLocalizer/Subjects/';
BOLD_DIR = '/BOLD/';
FWHM = '5';
INPUT_FILE_PREFIX = 'stats';


%% Iterate over subjects

for s = 1:length(theSubjects)
    SUBJECT_FSL = theSubjects{s}; 
    
    % Combine
    INPUT_FILE_PREFIX = 'stats';
    
    FEAT_DIRS = {'FOBSLocalizer_Run1.feat' 'FOBSLocalizer_Run2.feat' 'FOBSLocalizer_Run3.feat'};
    nRuns = length(FEAT_DIRS);
    
    COPES = {'cope1' 'cope2' 'cope3' 'cope4'};
    nCopes = length(COPES);
    VARCOPES = {'varcope1' 'varcope2' 'varcope3' 'varcope4'};
    
    glmDirs = CombineRunsFFXGLMxhemis(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'FOBSLocalizer_xrun', ...
        INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
    
    % Combine
    INPUT_FILE_PREFIX = 'stats';
    
    FEAT_DIRS = {'MTLocalizer_Run1.feat' 'MTLocalizer_Run2.feat' 'MTLocalizer_Run3.feat'};
    nRuns = length(FEAT_DIRS);
    
    COPES = {'cope1'};
    nCopes = length(COPES);
    VARCOPES = {'varcope1'};
    
    glmDirs = CombineRunsFFXGLMxhemis(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'MTLocalizer_xrun', ...
        INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
    
        

end