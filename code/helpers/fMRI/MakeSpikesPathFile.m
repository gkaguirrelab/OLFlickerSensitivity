function MakeSpikesPathFile(covDir, spikeDir, protocol, spikeOrder)
% MakeSpikesPathFile(covDir, spikeDir)
%
% Assembles the spike path file for FSL analysis
theFilesCov = dir(fullfile(covDir, '*.mat'));
theFilesSpike = dir(fullfile(spikeDir, ['*' protocol '*.txt']));

if length(theFilesCov) == 0
   fprintf('*** NO FILES FOUND ***'); 
end

if ~exist('spikeOrder', 'var')
    spikeOrder = 1:length(theFilesSpike);
end

for f = 1:length(theFilesCov)
    fprintf('\n%s -> %s', theFilesCov(f).name, theFilesSpike(spikeOrder(f)).name);
    [~, theSpikesPathFileName] = fileparts(theFilesCov(f).name);
    theSpikesPathFileName = fullfile(covDir, [theSpikesPathFileName '.spikes']);
    theSpikePath = fullfile(spikeDir, theFilesSpike(spikeOrder(f)).name);
    system(['touch ' theSpikesPathFileName]);
    system(['echo "' theSpikePath '" > ' theSpikesPathFileName]);
end
fprintf('\n*** \n');