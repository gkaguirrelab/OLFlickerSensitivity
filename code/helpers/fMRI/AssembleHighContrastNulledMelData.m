theAreas = {'V1'};

theSubjects = {'G082115A' 'M082115S' 'M082115M'};
%% Assemble bar plots for V1
labels = {'Nulled mel (32%)' 'L+M+S (32%)' 'Light flux (32%)'};

for ii = 1:length(theAreas)
    M1 = csvread(['/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/MRFlickerData/allSubs_xhemi_HighContrastNulled_' theAreas{ii} '.csv']);
    M1(:, 1) = [];
    
    theX = [1:3];
    theYraw = [M1];
    theY = mean([M1], 2);
    theYerr = std([M1], [], 2)/sqrt(size(M1, 2));
    
    fHand = figure;
    aHand = axes('parent', fHand);
    hold(aHand, 'on')
    colors = [0 0 0 ; 0.9 0.9 1 ; 0.9 1 0.9 ; 1 0.9 0.9 ; 0.5 0.5 0.5 ; 0.2 0.6 0.4 ; 1 0 0.2];
    for i = 1:numel(theY)
        bar(theX(i), theY(i), 1, 'parent', aHand, 'edgecolor', 'none', 'facecolor', colors(i,:)); hold on;
    end
    
    errorbar([1:3], mean([M1], 2), std([M1], [], 2)/sqrt(size(M1, 2)), 'k', 'LineStyle', 'none');
    pbaspect([1 1 1]);
    ylabel('BOLD signal change [%]');
    set(gca, 'XTick', theX, 'XTickLabel', labels);
            set(gca, 'YTick', [0 0.25 0.5]);
    pbaspect([1 1 1]);
    ylim([-0.25 0.52]);
    xlim([-1 5]);
    box off;
    %axis off;
    title([theAreas{ii} ' response']);
    xticklabel_rotate([], 45);
    set(gcf, 'PaperPosition', [0 0 4 4]); %Position plot at left hand corner with width 15 and height 6.
    set(gcf, 'PaperSize', [4 4]); %Set the paper to have width 15 and height 6.
    saveas(gcf, fullfile(plotSaveDir,['test_grp_xhemi_HighContrastNulled_' theAreas{ii}]), 'pdf');
    close(gcf);
    
    for s = 1:length(theSubjects)
        M1 = csvread(['/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/MRFlickerData/' theSubjects{s} '_Nulled_'  theAreas{ii} '.csv']);
        M1(:, 1) = [];
        
        theX = [1:3];
        theY = M1(:, 1);
        theYerr = M1(:, 2);
        
        fHand = figure;
        aHand = axes('parent', fHand);
        hold(aHand, 'on')
        colors = [0 0 0 ; 0.9 0.9 1 ; 0.9 1 0.9 ; 1 0.9 0.9 ; 0.5 0.5 0.5 ; 0.2 0.6 0.4 ; 1 0 0.2];
        for i = 1:numel(theY)
            bar(theX(i), theY(i), 1, 'parent', aHand, 'edgecolor', 'none', 'facecolor', colors(i,:)); hold on;
        end
        
        errorbar([1:3], theY, theYerr, 'k', 'LineStyle', 'none');
        pbaspect([1 1 1]);
        ylabel('BOLD signal change [%]');
        set(gca, 'XTick', theX, 'XTickLabel', labels);
        set(gca, 'YTick', [0 0.25 0.5]);
        pbaspect([1 1 1]);
    ylim([-0.25 0.52]);
            xlim([-1 5]);
        box off;
        %axis off;
        title([theAreas{ii} ' response']);
        xticklabel_rotate([], 45);
        set(gcf, 'PaperPosition', [0 0 4 4]); %Position plot at left hand corner with width 15 and height 6.
        set(gcf, 'PaperSize', [4 4]); %Set the paper to have width 15 and height 6.
        saveas(gcf, fullfile(plotSaveDir,[theSubjects{s} '_HighContrastNulled_' theAreas{ii}]), 'pdf');
        close(gcf);
    end
end

theAreas = {'V1' 'V2V3' 'MT' 'LOC'};
