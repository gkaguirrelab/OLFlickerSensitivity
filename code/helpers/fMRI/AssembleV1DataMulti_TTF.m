%% Add the code folder to the directory
cd /Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity
addpath(genpath(pwd));

% Define the plot directories
plotSaveDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/MRFlickerData';
if ~isdir(plotSaveDir);
    mkdir(plotSaveDir);
end

theROIs = {'V1', 'V2V3', 'LOC', 'MT'};

%%  
% Extract the TTFs

for r = 1:length(theROIs)
    ROI = theROIs{r};
    % L+M
    plotColor = [0.9490 0.7216 0.0275];
    AssembleV1DataMulti(2, {{'G042614A', 'M042914S', 'M042914M'} {'G042514A', 'M041814S', 'M041714M'}}, ...
        {'sLMDirected', 'LMDirected'}, {'TTFMRFlickerYs' 'TTFMRFlickerY'}, ...
        {[0.5 1], [2 4 8 16 32 64]}, 2, ROI, plotColor, plotSaveDir);
     
    % L-M
    plotColor = [0.1 0.5 0.1];
    AssembleV1DataMulti(2, {{'G042614A', 'M042914S', 'M042914M'} {'G042514A', 'M041814S', 'M041714M'}}, ...
        {'sLMinusMDirected', 'LMinusMDirected'}, {'TTFMRFlickerYs' 'TTFMRFlickerY'}, ...
        {[0.5 1], [2 4 8 16 32 64]}, 2, ROI, plotColor, plotSaveDir);
    
    % S
    plotColor = [0 0 1];
    AssembleV1DataMulti(2, {{'G042614A', 'M042914S', 'M042914M'} {'G042514A', 'M041814S', 'M041714M'}}, ...
        {'sSDirected', 'SDirected'}, {'TTFMRFlickerYs' 'TTFMRFlickerY'}, ...
        {[0.5 1], [2 4 8 16 32 64]}, 2, ROI, plotColor, plotSaveDir);
    
    % L+M (scaled)
    plotColor = [0.9490 0.7216 0.0275];
    AssembleV1DataMulti(2, {{'G042614A', 'M042714S', 'M043014M'} {'G042614A', 'M042714S', 'M043014M'}}, ...
        {'sLMDirected', 'LMDirectedScaled'}, {'TTFMRFlickerPurkinje' 'TTFMRFlickerPurkinje'}, ...
        {[0.5 1], [2 4 8 16 32 64]}, 2, ROI, plotColor, plotSaveDir);
    
    % Mel
    plotColor = [0.0275 0.4902 0.9490];
    AssembleV1DataMulti(2, {{'G042614A', 'M042914S', 'M042914M'} {'G042514A', 'M041814S', 'M041714M'}}, ...
        {'sMelanopsinDirected', 'MelanopsinDirected'}, {'TTFMRFlickerYs' 'TTFMRFlickerY'}, ...
        {[0.5 1], [2 4 8 16 32 64]}, 3, ROI, plotColor, plotSaveDir);
    
    % LMPenumbraDirected
    plotColor = [0.1 0.1 0.1];
    AssembleV1DataMulti(1, {{'G042614A', 'M042714S', 'M043014M'}}, ...
        {'LMPenumbraDirected'}, {'TTFMRFlickerPurkinje'}, ...
        {[2 4 8 16 32 64]}, 2, ROI, plotColor, plotSaveDir);
end

%% LMS
for r = 1:length(theROIs)
    ROI = theROIs{r};
% LMS
plotColor = [0.25 0.25 0.25];
AssembleV1DataMulti(2, {{'G050115A', 'M050115S',  'M050115M'} {'G050115A', 'M050115S', 'M050115M'}}, ...
    {'sLMSDirected' 'LMSDirected'}, {'TTFMRFlickerLMS' 'TTFMRFlickerLMS'}, ...
    {[0.5 1], [2 4 8 16 32 64]}, 2, ROI, plotColor, plotSaveDir);
end

%%%%% JULY 17 %%%%%
%% Light Flux control
for r = 1:length(theROIs)
    ROI = theROIs{r};
    % Light flux control
    plotColor = [0.25 0.25 0.25];
    AssembleV1DataMulti(1, {{'G071715A', 'M071715M',  'M071715S'}}, ...
        {'LightFlux'}, {'TTFMRFlickerNulledLightFluxControl'}, ...
        {[4]}, 1, ROI, plotColor, plotSaveDir);
end

%% Melanopsin 
for r = 1:length(theROIs)
    ROI = theROIs{r};
    % Light flux control
    plotColor = [0.25 0.25 0.25];
    AssembleV1DataMulti(1, {{'G071715A', 'M071715M',  'M071715S'}}, ...
        {'Nulled'}, {'TTFMRFlickerNulledLightFluxControl'}, ...
        {[0.5 1 2]}, 3, ROI, plotColor, plotSaveDir);
end

