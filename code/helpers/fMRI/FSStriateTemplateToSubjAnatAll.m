%% Script for all FreeSurfer preps.
addpath(genpath('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code'), false);

%% TTFMRFlickerY
FSStriateTemplateToSubjAnat('G042514A', 'TTFMRFlickerY', false);
FSStriateTemplateToSubjAnat('M041714M', 'TTFMRFlickerY', false);
FSStriateTemplateToSubjAnat('M041814S', 'TTFMRFlickerY', false);

%% TTFMRFlickerY
FSStriateTemplateToSubjAnat('G042614A', 'TTFMRFlickerYs', false);
FSStriateTemplateToSubjAnat('M042914M', 'TTFMRFlickerYs', false);
FSStriateTemplateToSubjAnat('M042914S', 'TTFMRFlickerYs', false);

%% TTFMRFlickerPurkinje
FSStriateTemplateToSubjAnat('G042614A', 'TTFMRFlickerPurkinje', false);
FSStriateTemplateToSubjAnat('M043014M', 'TTFMRFlickerPurkinje', false);
FSStriateTemplateToSubjAnat('M042714S', 'TTFMRFlickerPurkinje', false);

%% MTFOBSLocalizer
FSStriateTemplateToSubjAnat('G120413A', 'MTFOBSLocalizer', false);
FSStriateTemplateToSubjAnat('M121113M', 'MTFOBSLocalizer', false);
FSStriateTemplateToSubjAnat('M120413S', 'MTFOBSLocalizer', false);

%% TicklerLocalizer
FSStriateTemplateToSubjAnat('G120813A', 'TicklerLocalizer', false);
FSStriateTemplateToSubjAnat('M012614M', 'TicklerLocalizer', false);
FSStriateTemplateToSubjAnat('M120813S', 'TicklerLocalizer', false);

%% MRInteraction
FSStriateTemplateToSubjAnat('G091314A', 'MRInteraction', false);
FSStriateTemplateToSubjAnat('A091314B', 'MRInteraction', false);

%% MRLuxotonic
FSStriateTemplateToSubjAnat('G092014A', 'MRLuxotonic', false);
FSStriateTemplateToSubjAnat('A092014B', 'MRLuxotonic', false);
%FSStriateTemplateToSubjAnat('G092714A', 'MRLuxotonic', false);
%FSStriateTemplateToSubjAnat('A092714B', 'MRLuxotonic', false);