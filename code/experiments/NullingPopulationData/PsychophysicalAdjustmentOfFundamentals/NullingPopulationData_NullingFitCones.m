% AnalyzeNullingConeImplications
%
% We want to understand whether our nulling data can be reasonably
% understood in terms of variation in individual cone fundamentals
% within the CIE model.
%
% As part of the data, we have for each observer the actual validated
% backgrounds and nulling spectra.  So, the question is whether we
% can tweak the nominal parameters for each observer so that their
% measured nulls have the expected properties.
%
% By assumption, the expected properties are:
%   Red-Green nulling: Lcontrast - Mcontrast == 0
%   Flicker nulling: Lcontrast = 0, Mcontrast = 0
%
% For starters, we won't worry about a model of Blue-Yellow nulling,
% because these data are very noisy at the individual subject level.
%
% So we have four nulls (Mel+, Mel-, (L+M+S)+, (L+M+S)-) for each subject.
% For Mel+ and Mel-, these are Red-Green and Flicker nulled.  For L+M+S,
% these are just Red-Green nulled.
%
% There are two repeats of each null per subject.
%
% 1/29/16  ms, dhb   Started on this.

%% Specify a subject.
%
% Once we get this working for one subject, we
% can get more ambitious and analyze them all.
%
% Subjects are specified from 1:N, not according
% to their original subject numbers in the data tree.
thisSubject = 17;
thisRun = 1;

%% Point at some places we need
%
% Extract the user name
[~, usrName] = system('whoami');
usrName = strtrim(usrName);

% Set up directories
dataParentDir = ['/Users/' usrName '/Dropbox (Aguirre-Brainard Lab)/MELA_data/xCompleted/'];
theProtocolDirs = {'NullingPopulationData18To24' 'NullingPopulationDataFork2'};

% Get some stuff we need onto the path
AddToMatlabPathDynamically('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/experiments/NullingPopulationData');

%% Get the data
%
% Iterate over the protocols and get all the data.  This is a little slow
% so we use an indicator variable so that we only have to do it once per
% session.
if (~exist('LOADED','var') | ~LOADED)
    c = 1;
    for p = 1:length(theProtocolDirs)
        protocolDataDir = theProtocolDirs{p};
        baseDir = fullfile(dataParentDir, protocolDataDir);
        prefix = 'MELA_';
        theFiles = dir(baseDir);
        fprintf('>>> Processing data in %s ...\n', protocolDataDir)
        % Iterate over the participants and extract information for each
        % subject
        for f = 1:length(theFiles)
            if ~isempty(strfind(theFiles(f).name, prefix))
                fprintf('\t*** Found file %s ... ', theFiles(f).name)
                [~, ~, ~, ~, ~, ~, tmpBgSpd, tmpModSpd, tmpReceptorParams, tmpT_receptors, S_receptors, completeFlag] = NullingPopulationData_CheckAndAnalyzeNulling(theFiles(f).name, baseDir);
                if completeFlag
                    bgSpd{c} = tmpBgSpd;
                    modSpd{c} = tmpModSpd;
                    receptorParams(c) = tmpReceptorParams;
                    T_receptors{c} = tmpT_receptors;
                    c = c+1;
                    fprintf('Complete dataset.\n');
                else
                    fprintf('Incomplete dataset. - Ignored.\n');
                end
            end
        end
    end
    LOADED = true;
end

%% Get data for target subject and analyze
%
% For each subject, receptorParams contains the parameters necessary to
% reconstruct the spectral sensitivities. The spectral sensitivities are
% also in T_receptors, for double checking.
%
% bgSpd and modSpd contain, for each observer, the background and
% modulation spectra for each of the four arms (Mel+, LMS+, Mel-, LMS-, in
% that order), i.e.
%
% bgSpd{observerIdx}{runIndex}(:, 1) <- bgSpd for Mel+
% bgSpd{observerIdx}{runIndex}(:, 2) <- bgSpd for LMS+
% bgSpd{observerIdx}{runIndex}(:, 3) <- bgSpd for Mel-
% bgSpd{observerIdx}{runIndex}(:, 4) <- bgSpd for LMS-
%
% The second index, runIndex, indicates the replication.
% For the current subject, extract the data

