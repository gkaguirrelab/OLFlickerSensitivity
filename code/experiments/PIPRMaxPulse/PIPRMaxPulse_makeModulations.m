

%% get some basic subject information
commandwindow;
observerID = GetWithDefault('>> Enter <strong>user name</strong>', 'HERO_test');
observerAgeInYrs = GetWithDefault('>> Enter <strong>observer age</strong>:', 32);
takeTemperatureMeasurements = GetWithDefault('Take Temperature Measurements ?', false);
todayDate = datestr(now, 'mmddyy');
theCalType = OLGetCalibrationEnumerationType;
theCalType = theCalType.CalFileName(3:length(theCalType.CalFileName));

%% Determine the strongest blue PIPR stimulus we can deliver based on our most recent PIPR calculation
[ maxBluePIPRIntensity ] = determineMaxPIPR(observerAgeInYrs, theCalType);

maxBluePIPRIntensity = maxBluePIPRIntensity -  0.0001;
if maxBluePIPRIntensity > 12.85
    maxBluePIPRIntensity = 12.85;
end

%% run the prep script
PIPRMaxPulse_PrepOOC_function(theCalType, maxBluePIPRIntensity)

%% run the exp script
PIPRMaxPulse_ExptOOC_function(observerID, observerAgeInYrs, theCalType, takeTemperatureMeasurements)