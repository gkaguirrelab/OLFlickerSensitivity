theAreas = {'V1' 'V2V3' 'MT' 'LOC'};

%% Assemble bar plots for V1
labels = {'Nulled mel (17%)' 'Unnulled mel (17%)' 'Null splatter' 'Light flux (90%)'};

for ii = 1:length(theAreas)
    M1 = csvread(['/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/MRFlickerData/allSubs_xhemi_Nulled_' theAreas{ii} '.csv']);
    M1(:, 1) = [];
    
    M2 = csvread(['/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/MRFlickerData/allSubs_xhemi_LightFlux_' theAreas{ii} '.csv']);
    M2(:, 1) = [];
    
    theX = [1:4];
    theYraw = [M1 ; M2];
    theY = mean([M1 ; M2], 2);
    theYerr = std([M1 ; M2], [], 2)/sqrt(size(M2, 2));
    
    fHand = figure;
    aHand = axes('parent', fHand);
    hold(aHand, 'on')
    colors = [0 0 0 ; 0.9 0.9 1 ; 0.9 1 0.9 ; 1 0.9 0.9 ; 0.5 0.5 0.5 ; 0.2 0.6 0.4 ; 1 0 0.2];
    for i = 1:numel(theY)
        bar(theX(i), theY(i), 'parent', aHand, 'facecolor', colors(i,:)); hold on;
        plot(theX-0.1, theYraw(:, 1), 'or', 'MarkerSize', 3, 'MarkerFaceColor', 'r');
        plot(theX, theYraw(:, 2), 'sr', 'MarkerSize', 3, 'MarkerFaceColor', 'r');
        plot(theX+0.1, theYraw(:, 3), '^r', 'MarkerSize', 3, 'MarkerFaceColor', 'r');
    end
    
    errorbar([1:4], mean([M1 ; M2], 2), std([M1 ; M2], [], 2)/sqrt(size(M2, 2)), 'k', 'LineStyle', 'none');
    pbaspect([1 1 1]);
    ylabel('BOLD signal change [%]');
    set(gca, 'XTick', theX, 'XTickLabel', labels);
    pbaspect([1 1 1]);
    ylim([-0.25 1.2]);
    box off;
    %axis off;
    title([theAreas{ii} ' response']);
    xticklabel_rotate([], 45);
    set(gcf, 'PaperPosition', [0 0 4 4]); %Position plot at left hand corner with width 15 and height 6.
    set(gcf, 'PaperSize', [4 4]); %Set the paper to have width 15 and height 6.
    saveas(gcf, fullfile(plotSaveDir,['test_grp_xhemi_LightFluxControl_' theAreas{ii}]), 'pdf');
    close(gcf);
end

theAreas = {'V1' 'V2V3' 'MT' 'LOC'};
