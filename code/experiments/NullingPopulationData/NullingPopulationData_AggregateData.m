function NullingPopulationData_AggregateData
close all
GET_VALIDATION_CONTRAST = true;
avgMode = 'average';

% Extract the user name
[~, usrName] = system('whoami');
usrName = strtrim(usrName);

analysisDir = ['/Users/' usrName '/Dropbox (Aguirre-Brainard Lab)/MELA_analysis/NullingPopulationData'];
dataParentDir = ['/Users/' usrName '/Dropbox (Aguirre-Brainard Lab)/MELA_data/xCompleted/'];
theProtocolDirs = {'NullingPopulationData18To24' 'NullingPopulationDataFork2'};
theMarkers = {'o', 's'};
theTitles = {'L+M+S null', 'L-M null', 'S null'};

nullingVals1MelAggregate = [];
nullingVals2MelAggregate = [];
nullingVals1LMSAggregate = [];
nullingVals2LMSAggregate = [];

whichReceptorsToProbe = 'InCache';


m = 1;
for p = 1:length(theProtocolDirs)
    %clear nullingVals1Aggregate nullingVals2Aggregate nullingVals1MelAvg nullingVals1LMSAvg nullingVals2MelAvg nullingVals2LMSAvg;
    protocolDataDir = theProtocolDirs{p};
    baseDir = fullfile(dataParentDir, protocolDataDir);
    prefix = 'MELA_';
    
    theFiles = dir(baseDir);
    
    c = 1;
    for f = 1:length(theFiles)
        if ~isempty(strfind(theFiles(f).name, prefix))
            fprintf('Found file %s ...\n', theFiles(f).name)
            if GET_VALIDATION_CONTRAST
                [~, ~, nullingVals1, nullingVals2, nullingValsLuminance, nullingValsChromaticity, bgSpd, modSpd] = NullingPopulationData_CheckAndAnalyzeNulling(theFiles(f).name, baseDir, whichReceptorsToProbe);
            else
                [nullingVals1, nullingVals2] = NullingPopulationData_CheckAndAnalyzeNulling(theFiles(f).name, baseDir);
            end
            if ~isempty(nullingVals1) | ~isempty(nullingVals2)
                % Extract chromaticity
                nullingLuminance{p}(c, :) = [nullingValsLuminance];
                nullingChromaticity{p}(c, :) = [nullingValsChromaticity];
                
                nullingVals1Aggregate{c} = nullingVals1;
                nullingVals2Aggregate{c} = nullingVals2;
                
                % Repeat 1
                nullingVals1MelAvg{p}(c, :) = mean([nullingVals1Aggregate{c}(1, :) ; -1*nullingVals1Aggregate{c}(3, :)]);
                nullingVals1LMSAvg{p}(c, :) = mean([nullingVals1Aggregate{c}(2, :) ; -1*nullingVals1Aggregate{c}(4, :)]);
                nullingVals1MelPosArm{p}(c, :) = nullingVals1Aggregate{c}(1, :);
                nullingVals1LMSPosArm{p}(c, :) = nullingVals1Aggregate{c}(2, :);
                nullingVals1MelNegArm{p}(c, :) = -1*nullingVals1Aggregate{c}(3, :);
                nullingVals1LMSNegArm{p}(c, :) = -1*nullingVals1Aggregate{c}(4, :);
                
                % Repeat 2
                nullingVals2MelAvg{p}(c, :) = mean([nullingVals2Aggregate{c}(1, :) ; -1*nullingVals2Aggregate{c}(3, :)]);
                nullingVals2LMSAvg{p}(c, :) = mean([nullingVals2Aggregate{c}(2, :) ; -1*nullingVals2Aggregate{c}(4, :)]);
                nullingVals2MelPosArm{p}(c, :) = nullingVals2Aggregate{c}(1, :);
                nullingVals2LMSPosArm{p}(c, :) = nullingVals2Aggregate{c}(2, :);
                nullingVals2MelNegArm{p}(c, :) = -1*nullingVals2Aggregate{c}(3, :);
                nullingVals2LMSNegArm{p}(c, :) = -1*nullingVals2Aggregate{c}(4, :);
                
                
                % Assemble for both runs
                theSubjects{p, c} = theFiles(f).name;
                runID = 1;
                armID = 1;
                nullingValsMel{p, runID, armID}(c, :) = nullingVals1Aggregate{c}(1, :);
                nullingValsLMS{p, runID, armID}(c, :) = nullingVals1Aggregate{c}(2, :);
                armID = 2;
                nullingValsMel{p, runID, armID}(c, :) = -1*nullingVals1Aggregate{c}(3, :);
                nullingValsLMS{p, runID, armID}(c, :) = -1*nullingVals1Aggregate{c}(4, :);
                
                % Repeat 2
                runID = 2;
                armID = 1;
                nullingValsMel{p, runID, armID}(c, :) = nullingVals2Aggregate{c}(1, :);
                nullingValsLMS{p, runID, armID}(c, :) = nullingVals2Aggregate{c}(2, :);
                armID = 2;
                nullingValsMel{p, runID, armID}(c, :) = -1*nullingVals2Aggregate{c}(3, :);
                nullingValsLMS{p, runID, armID}(c, :) = -1*nullingVals2Aggregate{c}(4, :);
                
                switch avgMode
                    case 'average'
                        nullingVals1MelAvgAggregate{p}(m, :) = nullingVals1MelAvg{p}(c, :);
                        nullingVals2MelAvgAggregate{p}(m, :) = nullingVals2MelAvg{p}(c, :);
                        nullingVals1LMSAvgAggregate{p}(m, :) = nullingVals1LMSAvg{p}(c, :);
                        nullingVals2LMSAvgAggregate{p}(m, :) = nullingVals2LMSAvg{p}(c, :);
                    case 'positive'
                        nullingVals1MelAvgAggregate{p}(m, :) = nullingVals1MelPosArm{p}(c, :);
                        nullingVals2MelAvgAggregate{p}(m, :) = nullingVals2MelPosArm{p}(c, :);
                        nullingVals1LMSAvgAggregate{p}(m, :) = nullingVals1LMSPosArm{p}(c, :);
                        nullingVals2LMSAvgAggregate{p}(m, :) = nullingVals2LMSPosArm{p}(c, :);
                    case 'negative'
                        nullingVals1MelAvgAggregate{p}(m, :) = nullingVals1MelNegArm{p}(c, :);
                        nullingVals2MelAvgAggregate{p}(m, :) = nullingVals2MelNegArm{p}(c, :);
                        nullingVals1LMSAvgAggregate{p}(m, :) = nullingVals1LMSNegArm{p}(c, :);
                        nullingVals2LMSAvgAggregate{p}(m, :) = nullingVals2LMSNegArm{p}(c, :);
                end
                c = c+1; m = m+1;
            end
        end
    end
    %%
    subplot(2, 3, 1);
    switch avgMode
        case 'average'
            plot(nullingVals1MelAvg{p}(:, 1), nullingVals2MelAvg{p}(:, 1), 'k', 'LineStyle', 'none', 'Marker', theMarkers{p}, 'MarkerFaceColor', 'k'); hold on;
        case 'positive'
            plot(nullingVals1MelPosArm{p}(:, 1), nullingVals2MelPosArm{p}(:, 1), 'k', 'LineStyle', 'none', 'Marker', theMarkers{p}, 'MarkerFaceColor', 'k'); hold on;
        case 'negative'
            plot(nullingVals1MelNegArm{p}(:, 1), nullingVals2MelNegArm{p}(:, 1), 'k', 'LineStyle', 'none', 'Marker', theMarkers{p}, 'MarkerFaceColor', 'k'); hold on
    end
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    axLim = 0.11;
    xlim([-axLim axLim]); ylim([-axLim axLim]);
    plot([-axLim axLim], [-axLim axLim], '-k');
    plot([0 0], [-axLim axLim], '-k');
    plot([-axLim axLim], [0 0], '-k');
    xlabel('Run 1'); ylabel('Run 2');
    
    subplot(2, 3, 2);
    switch avgMode
        case 'average'
            plot(nullingVals1MelAvg{p}(:, 2), nullingVals2MelAvg{p}(:, 2), 'r', 'LineStyle', 'none', 'Marker', theMarkers{p}, 'MarkerFaceColor', 'r'); hold on;
        case 'positive'
            plot(nullingVals1MelPosArm{p}(:, 2), nullingVals2MelPosArm{p}(:, 2), 'r', 'LineStyle', 'none', 'Marker', theMarkers{p}, 'MarkerFaceColor', 'r'); hold on;
        case 'negative'
            plot(nullingVals1MelNegArm{p}(:, 2), nullingVals2MelNegArm{p}(:, 2), 'r', 'LineStyle', 'none', 'Marker', theMarkers{p}, 'MarkerFaceColor', 'r'); hold on
    end
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    axLim = 0.11;
    xlim([-axLim axLim]); ylim([-axLim axLim]);
    plot([-axLim axLim], [-axLim axLim], '-k');
    plot([0 0], [-axLim axLim], '-k');
    plot([-axLim axLim], [0 0], '-k');
    xlabel('Run 1'); ylabel('Run 2');
    
    subplot(2, 3, 3);
    switch avgMode
        case 'average'
            plot(nullingVals1MelAvg{p}(:, 3), nullingVals2MelAvg{p}(:, 3), 'b', 'LineStyle', 'none', 'Marker', theMarkers{p}, 'MarkerFaceColor', 'b'); hold on;
        case 'positive'
            plot(nullingVals1MelPosArm{p}(:, 3), nullingVals2MelPosArm{p}(:, 3), 'b', 'LineStyle', 'none', 'Marker', theMarkers{p}, 'MarkerFaceColor', 'b'); hold on;
        case 'negative'
            plot(nullingVals1MelNegArm{p}(:, 3), nullingVals2MelNegArm{p}(:, 3), 'b', 'LineStyle', 'none', 'Marker', theMarkers{p}, 'MarkerFaceColor', 'b'); hold on
    end
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    axLim = 0.11;
    xlim([-axLim axLim]); ylim([-axLim axLim]);
    plot([-axLim axLim], [-axLim axLim], '-k');
    plot([0 0], [-axLim axLim], '-k');
    plot([-axLim axLim], [0 0], '-k');
    xlabel('Run 1'); ylabel('Run 2');
    
    subplot(2, 3, 5);
    switch avgMode
        case 'average'
            plot(nullingVals1LMSAvg{p}(:, 2), nullingVals2LMSAvg{p}(:, 2), 'r', 'LineStyle', 'none', 'Marker', theMarkers{p}, 'MarkerFaceColor', 'r'); hold on;
        case 'positive'
            plot(nullingVals1LMSPosArm{p}(:, 2), nullingVals2LMSPosArm{p}(:, 2), 'r', 'LineStyle', 'none', 'Marker', theMarkers{p}, 'MarkerFaceColor', 'r'); hold on;
        case 'negative'
            plot(nullingVals1LMSNegArm{p}(:, 2), nullingVals2LMSNegArm{p}(:, 2), 'r', 'LineStyle', 'none', 'Marker', theMarkers{p}, 'MarkerFaceColor', 'r'); hold on
    end
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    axLim = 0.08;
    xlim([-axLim axLim]); ylim([-axLim axLim]);
    plot([-axLim axLim], [-axLim axLim], '-k');
    plot([0 0], [-axLim axLim], '-k');
    plot([-axLim axLim], [0 0], '-k');
    xlabel('Run 1'); ylabel('Run 2');
    
    subplot(2, 3, 6);
    switch avgMode
        case 'average'
            plot(nullingVals1LMSAvg{p}(:, 3), nullingVals2LMSAvg{p}(:, 3), 'b', 'LineStyle', 'none', 'Marker', theMarkers{p}, 'MarkerFaceColor', 'b'); hold on;
        case 'positive'
            plot(nullingVals1LMSPosArm{p}(:, 3), nullingVals2LMSPosArm{p}(:, 3), 'b', 'LineStyle', 'none', 'Marker', theMarkers{p}, 'MarkerFaceColor', 'b'); hold on;
        case 'negative'
            plot(nullingVals1LMSNegArm{p}(:, 3), nullingVals2LMSNegArm{p}(:, 3), 'b', 'LineStyle', 'none', 'Marker', theMarkers{p}, 'MarkerFaceColor', 'b'); hold on
    end
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    axLim = 0.08;
    xlim([-axLim axLim]); ylim([-axLim axLim]);
    plot([-axLim axLim], [-axLim axLim], '-k');
    plot([0 0], [-axLim axLim], '-k');
    plot([-axLim axLim], [0 0], '-k');
    xlabel('Run 1'); ylabel('Run 2');
    
    switch avgMode
        case 'average'
            nullingVals1MelAggregate = [nullingVals1MelAggregate ; nullingVals1MelAvg{p}];
            nullingVals2MelAggregate = [nullingVals2MelAggregate ; nullingVals2MelAvg{p}];
            nullingVals1LMSAggregate = [nullingVals1LMSAggregate ; nullingVals1LMSAvg{p}];
            nullingVals2LMSAggregate = [nullingVals2LMSAggregate ; nullingVals2LMSAvg{p}];
        case 'positive'
            nullingVals1MelAggregate = [nullingVals1MelAggregate ; nullingVals1MelPosArm{p}];
            nullingVals2MelAggregate = [nullingVals2MelAggregate ; nullingVals2MelPosArm{p}];
            nullingVals1LMSAggregate = [nullingVals1LMSAggregate ; nullingVals1LMSPosArm{p}];
            nullingVals2LMSAggregate = [nullingVals2LMSAggregate ; nullingVals2LMSPosArm{p}];
        case 'negative'
            nullingVals1MelAggregate = [nullingVals1MelAggregate ; nullingVals1MelNegArm{p}];
            nullingVals2MelAggregate = [nullingVals2MelAggregate ; nullingVals2MelNegArm{p}];
            nullingVals1LMSAggregate = [nullingVals1LMSAggregate ; nullingVals1LMSNegArm{p}];
            nullingVals2LMSAggregate = [nullingVals2LMSAggregate ; nullingVals2LMSNegArm{p}];
    end
