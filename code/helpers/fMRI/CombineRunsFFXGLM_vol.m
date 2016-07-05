function glmDirs = CombineRunsFFXGLM(BASE_PATH, SUBJECT_FSL, BOLD_DIR, COMBINED_DIR, INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes)

% Test whether the number of passed FEAT_DIRS is equal to the number of
% runs claimed in 'runs'
if ~(nRuns == length(FEAT_DIRS))
    error('ERROR: Inconsistency between number of passed FEAT dirs and runs in nRuns');
end

for j = 1:nRuns
    disp(['Processing ' FEAT_DIRS{j}]);
end

% Test whether the nmber of COPEs and VARCOPEs is consistent with what's in
% nCopes
if ~(nCopes == length(COPES)) || ~(nCopes == length(VARCOPES))
    error('ERROR: Inconsistency between number of passed COPEs/VARCOPEs and COPEs in nCopes');
end

%% Create an output folder
INPUT_FILE_PREFIX = 'stats';
xrunFolder = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, COMBINED_DIR, INPUT_FILE_PREFIX);
if ~isdir(xrunFolder)
    mkdir(xrunFolder);
end

%% Iterate over copess, then iterate over runs

%% Concatenate runs
% Keep track of the GlmDirs
glmCount = 1;
for i = 1:nCopes
    % Concatenate runs
    outFile = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, COMBINED_DIR, INPUT_FILE_PREFIX, ['cope' num2str(i) '.xrun_osgm.vol.orig.nii.gz']);
    theInputs = [];
    theSubjects = [];
    for j = 1:nRuns % Assemble the inputs
        theInputs = [theInputs ' ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIRS{j}, INPUT_FILE_PREFIX, ['cope' num2str(i) '.vol.orig.nii.gz '])];
    end
    commandc = ['fslmerge -t ' outFile ' ' theInputs];
    [RuN o] = system(commandc);
    if RuN ~= 0
        disp (['WARNING: fslmerge error on cope ' num2str(i)]);
    else
        disp (['SUCCESS: fslmerge on cope ' num2str(i)]);
    end
    
    % Concatenate runs
    outFile = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, COMBINED_DIR, INPUT_FILE_PREFIX, ['varcope' num2str(i) '.xrun_osgm.vol.orig.nii.gz']);
    theInputs = [];
    theSubjects = [];
    for j = 1:nRuns % Assemble the inputs
        theInputs = [theInputs ' ' fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIRS{j}, INPUT_FILE_PREFIX, ['varcope' num2str(i) '.vol.orig.nii.gz '])];
    end
    commandc = ['fslmerge -t ' outFile ' ' theInputs];
    [RuN o] = system(commandc);
    if RuN ~= 0
        disp (['WARNING: fslmerge error on varcope ' num2str(i)]);
    else
        disp (['SUCCESS: fslmerge on varcope ' num2str(i)]);
    end
    
    % Figure out the DOFs by reading them from the file 'dof' which exists
    % in each of FEAT's 'stats' directory.
    DOF = 0;
    for j = 1:nRuns
        tmp = csvread(fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, FEAT_DIRS{j}, INPUT_FILE_PREFIX, 'dof'));
        DOF = DOF + tmp;
    end
    if (DOF == 0)
        disp (['WARNING: DOF ' num2str(DOF)]);
    else
        disp (['SUCCESS: DOF ' num2str(DOF)]);
    end
    
    % Do the GLM
    inputXRun = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, COMBINED_DIR, INPUT_FILE_PREFIX, ['cope' num2str(i) '.xrun_osgm.vol.orig.nii.gz']);
    inputXRunVar = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, COMBINED_DIR, INPUT_FILE_PREFIX, ['varcope' num2str(i) '.xrun_osgm.vol.orig.nii.gz']);
    glmDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, COMBINED_DIR, INPUT_FILE_PREFIX, ['cope' num2str(i) '.vol.orig.osgm.ffx']);
    commandc = ['mri_glmfit --y  ' inputXRun ' --yffxvar ' inputXRunVar ' --ffxdof ' num2str(DOF)  ...
        ' --osgm --glmdir ' glmDir];
    [RuN o] = system(commandc);
    if RuN ~= 0
        disp (['WARNING: mri_glmfit on cope ' num2str(i)]);
    else
        disp (['SUCCESS: mri_glmfit on cope ' num2str(i)]);
    end
    % Keep track of the outputs, we will return them from this function.
    glmDirs{glmCount} = glmDir; glmCount = glmCount+1;
end