thisBgSpd = bgSpd{thisSubject}{thisRun};
thisModSpd = modSpd{thisSubject}{thisRun};
thisReceptorParams = receptorParams(thisSubject);
thisT_cones = T_receptors{thisSubject}(1:3,:);

% Reconstruct the spectral sensitivities for the subject from the
% parameters
photoreceptorClasses = thisReceptorParams.photoreceptorClasses(1:4);
T_receptors_reconstructed = GetReceptorsFromStruct(S_receptors, photoreceptorClasses, thisReceptorParams);

% Perturb the observer
agePerturbation = 5;
pupilPertubation = 0;
fieldSizePurturbation = 0;
LshiftPerturbation = 0;
MshiftPerturbation = 0;
SshiftPerturbation = 0;
MelShiftPerturbation = 0;
theConesPerturbed = thisReceptorParams;
theConesPerturbed.observerAgeInYears = theConesPerturbed.observerAgeInYears + agePerturbation;
theConesPerturbed.pupilDiameterMm = theConesPerturbed.pupilDiameterMm + pupilPertubation;
theConesPerturbed.fieldSizeDegrees = theConesPerturbed.fieldSizeDegrees + fieldSizePurturbation;
theConesPerturbed.Lshift = theConesPerturbed.Lshift + LshiftPerturbation;
theConesPerturbed.Mshift = theConesPerturbed.Mshift + MshiftPerturbation;
theConesPerturbed.Sshift = theConesPerturbed.Sshift + SshiftPerturbation;
theConesPerturbed.Melshift = theConesPerturbed.Melshift + MelShiftPerturbation;
% theConesPerturbed.observerAgeInYears = 22;
% theConesPerturbed.pupilDiameterMm = 6;
% theConesPerturbed.fieldSizeDegrees = 30;
% theConesPerturbed.Lshift = 0;
% theConesPerturbed.Mshift = 4;
% theConesPerturbed.Sshift = 1;
% theConesPerturbed.Melshift = 0;
T_receptors_perturbed = GetReceptorsFromStruct(S_receptors, photoreceptorClasses, theConesPerturbed);

% Get penumbral cones. We're assuming that they are perturbed in the same
% way.
T_receptors_hemo = GetHumanPhotoreceptorSS(S_receptors, {'LConeHemo', 'MConeHemo', 'SConeHemo'}, ...
            theConesPerturbed.fieldSizeDegrees, theConesPerturbed.observerAgeInYears, theConesPerturbed.pupilDiameterMm, [0 0 0], ...
            theConesPerturbed.fractionBleached, theConesPerturbed.oxygenationFraction, theConesPerturbed.vesselThickness);

%% Overwrite with the Stockman-Sharpe 10° fundamentals with tabulated densitites
T_receptors_perturbed(1:3, :) = ComputeCIEConeFundamentals(S,theConesPerturbed.fieldSizeDegrees,theConesPerturbed.observerAgeInYears,theConesPerturbed.pupilDiameterMm);