end
close all;

%% 1) Rescale the contrast
% Rescale the contrast values such that the contrast of the targeted direction is at 42%.
pegContrast = 0.42;
for p = 1:length(theProtocolDirs)
    % Mel
    % Run 1, Mel+
    scalar1MelPosArm = pegContrast./nullingVals1MelPosArm{p}(:, 4)
    nullingVals1MelPosArm{p} = repmat(scalar1MelPosArm, 1, 4).*nullingVals1MelPosArm{p};
    
    % Run 2, Mel+
    scalar2MelPosArm = pegContrast./nullingVals2MelPosArm{p}(:, 4)
    nullingVals2MelPosArm{p} = repmat(scalar2MelPosArm, 1, 4).*nullingVals2MelPosArm{p};
    
    % Run 1, Mel-
    scalar1MelNegArm = pegContrast./nullingVals1MelNegArm{p}(:, 4)
    nullingVals1MelNegArm{p} = repmat(scalar1MelNegArm, 1, 4).*nullingVals1MelNegArm{p};
    
    % Run 2, Mel-
    scalar2MelNegArm = pegContrast./nullingVals2MelNegArm{p}(:, 4)
    nullingVals2MelNegArm{p} = repmat(scalar2MelNegArm, 1, 4).*nullingVals2MelNegArm{p};
    
    % LMS
    % Run 1, LMS+
    scalar1LMSPosArm = pegContrast./nullingVals1LMSPosArm{p}(:, 1)
    nullingVals1LMSPosArm{p} = repmat(scalar1LMSPosArm, 1, 4).*nullingVals1LMSPosArm{p};
    
    % Run 2, LMS+
    scalar2LMSPosArm = pegContrast./nullingVals2LMSPosArm{p}(:, 1)
    nullingVals2LMSPosArm{p} = repmat(scalar2LMSPosArm, 1, 4).*nullingVals2LMSPosArm{p};
    
    % Run 1, LMS-
    scalar1LMSNegArm = pegContrast./nullingVals1LMSNegArm{p}(:, 1)
    nullingVals1LMSNegArm{p} = repmat(scalar1LMSNegArm, 1, 4).*nullingVals1LMSNegArm{p};
    
    % Run 2, LMS-
    scalar2LMSNegArm = pegContrast./nullingVals2LMSNegArm{p}(:, 1)
    nullingVals2LMSNegArm{p} = repmat(scalar2LMSNegArm, 1, 4).*nullingVals2LMSNegArm{p};
