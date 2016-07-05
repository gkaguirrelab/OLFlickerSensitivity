%% Script for all FreeSurfer preps.
addpath(genpath('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code'));

%% TTFMRFlickerY
RunReconFS('G042514A', 'TTFMRFlickerY');
RunReconFS('M041714M', 'TTFMRFlickerY');
RunReconFS('M041814S', 'TTFMRFlickerY');

%% TTFMRFlickerY
RunReconFS('G042614A', 'TTFMRFlickerYs');
RunReconFS('M042914M', 'TTFMRFlickerYs');
RunReconFS('M042914S', 'TTFMRFlickerYs');

%% TTFMRFlickerPurkinje
RunReconFS('G042614A', 'TTFMRFlickerPurkinje');
RunReconFS('M043014M', 'TTFMRFlickerPurkinje');
RunReconFS('M042714S', 'TTFMRFlickerPurkinje');

%% MTFOBSLocalizer
RunReconFS('G120413A', 'MTFOBSLocalizer');
RunReconFS('M121113M', 'MTFOBSLocalizer');
RunReconFS('M120413S', 'MTFOBSLocalizer');

%% TicklerLocalizer
RunReconFS('G120813A', 'TicklerLocalizer');
RunReconFS('M012614M', 'TicklerLocalizer');
RunReconFS('M120813S', 'TicklerLocalizer');

%% MRInteraction
RunReconFS('G091314A', 'MRInteraction');
RunReconFS('A091314B', 'MRInteraction');

%% MRLuxotonic
RunReconFS('G092014A', 'MRLuxotonic');
RunReconFS('A092014B', 'MRLuxotonic');
RunReconFS('G092714A', 'MRLuxotonic');
RunReconFS('A092714B', 'MRLuxotonic');

%% TTFMRFlickerLMS
RunReconFS('G050115A', 'TTFMRFlickerLMS');
RunReconFS('M050115M', 'TTFMRFlickerLMS');
RunReconFS('M050115S', 'TTFMRFlickerLMS');