% Little sanity check of the spectral sensitivity reconstruction
CHECK_RECEPTORS = false;
if CHECK_RECEPTORS
    plot(SToWls(S_receptors), T_receptors{thisSubject}(1:4, :)'); hold on;
    plot(T_receptors_reconstructed');
end

%% Clear the figures
clf(figure(1)); clf(figure(2));

% Now, calculate the contrast for each nulling direction as both cone
% contrasts and as post-receptoral direction contrasts.
%
% Define the basis functions for the postreceptoral mechanisms
B_postreceptoral = [1 1 0 0 ; ... % L+M+S
    1 -1 0 0]'; % L-M
for ii = 1:4
    % Nominal observer
    coneContrasts(:, ii) = ComputeAndReportContrastsFromSpds('-',photoreceptorClasses,T_receptors_reconstructed,thisBgSpd(:, ii),thisModSpd(:, ii),false);
    postreceptoralContrasts(:, ii) =  B_postreceptoral \ coneContrasts(:, ii);
    
    % Perturbed observer
    coneContrastsPerturbed(:, ii) = ComputeAndReportContrastsFromSpds('-',photoreceptorClasses,T_receptors_perturbed,thisBgSpd(:, ii),thisModSpd(:, ii),false);
    postreceptoralContrastsPerturbed(:, ii) =  B_postreceptoral \ coneContrastsPerturbed(:, ii);
    penumbralConeContrastsPerturbed(:, ii) = ComputeAndReportContrastsFromSpds('-',photoreceptorClasses,T_receptors_hemo,thisBgSpd(:, ii),thisModSpd(:, ii),false);
end

% Now, we plot the contrasts on the L+M+S and L-M mechanisms
% Nominal observer
figure(1);
subplot(1, 2, 1);
limContrast = 0.05;
plot([0 0], [0 7], '-k'); hold on;
plot(postreceptoralContrasts(1, 1), 1, 'sk', 'MarkerFaceColor', 'k', 'MarkerSize', 12) % Mel+, LMS
plot(postreceptoralContrasts(2, 1), 2, 'sr', 'MarkerFaceColor', 'r', 'MarkerSize', 12) % Mel+, L-M
plot(postreceptoralContrasts(1, 3), 3, 'sk', 'MarkerFaceColor', 'k', 'MarkerSize', 12) % Mel-, LMS
plot(postreceptoralContrasts(2, 3), 4, 'sr', 'MarkerFaceColor', 'r', 'MarkerSize', 12) % Mel-, L-M
plot(postreceptoralContrasts(2, 2), 5, 'sr', 'MarkerFaceColor', 'r', 'MarkerSize', 12) % LMS+, L-M
plot(postreceptoralContrasts(2, 4), 6, 'sr', 'MarkerFaceColor', 'r', 'MarkerSize', 12) % LMS-, L-M
theLabels = {'Mel+, LMS null', 'Mel+, L-M null', 'Mel-, LMS null', 'Mel-, L-M null', 'LMS+, L-M null', 'LMS-, L-M null'};
hold off;
set(gca, 'XTick', [-limContrast -limContrast/2 0 limContrast/2 limContrast]);
set(gca, 'YTick', 1:6, 'YTickLabel', theLabels);
set(gca, 'TickDir', 'out');
xlabel('Nulling contrast');
xlim([-limContrast limContrast]); ylim([0 7]);
pbaspect([1 1 1]);
title('Contrasts for nominal observer');

% Perturbed observer
hold off;
subplot(1, 2, 2);
limContrast = 0.05;
plot([0 0], [0 7], '-k'); hold on;
plot(postreceptoralContrastsPerturbed(1, 1), 1, 'sk', 'MarkerFaceColor', 'k', 'MarkerSize', 12) % Mel+, LMS
plot(postreceptoralContrastsPerturbed(2, 1), 2, 'sr', 'MarkerFaceColor', 'r', 'MarkerSize', 12) % Mel+, L-M
plot(postreceptoralContrastsPerturbed(1, 3), 3, 'sk', 'MarkerFaceColor', 'k', 'MarkerSize', 12) % Mel-, LMS
plot(postreceptoralContrastsPerturbed(2, 3), 4, 'sr', 'MarkerFaceColor', 'r', 'MarkerSize', 12) % Mel-, L-M
plot(postreceptoralContrastsPerturbed(2, 2), 5, 'sr', 'MarkerFaceColor', 'r', 'MarkerSize', 12) % LMS+, L-M
plot(postreceptoralContrastsPerturbed(2, 4), 6, 'sr', 'MarkerFaceColor', 'r', 'MarkerSize', 12) % LMS-, L-M
theLabels = {'Mel+, LMS null', 'Mel+, L-M null', 'Mel-, LMS null', 'Mel-, L-M null', 'LMS+, L-M null', 'LMS-, L-M null'};
hold off;
set(gca, 'XTick', [-limContrast -limContrast/2 0 limContrast/2 limContrast]);
set(gca, 'YTick', 1:6, 'YTickLabel', theLabels);
set(gca, 'TickDir', 'out');
xlabel('Nulling contrast');
xlim([-limContrast limContrast]); ylim([0 7]);
pbaspect([1 1 1]);
title('Contrasts for perturbed observer');

% Let's look at cone contrasts
figure(2); 
subplot(2,2,1); hold on
plot(coneContrasts(1,1),coneContrasts(2,1),'sk', 'MarkerFaceColor', 'k', 'MarkerSize', 12)
plot(coneContrasts(1,3),coneContrasts(2,3),'ok', 'MarkerFaceColor', 'k', 'MarkerSize', 12)
xlim([-limContrast limContrast]); ylim([-limContrast limContrast]);
plot([-limContrast limContrast],[-limContrast limContrast],'k:');
plot([0 0],[-limContrast limContrast],'k:');
xlabel('L cone contrast');
ylabel('M cone contrast');
title({'Mel null' 'Nominal fundamentals'});
axis('square');
subplot(2,2,2); hold on
plot(coneContrasts(1,2),coneContrasts(2,2),'sr', 'MarkerFaceColor', 'r', 'MarkerSize', 12)
plot(coneContrasts(1,4),coneContrasts(2,4),'or', 'MarkerFaceColor', 'r', 'MarkerSize', 12)
xlim([0 0.50]); ylim([0 0.50]);
plot([0 0.50],[0 0.50],'r:');
xlabel('L cone contrast');
ylabel('M cone contrast');
title({'LMS null' 'Nominal fundamentals'});
axis('square');

subplot(2,2,3); hold on
plot(coneContrastsPerturbed(1,1),coneContrastsPerturbed(2,1),'sk', 'MarkerFaceColor', 'k', 'MarkerSize', 12)
plot(coneContrastsPerturbed(1,3),coneContrastsPerturbed(2,3),'ok', 'MarkerFaceColor', 'k', 'MarkerSize', 12)
plot(penumbralConeContrastsPerturbed(1,1),penumbralConeContrastsPerturbed(2,1),'sk', 'MarkerFaceColor', 'w', 'MarkerSize', 12)
plot(penumbralConeContrastsPerturbed(1,3),penumbralConeContrastsPerturbed(2,3),'ok', 'MarkerFaceColor', 'w', 'MarkerSize', 12)
xlim([-limContrast limContrast]); ylim([-limContrast limContrast]);
plot([-limContrast limContrast],[-limContrast limContrast],'k:');
plot([0 0],[-limContrast limContrast],'k:');
xlabel('L cone contrast');
ylabel('M cone contrast');
title({'Mel null' 'Perturbed fundamentals'});
axis('square');

subplot(2,2,4); hold on
plot(coneContrastsPerturbed(1,2),coneContrastsPerturbed(2,2),'sr', 'MarkerFaceColor', 'r', 'MarkerSize', 12)
plot(coneContrastsPerturbed(1,4),coneContrastsPerturbed(2,4),'or', 'MarkerFaceColor', 'r', 'MarkerSize', 12)
plot(penumbralConeContrastsPerturbed(1,2),penumbralConeContrastsPerturbed(2,2),'sr', 'MarkerFaceColor', 'w', 'MarkerSize', 12)
plot(penumbralConeContrastsPerturbed(1,4),penumbralConeContrastsPerturbed(2,4),'or', 'MarkerFaceColor', 'w', 'MarkerSize', 12)
xlim([0 0.50]); ylim([0 0.50]);
plot([0 0.50],[0 0.50],'r:');
xlabel('L cone contrast');
ylabel('M cone contrast');
title({'LMS null' 'Perturbed fundamentals'});
axis('square');