end

%% Dump out all the data
switch whichReceptorsToProbe
    case 'LMSTabulatedAbsorbance'
        fidMel = fopen(fullfile(analysisDir, 'xLMSTabulatedAbsorbance', 'Mel_AllNullingContrast_LMSFromTabulatedAbsorbance.csv'), 'w'); fprintf(fidMel, 'Group,Subject,Nulling direction,Run,Arm,LMS null,L-M null,S null\n');
        fidLMS = fopen(fullfile(analysisDir, 'xLMSTabulatedAbsorbance', 'LMS_AllNullingContrast_LMSFromTabulatedAbsorbance.csv'), 'w'); fprintf(fidLMS, 'Group,Subject,Nulling direction,Run,Arm,LMS null,L-M null,S null\n');
    case 'InCache'
        fidMel = fopen(fullfile(analysisDir, 'xInCache', 'Mel_AllNullingContrast.csv'), 'w'); fprintf(fidMel, 'Group,Subject,Nulling direction,Run,Arm,LMS null,L-M null,S null\n');
        fidLMS = fopen(fullfile(analysisDir, 'xInCache', 'LMS_AllNullingContrast.csv'), 'w'); fprintf(fidLMS, 'Group,Subject,Nulling direction,Run,Arm,LMS null,L-M null,S null\n');
