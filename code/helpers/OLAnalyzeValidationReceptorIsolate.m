function photopicLuminance = OLAnalyzeValidationReceptorIsolateShort(valFileNameFull, mode)
% OLAnalyzeValidationReceptorIsolate(valFileNameFull)

[validationDir, valFileName] = fileparts(valFileNameFull);
val = LoadCalFile(valFileName, [], [validationDir '/']);

% Pull out the data for the reference observer
data = val.describe.cache.data;

% Pull out the cal ID to add to file names and titles. We can't use
% OLGetCalID since we don't necessary have the cal struct.
if isfield(val.describe, 'calID')
    calID = val.describe.calID;
    calIDTitle = val.describe.calIDTitle;
else
    calID = '';
    calIDTitle = '';
end

% Pull out S
S = val.describe.S;

switch mode
    case 'short'
        theCanonicalPhotoreceptors = data(32).describe.photoreceptors;%{'LCone', 'MCone', 'SCone', 'Melanopsin', 'Rods'};
        T_receptors = data(32).describe.T_receptors;%GetHumanPhotoreceptorSS(S, theCanonicalPhotoreceptors, data(val.describe.REFERENCE_OBSERVER_AGE).describe.params.fieldSizeDegrees, val.describe.REFERENCE_OBSERVER_AGE, 4.7, [], data(val.describe.REFERENCE_OBSERVER_AGE).describe.fractionBleached);
        
        load T_xyz1931
        T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);
        photopicLuminanceCdM2 = T_xyz(2,:)*val.modulationBGMeas.meas.pr650.spectrum;
        
        fid = fopen(fullfile(validationDir, [valFileName '.txt']), 'w');
        fprintf(fid, 'Background luminance [cd/m2]: %.2f cd/m2\n', photopicLuminanceCdM2);
        fprintf('Background luminance [cd/m2]: %.2f cd/m2\n', photopicLuminanceCdM2);
        if ~strcmp(val.describe.cache.data(32).describe.params.receptorIsolateMode, 'PIPR')
            % Calculate the receptor activations to the background
            backgroundReceptors = T_receptors* val.modulationBGMeas.meas.pr650.spectrum;
            %% Compute and report constrasts
            differenceSpdSignedPositive = val.modulationMaxMeas.meas.pr650.spectrum-val.modulationBGMeas.meas.pr650.spectrum;
            differenceReceptors = T_receptors*differenceSpdSignedPositive;
            isolateContrastsSignedPositive = differenceReceptors ./ backgroundReceptors;
            
            
            %differenceSpdSignedNegative = val.modulationMinMeas.meas.pr650.spectrum-val.modulationBGMeas.meas.pr650.spectrum;
            %differenceReceptors = T_receptors*differenceSpdSignedNegative;
            %isolateContrastsSignedNegative = differenceReceptors ./ backgroundReceptors;
            
            for j = 1:size(T_receptors,1)
                fprintf(fid, '  - %s: contrast = \t%f \n',theCanonicalPhotoreceptors{j},isolateContrastsSignedPositive(j));%=,isolateContrastsSignedNegative(j));
                fprintf('  - %s: contrast = \t%f \n',theCanonicalPhotoreceptors{j},isolateContrastsSignedPositive(j));% d,isolateContrastsSignedNegative(j));
            end
            fclose(fid);
        end
        
    case 'full'
        fprintf('> Requested to calculate splatter as per CALCULATE_SPLATTER flag...\n');
        
        %% Plot the spectra
        theSpectraFig = figure;
        subplot(3, 4, 1);
        plot(SToWls(S), val.modulationBGMeas.meas.pr650.spectrum, '-k'); hold on;
        plot(SToWls(S), data(val.describe.REFERENCE_OBSERVER_AGE).backgroundSpd*(data(val.describe.REFERENCE_OBSERVER_AGE).backgroundSpd \ val.modulationBGMeas.meas.pr650.spectrum), '-r');
        legend('Measured', 'Rescaled predicted', 'Location', 'North'); legend boxoff;
        xlim([380 780]);
        %ylim([0 0.1]);
        xlabel('Wavelength [nm]'); ylabel('Power'); title('Background (measured)'); pbaspect([1 1 1]);
        
        subplot(3, 4, 2);
        plot(SToWls(S), val.modulationMaxMeas.meas.pr650.spectrum, '-k'); hold on;
        plot(SToWls(S), val.modulationBGMeas.meas.pr650.spectrum, '--k');
        % Rescale the predicted modulation spectrum to match the measured one,
        % minus bg
        scaleFactor = (data(val.describe.REFERENCE_OBSERVER_AGE).modulationSpdSignedPositive - data(val.describe.REFERENCE_OBSERVER_AGE).backgroundSpd) \ (val.modulationMaxMeas.meas.pr650.spectrum - val.modulationBGMeas.meas.pr650.spectrum);
        plot(SToWls(S), data(val.describe.REFERENCE_OBSERVER_AGE).backgroundSpd+scaleFactor*(data(val.describe.REFERENCE_OBSERVER_AGE).modulationSpdSignedPositive-data(val.describe.REFERENCE_OBSERVER_AGE).backgroundSpd), '-r');
        xlim([380 780]);
        %ylim([0 0.1]);
        xlabel('Wavelength [nm]'); ylabel('Power'); title('Positive'); pbaspect([1 1 1]);
        
        if ~strcmp(val.describe.cache.data(32).describe.params.receptorIsolateMode, 'PIPR')
            subplot(3, 4, 3);
            plot(SToWls(S), val.modulationMinMeas.meas.pr650.spectrum, '-k'); hold on;
            plot(SToWls(S), val.modulationBGMeas.meas.pr650.spectrum, '--k');
            % Rescale the predicted modulation spectrum to match the measured one,
            % minus bg
            scaleFactor = (data(val.describe.REFERENCE_OBSERVER_AGE).modulationSpdSignedNegative - data(val.describe.REFERENCE_OBSERVER_AGE).backgroundSpd) \ (val.modulationMinMeas.meas.pr650.spectrum - val.modulationBGMeas.meas.pr650.spectrum);
            plot(SToWls(S), data(val.describe.REFERENCE_OBSERVER_AGE).backgroundSpd+scaleFactor*(data(val.describe.REFERENCE_OBSERVER_AGE).modulationSpdSignedNegative-data(val.describe.REFERENCE_OBSERVER_AGE).backgroundSpd), '-r');
            xlim([380 780]);
            xlabel('Wavelength [nm]'); ylabel('Power'); title('Negative'); pbaspect([1 1 1]);
        end
        
        subplot(3, 4, 4);
        plot(SToWls(S), val.modulationMaxMeas.meas.pr650.spectrum-val.modulationBGMeas.meas.pr650.spectrum, '-r'); hold on;
        if ~strcmp(val.describe.cache.data(32).describe.params.receptorIsolateMode, 'PIPR')
            plot(SToWls(S), val.modulationMinMeas.meas.pr650.spectrum-val.modulationBGMeas.meas.pr650.spectrum, '-b');
        end
        
        xlim([380 780]);
        %ylim([0 0.1]);
        xlabel('Wavelength [nm]'); ylabel('Power'); title('Difference spectra'); pbaspect([1 1 1]);
        
        subplot(3, 4, 5);
        plot(SToWls(S), val.modulationBGMeas.meas.pr650.spectrum./data(val.describe.REFERENCE_OBSERVER_AGE).backgroundSpd, '-k'); hold on;
        if isfield(val.fullOnMeas, 'meas');
            plot(SToWls(S), val.fullOnMeas.meas.pr650.spectrum./val.fullOnMeas.predictedFromCal, 'Color', [0 .5 0]); hold on;
            legend('Background', 'Full-on (wrt cal)', 'Location', 'South'); legend boxoff;
        end
        plot([380 780], [1 1], '--k');
        xlabel('Wavelength [nm]'); ylabel('Power ratio');
        xlim([380 780]);
        ylim([0.2 1.8]);
        pbaspect([1 1 1]);
        
        subplot(3, 4, 6);
        plot(SToWls(S), val.modulationMaxMeas.meas.pr650.spectrum./(data(val.describe.REFERENCE_OBSERVER_AGE).backgroundSpd+scaleFactor*(data(val.describe.REFERENCE_OBSERVER_AGE).modulationSpdSignedPositive-data(val.describe.REFERENCE_OBSERVER_AGE).backgroundSpd)), '-b'); hold on;
        plot([380 780], [1 1], '--k');
        xlabel('Wavelength [nm]'); ylabel('Power ratio');
        xlim([380 780]);
        ylim([0.2 1.8]);
        pbaspect([1 1 1]);
        
        if ~strcmp(val.describe.cache.data(32).describe.params.receptorIsolateMode, 'PIPR')
            subplot(3, 4, 7);
            plot(SToWls(S), val.modulationMinMeas.meas.pr650.spectrum./(data(val.describe.REFERENCE_OBSERVER_AGE).backgroundSpd+scaleFactor*(data(val.describe.REFERENCE_OBSERVER_AGE).modulationSpdSignedNegative-data(val.describe.REFERENCE_OBSERVER_AGE).backgroundSpd)), '-r'); hold on;
            plot([380 780], [1 1], '--k');
            xlabel('Wavelength [nm]'); ylabel('Power ratio');
            xlim([380 780]);
            ylim([0.2 1.8]);
            pbaspect([1 1 1]);
        end
        
        %% Plot the scatter of predicted vs. validated
        subplot(3, 4, 9);
        plot(data(val.describe.REFERENCE_OBSERVER_AGE).backgroundSpd, val.modulationBGMeas.meas.pr650.spectrum, '.'); hold on;
        plot([0 0.1], [0 0.1], '--k');
        axis equal;
        xlabel('Target'); ylabel('Measured'); title('Measured vs. target'); pbaspect([1 1 1]);
        
        subplot(3, 4, 10);
        plot(data(val.describe.REFERENCE_OBSERVER_AGE).modulationSpdSignedPositive, val.modulationMaxMeas.meas.pr650.spectrum, '.'); hold on;
        plot([0 0.1], [0 0.1], '--k');
        axis equal;
        xlabel('Target'); ylabel('Measured'); title('Measured vs. target'); pbaspect([1 1 1]);
        
        if ~strcmp(val.describe.cache.data(32).describe.params.receptorIsolateMode, 'PIPR')
            subplot(3, 4, 11);
            plot(data(val.describe.REFERENCE_OBSERVER_AGE).modulationSpdSignedNegative, val.modulationMinMeas.meas.pr650.spectrum, '.'); hold on;
            plot([0 0.1], [0 0.1], '--k');
            axis equal;
            xlabel('Target'); ylabel('Measured'); title('Measured vs. target'); pbaspect([1 1 1]);
        end
        
        set(theSpectraFig, 'PaperPosition', [0 0 10 10]);
        set(theSpectraFig, 'PaperSize', [10 10]);
        %suptitle(sprintf('%s\n%s', calIDTitle, valFileName));
        currDir = pwd;
        cd(validationDir);
        saveas(theSpectraFig, ['Spectra_' calID], 'pdf');
        cd(currDir);
        
        if ~strcmp(val.describe.cache.data(32).describe.params.receptorIsolateMode, 'PIPR')
            try
                %% Infer primary weights. Plot the inferred primary weights.
                theInferredPrimaryWeights = figure;
                cal = val.describe.cal;
                B_primary = cal.computed.pr650M;
                % BG
                subplot(2, 3, 1);
                nPrimaries = length(data(val.describe.REFERENCE_OBSERVER_AGE).backgroundPrimary);
                plot(1:nPrimaries, data(val.describe.REFERENCE_OBSERVER_AGE).backgroundPrimary, '-k'); hold on;
                theBGPrimaryValsInferred = B_primary \ (val.modulationBGMeas.meas.pr650.spectrum-data(val.describe.REFERENCE_OBSERVER_AGE).ambientSpd);
                plot(1:nPrimaries, theBGPrimaryValsInferred);
                xlabel('Primary #'); ylabel('Primary weight'); pbaspect([1 1 1]);
                legend('Actual', 'Inferred', 'Location', 'South'); legend boxoff;
                xlim([0, nPrimaries+1]);
                ylim([0 1]);
                pbaspect([1 1 1]);
                
                % Scatter plot
                subplot(2, 3, 4);
                plot(data(val.describe.REFERENCE_OBSERVER_AGE).backgroundPrimary, theBGPrimaryValsInferred, '.b'); hold on;
                xlim([0 1]); ylim([0 1]); pbaspect([1 1 1]);
                plot([0 1], [0 1], '--k');
                xlabel('Actual');
                ylabel('Inferred');
                
                % Max
                subplot(2, 3, 2);
                plot(1:nPrimaries, data(val.describe.REFERENCE_OBSERVER_AGE).modulationPrimarySignedPositive, '-k'); hold on;
                theModulationMaxPrimaryValsInferred = B_primary \ (val.modulationMaxMeas.meas.pr650.spectrum-data(val.describe.REFERENCE_OBSERVER_AGE).ambientSpd);
                plot(1:nPrimaries, theModulationMaxPrimaryValsInferred);
                xlabel('Primary #'); ylabel('Primary weight'); pbaspect([1 1 1]);
                xlim([0, nPrimaries+1]);
                ylim([0 1]);
                pbaspect([1 1 1]);
                
                % Scatter plot
                subplot(2, 3, 5);
                plot(data(val.describe.REFERENCE_OBSERVER_AGE).modulationPrimarySignedPositive, theModulationMaxPrimaryValsInferred, '.b');  hold on;
                xlim([0 1]); ylim([0 1]); pbaspect([1 1 1]);
                plot([0 1], [0 1], '--k');
                xlabel('Actual');
                ylabel('Inferred');
                
                % Min
                subplot(2, 3, 3);
                plot(1:nPrimaries, data(val.describe.REFERENCE_OBSERVER_AGE).modulationPrimarySignedNegative, '-k'); hold on;
                theModulationMinPrimaryValsInferred = B_primary \ (val.modulationMinMeas.meas.pr650.spectrum-data(val.describe.REFERENCE_OBSERVER_AGE).ambientSpd);
                plot(1:nPrimaries, theModulationMinPrimaryValsInferred);
                xlabel('Primary #'); ylabel('Primary weight'); pbaspect([1 1 1]);
                xlim([0, nPrimaries+1]);
                ylim([0 1]);
                pbaspect([1 1 1]);
                
                % Scatter plot
                subplot(2, 3, 6);
                plot(data(val.describe.REFERENCE_OBSERVER_AGE).modulationPrimarySignedNegative, theModulationMinPrimaryValsInferred, '.b'); hold on;
                xlim([0 1]); ylim([0 1]); pbaspect([1 1 1]);
                plot([0 1], [0 1], '--k');
                xlabel('Actual');
                ylabel('Inferred');
                
                suptitle(sprintf('%s\n%s', calIDTitle, valFileName));
                set(theInferredPrimaryWeights, 'PaperPosition', [0 0 10 8]);
                set(theInferredPrimaryWeights, 'PaperSize', [10 8]);
                
                currDir = pwd;
                cd(validationDir);
                saveas(theInferredPrimaryWeights, ['InferredWeights_' calID], 'pdf');
                cd(currDir);
            end
        end
        %% Save out the spectra
        if ~strcmp(val.describe.cache.data(32).describe.params.receptorIsolateMode, 'PIPR')
            csvwrite(fullfile(validationDir, ['Spectra_' calID '.csv']), [SToWls(S) val.modulationBGMeas.meas.pr650.spectrum val.modulationMaxMeas.meas.pr650.spectrum val.modulationMinMeas.meas.pr650.spectrum]);
        else
            csvwrite(fullfile(validationDir, ['Spectra_' calID '.csv']), [SToWls(S) val.modulationBGMeas.meas.pr650.spectrum val.modulationMaxMeas.meas.pr650.spectrum]);
        end
        
        % Only do the splatter calcs if the Klein is not involved
        if ~(isfield(data(val.describe.REFERENCE_OBSERVER_AGE).describe.params, 'checkKlein') && data(val.describe.REFERENCE_OBSERVER_AGE).describe.params.checkKlein) && ~strcmp(val.describe.cache.data(32).describe.params.receptorIsolateMode, 'PIPR');
            theCanonicalPhotoreceptors = {'LCone', 'MCone', 'SCone', 'Melanopsin', 'Rods'};
            %% Plot both the positive and the negative lobes.
            
            %% Positive modulation
            for k = 1:length(theCanonicalPhotoreceptors)
                targetContrasts{k} = data(val.describe.REFERENCE_OBSERVER_AGE).describe.contrastSignedPositive(k);
            end
            backgroundSpd = val.modulationBGMeas.meas.pr650.spectrum;
            modulationSpd = val.modulationMaxMeas.meas.pr650.spectrum;
            fileNameSuffix = '_positive';
            titleSuffix = 'Positive';
            
            % Calculate the splatter
            lambdaMaxRange = [];
            ageRange = [];
            [contrastMapPositive, nominalLambdaMax, ageRange, lambdaMaxShiftRange] = CalculateSplatter(S, backgroundSpd, modulationSpd, theCanonicalPhotoreceptors, data(val.describe.REFERENCE_OBSERVER_AGE).describe.params.fieldSizeDegrees, ageRange, [], lambdaMaxRange, data(val.describe.REFERENCE_OBSERVER_AGE).describe.fractionBleached);
            
            % Plot the splatter
            SAVEPLOTS = 0;
            theFig = PlotSplatter(figure, contrastMapPositive, theCanonicalPhotoreceptors, nominalLambdaMax, val.describe.REFERENCE_OBSERVER_AGE, ageRange, lambdaMaxShiftRange, targetContrasts, [], 1, 2, SAVEPLOTS, titleSuffix, [], val.describe.REFERENCE_OBSERVER_AGE);
            % Save out the splatter
            SaveSplatter(validationDir, [fileNameSuffix '_' calID], contrastMapPositive, theCanonicalPhotoreceptors, nominalLambdaMax, val.describe.REFERENCE_OBSERVER_AGE, ageRange, lambdaMaxShiftRange, targetContrasts);
            SaveSplatterConfidenceBounds(validationDir, [fileNameSuffix '_95CI_' calID], contrastMapPositive, theCanonicalPhotoreceptors, nominalLambdaMax, ageRange, lambdaMaxShiftRange, targetContrasts, 0.9545);
            SaveSplatterConfidenceBounds(validationDir, [fileNameSuffix '_99CI_' calID], contrastMapPositive, theCanonicalPhotoreceptors, nominalLambdaMax, ageRange, lambdaMaxShiftRange, targetContrasts, 0.9973);
            
            %% Negative modulation
            for k = 1:length(theCanonicalPhotoreceptors)
                targetContrasts{k} = data(val.describe.REFERENCE_OBSERVER_AGE).describe.contrastSignedNegative(k);
            end
            backgroundSpd = val.modulationBGMeas.meas.pr650.spectrum;
            modulationSpd = val.modulationMinMeas.meas.pr650.spectrum;
            fileNameSuffix = '_negative';
            titleSuffix = 'Negative';
            
            % Calculate the splatter
            lambdaMaxRange = [];
            ageRange = [];
            [contrastMapNegative, nominalLambdaMax, ageRange, lambdaMaxShiftRange] = CalculateSplatter(S, backgroundSpd, modulationSpd, theCanonicalPhotoreceptors, data(val.describe.REFERENCE_OBSERVER_AGE).describe.params.fieldSizeDegrees, ageRange, [], lambdaMaxRange, data(val.describe.REFERENCE_OBSERVER_AGE).describe.fractionBleached);
            
            % Plot the splatter
            theFig = PlotSplatter(theFig, contrastMapNegative, theCanonicalPhotoreceptors, nominalLambdaMax, val.describe.REFERENCE_OBSERVER_AGE, ageRange, lambdaMaxShiftRange, targetContrasts, [], 2, 2, SAVEPLOTS, titleSuffix, [], val.describe.REFERENCE_OBSERVER_AGE);
            
            % Add a suplabel
            figure(theFig);
            suplabel(sprintf('%s/%s', calIDTitle, valFileName));
            
            %% Save plots
            set(theFig, 'Color', [1 1 1]);
            set(theFig, 'InvertHardCopy', 'off');
            set(theFig, 'PaperPosition', [0 0 20 12]); %Position plot at left hand corner with width 15 and height 6.
            set(theFig, 'PaperSize', [20 12]); %Set the paper to have width 15 and height 6.
            
            currDir = pwd;
            cd(validationDir);
            saveas(theFig, ['Splatter_' calID], 'pdf');
            cd(currDir);
            
            fprintf('  - Contrast plot saved to %s.\n', fullfile(validationDir, ['Splatter_' calID]));
            
            % Save out the splatter
            SaveSplatter(validationDir, [fileNameSuffix '_' calID], contrastMapNegative, theCanonicalPhotoreceptors, nominalLambdaMax, val.describe.REFERENCE_OBSERVER_AGE, ageRange, lambdaMaxShiftRange, targetContrasts);
            SaveSplatterConfidenceBounds(validationDir, [fileNameSuffix '_95CI_' calID], contrastMapNegative, theCanonicalPhotoreceptors, nominalLambdaMax,  ageRange, lambdaMaxShiftRange, targetContrasts, 0.9545);
            SaveSplatterConfidenceBounds(validationDir, [fileNameSuffix '_99CI_' calID], contrastMapNegative, theCanonicalPhotoreceptors, nominalLambdaMax,  ageRange, lambdaMaxShiftRange, targetContrasts, 0.9973);
            
            %% Now, do the difference plots in terms of splatter
            % Load in the contrastMaps generated at stimulus generation
            try
                cd(validationDir);
                cd  ../..
                tmp = load(['Splatter_positive_' calID]);
                contrastMapPositivePredicted = tmp.contrastMap;
                tmp = load(['Splatter_negative_' calID]);
                contrastMapNegativePredicted = tmp.contrastMap;
                
                % Take the difference
                for k = 1:length(theCanonicalPhotoreceptors)
                    diffContrastMapPositive{k} = contrastMapPositive{k}-contrastMapPositivePredicted{k};
                    diffContrastMapNegative{k} = contrastMapNegative{k}-contrastMapNegativePredicted{k};
                end
                
                % Plot out (positive)
                theFig = PlotSplatter(figure, diffContrastMapPositive, theCanonicalPhotoreceptors, nominalLambdaMax, val.describe.REFERENCE_OBSERVER_AGE, ageRange, lambdaMaxShiftRange, [], [], 1, 2, 0, 'Positive (diff meas-pred)', []);
                theFig = PlotSplatter(theFig, diffContrastMapNegative, theCanonicalPhotoreceptors, nominalLambdaMax, val.describe.REFERENCE_OBSERVER_AGE, ageRange, lambdaMaxShiftRange, [], [], 2, 2, 0, 'Negative (diff meas-pred)', []);
                
                % Add a suplabel
                figure(theFig);
                suplabel(sprintf('%s/%s', calIDTitle, valFileName));
                
                %% Save plots
                set(theFig, 'Color', [1 1 1]);
                set(theFig, 'InvertHardCopy', 'off');
                set(theFig, 'PaperPosition', [0 0 20 12]); %Position plot at left hand corner with width 15 and height 6.
                set(theFig, 'PaperSize', [20 12]); %Set the paper to have width 15 and height 6.
                
                currDir = pwd;
                cd(validationDir);
                saveas(theFig, ['SplatterDiff_' calID], 'pdf');
                cd(currDir);
                
                cd(validationDir);
            end
        end
end