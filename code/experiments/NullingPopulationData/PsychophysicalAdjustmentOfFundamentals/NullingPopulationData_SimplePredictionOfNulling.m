function SimplePredictionOfNulling
% SimplePredictionOfNulling
%
% This is a simple little test function.  What we'll do is as follows.
%
%   a) Assume some nominal CIE cone fundamentals.
%   b) Generate melanopsin isolating and L+M+S stimuli with respect to a)
%   c) Assume some CIE cone parameters for an observer.
%   d) Simulate psychophysical nulling of the stimuli for the observer in c)
%   e) Look at where how the nulls behave as a function of cone parameters.
%
% 10/22/15  dhb  Wrote it.

%% Clear and close
clear; close all;

%% Set up receptor sensitivities
%
% Nominal observer
S = [380 1 401];
photoreceptorClasses = {'LCone', 'MCone', 'SCone', 'Melanopsin'};

% Allowable types, 'CIE', 'SmithPokorny10'. 'StockmanSharpe10'
nominalCones.type = 'CIE';
nominalCones.fieldSizeDegrees = 27.5;
nominalCones.observerAgeInYears = 32;
nominalCones.pupilDiameterMm = 4.7;
nominalCones.Lshift = 0;
nominalCones.Mshift = 0;
nominalCones.Sshift = 0;
nominalCones.Melshift = 0;
T_nominalReceptors = GetReceptorsFromStruct(S, photoreceptorClasses, nominalCones);
     
% Actual observer
actualCones.type = 'CIE';
actualCones.fieldSizeDegrees = 27.5;
actualCones.observerAgeInYears = 60;
actualCones.pupilDiameterMm = 4.7;
actualCones.Lshift = 0;
actualCones.Mshift = 0;
actualCones.Sshift = 0;
actualCones.Melshift = 0;
T_actualReceptors = GetReceptorsFromStruct(S, photoreceptorClasses, actualCones);

