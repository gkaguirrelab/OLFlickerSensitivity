function theFig = AnalyzeMRTTFGroup(theFig, BASE_PATH, subjects, direction, fieldInnerRing, fieldOuterRing, controlFlag, protocolIterFlag, controlLabels, area, plotSpec, savePath, plotAllSubs, fitTTF, normFactor)
% theFig = AnalyzeMRTTFGroup(theFig, BASE_PATH, subjects, direction, fieldInnerRing, fieldOuterRing,controlFlag, protocolIterFlag, controlLabels, area, plotSpec, savePath, plotAllSubs, fitTTF, normFactor)
%
% normFactor is only used for plotting, not for fitting.

for s = 1:length(subjects)
    if ~controlFlag
        switch area
            case {'V1', 'V2', 'V3'}
                fileName = ['copes.osgm.ffx.results_cortex_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.csv'];
            case 'LGN'
                fileName = ['copes.osgm.ffx.results_lgn_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.csv'];
        end
        thePath = fullfile(BASE_PATH, subjects{s}, 'BOLD', ['TTFMRFlicker' protocolIterFlag '_' direction '_xrun.feat'], 'stats', fileName);
    else
        fileName = ['copes.osgm.ffx.results_cortex_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.csv'];
        thePath = fullfile(BASE_PATH, subjects{s}, 'BOLD', ['TTFMRFlickerC1_xrun.feat'], 'stats', fileName);
    end
    M = csvread(thePath);
    
    if ~controlFlag
        frequencies = M(:, 1);
        frequencyLabels = [0.5 1 2 4 8 16 32 64];
        M(:, 1) = [];
    end
    switch area
        case {'V1', 'V2', 'V3'}
            V1_res(:, s) = M(:, 1);
            V2_res(:, s) = M(:, 3);
            V3_res(:, s) = M(:, 5);
            V4_res(:, s) = M(:, 7);
        case 'LGN'
            LGN_res(:, s) = M(:, 1);
    end
end

