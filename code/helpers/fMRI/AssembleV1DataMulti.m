function AssembleV1DataMulti(nSessions, theSubjectsPerSession, theDirectionPerSession, theProtocolPerSession, freqsPerSession, nRunsPerSession, ROI, plotColor, plotSaveDir);

% Make a new figure
nSubjects = length(theSubjectsPerSession{end}); % Assumes we have the same number of subjects in each session

% Generate ROIs: V1v, V2v, V3v, V1d, V2d, V3d
roiLabels = {'V1v', 'V1d', 'V2v', 'V2d', 'V3v', 'V3d', 'MT', 'LOC'};
roiNum = [1 -1 2 -2 3 -3 0 0];
roi_idx = [];

% Create the ROIs based on Noah's template
areas_t = MRIread('/Applications/freesurfer/subjects/fsaverage_sym/templates/2014-10-29.areas-template.nii.gz');
eccen_t = MRIread('/Applications/freesurfer/subjects/fsaverage_sym/templates/2014-10-29.eccen-template.nii.gz');
for i = 1:6
    tmp = zeros(163842, 1);
    
    areas_vertices = find(areas_t.vol == roiNum(i));
    roi_nvoxels = length(areas_vertices);
    % Eccentricity range is defined here.
    eccen_range = find(eccen_t.vol > 3 & eccen_t.vol < 13);
    tmp1 = intersect(areas_vertices, eccen_range);
    tmp(tmp1) = 1;
    
    roi_idx = [roi_idx tmp];
end

% Add the LOC and MT ROIs
MT_t = MRIread('/Data/Imaging/Protocols/MTFOBSLocalizer/Subjects/allMT.mgh');
LOC_t = MRIread('/Data/Imaging/Protocols/MTFOBSLocalizer/Subjects/allLOC.mgh');

roi_idx = [roi_idx MT_t.vol' LOC_t.vol'];

