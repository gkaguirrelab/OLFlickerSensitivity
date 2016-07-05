theSubjects = {'G092x14A' }%'A092x14A'};

%% Set some parameters
BASE_PATH = '/Volumes/PASSPORT/MRLuxotonic/Subjects';
BOLD_DIR = '/BOLD/';
FWHM = '5';
INPUT_FILE_PREFIX = 'stats';

SUBJECTS_PER_FEAT = { 'G092014A' 'G092014A' 'G092014A' 'G092014A' 'G092014A' 'G092014A' 'G092714A' 'G092714A' 'G092714A' 'G092714A' 'G092714A' 'G092714A' ;
    'A092014B' 'A092014B' 'A092014B' 'A092014B' 'A092014B' 'A092014B' 'A092714B' 'A092714B' 'A092714B' 'A092714B' 'A092714B' 'A092714B'};

%% Iterate over subjects

for s = 1:length(theSubjects)
    SUBJECT_FSL = theSubjects{s};
    
    % Combine
    INPUT_FILE_PREFIX = 'stats';
    
    % Isochromatic
    FEAT_DIRS = {'MRLuxotonic_Isochromatic_A.feat' 'MRLuxotonic_Isochromatic_B.feat' 'MRLuxotonic_Isochromatic_C.feat' ...
        'MRLuxotonic_Isochromatic_D.feat' 'MRLuxotonic_Isochromatic_E.feat' 'MRLuxotonic_Isochromatic_F.feat' ...
        'MRLuxotonic_Isochromatic_A.feat' 'MRLuxotonic_Isochromatic_B.feat' 'MRLuxotonic_Isochromatic_C.feat' ...
        'MRLuxotonic_Isochromatic_D.feat' 'MRLuxotonic_Isochromatic_E.feat' 'MRLuxotonic_Isochromatic_F.feat'};
    nRuns = length(FEAT_DIRS);
    
    COPES = {'cope2' 'cope3' };
    nCopes = length(COPES);
    VARCOPES = {'varcope2' 'varcope3'};
    
    %glmDirs = CombineRunsFFXGLMxhemis(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'MRLuxotonic_Isochromatic_xrun', ...
    %    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, SUBJECTS_PER_FEAT);
    %glmDirs = CombineRunsFFXGLM(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'MRLuxotonic_Isochromatic_xrun', ...
    %    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, SUBJECTS_PER_FEAT);
    glmDirs = CombineRunsFFXGLMxcopes(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'MRLuxotonic_Isochromatic_xrun', ...
        INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, SUBJECTS_PER_FEAT);
    
    % LMS
    FEAT_DIRS = {'MRLuxotonic_LMS_A.feat' 'MRLuxotonic_LMS_B.feat' 'MRLuxotonic_LMS_C.feat' ...
        'MRLuxotonic_LMS_D.feat' 'MRLuxotonic_LMS_E.feat' 'MRLuxotonic_LMS_F.feat' ...
        'MRLuxotonic_LMS_A.feat' 'MRLuxotonic_LMS_B.feat' 'MRLuxotonic_LMS_C.feat' ...
        'MRLuxotonic_LMS_D.feat' 'MRLuxotonic_LMS_E.feat' 'MRLuxotonic_LMS_F.feat'};
    nRuns = length(FEAT_DIRS);
    
    COPES = {'cope2' 'cope3' };
    nCopes = length(COPES);
    VARCOPES = {'varcope2' 'varcope3'};
    
    %glmDirs = CombineRunsFFXGLMxhemis(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'MRLuxotonic_LMS_xrun', ...
    %    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, SUBJECTS_PER_FEAT);
    %glmDirs = CombineRunsFFXGLM(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'MRLuxotonic_LMS_xrun', ...
    %    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, SUBJECTS_PER_FEAT);
    glmDirs = CombineRunsFFXGLMxcopes(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'MRLuxotonic_LMS_xrun', ...
        INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, SUBJECTS_PER_FEAT);
    
    % Melanopsin
    FEAT_DIRS = {'MRLuxotonic_Melanopsin_A.feat' 'MRLuxotonic_Melanopsin_B.feat' 'MRLuxotonic_Melanopsin_C.feat' ...
        'MRLuxotonic_Melanopsin_D.feat' 'MRLuxotonic_Melanopsin_E.feat' 'MRLuxotonic_Melanopsin_F.feat' ...
        'MRLuxotonic_Melanopsin_A.feat' 'MRLuxotonic_Melanopsin_B.feat' 'MRLuxotonic_Melanopsin_C.feat' ...
        'MRLuxotonic_Melanopsin_D.feat' 'MRLuxotonic_Melanopsin_E.feat' 'MRLuxotonic_Melanopsin_F.feat'};
    nRuns = length(FEAT_DIRS);
    
    COPES = {'cope2' 'cope3'};
    nCopes = length(COPES);
    VARCOPES = {'varcope2' 'varcope3'};
    
    %glmDirs = CombineRunsFFXGLMxhemis(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'MRLuxotonic_Melanopsin_xrun', ...
    %    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, SUBJECTS_PER_FEAT);
    
    %glmDirs = CombineRunsFFXGLM(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'MRLuxotonic_Melanopsin_xrun', ...
    %    INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, SUBJECTS_PER_FEAT);
    glmDirs = CombineRunsFFXGLMxcopes(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, 'MRLuxotonic_Melanopsin_xrun', ...
        INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, SUBJECTS_PER_FEAT);
    
    
end







