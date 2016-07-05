function [nullingVals1 nullingVals2, nullingValsValidation1, nullingValsValidation2, nullingValsLuminance, nullingValsChromaticity, bgSpdSave, modSpdSave, theReceptorStruct, T_receptors, S_receptors, completeFlag] = NullingPopulationData_CheckAndAnalyzeNulling(nullingID, baseDir, whichReceptorsToProbe)

if nargin < 3
    whichReceptorsToProbe = 'InCache';
end

%% Define the basis functions for the postreceptoral mechanisms
B_postreceptoral = [1 1 1 0 ; 1 -1 0 0 ; 0 0 1 0 ; 0 0 0 1]';

%% Load CIE functions
load T_xyz1931
T_xyz = SplineCmf(S_xyz1931, 683*T_xyz1931, [380 2 201]);


%% Screening session
screeningFile = fullfile(baseDir, nullingID, 'screening', [nullingID '-screening-1.mat']);

% Check if the screening file exists
if exist(screeningFile, 'file')
    tmp = load(screeningFile);
    for s = 1:length(tmp.nulling_screening)
        %fprintf('>> Screening #%g [%s]: %g attempt(s).\n', s, char(tmp.nulling_screening{s}.nullingModes), ...
        %tmp.nulling_screening{s}.nTries)
        %fprintf('   * Contrasts: [%.2f | %.2f | %.2f]\n', 100*tmp.nulling_screening{s}.contrasts(1), ...
        %100*tmp.nulling_screening{s}.contrasts(2), 100*tmp.nulling_screening{s}.contrasts(3));
    end
else
    %fprintf('\n*** Screening file does not exist ***\n');
end

%% Nulling session #1
nulling1File = fullfile(baseDir, nullingID, [nullingID '-nulling-1.mat']);

% Check if the screening file exists
if exist(nulling1File, 'file')
    tmp = load(nulling1File);
    for s = 1:length(tmp.nulling)
        %fprintf('>> Nulling %g/%g\n', s, length(tmp.nulling));
        %fprintf('   * Stimulus contrasts [L, M, S, Mel]:\n     [%.2f | %.2f | %.2f | %.2f]\n', 100*tmp.nulling{s}.contrast_calc(1), ...
        %100*tmp.nulling{s}.contrast_calc(2), 100*tmp.nulling{s}.contrast_calc(3), 100*tmp.nulling{s}.contrast_calc(4));
        %fprintf('   * Contrasts: [%.2f LMS | %.2f L-M | %.2f S]\n', 100*tmp.nulling{s}.contrasts(1), ...
        %100*tmp.nulling{s}.contrasts(2), 100*tmp.nulling{s}.contrasts(3));
        
        nullingVals1(s, :) = [tmp.nulling{s}.contrasts(1) tmp.nulling{s}.contrasts(2) tmp.nulling{s}.contrasts(3)];
    end
else
    %fprintf('\n*** Nulling #1 file does not exist ***\n');
    nullingVals1 = [];
end

%% Nulling session #2
nulling2File = fullfile(baseDir, nullingID, [nullingID '-nulling-2.mat']);

% Check if the screening file exists
if exist(nulling2File, 'file')
    tmp = load(nulling2File);
    for s = 1:length(tmp.nulling)
        %fprintf('>> Nulling %g/%g\n', s, length(tmp.nulling));
        %fprintf('   * Stimulus contrasts [L, M, S, Mel]:\n     [%.2f | %.2f | %.2f | %.2f]\n', 100*tmp.nulling{s}.contrast_calc(1), ...
        %100*tmp.nulling{s}.contrast_calc(2), 100*tmp.nulling{s}.contrast_calc(3), 100*tmp.nulling{s}.contrast_calc(4));
        %fprintf('   * Contrasts: [%.2f LMS | %.2f L-M | %.2f S]\n', 100*tmp.nulling{s}.contrasts(1), ...
        %100*tmp.nulling{s}.contrasts(2), 100*tmp.nulling{s}.contrasts(3));
        
        nullingVals2(s, :) = [tmp.nulling{s}.contrasts(1) tmp.nulling{s}.contrasts(2) tmp.nulling{s}.contrasts(3)];
    end
else
    %fprintf('\n*** Nulling #2 file does not exist ***\n');
    nullingVals2 = [];
end