% Iterate over sessions
for k = 1:nSessions
    for s = 1:length(theSubjectsPerSession{k})
        
        sessionSuffixes = {'A+', 'B+', 'C+', 'D+'};
        
        sessionSuffixes = {'A', 'B', 'C', 'D'};
        
        %% Load in the data
        for m = 1:nRunsPerSession
            %% Load in mean volumes
            sessionIdentifier = sessionSuffixes{m};
            
            tmp = MRIread(['/Data/Imaging/Protocols/' theProtocolPerSession{k} '/Subjects/' theSubjectsPerSession{k}{s} '/BOLD/' theProtocolPerSession{k} '_' theDirectionPerSession{k} '_' sessionIdentifier '.feat/mean_func.diffeo.lh.sym.mgh']);
            lh_mean_func{m} = squeeze(tmp.vol);
            
            tmp = MRIread(['/Data/Imaging/Protocols/' theProtocolPerSession{k} '/Subjects/' theSubjectsPerSession{k}{s} '/BOLD/' theProtocolPerSession{k} '_' theDirectionPerSession{k} '_' sessionIdentifier '.feat/mean_func.diffeo.rh.sym.mgh']);
            rh_mean_func{m} = squeeze(tmp.vol);
            
            %% Load in beta weights for each frequency
            for f = 1:length(freqsPerSession{k})
                tmp = MRIread(['/Data/Imaging/Protocols/' theProtocolPerSession{k} '/Subjects/' theSubjectsPerSession{k}{s} '/BOLD/' theProtocolPerSession{k} '_' theDirectionPerSession{k} '_' sessionIdentifier '.feat/stats/cope' num2str(f) '.diffeo.lh.sym.mgh']);
                lh_func_vol{m, f} = squeeze(tmp.vol);
                
                tmp = MRIread(['/Data/Imaging/Protocols/' theProtocolPerSession{k} '/Subjects/' theSubjectsPerSession{k}{s} '/BOLD/' theProtocolPerSession{k} '_' theDirectionPerSession{k} '_' sessionIdentifier '.feat/stats/cope' num2str(f) '.diffeo.rh.sym.mgh']);
                rh_func_vol{m, f} = squeeze(tmp.vol);
            end
        end
        
        %% Test if we have good voxels in the ROI for each
        % hemisphere
        for m = 1:nRunsPerSession
            for i =  1:length(roiLabels)
                lh_coverage(i, m) = 1-(sum(lh_mean_func{m}(find(roi_idx(:, i))) == 0)/sum(roi_idx(:, i)));
                rh_coverage(i, m) = 1-(sum(rh_mean_func{m}(find(roi_idx(:, i))) == 0)/sum(roi_idx(:, i)));
            end
        end
        
        
        
        % Make a logical matrix that tells us if we can trust the
        % ROI and run
        lh_valid_runs_per_roi = (lh_coverage == 1);
        rh_valid_runs_per_roi = (rh_coverage == 1);
        
        
        if strcmp(theSubjectsPerSession{k}{s}(1), 'M') && strcmp(theSubjectsPerSession{k}{s}(end), 'M')
            subjID = 'MM';
        elseif strcmp(theSubjectsPerSession{k}{s}(1), 'M') && strcmp(theSubjectsPerSession{k}{s}(end), 'S')
            subjID = 'MS';
        elseif strcmp(theSubjectsPerSession{k}{s}(1), 'G') && strcmp(theSubjectsPerSession{k}{s}(end), 'A')
            subjID = 'GA';
        end
        fid = fopen(fullfile(plotSaveDir, ['coverage_' subjID '_' theDirectionPerSession{k} '.txt']), 'a');
        for i = 1:length(roiLabels)
            fprintf(fid, '%s (LH),%g', roiLabels{i}, sum(lh_valid_runs_per_roi(i, :)));
            fprintf(fid, '\n');
            fprintf(fid, '%s (RH),%g', roiLabels{i}, sum(rh_valid_runs_per_roi(i, :)));
            fprintf(fid, '\n');
        end
        
        
        fclose(fid);
        
        fid = fopen(fullfile(plotSaveDir, ['coverage_summary_' subjID '.txt']), 'a');
        for i = 1:length(roiLabels)
            fprintf(fid, '%g,%g,', sum(lh_valid_runs_per_roi(i, :)), sum(rh_valid_runs_per_roi(i, :)));
        end
        fprintf(fid, '\n');
        
        
        % Pull out the data
        for m = 1:nRunsPerSession
            for f = 1:length(freqsPerSession{k})
                lh_pct_change{s, k, m}(f, :) = lh_func_vol{m, f}(:)./lh_mean_func{m}(:);
                rh_pct_change{s, k, m}(f, :) = rh_func_vol{m, f}(:)./rh_mean_func{m}(:);
                
                
            end
        end
        
        sess = k;
        subj = s;
        for freq = 1:length(freqsPerSession{k})
            lh_pct_change_xrun{subj, sess}(freq, :) = zeros(1, 163842);
            rh_pct_change_xrun{subj, sess}(freq, :) = zeros(1, 163842);
            
            lh_pct_change_xrun_raw{subj, sess}(freq, :) = zeros(1, 163842);
            rh_pct_change_xrun_raw{subj, sess}(freq, :) = zeros(1, 163842);
            
            % Keep track of how many runs contribute. We need
            % this number to calculate averages later on
            lh_nruns = zeros(163842, 1);
            rh_nruns = zeros(163842, 1);
            
            for m = 1:nRunsPerSession
                % Logical indices of the vertices to consider
                lh_indices = zeros(163842, 1);
                rh_indices = zeros(163842, 1);
                
                
                %% Assemble a brain made out of the ROIs
                for i =  1:length(roiLabels)
                    if lh_valid_runs_per_roi(i, m) == 1;
                        % If this is a valid run, take indices of
                        % all ROIs for our new 'valid' brain
                        lh_indices = lh_indices + roi_idx(:, i);
                        lh_nruns = lh_nruns + roi_idx(:, i);
                    end
                    
                    if rh_valid_runs_per_roi(i, m) == 1;
                        % If this is a valid run, take indices of
                        % all ROIs for our new 'valid' brain
                        rh_indices = rh_indices + roi_idx(:, i);
                        rh_nruns = rh_nruns + roi_idx(:, i);
                    end
                end
                
                
                lh_pct_change_xrun{subj, sess}(freq, :) = lh_pct_change_xrun{subj, sess}(freq, :) + lh_indices' .* lh_pct_change{subj, sess, m}(freq, :);
                rh_pct_change_xrun{subj, sess}(freq, :) = rh_pct_change_xrun{subj, sess}(freq, :) + rh_indices' .* rh_pct_change{subj, sess, m}(freq, :);
                lh_pct_change_xrun_raw{subj, sess}(freq, :) = lh_pct_change_xrun_raw{subj, sess}(freq, :) + lh_pct_change{subj, sess, m}(freq, :);
                rh_pct_change_xrun_raw{subj, sess}(freq, :) = rh_pct_change_xrun_raw{subj, sess}(freq, :) + rh_pct_change{subj, sess, m}(freq, :);
                
            end
            
            % Divide by nRuns
            lh_pct_change_xrun{subj, sess}(freq, :) = lh_pct_change_xrun{subj, sess}(freq, :)./lh_nruns';
            rh_pct_change_xrun{subj, sess}(freq, :) = rh_pct_change_xrun{subj, sess}(freq, :)./rh_nruns';
            
            lh_pct_change_xrun_raw{subj, sess}(freq, :) = lh_pct_change_xrun_raw{subj, sess}(freq, :)/nRunsPerSession;
            rh_pct_change_xrun_raw{subj, sess}(freq, :) = rh_pct_change_xrun_raw{subj, sess}(freq, :)/nRunsPerSession;
        end
        
        % Construct the average per vertex
        tmp0 = [];
        tmp0(:, :, 1) = lh_pct_change_xrun_raw{subj, sess};
        tmp0(:, :, 2) = rh_pct_change_xrun_raw{subj, sess};
        
        xhemi_pct_change_xrun{subj, sess} = nanmean(tmp0, 3);
        
    end
    clearvars mean_func func areas_t eccen_t
    