end
c = 1;
Mel_LMSNulls = [];
Mel_LMinusMNulls = [];
Mel_SNulls = [];
LMS_LMinusMNulls = [];
LMS_SNulls = [];

for p = 1:length(theProtocolDirs)
    for s = 1:size(nullingValsMel{1, 1, 1}, 1)
        if p == 1
            c = s;
        else
            c = size(nullingValsMel{1, 1, 1}, 1)+s;
        end
        for r = [1 2];
            for a = [1 2];
                scalarMel = pegContrast/nullingValsMel{p, r, a}(s, 4);
                scalarLMS = pegContrast/nullingValsLMS{p, r, a}(s, 1);
                fprintf(fidMel, '%s,%s,Mel,%g,%g,%.3f,%.3f,%.3f\n', theProtocolDirs{p}, theSubjects{p, s}, r, a, scalarMel*nullingValsMel{p, r, a}(s, 1), scalarMel*nullingValsMel{p, r, a}(s, 2), scalarMel*nullingValsMel{p, r, a}(s, 3));
                fprintf(fidLMS, '%s,%s,LMS,%g,%g,,%.3f,%.3f\n', theProtocolDirs{p}, theSubjects{p, s}, r, a, scalarLMS*nullingValsLMS{p, r, a}(s, 2), scalarLMS*nullingValsLMS{p, r, a}(s, 3));
                
                Mel_LMSNulls(c, a, r) = scalarMel*nullingValsMel{p, r, a}(s, 1);
                Mel_LMinusMNulls(c, a, r) = scalarMel*nullingValsMel{p, r, a}(s, 2);
                Mel_SNulls(c, a, r) = scalarMel*nullingValsMel{p, r, a}(s, 3);
                LMS_LMinusMNulls(c, a, r) = scalarLMS*nullingValsLMS{p, r, a}(s, 2);
                LMS_SNulls(c, a, r) = scalarLMS*nullingValsLMS{p, r, a}(s, 3);
            end
        end
    end