%% Validation file #1
validation1File = fullfile(baseDir, nullingID, 'validation', [nullingID '-nulling-1_validation.mat']);
if exist(validation1File, 'file')
    tmp = load(validation1File);
    for s = 1:length(tmp.nulling)
        %fprintf('>> Nulling validation %g/%g\n', s, length(tmp.nulling));
        switch whichReceptorsToProbe
            case 'LMSTabulatedAbsorbance'
                observerAgeInYrs = tmp.nulling{1, 1}.observerAgeInYrs;
                S = [380 2 201];
                T_receptors(1:3, :) = GetHumanPhotoreceptorSS(S, {'LConeTabulatedAbsorbance' 'MConeTabulatedAbsorbance', 'SConeTabulatedAbsorbance'}, 27.5, observerAgeInYrs, 6, [0 0 0], [], [], []);
                T_receptors(4, :) = tmp.nulling{s}.T_receptors(4, :);
            case 'SS10DegFromFile'
                S = [380 2 201];
                load T_cones_ss10;
                T_receptors(1:3, :) = SplineCmf(S_cones_ss10, T_cones_ss10, S);
                T_receptors(4, :) = tmp.nulling{s}.T_receptors(4, :);
            case 'InCache'
                T_receptors = tmp.nulling{s}.T_receptors;
        end
        bgSpd = tmp.nulling{s}.meas.background.pr670.spectrum;
        modSpd = tmp.nulling{s}.meas.modulation.pr670.spectrum;
        contrast = (T_receptors*(modSpd-bgSpd)) ./ (T_receptors*(bgSpd));
        %fprintf('   * Stimulus contrasts [L, M, S, Mel]:\n     [%.2f | %.2f | %.2f | %.2f]\n', 100*contrast(1), ...
        %100*contrast(2), 100*contrast(3), 100*contrast(4));
        nullingValsValidation1(s, :) = B_postreceptoral \ contrast(1:4);
        
        bgSpdSave{1}(:, s) = bgSpd;
        modSpdSave{1}(:, s) = modSpd;
    end
else
    %fprintf('\n*** Nulling validation #1 file does not exist ***\n');
    nullingValsValidation1 = [];
    bgSpdSave{1}(:, s) = NaN;
    modSpdSave{1}(:, s) = NaN;
end

%% Validation file #2
validation2File = fullfile(baseDir, nullingID, 'validation', [nullingID '-nulling-2_validation.mat']);
if exist(validation2File, 'file')
    tmp = load(validation2File);
    for s = 1:length(tmp.nulling)
        %fprintf('>> Nulling validation %g/%g\n', s, length(tmp.nulling));
        switch whichReceptorsToProbe
            case 'LMSTabulatedAbsorbance'
                observerAgeInYrs = tmp.nulling{1, 1}.observerAgeInYrs;
                S = [380 2 201];
                T_receptors(1:3, :) = GetHumanPhotoreceptorSS(S, {'LConeTabulatedAbsorbance' 'MConeTabulatedAbsorbance', 'SConeTabulatedAbsorbance'}, 27.5, observerAgeInYrs, 6, [0 0 0], [], [], []);
                T_receptors(4, :) = tmp.nulling{s}.T_receptors(4, :);
            case 'SS10DegFromFile'
                S = [380 2 201];
                load T_cones_ss10;
                T_receptors(1:3, :) = SplineCmf(S_cones_ss10, T_cones_ss10, S);
                T_receptors(4, :) = tmp.nulling{s}.T_receptors(4, :);
            case 'InCache'
                T_receptors = tmp.nulling{s}.T_receptors;
        end
        bgSpd = tmp.nulling{s}.meas.background.pr670.spectrum;
        modSpd = tmp.nulling{s}.meas.modulation.pr670.spectrum;
        contrast = (T_receptors*(modSpd-bgSpd)) ./ (T_receptors*(bgSpd));
        %fprintf('   * Stimulus contrasts [L, M, S, Mel]:\n     [%.2f | %.2f | %.2f | %.2f]\n', 100*contrast(1), ...
        %100*contrast(2), 100*contrast(3), 100*contrast(4));
        nullingValsValidation2(s, :) = B_postreceptoral \ contrast(1:4);
        
        bgSpdSave{2}(:, s) = bgSpd;
        modSpdSave{2}(:, s) = modSpd;
    end
    %% Calculate chromaticity and luminance
    bgSpd = tmp.nulling{1}.meas.background.pr670.spectrum;
    nullingValsChromaticity = T_xyz(1:2, :)*bgSpd / sum(T_xyz*bgSpd);
    nullingValsLuminance = T_xyz(2, :)*bgSpd;
    
    observerAgeInYrs = tmp.nulling{1}.observerAgeInYrs;
    theReceptorStruct.observerAgeInYears = observerAgeInYrs;
    theReceptorStruct.fractionBleached = tmp.cache.cacheMelanopsin.data(observerAgeInYrs).describe.fractionBleached(1:4);
    theReceptorStruct.photoreceptorClasses = tmp.cache.cacheMelanopsin.data(observerAgeInYrs).describe.photoreceptors;
    theReceptorStruct.pupilDiameterMm = tmp.cache.cacheMelanopsin.data(observerAgeInYrs).describe.params.pupilDiameterMm;
    theReceptorStruct.fieldSizeDegrees = tmp.cache.cacheMelanopsin.data(observerAgeInYrs).describe.params.fieldSizeDegrees;
    theReceptorStruct.oxygenationFraction = [];
    theReceptorStruct.vesselThickness = [];
    theReceptorStruct.Lshift = 0;
    theReceptorStruct.Mshift = 0;
    theReceptorStruct.Sshift = 0;
    theReceptorStruct.Melshift = 0;
    S_receptors = [380 2 201];
else
    %fprintf('\n*** Nulling validation #2 file does not exist ***\n');
    nullingValsValidation2 = [];
    nullingValsChromaticity = [];
    nullingValsLuminance = [];
    bgSpdSave{2}(:, s) = NaN;
    modSpdSave{2}(:, s) = NaN;
    S_receptors = [];
    T_receptors = [];
    theReceptorStruct = [];
end

if (and(exist(validation1File, 'file'), exist(validation2File, 'file')))
    completeFlag = true;
else
    completeFlag = false;
end
