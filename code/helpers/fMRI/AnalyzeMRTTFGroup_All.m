BASE_PATH = '/Data/Imaging/Protocols/TTFMRFlickerX/Subjects';
subjects = {'G031614A' 'M031614S' 'L031614L'};
directions = {'Isochromatic' 'LMDirected' 'LMinusMDirected' 'MelanopsinDirected' 'SDirected' };
fieldInnerRing = 5;
fieldOuterRing = 13;
controlFlag = false;
for d = 1:length(directions)
    AnalyzeMRTTFGroup(BASE_PATH, subjects, directions{d}, fieldInnerRing, fieldOuterRing, controlFlag, []);
end
%%
BASE_PATH = '/Data/Imaging/Protocols/TTFMRFlickerX/Subjects';
subjects = {'G031614A', 'M031614S' 'L031614L'};
fieldInnerRing = 5;
fieldOuterRing = 13;
controlFlag = true;
AnalyzeMRTTFGroup(BASE_PATH, subjects, 'C1', fieldInnerRing, fieldOuterRing, controlFlag, {'MelanopsinDirectedRobust', 'MelanopsinDirectedEquiContrast', 'RodDirected', 'OmniSilent'});


%%
BASE_PATH = '/Data/Imaging/Protocols/TTFMRFlickerX/Subjects';
subjects = {'G040414A'};
fieldInnerRing = 5;
fieldOuterRing = 13;
controlFlag = true;
AnalyzeMRTTFGroup(BASE_PATH, subjects, 'C1', fieldInnerRing, fieldOuterRing, controlFlag, {'MelanopsinDirectedRobust', 'MelanopsinDirectedEquivContrast', 'RodDirected', 'OmniSilent'});

%% Plot out everything
% 2-64 Hz, bright
BASE_PATH1 = '/Data/Imaging/Protocols/TTFMRFlickerY/Subjects';
subjects1 = {'G042514A' 'M041714M' 'M041814S'};

% 2-64 Hz, dim
BASE_PATH2 = '/Data/Imaging/Protocols/TTFMRFlickerX/Subjects';
subjects2 = {'G031614A' 'M031614S'};

% 0.5-64 Hz,bright
BASE_PATH3 = '/Data/Imaging/Protocols/TTFMRFlickerYs/Subjects';
subjects3 = {'G042614A' 'M042914M' 'M042914S'};

directions = {'LMDirected' 'LMinusMDirected' 'SDirected' 'MelanopsinDirected'};
sDirections = {'sLMDirected' 'sLMinusMDirected' 'sSDirected' 'sMelanopsinDirected'};
dimAvailable = [1 1 1 0];
fieldInnerRing = 5;
fieldOuterRing = 13;
controlFlag = false;

% Combine the TTFs
OUT_PATH = '/Data/Imaging/Protocols/TTFMRFlickerYFull/Subjects';
combinedSubs = {'GA' 'MM' 'MS'};
for d = 1:length(directions)
    CombineTTFs(BASE_PATH1, subjects1, directions{d}, BASE_PATH3, subjects3, directions{d}, fieldInnerRing, fieldOuterRing, controlFlag, 'Y', 'Ys', [], 'V1', OUT_PATH);
    CombineTTFs(BASE_PATH1, subjects1, directions{d}, BASE_PATH3, subjects3, directions{d}, fieldInnerRing, fieldOuterRing, controlFlag, 'Y', 'Ys', [], 'LGN', OUT_PATH);
end

% We will normalize the plots to the max. across all data sets. Here, this
% is done by hand, but this should be changed.
normFactor = 152.3500;

% Plot TTF
for d = 1:length(directions)
    % Only averages
    % V1
    theFigV1 = figure;
    % Plot them average at 2 Hz
    plotSpec.marker = 'sk';
    plotSpec.color = 'k';
    plotSpec.markerFaceColor = 'k';
    plotSpec.markerSize = 8;
    plotSpec.legend = 'V1, 3700 cd/m2';
    theFigV1 = AnalyzeMRTTFGroup(theFigV1, OUT_PATH, combinedSubs, directions{d}, fieldInnerRing, fieldOuterRing, controlFlag, 'YFull', [], 'V1', plotSpec, OUT_PATH, false, true, normFactor);
    
