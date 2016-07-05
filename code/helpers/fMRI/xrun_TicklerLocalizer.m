theSubjects = {'G120813A' }%'A092x14A'};

%% Set some parameters
BASE_PATH = '/Volumes/PASSPORT/Imaging/Protocols/TicklerLocalizer/Subjects/';
BOLD_DIR = '/BOLD/';
FWHM = '5';
INPUT_FILE_PREFIX = 'stats';

SUBJECTS_PER_FEAT = { 'G120813A' 'G120813A' 'G120813A' 'G120813A' 'G120813A'};

%% Iterate over subjects

for s = 1:length(theSubjects)
    SUBJECT_FSL = theSubjects{s}; 
    
    % Combine
    INPUT_FILE_PREFIX = 'stats';
    
    % Isochromatic
    FEAT_DIRS = {'TicklerLocalizer_Run1.feat' 'TicklerLocalizer_Run2.feat' 'TicklerLocalizer_Run3.feat' 'TicklerLocalizer_Run4.feat' 'TicklerLocalizer_Run5.feat'};
    nRuns = length(FEAT_DIRS);
    
    COPES = {'cope1'};
    nCopes = length(COPES);
    VARCOPES = {'cope1'};
    
    glmDirs = CombineRunsFFXGLM(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'TicklerLocalizer_xrun', ...
        INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes);
    

    
    
end







