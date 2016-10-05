%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prepare for the experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ask for the observer age
commandwindow;
observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_test');
observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
todayDate = datestr(now, 'mmddyy');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Correct the spectrum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic;
theCalType = 'BoxBRandomizedLongCableDStubby1_ND00';
spectroRadiometerOBJ = [];
spectroRadiometerOBJWillShutdownAfterMeasurement = false;
theDirections = {'MelanopsinDirectedSuperMaxMel' 'LMSDirectedSuperMaxLMS' 'PIPRBlue', 'PIPRRed'};

theDirectionsCorrect = [true true false false];
cacheDir = getpref('OneLight', 'cachePath');
materialsPath = getpref('OneLight', 'materialsPath');

for d = 1:length(theDirections)
    % Print out some information
    fprintf(' * Direction:\t<strong>%s</strong>\n', theDirections{d});
    fprintf(' * Observer:\t<strong>%s</strong>\n', observerID);
    fprintf(' * Date:\t<strong>%s</strong>\n', todayDate);
    
    % Correct the cache
    fprintf(' * Starting spectrum-seeking loop...\n');
    [cacheData olCache spectroRadiometerOBJ] = OLCorrectCacheFileOOC(...
        fullfile(cacheDir, 'stimuli', ['Cache-' theDirections{d} '.mat']), ...
        'igdalova@mail.med.upenn.edu', ...
        'PR-670', spectroRadiometerOBJ, spectroRadiometerOBJWillShutdownAfterMeasurement, ...
        'FullOnMeas', false, ...
        'CalStateMeas', false, ...
        'DarkMeas', false, ...
        'REFERENCE_OBSERVER_AGE', observerAgeInYrs, ...
        'ReducedPowerLevels', false, ...
        'selectedCalType', theCalType, ...
        'CALCULATE_SPLATTER', false, ...
        'lambda', 0.8, ...
        'NIter', 10, ...
        'powerLevels', [0 1.0000], ...
        'doCorrection', theDirectionsCorrect(d), ...
        'postreceptoralCombinations', [1 1 1 0 ; 1 -1 0 0 ; 0 0 1 0 ; 0 0 0 1], ...
        'outDir', fullfile(materialsPath, 'PIPRMaxPulse', todayDate));
    fprintf(' * Spectrum seeking finished!\n');
    
    % Save the cache
    fprintf(' * Saving cache ...');
    params = cacheData.data(observerAgeInYrs).describe.params;
    params.modulationDirection = theDirections{d};
    params.cacheFile = ['Cache-' params.modulationDirection '_' observerID '_' todayDate '.mat'];
    OLReceptorIsolateSaveCache(cacheData, olCache, params);
    fprintf('done!\n');
end

if (~isempty(spectroRadiometerOBJ))
    spectroRadiometerOBJ.shutDown();
    spectroRadiometerOBJ = [];
end
toc;