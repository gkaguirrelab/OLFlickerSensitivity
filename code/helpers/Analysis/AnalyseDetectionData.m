function [dataAgg dataPerRun] = AnalyseDetectionData(file, nRuns)
close all;
minContrast = 0.0025; maxContrast = 0.05;

% Set some params
nContrastLevels = 20;
nBackgrounds = 4;

% Load the data and pull it out
C = csvimport(file, 'noHeader', true);

backgroundLabels = C(:, 2);
backgroundContrasts = cell2mat(C(:, 4));

% Construct the background labels
for i = 1:length(backgroundLabels)
    uniqueBackgroundLabelsPrint{i} = [backgroundLabels{i} num2str(backgroundContrasts(i)*100) '%'];
end

flickerContrast = cell2mat(C(:, 5));
flickerInterval = cell2mat(C(:, 6));
flickerDecision = cell2mat(C(:, 7));
flickerResponse = cell2mat(C(:, 8));

flickerCorrect = (flickerInterval == flickerDecision);

if flickerCorrect ~= flickerResponse
    error('Check data consistency.');
end

% Iterate over the directions
[uniqueBackgroundLabels, ~, backgroundLabelsNum] = unique(uniqueBackgroundLabelsPrint);

% Agregate the data
[xcon, ycon, ind] = consolidator([backgroundLabelsNum flickerContrast], flickerCorrect);
[~, ycon_n] = consolidator([backgroundLabelsNum flickerContrast], flickerCorrect, @sum);
[~, ycon_N] = consolidator([backgroundLabelsNum flickerContrast], flickerCorrect, 'count');


h = [];
c = 1;

%% Also, separate analyses per block
nTrials = 80;
backgroundLabelsNumPerRun = reshape(backgroundLabelsNum, nTrials, nRuns);
flickerContrastPerRun = reshape(flickerContrast, nTrials, nRuns);
flickerCorrectPerRun = reshape(flickerCorrect, nTrials, nRuns);

thresholdsMelNeg = [];
thresholdsMelPos = [];
% ITerate over each block
for r = 1:nRuns
    
    [xconPerRun, yconPerRun, ind] = consolidator(flickerContrastPerRun(:, r), flickerCorrectPerRun(:, r));
    [~, ycon_n_perRun] = consolidator(flickerContrastPerRun(:, r), flickerCorrectPerRun(:, r), @sum);
    [~, ycon_N_perRun] = consolidator(flickerContrastPerRun(:, r), flickerCorrectPerRun(:, r), 'count');
    
    dataPerRun(r).contrasts = xconPerRun;
    dataPerRun(r).nCorrect = ycon_n_perRun;
    dataPerRun(r).nTotal = ycon_N_perRun;
    
    dataPerRun(r).rawResponses = flickerCorrectPerRun(:, r);
    dataPerRun(r).rawContrast = flickerContrastPerRun(:, r);
    
    [dataPerRun(r).meanValues, dataPerRun(r).nCorrectPerBin, dataPerRun(r).nTrialsPerBin] = GetAggregatedStairTrials(dataPerRun(r).rawContrast, dataPerRun(r).rawResponses, 20);
    
    criterionCorr = 0.75;
    dataPerRun(r).criterionCorr = criterionCorr;
    fittype = 'w';
    pfitdata = [dataPerRun(r).contrasts, dataPerRun(r).nCorrect, dataPerRun(r).nTotal];
    pfitstruct = pfit(pfitdata,'no plot','matrix_format','xrn', ...
        'shape', fittype, 'n_intervals', 2, 'runs', 0, 'sens', 0, ...
        'compute_stats', 0, 'cuts', [0.5], 'verbose', 0,  'fix_gamma',0.5);
    dataPerRun(r).probCorrFitPsig = psigpsi(fittype, pfitstruct.params.est, [minContrast:0.001:maxContrast]);
    dataPerRun(r).threshPsig = findthreshold(fittype,pfitstruct.params.est,criterionCorr,'performance');
    
    dataPerRun(r).label = uniqueBackgroundLabels(max(backgroundLabelsNumPerRun(:, r)));
    
end