end
fclose(fidMel);
fclose(fidLMS);

Mel_LMSNullsAll = [Mel_LMSNulls(:, :, 1) Mel_LMSNulls(:, :, 2)]
Mel_LMinusMNullsAll = [Mel_LMinusMNulls(:, :, 1) Mel_LMinusMNulls(:, :, 2)]
Mel_SNullsAll = [Mel_SNulls(:, :, 1) Mel_SNulls(:, :, 2)]
LMS_LMinusMNullsAll = [LMS_LMinusMNulls(:, :, 1) LMS_LMinusMNulls(:, :, 2)]
LMS_SNullsAll = [LMS_SNulls(:, :, 1) LMS_SNulls(:, :, 2)]

%% Average arms, compare runs
subplot(2, 3, 1);
plot(mean(Mel_LMSNulls(:, :, 1),2), mean(Mel_LMSNulls(:, :, 2),2), 'k', 'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', 'k'); hold on;
theXRunCorrelations(1, 1) = corr(mean(Mel_LMSNulls(:, :, 1),2), mean(Mel_LMSNulls(:, :, 2),2), 'type', 'Spearman');
title({'Mel directed / LMS null' ['r = ' num2str(theXRunCorrelations(1, 1))]});

subplot(2, 3, 2);
plot(mean(Mel_LMinusMNulls(:, :, 1),2), mean(Mel_LMinusMNulls(:, :, 2),2), 'r', 'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', 'r'); hold on;
theXRunCorrelations(1, 2) = corr(mean(Mel_LMinusMNulls(:, :, 1),2), mean(Mel_LMinusMNulls(:, :, 2),2), 'type', 'Spearman');
title({'Mel directed / L-M null' ['r = ' num2str(theXRunCorrelations(1, 2))]});