%%%%% AUG 21 %%%%%
%% Melanopsin (32%), L+M+S (32%) & light flux (32%) - nulled, 4 Hz
for r = 1:length(theROIs)
    ROI = theROIs{r};
    % Light flux control
    plotColor = [0.25 0.25 0.25];
    AssembleV1DataMulti(1, {{'G082115A', 'M082115M' 'M082115S'}}, ...
        {'Nulled'}, {'TTFMRFlickerNulledMelanopsinHighContrast'}, ...
        {[0.5 1 2]}, 3, ROI, plotColor, plotSaveDir);
end


%%%%% Original data set (TTFMRFlickerOrig)
%% 45% L+M / 45% Mel
for r = 1:length(theROIs)
    ROI = theROIs{r};
    % L+M
    plotColor = [0.9490 0.7216 0.0275];
    AssembleV1DataMulti(1, {{'G111513A', 'M111913M', 'M111913S'}}, ...
        {'LMDirected'}, {'TTFMRFlickerOrig'}, ...
        {[1 2 4 8 16]}, 2, ROI, plotColor, plotSaveDir);
     
    % Mel
    plotColor = [0.0275 0.4902 0.9490];
    AssembleV1DataMulti(1, {{'G111513A', 'M111913M', 'M111913S'}}, ...
        {'MelanopsinDirected'}, {'TTFMRFlickerOrig'}, ...
        {[1 2 4 8 16]}, 2, ROI, plotColor, plotSaveDir);
     
end


%%
%%%%%%%%%%%%%%%%%%%%%%% DATA AT 175 CD/M2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Add the code folder to the directory
cd /Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity
addpath(genpath(pwd));

% Define the plot directories
plotSaveDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/MRFlickerData/TTFMRFlickerX';
if ~isdir(plotSaveDir);
    mkdir(plotSaveDir);
end


% Extract the TTFs
theROIs = {'V1', 'V2V3', 'LOC', 'MT'};
for r = 1:length(theROIs)
    ROI = theROIs{r};
        % Isochromatic
    plotColor = [0.2 0.2 0.2];
    AssembleV1DataMulti(1, {{'G031614A' 'M031614S'}}, ...
        {'Isochromatic'}, {'TTFMRFlickerX'}, ...
        { [2 4 8 16 32 64]}, 2, ROI, plotColor, plotSaveDir);
    
    % L+M
    plotColor = [0.9490 0.7216 0.0275];
    AssembleV1DataMulti(1, {{'G031614A' 'M031614S'}}, ...
        {'LMDirected'}, {'TTFMRFlickerX'}, ...
        { [2 4 8 16 32 64]}, 2, ROI, plotColor, plotSaveDir);
    
    % L-M
    plotColor = [0.1 0.5 0.1];
    AssembleV1DataMulti(1, {{'G031614A' 'M031614S'}}, ...
        {'LMinusMDirected'}, {'TTFMRFlickerX'}, ...
        { [2 4 8 16 32 64]}, 2, ROI, plotColor, plotSaveDir);
    
    % S
    plotColor = [0 0 1];
    AssembleV1DataMulti(1, {{'G031614A' 'M031614S'}}, ...
        {'SDirected'}, {'TTFMRFlickerX'}, ...
        { [2 4 8 16 32 64]}, 2, ROI, plotColor, plotSaveDir);
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% MAKE Z MAPS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% L+M
AssembleDataMultiZMap(2, {{'G042614A', 'M042914S', 'M042914M'} {'G042514A', 'M041814S', 'M041714M'}}, ...
    {'sLMDirected', 'LMDirected'}, {'TTFMRFlickerYs' 'TTFMRFlickerY'}, ...
    {[4], [7]}, 2);

% L-M
AssembleDataMultiZMap(2, {{'G042614A', 'M042914S', 'M042914M'} {'G042514A', 'M041814S', 'M041714M'}}, ...
    {'sLMinusMDirected', 'LMinusMDirected'}, {'TTFMRFlickerYs' 'TTFMRFlickerY'}, ...
    {[4], [7]}, 2);

% S
AssembleDataMultiZMap(2, {{'G042614A', 'M042914S', 'M042914M'} {'G042514A', 'M041814S', 'M041714M'}}, ...
    {'sSDirected', 'SDirected'}, {'TTFMRFlickerYs' 'TTFMRFlickerY'}, ...
    {[4], [7]}, 2);

% L+M (scaled)
AssembleDataMultiZMap(2, {{'G042614A', 'M042714S', 'M043014M'} {'G042614A', 'M042714S', 'M043014M'}}, ...
    {'sLMDirected', 'LMDirectedScaled'}, {'TTFMRFlickerPurkinje' 'TTFMRFlickerPurkinje'}, ...
    {[4], [7]}, 2);

% Mel
AssembleDataMultiZMap(2, {{'G042614A', 'M042914S', 'M042914M'} {'G042514A', 'M041814S', 'M041714M'}}, ...
    {'sMelanopsinDirected', 'MelanopsinDirected'}, {'TTFMRFlickerYs' 'TTFMRFlickerY'}, ...
    {[4], [7]}, 2);

% LMPenumbraDirected
AssembleDataMultiZMap(1, {{'G042614A', 'M042714S', 'M043014M'}}, ...
    {'LMPenumbraDirected'}, {'TTFMRFlickerPurkinje'}, ...
    {[7]}, 2);