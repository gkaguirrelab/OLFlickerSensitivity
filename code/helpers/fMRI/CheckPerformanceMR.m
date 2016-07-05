function CheckPerformanceMR(matFile)
% Displays the hit rate and false alarm rate for an attention task created
%   using the OneLight, based on an input .mat file
%
%   Usage:
%   CheckPerformanceMR(matFile)
%
%   Written by Andrew S Bock Mar 2016

%% Load the .mat file
load(matFile);
%% Iterate over the segments and count analyze accuracy
NSegments           = length(params.responseStruct.events);
attentionTaskFlag   = zeros(1,NSegments);
responseDetection   = zeros(1,NSegments);
hit                 = zeros(1,NSegments);
miss                = zeros(1,NSegments);
falseAlarm          = zeros(1,NSegments);
for i = 1:NSegments
    % Attentional 'blinks'
    if params.responseStruct.events(i).attentionTask.segmentFlag
        attentionTaskFlag(i) = 1;
    end
    % Subject key press responses
    if ~isempty(params.responseStruct.events(i).buffer)
        responseDetection(i) = 1;
    end
    % Hits
    if (attentionTaskFlag(i) == 1) && (responseDetection(i) == 1)
        hit(i) = 1;
    end
    % Misses
    if (attentionTaskFlag(i) == 1) && (responseDetection(i) == 0)
        miss(i) = 1;
    end
    % False Alarms
    if (attentionTaskFlag(i) == 0) && (responseDetection(i) == 1)
        falseAlarm(i) = 1;
    end
end
%% Display performance
fprintf('*** Subject %s - hit rate: %.3f (%g/%g) / false alarm: %.3f (%g/%g)\n', ...
    exp.subject, sum(hit)/sum(attentionTaskFlag), sum(hit), sum(attentionTaskFlag), ...
    sum(falseAlarm)/(NSegments-sum(attentionTaskFlag)), sum(falseAlarm), ...
    (NSegments-sum(attentionTaskFlag)));