end






for subj = 1:nSubjects
    for sess = 1:nSessions
        switch ROI
            case 'V1'
                theIndices = find(abs(roiNum) == 1);
                
            case 'V2V3'
                theIndices = find(abs(roiNum) == 2 | abs(roiNum) == 3); % Taking abs allows us to take both ventral and dorsal
                
            case 'MT'
                theIndices =  7;
            case 'LOC'
                theIndices = 8;
        end
        lh_avg_per_session{subj, sess} = nanmedian(lh_pct_change_xrun{subj, sess}(:, find(sum(roi_idx(:, theIndices), 2))), 2);
        rh_avg_per_session{subj, sess} = nanmedian(rh_pct_change_xrun{subj, sess}(:, find(sum(roi_idx(:, theIndices), 2))), 2);
        avg_per_session{subj, sess} = nanmedian([lh_avg_per_session{subj, sess} rh_avg_per_session{subj, sess}], 2);
        sd_per_session{subj, sess} = nanstd([lh_avg_per_session{subj, sess} rh_avg_per_session{subj, sess}], [], 2)/sqrt(2);
    end
end


freqs = [freqsPerSession{:}];

DO_SEARCHLIGHT = false;
if DO_SEARCHLIGHT
    polOrder = 3:5;
    for pol = polOrder;
        for radii = 4
            
            for subj = 1:nSubjects
                xhemi_pct_change_xrun_xsess{subj} = [xhemi_pct_change_xrun{subj, 1} ; xhemi_pct_change_xrun{subj, 2}];
                % Do a searchlight if needed
                
                % Load the 'iarray' structure
                eval(['load iarray' num2str(radii) ';']);
                eval(['iarray = iarray' num2str(radii) ';']);
                nVertices = length(iarray);
                
                
                for q = 1:nVertices
                    %fprintf('%g\n',q);
                    ind = iarray{q}.index;
                    if sum(isnan(sum(xhemi_pct_change_xrun_xsess{subj}(:, ind), 1)))/length(xhemi_pct_change_xrun_xsess{subj}(:, ind)) < 0.5
                        [~, sp] = max(xhemi_pct_change_xrun_xsess{subj}(:, ind));
                        maxFreq(q) = nanmean(freqs(sp));
                        
                        % xhemi_pct_change_xrun_xsess_in_radius{subj}(:, q) = nanmean(xhemi_pct_change_xrun_xsess{subj}(:, ind), 2);
                        
                        %p = polyfit(freqs,xhemi_pct_change_xrun_xsess_in_radius{subj}(:, q)',pol);
                        %f1 = polyval(p,x1);
                        %p = fit(log2(freqs)', xhemi_pct_change_xrun_xsess_in_radius{subj}(:, q), 'smoothingspline');
                        %x1 = linspace(0,64,65001);
                        %f1 = feval(p, log2(x1));
                        
                        %[~, maxInd] = max(f1);
                        %maxFreq(q) = x1(maxInd);
                        
                    else
                        maxFreq(q) = NaN;
                    end
                end
                
                
                % Save out the volume
                
                tmp.vol = maxFreq;
                MRIwrite(tmp, fullfile('~/Desktop', [theSubjectsPerSession{1}{subj} '_' theDirectionPerSession{end} '_searchlight_iarray' num2str(radii) '_max.mgh']));
                fprintf('\n*** Saved to %s\n', [theSubjectsPerSession{1}{subj} '_' theDirectionPerSession{end} '_searchlight_iarray' num2str(radii) '_max.mgh']);
                
                
                
                tmp.vol = maxFreq .* sum(roi_idx, 2)';
                MRIwrite(tmp, fullfile('~/Desktop', [theSubjectsPerSession{1}{subj} '_' theDirectionPerSession{end} '_searchlight_iarray' num2str(radii) '_max_masked.mgh']));
                fprintf('\n*** Saved to %s\n', [theSubjectsPerSession{1}{subj} '_' theDirectionPerSession{end} '_searchlight_iarray' num2str(radii) '_max_masked.mgh']);
            end
        end
    end
end


figure;
DO_PLOTS = true;
if DO_PLOTS
    % Plot results for each observer separately
    for s = 1:nSubjects
        lh_avg_per_subject{s} = [];
        rh_avg_per_subject{s} = [];
        avg_per_subject{s} = [];
        
        % Assemble data across sessions
        for k = 1:nSessions
            
            lh_avg_per_subject{s} = [lh_avg_per_subject{s} ; lh_avg_per_session{s, k}];
            rh_avg_per_subject{s} = [rh_avg_per_subject{s} ; rh_avg_per_session{s, k}];
            avg_per_subject{s} = [avg_per_subject{s} ; avg_per_session{s, k}];
        end
        
%                 % xhemi, xrun
%                 figure;
%                 bar(log2(freqs), 100*avg_per_subject{s}); hold on;
%                 errorbar(log2(freqs), 100*avg_per_subject{s}, 100*sd_per_session{s});
%                 plot(log2([0.01 128]), [0 0], '--k');
%                 ylim([-0.2 1.2]); xlim([-2 7]);
%                 title({ROI ; theDirectionPerSession{end} ; theSubjectsPerSession{end}{s} ; 'Average across hemispheres'});
%                 set(gca, 'XTick', log2(freqs), 'XTickLabel', freqs);
%                 xlabel('Frequency [Hz]');
%                 ylabel('BOLD signal change [%]');
%                 pbaspect([1 0.8 1]);
%                 box off;
%         
%                 %% Save plots
%                 set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 15 and height 6.
%                 set(gcf, 'PaperSize', [5 5]); %Set the paper to have width 15 and height 6.
%         
%                 saveas(gcf, fullfile(plotSaveDir, [theSubjectsPerSession{end}{s} '_' theDirectionPerSession{end} '_' ROI]), 'pdf');
%                 close(gcf);
%         
                    M2 = [freqs' 100*avg_per_subject{s} 100*sd_per_session{s}];
    dlmwrite(fullfile(plotSaveDir,[theSubjectsPerSession{end}{s} '_' theDirectionPerSession{end} '_' ROI '.csv']), M2);
                
        
        % xhemi, xrun
        if s == 1
            plot(log2(freqs), 100*avg_per_subject{s}, '-o','color', plotColor, 'markerfacecolor', [0 0 0], 'LineWidth', 1.8); hold on;
        elseif s == 2
            
            plot(log2(freqs), 100*avg_per_subject{s}, '-s','color', plotColor*0.9, 'markerfacecolor', [0 0 0], 'LineWidth', 1.8); hold on;
        elseif s == 3
            
            plot(log2(freqs), 100*avg_per_subject{s}, '-^','color', plotColor*0.8, 'markerfacecolor', [0 0 0], 'LineWidth', 1.8); hold on;
        end
        
        
        
    end
    plot(log2([0.01 128]), [0 0], '--k');
    
%     p = polyfit(log2(freqs),100*avg_per_subject{s}',4);
%     x0 = linspace(min(log2(freqs))-0.1, max(log2(freqs))+0.1, 100);
%     y0 = polyval(p, x0');
%     plot(x0, y0, '-k', 'LineWidth', 1.8);
    
    plot([-2 -1.8], [0.5 0.5], '-k');
    plot([-2 -1.8], [1 1], '-k');
    plot([-2 -1.8], [1.5 1.5], '-k');
    ylim([-0.5 1.75]); xlim([-2 7]);
    %title({ROI ; theDirectionPerSession{end} ; 'Group average'});
    set(gca, 'XTick', log2(freqs), 'XTickLabel', freqs);
    xlabel('Frequency [Hz]');
    ylabel('BOLD signal change [%]');
    pbaspect([1 0.8 1]);
    box off;
    axis off;
    
    set(gcf, 'PaperPosition', [0 0 4 4]); %Position plot at left hand corner with width 15 and height 6.
    set(gcf, 'PaperSize', [4 4]); %Set the paper to have width 15 and height 6.
    
    
    saveas(gcf, fullfile(plotSaveDir, ['allSubs_' theDirectionPerSession{end} '_' ROI '_xhemi']), 'pdf');
    close(gcf);
    %
    % Average across subjects
    a_pct_change_v1_xrun_xsub = [];
    for s = 1:nSubjects
        a_pct_change_v1_xrun_xsub = [a_pct_change_v1_xrun_xsub avg_per_subject{s}];
    end
    
    grpAvgFig = figure;
    % Plot V1
    shadedErrorBar(log2(freqs), 100*mean(a_pct_change_v1_xrun_xsub, 2), 100*std(a_pct_change_v1_xrun_xsub, [], 2)/sqrt(nSubjects), {'o','color', plotColor, 'markerfacecolor',[0 0 0]}); hold on;
    plot(log2(freqs), 100*mean(a_pct_change_v1_xrun_xsub, 2), '.k');
    plot(log2([0.01 128]), [0 0], '--k');
    p = polyfit(log2(freqs),100*mean(a_pct_change_v1_xrun_xsub, 2)',4);
    x0 = linspace(min(log2(freqs))-0.1, max(log2(freqs))+0.1, 100);
    y0 = polyval(p, x0');
    x1 = (-1:0.001:6);
    y1 = polyval(p, x1');
    [~, mm] = max(y1);
    
%     fid = fopen(fullfile(plotSaveDir, 'grp_xhemi_peakf.txt'), 'a');
%     fprintf(fid, '%s,%s,%.2f\n', theDirectionPerSession{end}, ROI, 2^x1(mm));
%     fclose(fid);
    
    %plot(x0, y0, '-k', 'LineWidth', 1.8);
    
    
    %plot([-2 -1.8], [0 0], '-k');
    plot([-2 -1.8], [0.5 0.5], '-k');
    plot([-2 -1.8], [1 1], '-k');
    ylim([-0.25 1.2]); xlim([-2 7]);
    %title({ROI ; theDirectionPerSession{end} ; 'Group average'});
    set(gca, 'XTick', log2(freqs), 'XTickLabel', freqs);
    xlabel('Frequency [Hz]');
    ylabel('BOLD signal change [%]');
    pbaspect([1 0.8 1]);
    box off;
    axis off;
    
    set(grpAvgFig, 'PaperPosition', [0 0 4 4]); %Position plot at left hand corner with width 15 and height 6.
    set(grpAvgFig, 'PaperSize', [4 4]); %Set the paper to have width 15 and height 6.
    
    saveas(grpAvgFig, fullfile(plotSaveDir,['grp_xhemi_' theDirectionPerSession{end} '_' ROI]), 'pdf');
    close(grpAvgFig);
    
    
    % Save out the numbers
    M = [freqs' 100*mean(a_pct_change_v1_xrun_xsub, 2) 100*std(a_pct_change_v1_xrun_xsub, [], 2)/sqrt(nSubjects)];
    dlmwrite(fullfile(plotSaveDir,['grp_xhemi_' theDirectionPerSession{end} '_' ROI, '.csv']), M);
   

end

    
    M2 = [freqs' 100*a_pct_change_v1_xrun_xsub];
    dlmwrite(fullfile(plotSaveDir,['allSubs_xhemi_' theDirectionPerSession{end} '_' ROI, '.csv']), M2);