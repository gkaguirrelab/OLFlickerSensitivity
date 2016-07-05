function glmDirs = CombineRunsFFXGLMxhemis(BASE_PATH, FWHM, SUBJECT_FSL, BOLD_DIR, COMBINED_DIR, INPUT_FILE_PREFIX, FEAT_DIRS, nRuns, COPES, VARCOPES, nCopes, SUBJECTS_PER_FEAT)

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

%% Concatenate runs and hemis
hemis = {'lh', 'rh'};

% Keep track of the GlmDirs
lhGlmCount = 1;
rhGlmCount = 1;


% Let's do mean_func concatenation

outFile = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, COMBINED_DIR, ['mean_func.xhemi.xrun_osgm.diffeo.sym.mgh']);
theInputs = [];
theSubjects = [];
for j = 1:nRuns % Assemble the inputs
    for h = 1:length(hemis)
        theInputs = [theInputs, ' --is ' fullfile(BASE_PATH, SUBJECTS_PER_FEAT{j}, BOLD_DIR, FEAT_DIRS{j}, ['mean_func.diffeo.' hemis{h} '.sym.mgh '])];
        theSubjects = [theSubjects '--s fsaverage_sym '];
    end
end
commandc = ['mris_preproc --fwhm ' FWHM ' --target fsaverage_sym --out ' outFile ' --hemi lh ' theSubjects theInputs];
[RuN o] = system(commandc);
if RuN ~= 0
    disp (['WARNING: mris_preproc error on mean_func']);
    disp(o);
else
    disp (['SUCCESS: mris_preproc on mean_func']);
end


for i = 1:nCopes
    % Copes
    % both hemispheres
    outFile = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, COMBINED_DIR, INPUT_FILE_PREFIX, ['cope' num2str(i) '.xhemi.xrun_osgm.diffeo.sym.mgh']);
    theInputs = [];
    theSubjects = [];
    for j = 1:nRuns % Assemble the inputs
        for h = 1:length(hemis)
            theInputs = [theInputs, ' --is ' fullfile(BASE_PATH, SUBJECTS_PER_FEAT{j}, BOLD_DIR, FEAT_DIRS{j}, INPUT_FILE_PREFIX, ['cope' num2str(i) '.diffeo.' hemis{h} '.sym.mgh '])];
            theSubjects = [theSubjects '--s fsaverage_sym '];
        end
    end
    commandc = ['mris_preproc --fwhm ' FWHM ' --target fsaverage_sym --out ' outFile ' --hemi lh ' theSubjects theInputs];
    [RuN o] = system(commandc);
    if RuN ~= 0
        disp (['WARNING: mris_preproc error on cope ' num2str(i)]);
        disp(o);
    else
        disp (['SUCCESS: mris_preproc on cope ' num2str(i)]);
    end
    
    % Varcopes
    % both hemispheres
    outFile = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, COMBINED_DIR, INPUT_FILE_PREFIX, ['varcope' num2str(i) '.xhemi.xrun_osgm.diffeo.sym.mgh']);
    theInputs = [];
    theSubjects = [];
    for j = 1:nRuns % Assemble the inputs
        for h = 1:length(hemis)
            theInputs = [theInputs, ' --is ' fullfile(BASE_PATH, SUBJECTS_PER_FEAT{j}, BOLD_DIR, FEAT_DIRS{j}, INPUT_FILE_PREFIX, ['varcope' num2str(i) '.diffeo.' hemis{h} '.sym.mgh '])];
            theSubjects = [theSubjects '--s fsaverage_sym '];
        end
    end
    commandc = ['mris_preproc --fwhm ' FWHM ' --target fsaverage_sym --out ' outFile ' --hemi lh ' theSubjects theInputs];
    [RuN o] = system(commandc);
    if RuN ~= 0
        disp (['WARNING: mris_preproc error on cope ' num2str(i)]);
        disp(o);
    else
        disp (['SUCCESS: mris_preproc on cope ' num2str(i)]);
    end
    
    % Figure out the DOFs by reading them from the file 'dof' which exists
    % in each of FEAT's 'stats' directory.
    DOF = 0;
    for j = 1:nRuns
        tmp = csvread(fullfile(BASE_PATH, SUBJECTS_PER_FEAT{j}, BOLD_DIR, FEAT_DIRS{j}, INPUT_FILE_PREFIX, 'dof'));
        DOF = DOF + tmp;
    end
    if (DOF == 0)
        disp (['WARNING: DOF ' num2str(DOF)]);
        disp(o);
    else
        disp (['SUCCESS: DOF ' num2str(DOF)]);
    end
    
    % Do the GLM on each hemisphere separately
    % Left hemisphere
    hemi = 'lh';
    inputXRun = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, COMBINED_DIR, INPUT_FILE_PREFIX, ['cope' num2str(i) '.xhemi.xrun_osgm.diffeo.sym.mgh']);
    inputXRunVar = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, COMBINED_DIR, INPUT_FILE_PREFIX, ['varcope' num2str(i) '.xhemi.xrun_osgm.diffeo.sym.mgh']);
    glmDir = fullfile(BASE_PATH, SUBJECT_FSL, BOLD_DIR, COMBINED_DIR, INPUT_FILE_PREFIX, ['cope' num2str(i) '.xhemi.osgm.ffx']);
    commandc = ['mri_glmfit --y  ' inputXRun ' --yffxvar ' inputXRunVar ' --ffxdof ' num2str(DOF)  ...
        ' --osgm --glmdir ' glmDir ' --surf fsaverage_sym lh'];
    [RuN o] = system(commandc);
    if RuN ~= 0
        disp (['WARNING: mri_glmfit on cope ' num2str(i)]);
        disp(o);
    else
        disp (['SUCCESS: mri_glmfit on cope ' num2str(i)]);
    end
    % Keep track of the outputs, we will return them from this function.
    glmDirs{lhGlmCount} = glmDir; lhGlmCount = lhGlmCount+1;
end