%% All data
for i = 1:length(unique(xcon(:, 1)))
    indices = find(xcon(:, 1) == i);
    % Aggregate data for plotting
    dataAgg(c).rawResponses = flickerCorrect(backgroundLabelsNum == i);
    dataAgg(c).rawContrast = flickerContrast(backgroundLabelsNum == i);
    
    theInds = Shuffle(1:length(dataAgg(c).rawResponses));
    
    % Bin the trials
    [dataAgg(c).meanValues, dataAgg(c).nCorrectPerBin, dataAgg(c).nTrialsPerBin] = GetAggregatedStairTrials(dataAgg(c).rawContrast(theInds), dataAgg(c).rawResponses(theInds), 30);
    
    dataAgg(c).label = uniqueBackgroundLabels(c);
    dataAgg(c).contrasts = xcon(indices, 2);
    dataAgg(c).propCorrect = ycon(indices);
    dataAgg(c).nCorrect = ycon_n(indices);
    dataAgg(c).nTotal = ycon_N(indices);
    
    %% Fith with psychmetric function
    % PSIGNIFIT
    % Fit simulated data, psignifit.  These parameters do a one interval (y/n) fit.  Both lambda (lapse rate) and
    % gamma (value for -Inf input) are locked at 0.
    criterionCorr = 0.75;
    dataAgg(c).criterionCorr = criterionCorr;
    fittype = 'w';
    pfitdata = [dataAgg(c).contrasts, dataAgg(c).nCorrect, dataAgg(c).nTotal];
    pfitstruct = pfit(pfitdata,'no plot','matrix_format','xrn', ...
        'shape', fittype, 'n_intervals', 2, 'runs', 0, 'sens', 0, ...
        'compute_stats', 0, 'cuts', [0.5], 'verbose', 0, 'fix_gamma',0.5);
    dataAgg(c).probCorrFitPsig = psigpsi(fittype, pfitstruct.params.est, [minContrast:0.001:maxContrast]);
    dataAgg(c).threshPsig = findthreshold(fittype,pfitstruct.params.est,criterionCorr,'performance');
    
    
    c = c+1;
    
    
    
    
end

h1 = []; h1i = [];
h2 = []; h2i = [];

% Plot the data
for c = 1:length(dataAgg)
    length(unique(dataAgg(c).meanValues))
    switch dataAgg(c).label{1}
        case 'MelanopsinDirectedLegacy25.6%'
            subplot(1, 2, 2);
            ht = plot(dataAgg(c).meanValues, dataAgg(c).nCorrectPerBin./dataAgg(c).nTrialsPerBin, 'sr', 'MarkerFaceColor', 'r'); hold on;
            h2 = [h2 ht];
            h2i = [h2i c];
            
            
            %% Plot pf
            plot([minContrast:0.001:maxContrast],dataAgg(c).probCorrFitPsig,'-r','LineWidth',2);
            plot([dataAgg(c).threshPsig dataAgg(c).threshPsig],[0 dataAgg(c).criterionCorr],'-k','LineWidth',1.5);
            
        case 'MelanopsinDirectedLegacy-25.6%'
            subplot(1, 2, 2);
            ht = plot(dataAgg(c).meanValues, dataAgg(c).nCorrectPerBin./dataAgg(c).nTrialsPerBin, 'ob', 'MarkerFaceColor', 'b'); hold on;
            h2 = [h2 ht];
            h2i = [h2i c];
            
            
            %% Plot pf
            plot([minContrast:0.001:maxContrast],dataAgg(c).probCorrFitPsig,'b','LineWidth',2);
            plot([dataAgg(c).threshPsig dataAgg(c).threshPsig],[0 dataAgg(c).criterionCorr],'-k','LineWidth',1.5);
            
        case 'LMSDirected25.6%'
            subplot(1, 2, 1);
            ht = plot(dataAgg(c).meanValues, dataAgg(c).nCorrectPerBin./dataAgg(c).nTrialsPerBin, 'or', 'MarkerFaceColor', 'r'); hold on;
            h1 = [h1 ht];
            h1i = [h1i c];
            
            %% Plot pf
            plot([minContrast:0.001:maxContrast],dataAgg(c).probCorrFitPsig,'r','LineWidth',2);
            plot([dataAgg(c).threshPsig dataAgg(c).threshPsig],[0 dataAgg(c).criterionCorr],'-k','LineWidth',1.5);
            
        case 'LMSDirected-25.6%'
            subplot(1, 2, 1);
            ht = plot(dataAgg(c).meanValues, dataAgg(c).nCorrectPerBin./dataAgg(c).nTrialsPerBin, 'ob', 'MarkerFaceColor', 'b'); hold on;
            h1 = [h1 ht];
            h1i = [h1i c];
            
            %% Plot pf
            plot([minContrast:0.001:maxContrast],dataAgg(c).probCorrFitPsig,'-b','LineWidth',2);
            plot([dataAgg(c).threshPsig dataAgg(c).threshPsig],[0 dataAgg(c).criterionCorr],'-k','LineWidth',1.5);
    end
end

% Make legends
subplot(1, 2, 1);
legend(h1, [dataAgg(h1i).label], 'Location', 'SouthEast'); legend boxoff;
pbaspect([1 1 1]); xlim([0 0.045]); ylim([0 1.1]);
xlabel('Contrast'); ylabel('Proportion correct');

subplot(1, 2, 2);
legend(h2, [dataAgg(h2i).label], 'Location', 'SouthEast'); legend boxoff;
pbaspect([1 1 1]); xlim([0 0.045]); ylim([0 1.1]);
xlabel('Contrast'); ylabel('Proportion correct');


set(gca,'TickDir','out')
set(gcf, 'PaperPosition', [0 0 12 4]);
set(gcf, 'PaperSize', [12 4]);
saveas(gcf, [file '.pdf'], 'pdf');

xlabel('Contrast'); ylabel('Proportion correct');
title(fileparts(file));

%legend(h, uniqueBackgroundLabelsPrint);

%keyboard;