%     if dimAvailable(d)
%         % 2-64 Hz, dim
%         plotSpec.marker = '-ok';
%         plotSpec.color = 'k';
%         plotSpec.markerFaceColor = [0.5 0.5 0.5];
%         plotSpec.markerSize = 8;
%         plotSpec.legend = 'V1, 175 cd/m2';
%         theFig = AnalyzeMRTTFGroup(theFigV1, BASE_PATH2, subjects2, directions{d}, fieldInnerRing, fieldOuterRing, controlFlag, 'X', [], 'V1', plotSpec, BASE_PATH1, false, true);
%     end
    
%     % LGN
%     theFigLGN = figure;
%     plotSpec.marker = '-sk';
%     plotSpec.color = 'k';
%     plotSpec.markerFaceColor = 'w';
%     plotSpec.markerSize = 8;
%     plotSpec.legend = 'LGN';
%     theFigLGN = AnalyzeMRTTFGroup(theFigLGN, OUT_PATH, combinedSubs, directions{d}, fieldInnerRing, fieldOuterRing, controlFlag, 'YFull', [], 'LGN', plotSpec, BASE_PATH1, false, true);
%     
%     % Vx - V3
%     theFigVx = figure;
%     % Plot them average at 2 Hz
%     plotSpec.marker = '-sk';
%     plotSpec.color = 'k';
%     plotSpec.markerFaceColor = 'w';
%     plotSpec.markerSize = 8;
%     plotSpec.legend = 'V2';
%     theFigV1 = AnalyzeMRTTFGroup(theFigVx, OUT_PATH, combinedSubs, directions{d}, fieldInnerRing, fieldOuterRing, controlFlag, 'YFull', [], 'V2', plotSpec, BASE_PATH1, false, true);
%     
%     % Vx - V2
%     plotSpec.marker = '-ok';
%     plotSpec.color = 'k';
%     plotSpec.markerFaceColor = 'k';
%     plotSpec.markerSize = 8;
%     plotSpec.legend = 'V3';
%     theFigV1 = AnalyzeMRTTFGroup(theFigVx, OUT_PATH, combinedSubs, directions{d}, fieldInnerRing, fieldOuterRing, controlFlag, 'YFull', [], 'V3', plotSpec, BASE_PATH1, false, true);
%     
%     % All subjects
%     % V1
%     theFigV1 = figure;
%     % Plot them average at 2 Hz
%     plotSpec.marker = '-sk';
%     plotSpec.color = 'k';
%     plotSpec.markerFaceColor = 'k';
%     plotSpec.markerSize = 8;
%     plotSpec.legend = 'V1';
%     theFigV1 = AnalyzeMRTTFGroup(theFigV1, OUT_PATH, combinedSubs, directions{d}, fieldInnerRing, fieldOuterRing, controlFlag, 'YFull', [], 'V1', plotSpec, BASE_PATH1, true, true);
    
%     % LGN
%     theFigLGN = figure;
%     plotSpec.marker = '-sk';
%     plotSpec.color = 'k';
%     plotSpec.markerFaceColor = 'w';
%     plotSpec.markerSize = 8;
%     plotSpec.legend = 'LGN';
%     theFigLGN = AnalyzeMRTTFGroup(theFigLGN, OUT_PATH, combinedSubs, directions{d}, fieldInnerRing, fieldOuterRing, controlFlag, 'YFull', [], 'LGN', plotSpec, BASE_PATH1, true, true);
end


%% LMDirected scaled
% Plot out everything
% 2-64 Hz, bright
BASE_PATH1 = '/Data/Imaging/Protocols/TTFMRFlickerPurkinje/Subjects';
subjects1 = {'G042614A' 'M043014M' 'M042714S'};

directions = {'LMDirected' 'LMinusMDirected' 'SDirected' 'MelanopsinDirected'};
sDirections = {'sLMDirected' 'sLMinusMDirected' 'sSDirected' 'sMelanopsinDirected'};
dimAvailable = [1 1 1 0];
fieldInnerRing = 5;
fieldOuterRing = 13;
controlFlag = false;

% Combine the TTFs
OUT_PATH = '/Data/Imaging/Protocols/TTFMRFlickerYFull/Subjects';
combinedSubs = {'GA' 'MM' 'MS'};
for d = 1:length(directions)
    CombineTTFs(BASE_PATH1, subjects1, 'LMDirectedScaled', BASE_PATH1, subjects1, 'LMDirectedScaled', fieldInnerRing, fieldOuterRing, controlFlag, 'Purkinje', 'Purkinje', [], 'V1', OUT_PATH);
    CombineTTFs(BASE_PATH1, subjects1, 'LMDirectedScaled', BASE_PATH1, subjects1, 'LMDirectedScaled', fieldInnerRing, fieldOuterRing, controlFlag, 'Purkinje', 'Purkinje', [], 'LGN', OUT_PATH);