switch area
    case {'V1', 'V2', 'V3'}
        %% Take averages
        V1_avg = mean(V1_res, 2);
        V2_avg = mean(V2_res, 2);
        V3_avg = mean(V3_res, 2);
        V4_avg = mean(V4_res, 2);
        
        % Take SEMs
        V1_sem = std(V1_res, [], 2)/sqrt(length(subjects));
        V2_sem = std(V2_res, [], 2)/sqrt(length(subjects));
        V3_sem = std(V3_res, [], 2)/sqrt(length(subjects));
        V4_sem = std(V4_res, [], 2)/sqrt(length(subjects));
        
        
        %% Fit the results for V1
        if fitTTF
            [theParams, V1_theXFit, V1_theYFit, V1_theXInterp, V1_theYInterp] = FitMRTTF(frequencies, V1_avg+20, V1_sem);
            save(fullfile(fullfile(savePath, ['grp_avg_' direction '_copes.osgm.ffx.results_cortex_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing)  'deg_' area '.mat'])), 'theParams', 'V1_theXFit', 'V1_theYFit', 'V1_theXInterp', 'V1_theYInterp', 'V1_avg', 'V1_sem');
            V1_theYFit = V1_theYFit - 20;
            V1_theYInterp = V1_theYInterp - 20;
        end
    case 'LGN'
        %% Take averages
        LGN_avg = mean(LGN_res, 2);
        
        % Take SEMs
        LGN_sem = std(LGN_res, [], 2)/sqrt(length(subjects));
end

% Set up some markers
theMarkers = {'--', '.', '-.', '-'};

if ~controlFlag
    % Make a figure
    figure(theFig);
    theColors = lbmap(4, 'RedBlue');
    
    % Plot the data points with error bars
    switch area
        case 'V1'
            if fitTTF
                plot(log2(V1_theXInterp), V1_theYInterp/normFactor, '-k'); hold on;
            end
            hnew = errorbar(log2(frequencies)', V1_avg/normFactor, V1_sem/normFactor, plotSpec.marker, 'Color', plotSpec.color, 'MarkerFaceColor', plotSpec.markerFaceColor, 'MarkerSize', plotSpec.markerSize); hold on; % V1
            if plotAllSubs
                for i = 1: size(V1_res, 2)
                    plot(log2(frequencies)', V1_res(:, i)/normFactor, 'Color', theColors(i, :));
                end
            end
            
            %hnew = shadedErrorBar(log2(frequencies)', V1_avg, V1_sem, {plotSpec.marker, 'Color', plotSpec.color, 'MarkerFaceColor', plotSpec.markerFaceColor, 'MarkerSize', plotSpec.markerSize}, 1); hold on;
        case 'V2'
            hnew = errorbar(log2(frequencies)', V2_avg, V2_sem, plotSpec.marker, 'Color', plotSpec.color, 'MarkerFaceColor', plotSpec.markerFaceColor, 'MarkerSize', plotSpec.markerSize); hold on; % V1
            if plotAllSubs
                for i = 1: size(V2_res, 2)
                    plot(log2(frequencies)', V2_res(:, i), 'Color', theColors(i, :));
                end
            end
            %hnew = shadedErrorBar(log2(frequencies)', V2_avg, V2_sem, {plotSpec.marker, 'Color', plotSpec.color, 'MarkerFaceColor', plotSpec.markerFaceColor, 'MarkerSize', plotSpec.markerSize}, 1); hold on
        case 'V3'
            hnew = errorbar(log2(frequencies)', V3_avg, V3_sem, plotSpec.marker, 'Color', plotSpec.color, 'MarkerFaceColor', plotSpec.markerFaceColor, 'MarkerSize', plotSpec.markerSize); hold on; % V1
            if plotAllSubs
                for i = 1: size(V3_res, 2)
                    plot(log2(frequencies)', V3_res(:, i), 'Color', theColors(i, :));
                end
            end
            %hnew = shadedErrorBar(log2(frequencies)', V3_avg, V3_sem, {plotSpec.marker, 'Color', plotSpec.color, 'MarkerFaceColor', plotSpec.markerFaceColor, 'MarkerSize', plotSpec.markerSize}, 1); hold on
        case 'V4'
            %hnew = shadedErrorBar(log2(frequencies)', V4_avg, V4_sem, {plotSpec.marker, 'Color', plotSpec.color, 'MarkerFaceColor', plotSpec.markerFaceColor, 'MarkerSize', plotSpec.markerSize}, 1); hold on
        case 'LGN'
            hnew = errorbar(log2(frequencies)', 3*LGN_avg, LGN_sem, plotSpec.marker, 'Color', plotSpec.color, 'MarkerFaceColor', plotSpec.markerFaceColor, 'MarkerSize', plotSpec.markerSize); hold on; % V1
            if plotAllSubs
                for i = 1: size(LGN_res, 2)
                    plot(log2(frequencies)', LGN_res(:, i), 'Color', theColors(i, :));
                end
            end
            
            
    end
    
    % Tweak plot parameters
    xlim([-2 6.5]);
    if normFactor == 1
        ylim([-50 250]);
    else
        ylim([-0.3 1.4]);
    end
    
    plot([-3 7], [0 0], '--k'); % Reference line
    xlabel('Frequency');
    switch area
        case 'V1'
            if normFactor == 1
                ylabel('Parameter estimates');
            else
                ylabel('Response relative to max.');
            end
        case 'LGN'
            ylabel('Parameter estimates x3');
    end
    %set(gca, 'XTick', frequencyLabels));
    %set(gca, 'XTickLabel', frequencyLabels);
    pbaspect([1 .7 1]);
    
    % Add a legend
    % Get object handles
    [LEGH,OBJH,OUTH,OUTM] = legend;
    if isempty(LEGH)
        %legend(hnew.mainLine, plotSpec.legend); legend boxoff;
        legend(hnew, plotSpec.legend); legend boxoff;
    else
        % Add object with new handle and new legend string to legend
        legend([OUTH;hnew],OUTM{:},plotSpec.legend); legend boxoff;
    end
    title({direction [num2str(fieldInnerRing) '-' num2str(fieldOuterRing) ' deg ecc., ' area]});
else
    % Make a figure
    figure(theFig);
    theColors = lbmap(4, 'RedBlue');
    errorbarbar([1 2 3 4], [V1_avg V2_avg V3_avg], [V1_sem V2_sem V3_sem]);
    P=findobj(gca,'type','patch');
    for n=1:length(P)
        set(P(n),'facecolor',theColors(length(P)-(n-1), :));
    end
    
    xlim([0.5 4.5]);
    ylim([-50 200]);
    set(gca, 'XTickLabel', controlLabels);
    pbaspect([1 .7 1]);
end


set(theFig, 'PaperPosition', [0 0 8 5]); %Position plot at left hand corner with width 12 and height 8.
set(theFig, 'PaperSize', [8 5]); %Set the paper to have width 12 and height 8.
if normFactor ~= 1
    normSuffix = '_norm';
else
    normSuffix = '';
end

if plotAllSubs
    saveas(theFig, fullfile(savePath, ['grp_avg_' direction '_copes.osgm.ffx.results_cortex_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing)  'deg_' area '_allSubs' normSuffix '.pdf']), 'pdf');
else
    saveas(theFig, fullfile(savePath, ['grp_avg_' direction '_copes.osgm.ffx.results_cortex_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing)  'deg_' area normSuffix '.pdf']), 'pdf');
    fullfile(savePath, ['grp_avg_' direction '_copes.osgm.ffx.results_cortex_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing)  'deg_' area normSuffix '.pdf']);
end