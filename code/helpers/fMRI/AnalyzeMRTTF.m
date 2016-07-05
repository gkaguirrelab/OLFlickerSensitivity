function AnalyzeMRTTF(lhGlmDirs, rhGlmDirs, analysisFile, outDir, modulations, frequencies, contrast, roi, fieldInnerRing, fieldOuterRing);
% Makes plots of the parameter estimates



%% Add the FreeSurfer path just to be sure.
addpath(genpath('/Applications/freesurfer/matlab'));

% Do different things for different ROIs
switch roi
    case 'LGN'
        % Check if everything is consistent
        if ~isempty(rhGlmDirs)
            error(['Mode is ' roi ', but rhGlmDirs was specified.']);
        end
        glmDirs = lhGlmDirs;
        nDirs = length(glmDirs);
        
        % Load in the LGN template
        templateDir = '/Data/Imaging/Protocols/TTFMRFlickerX/Templates';
        tmp = MRIread(fullfile(templateDir, 'LGN', 'Juelich-LGN.nii.gz'));
        LGNindices = find(tmp.vol);
        
        %% Read in the data
        for i = 1:nDirs
            % Load in the volume
            tmp = MRIread(fullfile( glmDirs{i}, analysisFile));
            theData = tmp.vol;
            theData_LGN = theData(LGNindices);
            
            % Take the average
            LGN_avg(i, :) = mean(theData_LGN);
            LGN_sem(i, :) = std(theData_LGN)/sqrt(length(LGNindices));
        end
        
        % Write the results as CSV
        csvwrite(fullfile(outDir, ['copes.osgm.ffx.results_lgn_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing)  'deg.csv']), [frequencies' LGN_avg LGN_sem]);
        
        % Make a figure
        theFig = figure;
        theColors = lbmap(4, 'RedBlue');
        
        % Plot the data points with error bars
        errorbar(log2(frequencies)', 3*LGN_avg, LGN_sem, '-ok', 'MarkerFaceColor', theColors(1, :)); hold on; % V1
        
        % Tweak plot parameters
        xlim([-2 6.5]);
        ylim([-50 250]);
        plot([-3 7], [0 0], '--k'); % Reference line
        xlabel('Frequency');
        ylabel('Parameter estimates x3');
        set(gca, 'XTick', log2(frequencies));
        set(gca, 'XTickLabel', frequencies);
        pbaspect([1 .7 1]);
        % Add a legend
        legend('LGN');
        title({modulations{1} [num2str(fieldInnerRing) '-' num2str(fieldOuterRing) ' deg ecc.']});
        
        set(theFig, 'PaperPosition', [0 0 12 8]); %Position plot at left hand corner with width 12 and height 8.
        set(theFig, 'PaperSize', [12 8]); %Set the paper to have width 12 and height 8.
        saveas(theFig, fullfile(fullfile(outDir, ['copes.osgm.ffx.results_lgn_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing)  'deg.pdf'])), 'pdf');
        
    case {'Cortex', 'cortex'}
        % Check if we are consistent in the number of lhGlmDirs and rhGlmDirs
        if ~(length(lhGlmDirs) == length(rhGlmDirs))
            error('The number of GLM directories is different for the two hemisphere');
        end
        nDirs = min([length(lhGlmDirs) length(rhGlmDirs)]);
        
        
        %% Load in the masks
        templateDir = '/Data/Imaging/Protocols/TTFMRFlickerX/Templates';
        load(fullfile(templateDir, ['V1_mask_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.mat']));
        load(fullfile(templateDir, ['V2_mask_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.mat']));
        load(fullfile(templateDir, ['V3_mask_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.mat']));
        load(fullfile(templateDir, ['hV4_mask_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.mat']));
        
        %% Read in the data
        for i = 1:nDirs
            % Left hemisphere
            lhData = load_mgh(fullfile(lhGlmDirs{i}, analysisFile));
            
            % Reft hemisphere
            rhData = load_mgh(fullfile(rhGlmDirs{i}, analysisFile));
            
            % Pull out the data
            theData_V1 = [lhData(V1_mask) ; rhData(V1_mask)];
            theData_V2 = [lhData(V2_mask) ; rhData(V2_mask)];
            theData_V3 = [lhData(V3_mask) ; rhData(V3_mask)];
            theData_V4 = [lhData(V4_mask) ; rhData(V4_mask)];
            
            % Take the mean
            V1_avg(i, :) = mean(theData_V1);
            V2_avg(i, :) = mean(theData_V2);
            V3_avg(i, :) = mean(theData_V3);
            V4_avg(i, :) = mean(theData_V4);
            
            % Take the SEM
            V1_sem(i, :) = std(theData_V1)/sqrt(length([V1_mask V1_mask]));
            V2_sem(i, :) = std(theData_V2)/sqrt(length([V1_mask V1_mask]));
            V3_sem(i, :) = std(theData_V3)/sqrt(length([V1_mask V1_mask]));
            V4_sem(i, :) = std(theData_V4)/sqrt(length([V1_mask V1_mask]));
        end
        
        % Find the singleton dimension in the parameters:
        %   - If we have one direction and multiple frequencies, plot them
        %   in one graph.
        %   - If we have multiple directions and one frequency, plot them
        %   in one graph.
        %   - If we have multiple directions and one frequenci, plot
        %   different directions in different graphs but frequency on x
        %   axis.
        if (length(modulations) == 1)
            % Write the results as CSV
            csvwrite(fullfile(outDir, ['copes.osgm.ffx.results_cortex_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing)  'deg.csv']), [frequencies' V1_avg V1_sem V2_avg V2_sem V3_avg V3_sem V4_avg V4_sem]);
            
            % Make a figure
            theFig = figure;
            theColors = lbmap(4, 'RedBlue');
            
            % Plot the data points with error bars
            errorbar(log2(frequencies)', V1_avg, V1_sem, '-ok', 'MarkerFaceColor', theColors(1, :)); hold on; % V1
            errorbar(log2(frequencies)', V2_avg, V2_sem, '-ok', 'MarkerFaceColor', theColors(2, :)); hold on; % V2
            errorbar(log2(frequencies)', V3_avg, V3_sem, '-ok', 'MarkerFaceColor', theColors(3, :)); hold on; % V3
            errorbar(log2(frequencies)', V4_avg, V4_sem, '-ok', 'MarkerFaceColor', theColors(4, :)); hold on; % hV4
            
            % Tweak plot parameters
            xlim([-2 6.5]);
            ylim([-50 250]);
            plot([-3 7], [0 0], '--k'); % Reference line
            xlabel('Frequency');
            ylabel('Parameter estimates');
            set(gca, 'XTick', log2(frequencies));
            set(gca, 'XTickLabel', frequencies);
            pbaspect([1 .7 1]);
            % Add a legend
            legend('V1', 'V2', 'V3', 'hV4');
            title({modulations{1} [num2str(fieldInnerRing) '-' num2str(fieldOuterRing) ' deg ecc.']});
            
            set(theFig, 'PaperPosition', [0 0 12 8]); %Position plot at left hand corner with width 12 and height 8.
            set(theFig, 'PaperSize', [12 8]); %Set the paper to have width 12 and height 8.
            saveas(theFig, fullfile(fullfile(outDir, ['copes.osgm.ffx.results_cortex_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing)  'deg.pdf'])), 'pdf');
        elseif (length(frequencies) == 1)
            csvwrite(fullfile(outDir, ['copes.osgm.ffx.results_cortex_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing)  'deg.csv']), [V1_avg V1_sem V2_avg V2_sem V3_avg V3_sem V4_avg V4_sem]);
            
            % Make a figure
            theFig = figure;
            theColors = lbmap(nDirs, 'RedBlue');
            
            % Plot the data points with error bars
            for i = 1:nDirs
                subplot(nDirs, 1, i)
                errorbar(log2(frequencies)', V1_avg(i, :), V1_sem(i, :), '-ok', 'MarkerFaceColor', theColors(1, :)); hold on; % V1
                errorbar(log2(frequencies)', V2_avg(i, :), V2_sem(i, :), '-ok', 'MarkerFaceColor', theColors(2, :)); hold on; % V2
                errorbar(log2(frequencies)', V3_avg(i, :), V3_sem(i, :), '-ok', 'MarkerFaceColor', theColors(3, :)); hold on; % V3
                errorbar(log2(frequencies)', V4_avg(i, :), V4_sem(i, :), '-ok', 'MarkerFaceColor', theColors(4, :)); hold on; % hV4
                
                % Tweak plot parameters
                xlim([0 6.5]);
                ylim([-50 160]);
                plot([0 7], [0 0], '--k'); % Reference line
                xlabel('Frequency');
                ylabel('Parameter estimates');
                set(gca, 'XTick', log2(frequencies));
                set(gca, 'XTickLabel', frequencies);
                pbaspect([1 .7 1]);
                % Add a legend
                legend('V1', 'V2', 'V3', 'hV4');
                title({modulations{i} [num2str(fieldInnerRing) '-' num2str(fieldOuterRing) ' deg ecc.']});
            end
            
            
            %set(theFig, 'PaperPosition', [0 0 12 8]); %Position plot at left hand corner with width 12 and height 8.
            %set(theFig, 'PaperSize', [12 8]); %Set the paper to have width 12 and height 8.
            saveas(theFig, fullfile(fullfile(outDir, ['copes.osgm.ffx.results_cortex_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing)  'deg.pdf'])), 'pdf');
        elseif ~(length(frequencies) == 1) &&  ~(length(modulations) == 1)
            error('Not implemented yet.')
        end
        
end