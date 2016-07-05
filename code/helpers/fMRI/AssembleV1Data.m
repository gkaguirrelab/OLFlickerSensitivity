function AssembleV1Data(theSubjects, theDirection, theProtocol, theFreqs);

% Make a new figure
theFig = figure;

for s = 1:length(theSubjects)
    for f = 1:length(theFreqs)
        
        % Load in V1
        areas_t = MRIread('/Applications/freesurfer/subjects/fsaverage_sym/templates/areas-template.sym.mgh');
        v1 = find(areas_t.vol == 1);
        
        % Get eccentricity map
        eccen_t = MRIread('/Applications/freesurfer/subjects/fsaverage_sym/templates/eccen-template.sym.mgh');
        eccen_range = find(eccen_t.vol > 2.5 & eccen_t.vol < 13.5);
        
        % Find the intersecting vertices
        v1_vol_idx = intersect(v1, eccen_range);
        
        %% Functional data
        % Load in the mean func
        mean_func = MRIread(['/Data/Imaging/Protocols/' theProtocol '/Subjects/' theSubjects{s} '/BOLD/' theProtocol '_' theDirection '_xrun/mean_func.xhemi.xrun_osgm.diffeo.sym.mgh']);
        mean_func_vol = squeeze(mean_func.vol);
        
        % Load in the func volume
        func = MRIread(['/Data/Imaging/Protocols/' theProtocol '/Subjects/' theSubjects{s} '/BOLD/' theProtocol '_' theDirection '_xrun/stats/cope' num2str(f) '.xhemi.xrun_osgm.diffeo.sym.mgh']);
        func_vol = squeeze(func.vol);
        %% Isolate the vertices in the V1 ROI
        pct_change_v1 = func_vol(v1_vol_idx, :)./mean_func_vol(v1_vol_idx, :);
        pct_change_v1_xvoxel = mean(pct_change_v1);
        
        pct_change_v1_xvoxel_xrun_mean(f) = mean(pct_change_v1_xvoxel);
        pct_change_v1_xvoxel_xrun_std(f) = std(pct_change_v1_xvoxel);
        
    end
    clearvars mean_func func areas_t eccen_t
    
    pct_change_v1_xvoxel_xrun_mean_xsubs(:, s) = pct_change_v1_xvoxel_xrun_mean;
    
    % Plot V1
    subplot(1, length(theSubjects)+1, s);
    shadedErrorBar(log2(theFreqs), 100*pct_change_v1_xvoxel_xrun_mean, 100*pct_change_v1_xvoxel_xrun_std/sqrt(length(pct_change_v1_xvoxel))); hold on;
    plot(log2([1 128]), [0 0], '--k');
    ylim([-0.4 1.5]); xlim([0 7]);
    
    % Tweak labels, etc.
    title({'V1' ; theSubjects{s}});
    set(gca, 'XTick', log2(theFreqs), 'XTickLabel', theFreqs);
    xlabel('Frequency [Hz]');
    ylabel('BOLD signal change [%]');
    pbaspect([1 0.8 1]);

    pbaspect([1 0.8 1]);
end


subplot(1, length(theSubjects)+1, length(theSubjects)+1);

shadedErrorBar(log2(theFreqs), 100*mean(pct_change_v1_xvoxel_xrun_mean_xsubs, 2), 100*std(pct_change_v1_xvoxel_xrun_mean_xsubs, [], 2)/size(pct_change_v1_xvoxel_xrun_mean_xsubs, 2)); hold on;
plot(log2([1 128]), [0 0], '--k');
ylim([-0.4 1.5]); xlim([0 7]);
% Tweak labels, etc.
title('Group average');
set(gca, 'XTick', log2(theFreqs), 'XTickLabel', theFreqs);
xlabel('Frequency [Hz]');
ylabel('BOLD signal change [%]');
pbaspect([1 0.8 1]);


suptitle(theDirection)


%% Save plots
set(theFig, 'PaperPosition', [0 0 12 20]); %Position plot at left hand corner with width 15 and height 6.
set(theFig, 'PaperSize', [12 20]); %Set the paper to have width 15 and height 6.

saveas(theFig, theDirection, 'pdf');