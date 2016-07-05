%% Make the spike files
basePathData = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data';
basePathSpikes = '/Data/Imaging/Protocols';

% TTFMRFlickerY
protocol = 'TTFMRFlickerY';
subjID = 'G042514A'; MakeSpikesPathFile(fullfile(basePathData, protocol, subjID), fullfile(basePathSpikes, protocol, 'Subjects', subjID, 'BOLD', '_covariates', '_spikes'), protocol);
subjID = 'M041714M'; MakeSpikesPathFile(fullfile(basePathData, protocol, subjID), fullfile(basePathSpikes, protocol, 'Subjects', subjID, 'BOLD', '_covariates', '_spikes'), protocol);
subjID = 'M041814S'; MakeSpikesPathFile(fullfile(basePathData, protocol, subjID), fullfile(basePathSpikes, protocol, 'Subjects', subjID, 'BOLD', '_covariates', '_spikes'), protocol);

% TTFMRFlickerYs
protocol = 'TTFMRFlickerYs';
subjID = 'G042614A'; MakeSpikesPathFile(fullfile(basePathData, protocol, subjID), fullfile(basePathSpikes, protocol, 'Subjects', subjID, 'BOLD', '_covariates', '_spikes'), protocol);
subjID = 'M042914M'; MakeSpikesPathFile(fullfile(basePathData, protocol, subjID), fullfile(basePathSpikes, protocol, 'Subjects', subjID, 'BOLD', '_covariates', '_spikes'), protocol);
subjID = 'M042914S'; MakeSpikesPathFile(fullfile(basePathData, protocol, subjID), fullfile(basePathSpikes, protocol, 'Subjects', subjID, 'BOLD', '_covariates', '_spikes'), protocol);

% TTFMRFlickerPurkinje
protocol = 'TTFMRFlickerPurkinje';
subjID = 'G042614A'; MakeSpikesPathFile(fullfile(basePathData, protocol, subjID), fullfile(basePathSpikes, protocol, 'Subjects', subjID, 'BOLD', '_covariates', '_spikes'), protocol);
subjID = 'M043014M'; MakeSpikesPathFile(fullfile(basePathData, protocol, subjID), fullfile(basePathSpikes, protocol, 'Subjects', subjID, 'BOLD', '_covariates', '_spikes'), protocol);
subjID = 'M042714S'; MakeSpikesPathFile(fullfile(basePathData, protocol, subjID), fullfile(basePathSpikes, protocol, 'Subjects', subjID, 'BOLD', '_covariates', '_spikes'), protocol);

% TTFMRFlickerLMS
protocol = 'TTFMRFlickerLMS';
subjID = 'G050115A'; MakeSpikesPathFile(fullfile(basePathData, protocol, subjID), fullfile(basePathSpikes, protocol, 'Subjects', subjID, 'BOLD', '_covariates', '_spikes'), protocol, [1 3 2 4]);
subjID = 'M050115M'; MakeSpikesPathFile(fullfile(basePathData, protocol, subjID), fullfile(basePathSpikes, protocol, 'Subjects', subjID, 'BOLD', '_covariates', '_spikes'), protocol, [1 3 2 4]);
subjID = 'M050115S'; MakeSpikesPathFile(fullfile(basePathData, protocol, subjID), fullfile(basePathSpikes, protocol, 'Subjects', subjID, 'BOLD', '_covariates', '_spikes'), protocol, [1 3 2 4]);


% TTFMRFlickerNulledMelanopsinHighContrast
protocol = 'TTFMRFlickerNulledMelanopsinHighContrast';
subjID = 'G082115A'; MakeSpikesPathFile(fullfile(basePathData, protocol, subjID), fullfile(basePathSpikes, protocol, 'Subjects', subjID, 'BOLD', '_covariates', '_spikes'), protocol);
subjID = 'M082115M'; MakeSpikesPathFile(fullfile(basePathData, protocol, subjID), fullfile(basePathSpikes, protocol, 'Subjects', subjID, 'BOLD', '_covariates', '_spikes'), protocol);
subjID = 'M082115S'; MakeSpikesPathFile(fullfile(basePathData, protocol, subjID), fullfile(basePathSpikes, protocol, 'Subjects', subjID, 'BOLD', '_covariates', '_spikes'), protocol);


%% Make the covariates for all runs
basePath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data';



% TTFMRFlickerY
protocol = 'TTFMRFlickerY';
MakeCovariatesFSL(basePath, 'G042514A', protocol);
MakeCovariatesFSL(basePath, 'M041714M', protocol);
MakeCovariatesFSL(basePath, 'M041814S', protocol);

% TTFMRFlickerYs
protocol = 'TTFMRFlickerYs';
MakeCovariatesFSL(basePath, 'G042614A', protocol);
MakeCovariatesFSL(basePath, 'M042914M', protocol);
MakeCovariatesFSL(basePath, 'M042914S', protocol);

% TTFMRFlickerPurkinje
protocol = 'TTFMRFlickerPurkinje';
MakeCovariatesFSL(basePath, 'G042614A', protocol); 
MakeCovariatesFSL(basePath, 'M043014M', protocol);
MakeCovariatesFSL(basePath, 'M042714S', protocol);

% TTFMRFlickerLMS
protocol = 'TTFMRFlickerLMS';
MakeCovariatesFSL(basePath, 'G050115A', protocol);
MakeCovariatesFSL(basePath, 'M050115M', protocol);
MakeCovariatesFSL(basePath, 'M050115S', protocol);

% TTFMRFlickerLightFluxControl
protocol = 'TTFMRFlickerLightFluxControl';
MakeCovariatesFSL(basePath, 'G071715A', protocol);
MakeCovariatesFSL(basePath, 'M071715M', protocol);
MakeCovariatesFSL(basePath, 'M071715S', protocol);

% TTFMRFlickerNulled
protocol = 'TTFMRFlickerNulled';
MakeCovariatesFSL(basePath, 'G071715A', protocol);
MakeCovariatesFSL(basePath, 'M071715M', protocol);
MakeCovariatesFSL(basePath, 'M071715S', protocol);

%% TTFMRFlickerNulledMelanopsinHighContrast
protocol = 'TTFMRFlickerNulledMelanopsinHighContrast';
MakeCovariatesFSL(basePath, 'G082115A', protocol);
MakeCovariatesFSL(basePath, 'M082115M', protocol);
MakeCovariatesFSL(basePath, 'M082115S', protocol);

%% TTFMRFlickerOrig
basePath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data';
subjID = 'G111513A';
protocol = 'TTFMRFlicker';
MakeCovariatesFSL(basePath, subjID, protocol)

basePath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data';
subjID = 'M111913M';
protocol = 'TTFMRFlicker';
MakeCovariatesFSL(basePath, subjID, protocol)

basePath = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data';
subjID = 'M111913S';
protocol = 'TTFMRFlicker';
MakeCovariatesFSL(basePath, subjID, protocol)