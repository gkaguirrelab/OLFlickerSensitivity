%
% Demo of basic analog digital aquisition via a LabJackU6 device.
%
% Jan 6, 2015     npc    Wrote it .
% Jan 9, 2015     gka, ams  Modified to return measured trial data
% Jan 26, 2015    gka, ams Modified to remove the initial addpath, as this
%                         adding a delay to the start of recording.

function [time,data]=LabJackSample(durationInSeconds)

%addpath(genpath(pwd));

% Instantiate a LabJack object to handle communication with the device
labjackOBJ = LabJackU6('verbosity', 1);

% Set up sampling parameters
samplingParams = struct(...
    'channelIDs', [1], ...         % list of  channels to aquire from (AIN1, AIN2, AIN3)
    'frequencyInHz', 1000 ...    % using an 1 KHz sampling rate, as EMG signals
    );                            % are in the 5 - 450 Hz range


    % Configure analog input sampling
    labjackOBJ.configureAnalogDataStream(samplingParams.channelIDs, samplingParams.frequencyInHz);
    
    % Aquire the data
    labjackOBJ.startDataStreamingForSpecifiedDuration(durationInSeconds);
    
    time=labjackOBJ.timeAxis;
    data=labjackOBJ.data;
    

% Close-up shop
labjackOBJ.shutdown();

end


function plotData(session, sessionsNum, timeAxis,data)
figure(1);
subplot('Position', [0.07 0.07 0.9 0.88]);
plot(timeAxis,data(:,1), 'b-');
set(gca, 'YLim', 1*[-1 1], 'YTick', [-4 -3 -2 -1 0 1 2 3 4]);
set(gca, 'FontName', 'Helvetica', 'FontSize', 12);
ylabel('input signal (volts)');
xlabel('time (seconds)');
title(sprintf('Session %d of %d', session, sessionsNum));
end

function [durationInSeconds, sessions, keepLooping] = getRecordingOptions()

prompt = {'Recording duration (secs)', 'Recording sessions'};
title = 'LabJack Demo';
numLines = 1;
defaults = {'2', '10'};

keepLooping = true;
durationInSeconds = str2double(defaults{1});
sessions = str2double(defaults{2});

options = inputdlg(prompt, title, numLines, defaults);
if (isempty(options))
    keepLooping = false;
elseif (isempty(options{1}))
    fprintf('\nNo duration was entered. Will record for 1 second.\n');
    durationInSeconds = 1;
elseif (isempty(options{2}))
    fprintf('\nNo sessions was entered. Will record for 1 session.\n');
    durationInSeconds = 1;
else
    durationInSeconds = str2double(options{1});
    sessions = str2double(options{2});
    if (durationInSeconds == 0)
        durationInSeconds = 1;
        fprintf('\nEntered 0 seconds of recording. Will record for 1 second.\n');
    end
    if (sessions == 0)
        sessions = 1;
        fprintf('\nEntered 0 recording sessions. Will so 1 session.\n');
    end
end
end