end

% LMDirectedScaled
% Only averages
% V1
theFigV1 = figure;

plotSpec.marker = 'sk';
plotSpec.color = 'k';
plotSpec.markerFaceColor = 'k';
plotSpec.markerSize = 8;
plotSpec.legend = 'V1';
theFigV1 = AnalyzeMRTTFGroup(theFigV1, OUT_PATH, combinedSubs, 'LMDirectedScaled', fieldInnerRing, fieldOuterRing, controlFlag, 'YFull', [], 'V1', plotSpec, OUT_PATH, false, true, normFactor);

% % LGN
% theFigLGN = figure;
% 
% plotSpec.marker = '-sk';
% plotSpec.color = 'k';
% plotSpec.markerFaceColor = 'k';
% plotSpec.markerSize = 8;
% plotSpec.legend = 'V1, 2-64 Hz';
% theFigLGN = AnalyzeMRTTFGroup(theFigLGN, BASE_PATH1, subjects1, 'LMDirectedScaled', fieldInnerRing, fieldOuterRing, controlFlag, 'Purkinje', [], 'LGN', plotSpec, BASE_PATH1, false, true);
% 
% plotSpec.marker = '-sk';
% plotSpec.color = 'k';
% plotSpec.markerFaceColor = 'k';
% plotSpec.markerSize = 8;
% plotSpec.legend = 'V1, 0.5-2 Hz';
% theFigLGN = AnalyzeMRTTFGroup(theFigLGN, BASE_PATH1, subjects1, 'sLMDirectedScaled', fieldInnerRing, fieldOuterRing, controlFlag, 'Purkinje', [], 'LGN', plotSpec, BASE_PATH1, false, true);
% 
% % Vx - V3
% theFigVx = figure;
% plotSpec.marker = '-sk';
% plotSpec.color = 'k';
% plotSpec.markerFaceColor = 'k';
% plotSpec.markerSize = 8;
% plotSpec.legend = 'V2';
% theFigVx = AnalyzeMRTTFGroup(theFigVx, BASE_PATH1, subjects1, 'LMDirectedScaled', fieldInnerRing, fieldOuterRing, controlFlag, 'Purkinje', [], 'V2', plotSpec, BASE_PATH1, false, true);
% 
% plotSpec.marker = '-sk';
% plotSpec.color = 'k';
% plotSpec.markerFaceColor = 'k';
% plotSpec.markerSize = 8;
% plotSpec.legend = 'V3';
% theFigVx = AnalyzeMRTTFGroup(theFigVx, BASE_PATH1, subjects1, 'sLMDirectedScaled', fieldInnerRing, fieldOuterRing, controlFlag, 'Purkinje', [], 'V3', plotSpec, BASE_PATH1, false, true);

% LMDirectedScaled
% Only averages
% V1
% theFigV1 = figure;
% 
% plotSpec.marker = '-sk';
% plotSpec.color = 'k';
% plotSpec.markerFaceColor = 'k';
% plotSpec.markerSize = 8;
% plotSpec.legend = 'V1, 2-64 Hz';
% theFigV1 = AnalyzeMRTTFGroup(theFigV1, BASE_PATH1, subjects1, 'LMDirectedScaled', fieldInnerRing, fieldOuterRing, controlFlag, 'Purkinje', [], 'V1', plotSpec, BASE_PATH1, false, true);
% 
% plotSpec.marker = '-sk';
% plotSpec.color = 'k';
% plotSpec.markerFaceColor = 'k';
% plotSpec.markerSize = 8;
% plotSpec.legend = 'V1, 0.5-2 Hz';
% theFigV1 = AnalyzeMRTTFGroup(theFigV1, BASE_PATH1, subjects1, 'sLMDirectedScaled', fieldInnerRing, fieldOuterRing, controlFlag, 'Purkinje', [], 'V1', plotSpec, BASE_PATH1, false, true);

