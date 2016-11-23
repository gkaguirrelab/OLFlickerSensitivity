% MaxPulsePsychophysics_Analysis.m
%
% Analyses rating data. Hacked up for now.
%
% 11/22/16  spitschan  Wrote it.
% Proposed edits: Add in variable for subject id and date of experiment. 

% Subject information:
%observerID = HERO_test3
%expDate = 112216

% Load the file
% dataPath = getpref('OneLight', 'dataPath');
%load(fullfile(datapath, observerID, expDate, 'MatFiles', 
load('/Users/melanopsin/Dropbox (Aguirre-Brainard Lab)/MELA_data/MaxPulsePsychophysics/Hero_test3/112216/MatFiles/HERO_test3-MaxPulsePsychophysics.mat'); 
% Get all the stimulus types
allLabels = {data.stimLabel};
[uniqueLabels, ~, allLabelsIdx] = unique(allLabels);

% Get all the perceptual dimensions
allDimensions = {data.perceptualDimension};
[uniqueDimensions, ~, allDimensionsIdx] = unique(allDimensions);

% Assemble all responses
allResponses = [data.response];

% Iterate over stimulus types and perceptual rating dimensions
for ii = 1:length(uniqueLabels)
   for jj = 1:length(uniqueDimensions)
      % Find the trials that correspond to this
      aggregatedData{ii, jj} = allResponses((allLabelsIdx == ii) & (allDimensionsIdx == jj));
      aggregatedDataMean(ii, jj) = mean(allResponses((allLabelsIdx == ii) & (allDimensionsIdx == jj)));
   end
end

% Make a bar plot of the mean ratings
h = bar(aggregatedDataMean');
set(gca, 'XTickLabel', uniqueDimensions);
legend(h, uniqueLabels);