subplot(2, 3, 3);
plot(mean(Mel_SNulls(:, :, 1),2), mean(Mel_SNulls(:, :, 2),2), 'b', 'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', 'b'); hold on;
theXRunCorrelations(1, 3) = corr(mean(Mel_SNulls(:, :, 1),2), mean(Mel_SNulls(:, :, 2),2), 'type', 'Spearman');
title({'Mel directed / S null' ['r = ' num2str(theXRunCorrelations(1, 3))]});

theXRunCorrelations(2, 1) = NaN;
subplot(2, 3, 5);
plot(mean(LMS_LMinusMNulls(:, :, 1),2), mean(LMS_LMinusMNulls(:, :, 2),2), 'r', 'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', 'r'); hold on;
theXRunCorrelations(2, 2) = corr(mean(LMS_LMinusMNulls(:, :, 1),2), mean(LMS_LMinusMNulls(:, :, 2),2), 'type', 'Spearman');
title({'LMS directed / L-M null' ['r = ' num2str(theXRunCorrelations(2, 2))]});

subplot(2, 3, 6);
plot(mean(LMS_SNulls(:, :, 1),2), mean(LMS_SNulls(:, :, 2),2), 'b', 'LineStyle', 'none', 'Marker', 'o', 'MarkerFaceColor', 'b'); hold on;
theXRunCorrelations(2, 3) = corr(mean(LMS_SNulls(:, :, 1),2), mean(LMS_SNulls(:, :, 2),2), 'type', 'Spearman');
title({'LMS directed / S null' ['r = ' num2str(theXRunCorrelations(2, 3))]});

for i = [1:3 5 6]
    subplot(2, 3, i)
    pbaspect([1 1 1]); set(gca, 'TickDir', 'out'); box off;
    axLim = 0.14;
    xlim([-axLim axLim]); ylim([-axLim axLim]);
    plot([-axLim axLim], [-axLim axLim], '-k');
    plot([0 0], [-axLim axLim], '-k');
    plot([-axLim axLim], [0 0], '-k');
    xlabel('Run 1'); ylabel('Run 2');
end
switch whichReceptorsToProbe
    case 'InCache'
        set(gcf, 'PaperPosition', [0 0 8 6]); %Position plot at left hand corner with width 8 and height 5.
        set(gcf, 'PaperSize', [8 6]); %Set the paper to have width 8 and height 5.
        outFile = ['MelLMS_AcrossRuns.png'];
        saveas(gcf, fullfile(analysisDir, outFile), 'png');
end