% % LGN
% theFigLGN = figure;
% 
% plotSpec.marker = '-sk';
% plotSpec.color = 'k';
% plotSpec.markerFaceColor = 'k';
% plotSpec.markerSize = 8;
% plotSpec.legend = 'V1, 2-64 Hz';
% theFigLGN = AnalyzeMRTTFGroup(theFigLGN, BASE_PATH1, subjects1, 'LMDirectedScaled', fieldInnerRing, fieldOuterRing, controlFlag, 'Purkinje', [], 'LGN', plotSpec, BASE_PATH1, true, true);
% 
% plotSpec.marker = '-sk';
% plotSpec.color = 'k';
% plotSpec.markerFaceColor = 'k';
% plotSpec.markerSize = 8;
% plotSpec.legend = 'V1, 0.5-2 Hz';
% theFigLGN = AnalyzeMRTTFGroup(theFigLGN, BASE_PATH1, subjects1, 'sLMDirectedScaled', fieldInnerRing, fieldOuterRing, controlFlag, 'Purkinje', [], 'LGN', plotSpec, BASE_PATH1, true, true);

% LMPenumbraDirected
% Plot out everything
% 2-64 Hz, bright
BASE_PATH1 = '/Data/Imaging/Protocols/TTFMRFlickerPurkinje/Subjects';
subjects1 = {'G042614A' 'M043014M' 'M042714S'};

fieldInnerRing = 5;
fieldOuterRing = 13;
controlFlag = false;

% LMDirectedScaled
% Only averages
% V1
theFigV1 = figure;

plotSpec.marker = 'sk';
plotSpec.color = 'k';
plotSpec.markerFaceColor = 'k';
plotSpec.markerSize = 8;
plotSpec.legend = 'V1, 2-64 Hz';
theFigV1 = AnalyzeMRTTFGroup(theFigV1, BASE_PATH1, subjects1, 'LMPenumbraDirected', fieldInnerRing, fieldOuterRing, controlFlag, 'Purkinje', [], 'V1', plotSpec, OUT_PATH, false, true, normFactor);

% % LGN
% theFigLGN = figure;
% 
% plotSpec.marker = '-sk';
% plotSpec.color = 'k';
% plotSpec.markerFaceColor = 'k';
% plotSpec.markerSize = 8;
% plotSpec.legend = 'V1, 2-64 Hz';
% theFigLGN = AnalyzeMRTTFGroup(theFigLGN, BASE_PATH1, subjects1, 'LMPenumbraDirected', fieldInnerRing, fieldOuterRing, controlFlag, 'Purkinje', [], 'LGN', plotSpec, BASE_PATH1, false, true);
% 
% 
% % Vx - V3
% theFigVx = figure;
% plotSpec.marker = '-sk';
% plotSpec.color = 'k';
% plotSpec.markerFaceColor = 'k';
% plotSpec.markerSize = 8;
% plotSpec.legend = 'V2';
% theFigVx = AnalyzeMRTTFGroup(theFigVx, BASE_PATH1, subjects1, 'LMPenumbraDirected', fieldInnerRing, fieldOuterRing, controlFlag, 'Purkinje', [], 'V2', plotSpec, BASE_PATH1, false, true);
% 
% plotSpec.marker = '-sk';
% plotSpec.color = 'k';
% plotSpec.markerFaceColor = 'k';
% plotSpec.markerSize = 8;
% plotSpec.legend = 'V3';
% theFigVx = AnalyzeMRTTFGroup(theFigVx, BASE_PATH1, subjects1, 'LMPenumbraDirected', fieldInnerRing, fieldOuterRing, controlFlag, 'Purkinje', [], 'V3', plotSpec, BASE_PATH1, false, true);


% LMDirectedScaled
% Only averages
% V1
% theFigV1 = figure;
% 
% plotSpec.marker = '-sk';
% plotSpec.color = 'k';
% plotSpec.markerFaceColor = 'k';
% plotSpec.markerSize = 8;
% plotSpec.legend = 'V1, 2-64 Hz';
% theFigV1 = AnalyzeMRTTFGroup(theFigV1, BASE_PATH1, subjects1, 'LMPenumbraDirected', fieldInnerRing, fieldOuterRing, controlFlag, 'Purkinje', [], 'V1', plotSpec, BASE_PATH1, true, true);
% 
% % % LGN
% theFigLGN = figure;
% 
% plotSpec.marker = '-sk';
% plotSpec.color = 'k';
% plotSpec.markerFaceColor = 'k';
% plotSpec.markerSize = 8;
% plotSpec.legend = 'V1, 2-64 Hz';
% theFigLGN = AnalyzeMRTTFGroup(theFigLGN, BASE_PATH1, subjects1, 'LMPenumbraDirected', fieldInnerRing, fieldOuterRing, controlFlag, 'Purkinje', [], 'LGN', plotSpec, BASE_PATH1, true, true);
% 
% close(theFigVx); close(theFigLGN);