% Plot photoreceptor sensitivities
photoreceptorFig = figure; clf; hold on
plot(SToWls(S),T_nominalReceptors','LineWidth',2);
plot(SToWls(S),T_actualReceptors',':','LineWidth',2);
xlabel('Wavelength (nm)')
ylabel('Sensitivity');
title('Normalized photoreceptor sensitivities');
   
%% Define device primaries and some modulation parametres
% These are taken from the OneLight demo file in the SilentSubstitutionToolbox.
% We also set here the parameters for our receptor isolation code that work
% reasonably well for these primaries.
%
% Get a OneLight calibration file, stored here for demo purposes.
% Extract the descrption of spectral primaries, which is what we
% need for this demo.  Gamma correction of primary values to
% settings would need to be handled to get the device to actually
% produce the spectrum, but here we are just finding the desired
% modulation.
calPath = fullfile(fileparts(which('ReceptorIsolateDemo')), 'ReceptorIsolateDemoData', []);
cal = LoadCalFile('OneLightDemoCal.mat',[],calPath);
B_primary = SplineSpd(cal.describe.S,cal.computed.pr650M,S);
ambientSpd = SplineSpd(cal.describe.S,cal.computed.pr650MeanDark,S);

% Background is half on in primary space
backgroundPrimary = 0.5*ones(size(B_primary,2),1);

% Set primary headroom smoothness constraint for dir optimization
primaryHeadRoom = 0.02;
maxPowerDiff = 10^-1.5;

%% Specify the modulations we want
%
% These are defined with respect to the nominal photoreceptor
% sensitivities.
%
% Melanopsin isolating
whichReceptorsToTarget = [4];
whichReceptorsToIgnore = [];
whichReceptorsToMinimize = [];
whichPrimariesToPin = [];
desiredContrast = [0.4];
melIsolateDirPrimary = ReceptorIsolate(T_nominalReceptors,whichReceptorsToTarget, whichReceptorsToIgnore, whichReceptorsToMinimize, ...
    B_primary, backgroundPrimary, backgroundPrimary, whichPrimariesToPin,...
    primaryHeadRoom, maxPowerDiff, desiredContrast, ambientSpd) - backgroundPrimary;
fprintf('\n');
nominalMelIsolateContrast = ComputeAndReportContrastsFromOLPrimaries('Nominal receptors Mel isolating dir',photoreceptorClasses,T_nominalReceptors,B_primary,backgroundPrimary,melIsolateDirPrimary,ambientSpd);
actualMelIsolateContrast = ComputeAndReportContrastsFromOLPrimaries('Actual receptors Mel isolating dir',photoreceptorClasses,T_actualReceptors,B_primary,backgroundPrimary,melIsolateDirPrimary,ambientSpd);

% L+M+S isolating
whichReceptorsToTarget = [1 2 3];
whichReceptorsToIgnore = [];
whichReceptorsToMinimize = [];
whichPrimariesToPin = [];
desiredContrast = [0.4 0.4 0.4];
LMSIsolateDirPrimary = ReceptorIsolate(T_nominalReceptors,whichReceptorsToTarget, whichReceptorsToIgnore, whichReceptorsToMinimize, ...
    B_primary, backgroundPrimary, backgroundPrimary, whichPrimariesToPin,...
    primaryHeadRoom, maxPowerDiff, desiredContrast, ambientSpd) - backgroundPrimary;
fprintf('\n');
nominalLMSIsolateContrast = ComputeAndReportContrastsFromOLPrimaries('Nominal receptors L+M+S isolating dir',photoreceptorClasses,T_nominalReceptors,B_primary,backgroundPrimary,LMSIsolateDirPrimary,ambientSpd);
actuallLMSIsolateContrast = ComputeAndReportContrastsFromOLPrimaries('Actual receptors L+M+S isolating dir',photoreceptorClasses,T_actualReceptors,B_primary,backgroundPrimary,LMSIsolateDirPrimary,ambientSpd);

% Plot modulation spectra
modulationSpectraFig = figure; hold on
plot(SToWls(S),B_primary*(melIsolateDirPrimary+backgroundPrimary)+ambientSpd,'b','LineWidth',2);
plot(SToWls(S),B_primary*(LMSIsolateDirPrimary+backgroundPrimary)+ambientSpd,'r','LineWidth',2);
plot(SToWls(S),B_primary*backgroundPrimary+ambientSpd,'k','LineWidth',2);
title('Modulation spectra');
xlim([380 780]);
xlabel('Wavelength');
ylabel('Power');
pbaspect([1 1 1]);

%% Set up nulling modulations
% 
% Adjustments are made in the L-M direction defined with respect to the
% nominal observer.  I am not entirely sure how Manuel instruments this,
% but I would guess that he adds in the right amount of L-M modulation 
% to cancel the redness-greenness, then the right amount of L+M+S contrast
% to cancel the flicker (which we assume means zeroing out L and M.)

% Find L-M equal contrast modulation to use for red-green nulling
whichReceptorsToTarget = [1 2];
whichReceptorsToIgnore = [];
whichReceptorsToMinimize = [];
whichPrimariesToPin = [];
nominalLMinusMContrastBase = 0.05;
desiredContrast = [nominalLMinusMContrastBase -nominalLMinusMContrastBase];
LMinusMAdjustPrimaryDir = ReceptorIsolate(T_nominalReceptors,whichReceptorsToTarget, whichReceptorsToIgnore, whichReceptorsToMinimize, ...
    B_primary, backgroundPrimary, backgroundPrimary, whichPrimariesToPin,...
    primaryHeadRoom, maxPowerDiff, desiredContrast, ambientSpd) - backgroundPrimary;
fprintf('\n');
nominalLMinusMDirContrastReceptor = ComputeAndReportContrastsFromOLPrimaries('Nominal receptors L-M dir',photoreceptorClasses,T_nominalReceptors,B_primary,backgroundPrimary,LMinusMAdjustPrimaryDir,ambientSpd);
actualLMinusMDirContrastReceptor = ComputeAndReportContrastsFromOLPrimaries('Actual receptors L-M dir',photoreceptorClasses,T_actualReceptors,B_primary,backgroundPrimary,LMinusMAdjustPrimaryDir,ambientSpd);

% Find L+M+S equal contrast modulation to use for flicker nulling
whichReceptorsToTarget = [1 2 3];
whichReceptorsToIgnore = [];
whichReceptorsToMinimize = [];
whichPrimariesToPin = [];
nominalLMSContrastBase = 0.05;
desiredContrast = [nominalLMSContrastBase nominalLMSContrastBase nominalLMSContrastBase];
LMSAdjustPrimaryDir = ReceptorIsolate(T_nominalReceptors,whichReceptorsToTarget, whichReceptorsToIgnore, whichReceptorsToMinimize, ...
    B_primary, backgroundPrimary, backgroundPrimary, whichPrimariesToPin,...
    primaryHeadRoom, maxPowerDiff, desiredContrast, ambientSpd) - backgroundPrimary;
fprintf('\n');
nominalLMSDirContrastReceptor = ComputeAndReportContrastsFromOLPrimaries('Nominal receptors LMS dir',photoreceptorClasses,T_nominalReceptors,B_primary,backgroundPrimary,LMSAdjustPrimaryDir,ambientSpd);
actualLMSDirContrastReceptor = ComputeAndReportContrastsFromOLPrimaries('Actual receptors LMS dir',photoreceptorClasses,T_actualReceptors,B_primary,backgroundPrimary,LMSAdjustPrimaryDir,ambientSpd);

%% Simulate nulling
[melLMinusMNullContrast, melLMSNullContrast, LMSLMinusMNullContrast] = SimulateNulling(T_nominalReceptors,T_actualReceptors,B_primary,backgroundPrimary,ambientSpd, ...
    melIsolateDirPrimary,LMSIsolateDirPrimary,LMinusMAdjustPrimaryDir,LMSAdjustPrimaryDir,nominalLMinusMContrastBase,nominalLMSContrastBase,photoreceptorClasses);
fprintf('\n');
fprintf('\tActual Mel red/green null, nominal L-M contrast added = %0.1f%%\n',100*melLMinusMNullContrast);
fprintf('\tActual Mel flicker null, nomnial L+M+S contrast added = %0.1f%%\n',100*melLMSNullContrast);
fprintf('\tActual L+M+S red/green null nominal L-M contrast added = %0.1f%%\n',100*LMSLMinusMNullContrast);
PrintReceptors(actualCones);

%% Run a parameter search to look for parameters that best account for nulling
fprintf('Searching, searching ....\n');
targetNulls = [-0.015 -0.015 0.015];
searchCones = actualCones;
searchCones.type = 'CIE';
x0 = [searchCones.fieldSizeDegrees searchCones.observerAgeInYears searchCones.pupilDiameterMm searchCones.Lshift searchCones.Mshift];
vlb = [5 20 3 -15 -15];
vub = [50 80 6 15 15];

% ga
optionsGA = gaoptimset('ga');
optionsGA = gaoptimset(optionsGA,'Display','off');
optionsGA = gaoptimset(optionsGA,'MutationFcn',@mutationadaptfeasible);
nParams=size(x0,2);
xGA = ga(@(x)ConeParametersSearchFun(x,targetNulls,S, ...
    T_nominalReceptors,nominalCones,B_primary,backgroundPrimary,ambientSpd, ...
    melIsolateDirPrimary,LMSIsolateDirPrimary,LMinusMAdjustPrimaryDir,LMSAdjustPrimaryDir,nominalLMinusMContrastBase,nominalLMSContrastBase,photoreceptorClasses),...    
   	nParams,[],[],[],[],vlb,vub,[],optionsGA);
xGA = x0;

% pattern search
optionsPS=psoptimset('patternsearch');
optionsPS=psoptimset(optionsPS,'Display','off');
xPS = patternsearch(@(x)ConeParametersSearchFun(x,targetNulls,S, ...
    T_nominalReceptors,nominalCones,B_primary,backgroundPrimary,ambientSpd, ...
    melIsolateDirPrimary,LMSIsolateDirPrimary,LMinusMAdjustPrimaryDir,LMSAdjustPrimaryDir,nominalLMinusMContrastBase,nominalLMSContrastBase,photoreceptorClasses),... 
    xGA,[],[],[],[],vlb,vub,[],optionsPS);
xPS

% fmincon
options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');
x = fmincon(@(x)ConeParametersSearchFun(xPS,targetNulls,S, ...
    T_nominalReceptors,nominalCones,B_primary,backgroundPrimary,ambientSpd, ...
    melIsolateDirPrimary,LMSIsolateDirPrimary,LMinusMAdjustPrimaryDir,LMSAdjustPrimaryDir,nominalLMinusMContrastBase,nominalLMSContrastBase,photoreceptorClasses),...    
    x0,[],[],[],[],vlb,vub,[],options);
x

searchCones.fieldSizeDegrees = x(1);
searchCones.observerAgeInYears = x(2);
searchCones.pupilDiameterMm = x(3);
searchCones.Lshift = x(4);
searchCones.Mshift = x(5);
T_searchReceptors = GetReceptorsFromStruct(S, photoreceptorClasses, searchCones);

[melLMinusMNullContrast, melLMSNullContrast, LMSLMinusMNullContrast] = SimulateNulling(T_nominalReceptors,T_searchReceptors,B_primary,backgroundPrimary,ambientSpd, ...
    melIsolateDirPrimary,LMSIsolateDirPrimary,LMinusMAdjustPrimaryDir,LMSAdjustPrimaryDir,nominalLMinusMContrastBase,nominalLMSContrastBase,photoreceptorClasses);
fprintf('\tSearch Mel red/green null, nominal L-M contrast added = %0.1f%%\n',100*melLMinusMNullContrast);
fprintf('\tSearch Mel flicker null, nomnial L+M+S contrast added = %0.1f%%\n',100*melLMSNullContrast);
fprintf('\tSearch L+M+S red/green null nominal L-M contrast added = %0.1f%%\n',100*LMSLMinusMNullContrast);
PrintReceptors(searchCones);

%% Save some figures
FigureSave(sprintf('Nominal_Sensitivities.pdf'),photoreceptorFig,'pdf');
FigureSave(sprintf('Modulation.pdf'),modulationSpectraFig,'pdf');
close all;

end

%% Error function for cone parameter search
function f = ConeParametersSearchFun(x,targetNulls,S, ...
    T_nominalReceptors,nominalCones,B_primary,backgroundPrimary,ambientSpd, ...
    melIsolateDirPrimary,LMSIsolateDirPrimary,LMinusMAdjustPrimaryDir,LMSAdjustPrimaryDir,nominalLMinusMContrastBase,nominalLMSContrastBase,photoreceptorClasses)

% Set up current cone spectral sensitivities
searchCones = nominalCones;
searchCones.type = 'CIE';
searchCones.fieldSizeDegrees = x(1);
searchCones.observerAgeInYears = x(2);
searchCones.pupilDiameterMm = x(3);
searchCones.Lshift = x(4);
searchCones.Mshift = x(5);
T_searchReceptors = GetReceptorsFromStruct(S, photoreceptorClasses, searchCones);

% Simulate nulling
[melLMinusMNullContrast, melLMSNullContrast, LMSLMinusMNullContrast] = SimulateNulling(T_nominalReceptors,T_searchReceptors,B_primary,backgroundPrimary,ambientSpd, ...
    melIsolateDirPrimary,LMSIsolateDirPrimary,LMinusMAdjustPrimaryDir,LMSAdjustPrimaryDir,nominalLMinusMContrastBase,nominalLMSContrastBase,photoreceptorClasses);

% Compute error wrt target nulled contrasts
diff = [melLMinusMNullContrast, melLMSNullContrast, LMSLMinusMNullContrast] - targetNulls;
f = 1000*sum(diff.^2);

% Diagnostic
DEBUG = false;
if (DEBUG)
    fprintf('\n');
    PrintReceptors(searchCones);
    fprintf('\t%0.3f %0.3f %0.3f: %0.4f\n',melLMinusMNullContrast, melLMSNullContrast, LMSLMinusMNullContrast,f);
end

end

%% Simulate nulling function
% 
% Simulates our red/green and flicker nulling procedure
function [melLMinusMNullContrast, melLMSNullContrast, LMSLMinusMNullContrast] = SimulateNulling(T_nominalReceptors,T_actualReceptors,B_primary,backgroundPrimary,ambientSpd, ...
    melIsolateDirPrimary,LMSIsolateDirPrimary,LMinusMAdjustPrimaryDir,LMSAdjustPrimaryDir,nominalLMinusMContrastBase,nominalLMSContrastBase,photoreceptorClasses)

% fmincon options
options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');

% Parameters
nNullIters = 5;
DEBUG = false;

%% Simulate melanopsin modulation nulling
melNulledDirPrimary{1} = melIsolateDirPrimary;
nNullIters = 5;
xMelLMinusMNullTotal = 0;
xMelLMSNullTotal = 0;

% Iterated nulling
if (DEBUG)
    fprintf('\nSimulating Mel nulling\n');
end
for nullIter = 1:nNullIters
    % Simulate red/green nulling
    x0 = 0;
    vlb = [-1];
    vub = [1];
    xLMinusMNull = fmincon(@(x)LMinusMNullingFun(x,T_actualReceptors,B_primary,backgroundPrimary,melNulledDirPrimary{nullIter},LMinusMAdjustPrimaryDir,ambientSpd),x0,[],[],[],[],vlb,vub,[],options);
    melNulLedLMinusMNulledPrimary = melNulledDirPrimary{nullIter}+xLMinusMNull*LMinusMAdjustPrimaryDir;
    if (DEBUG)
        fprintf('\n\tRed-green null %d: added nominal contrast = %0.2f%%\n',nullIter,100*xLMinusMNull*nominalLMinusMContrastBase);
        ComputeAndReportContrastsFromOLPrimaries('Nominal receptors',photoreceptorClasses,T_nominalReceptors,B_primary,backgroundPrimary,melNulledDirPrimary{1},ambientSpd);
        ComputeAndReportContrastsFromOLPrimaries('Actual receptors',photoreceptorClasses,T_actualReceptors,B_primary,backgroundPrimary,melNulledDirPrimary{1},ambientSpd);
        ComputeAndReportContrastsFromOLPrimaries('   Modulation',photoreceptorClasses,T_actualReceptors,B_primary,backgroundPrimary,melNulledDirPrimary{nullIter},ambientSpd);
        ComputeAndReportContrastsFromOLPrimaries('   Adjustment',photoreceptorClasses,T_actualReceptors,B_primary,backgroundPrimary,LMinusMAdjustPrimaryDir,ambientSpd);
        ComputeAndReportContrastsFromOLPrimaries('   Scaled adjustment',photoreceptorClasses,T_actualReceptors,B_primary,backgroundPrimary,xLMinusMNull*LMinusMAdjustPrimaryDir,ambientSpd);
        ComputeAndReportContrastsFromOLPrimaries('   Adjusted',photoreceptorClasses,T_actualReceptors,B_primary,backgroundPrimary,melNulledDirPrimary{nullIter}+xLMinusMNull*LMinusMAdjustPrimaryDir,ambientSpd);
    end

    % Simulate flicker photometric nulling
    x0 = 0;
    vlb = [-1];
    vub = [1];
    xLMSNull = fmincon(@(x)LMNullingFun(x,T_actualReceptors,B_primary,backgroundPrimary,melNulLedLMinusMNulledPrimary,LMSAdjustPrimaryDir,ambientSpd),x0,[],[],[],[],vlb,vub,[],options);
    melNulledDirPrimary{nullIter+1} = melNulledDirPrimary{nullIter}+xLMinusMNull*LMinusMAdjustPrimaryDir + xLMSNull*LMSAdjustPrimaryDir;
    if (DEBUG)
        fprintf('\n\tFlicker null %d: added nominal contrast = %0.2f%%\n',nullIter,100*xLMSNull*nominalLMSContrastBase);
        ComputeAndReportContrastsFromOLPrimaries('   Nominal receptors',photoreceptorClasses,T_nominalReceptors,B_primary,backgroundPrimary,melNulledDirPrimary{nullIter+1},ambientSpd);
        ComputeAndReportContrastsFromOLPrimaries('   Actual receptors',photoreceptorClasses,T_actualReceptors,B_primary,backgroundPrimary,melNulledDirPrimary{nullIter+1},ambientSpd);
    end

    xMelLMinusMNullTotal = xMelLMinusMNullTotal + xLMinusMNull;
    xMelLMSNullTotal = xMelLMSNullTotal + xLMSNull;
end

% Simulate L+M+S modulation nulling
LMSNulledDirPrimary{1} = LMSIsolateDirPrimary;
xLMSLMinusMNullTotal = 0;
if (DEBUG)
    fprintf('\nSimulating L+M+S nulling\n');
end
for nullIter = 1:nNullIters
    % Simulate L-M nulling
    x0 = 0;
    vlb = [-1];
    vub = [1];
    xLMinusMNull = fmincon(@(x)LMinusMNullingFun(x,T_actualReceptors,B_primary,backgroundPrimary,LMSNulledDirPrimary{nullIter},LMinusMAdjustPrimaryDir,ambientSpd),x0,[],[],[],[],vlb,vub,[],options);
    LMSNulLedMinusMNulledPrimary = LMSNulledDirPrimary{nullIter}+xLMinusMNull*LMinusMAdjustPrimaryDir;
    if (DEBUG)
        fprintf('\tRed-green null %d: added contrast = %0.1f%%\n',nullIter,100*xLMinusMNull*nominalLMinusMContrastBase);
    end

    % Here is the nulled modulation for this iteration
    LMSNulledDirPrimary{nullIter+1} = LMSNulledDirPrimary{nullIter}+xLMinusMNull*LMinusMAdjustPrimaryDir;
    xLMSLMinusMNullTotal = xLMSLMinusMNullTotal + xLMinusMNull;
end

% Get nulling contrasts
melLMinusMNullContrast = xMelLMinusMNullTotal*nominalLMinusMContrastBase;
melLMSNullContrast = xMelLMSNullTotal*nominalLMSContrastBase;
LMSLMinusMNullContrast = xLMSLMinusMNullTotal*nominalLMinusMContrastBase;

end


%% L-M nulling error function
function f = LMinusMNullingFun(x,T_receptors,B_primary,backgroundPrimary,modulationPrimary,addedPrimaryDir,ambientSpd)

% Return absolute L-M difference, which we want to minimize
contrastReceptors = ComputeAndReportContrastsFromOLPrimaries('','',T_receptors,B_primary,backgroundPrimary,modulationPrimary+x*addedPrimaryDir,ambientSpd,false);
f = abs(contrastReceptors(1)-contrastReceptors(2));

end


%% L+M nulling error function
function f = LMNullingFun(x,T_receptors,B_primary,backgroundPrimary,modulationPrimary,addedPrimaryDir,ambientSpd)

% Return absolute L plus absolute M, we want them both zero
contrastReceptors = ComputeAndReportContrastsFromOLPrimaries('','',T_receptors,B_primary,backgroundPrimary,modulationPrimary+x*addedPrimaryDir,ambientSpd,false);
f = abs(contrastReceptors(1)) + abs(contrastReceptors(2));

end