% Save out the correlations
switch whichReceptorsToProbe
    case 'InCache'
        fidMel = fopen(fullfile(analysisDir, 'xInCache', 'Mel_AcrossRunCorrelations.csv'), 'w'); fprintf(fidMel, 'LMS null,L-M null,S null\n');
        fclose(fidMel); dlmwrite(fullfile(analysisDir, 'xInCache', 'Mel_AcrossRunCorrelations.csv'), theXRunCorrelations(1, :), '-append');
        fidLMS = fopen(fullfile(analysisDir, 'xInCache', 'LMS_AcrossRunCorrelations.csv'), 'w'); fprintf(fidLMS, 'LMS null,L-M null,S null\n');
        fclose(fidLMS); dlmwrite(fullfile(analysisDir, 'xInCache', 'LMS_AcrossRunCorrelations.csv'), theXRunCorrelations(2, :), '-append');
    case 'LMSTabulatedAbsorbance'
        fidMel = fopen(fullfile(analysisDir, 'xLMSTabulatedAbsorbance', 'Mel_AcrossRunCorrelations.csv'), 'w'); fprintf(fidMel, 'LMS null,L-M null,S null\n');
        fclose(fidMel); dlmwrite(fullfile(analysisDir, 'xLMSTabulatedAbsorbance', 'Mel_AcrossRunCorrelations.csv'), theXRunCorrelations(1, :), '-append');
        fidLMS = fopen(fullfile(analysisDir, 'xLMSTabulatedAbsorbance', 'LMS_AcrossRunCorrelations.csv'), 'w'); fprintf(fidLMS, 'LMS null,L-M null,S null\n');
        fclose(fidLMS); dlmwrite(fullfile(analysisDir, 'xLMSTabulatedAbsorbance', 'LMS_AcrossRunCorrelations.csv'), theXRunCorrelations(2, :), '-append');
end
%% Average all measures within subject,
% Report the population means and standard deviations
Mel_LMSNullsAllGrandMean = mean(mean(Mel_LMSNullsAll, 2));
Mel_LMSNullsAllGrandSD = std(mean(Mel_LMSNullsAll, 2));

Mel_LMinusMNullsAllGrandMean = mean(mean(Mel_LMinusMNullsAll, 2));
Mel_LMinusMNullsAllGrandSD = std(mean(Mel_LMinusMNullsAll, 2));

Mel_SNullsAllGrandMean = mean(mean(Mel_SNullsAll, 2));
Mel_SNullsAllGrandSD = std(mean(Mel_SNullsAll, 2));

LMS_LMinusMNullsAllGrandMean = mean(mean(LMS_LMinusMNullsAll, 2));
LMS_LMinusMNullsAllGrandSD = std(mean(LMS_LMinusMNullsAll, 2));

LMS_SNullsAllGrandMean = mean(mean(LMS_SNullsAll, 2));
LMS_SNullsAllGrandSD = std(mean(LMS_SNullsAll, 2));

allMeans = [Mel_LMSNullsAllGrandMean Mel_LMinusMNullsAllGrandMean Mel_SNullsAllGrandMean LMS_LMinusMNullsAllGrandMean LMS_SNullsAllGrandMean];
allSDs = [Mel_LMSNullsAllGrandSD Mel_LMinusMNullsAllGrandSD Mel_SNullsAllGrandSD LMS_LMinusMNullsAllGrandSD LMS_SNullsAllGrandSD];

M = [allMeans' allSDs'];
switch whichReceptorsToProbe
    case 'InCache'
        fid = fopen(fullfile(analysisDir, 'xInCache', 'MelLMS_GrandMean.csv'), 'w'); fprintf(fid, ',Mean,SD\n');
        fprintf(fid, 'Mel LMS,%f,%f\n', M(1, 1), M(1, 2));
        fprintf(fid, 'Mel L-M,%f,%f\n', M(2, 1), M(2, 2));
        fprintf(fid, 'Mel S,%f,%f\n', M(3, 1), M(3, 2));
        fprintf(fid, 'LMS L-M,%f,%f\n', M(4, 1), M(4, 2));
        fprintf(fid, 'LMS S,%f,%f\n', M(5, 1), M(5, 2));
        fclose(fidMel);
    case 'LMSTabulatedAbsorbance'
        fid = fopen(fullfile(analysisDir, 'xLMSTabulatedAbsorbance', 'MelLMS_GrandMean.csv'), 'w'); fprintf(fid, ',Mean,SD\n');
        fprintf(fid, 'Mel LMS,%f,%f\n', M(1, 1), M(1, 2));
        fprintf(fid, 'Mel L-M,%f,%f\n', M(2, 1), M(2, 2));
        fprintf(fid, 'Mel S,%f,%f\n', M(3, 1), M(3, 2));
        fprintf(fid, 'LMS L-M,%f,%f\n', M(4, 1), M(4, 2));
        fprintf(fid, 'LMS S,%f,%f\n', M(5, 1), M(5, 2));
        fclose(fidMel);
end