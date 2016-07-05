% Clear the workspace
close all;
clear all;
sca;
Screen('Close');
cal = LoadCalFile('ViewSonicCFS');
gammaInversionMethod = 0;
cal = SetGammaMethod(cal, gammaInversionMethod);
bgColor = [0.5 0.5 0.5];
bgColor = PrimaryToSettings(cal, bgColor')';

commandwindow;


% Define step sizes for the navigation
fineStepSize = 1;
coarseStepSize = 30;

% Fixation cross
marginOuterDiameter = 20;



% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
Screen('Preference', 'SkipSyncTests', 1);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
inc = white - grey;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);


% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', window);
save('~/Desktop/foo.mat', 'ifi');
clear all;
close all;
% Retreive the maximum priority number
topPriorityLevel = MaxPriority(window);

% Length of time and number of frames we will use for each drawing test
numSecs = 0.1;
numFrames = round(numSecs / ifi);

% Numer of frames to wait when specifying good timing
waitframes = 2;

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
load('cfsCachedMasks.mat'); %mondrianMasks = pre-cached mondrian images

% Query the frame duration
ifi = Screen('GetFlipInterval', window);


% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Finally we do the same as the last example except now we additionally
% tell PTB that no more drawing commands will be given between coloring the
% screen and the flip command. This, under some circumstances, can help
% acheive good timing.

Priority(topPriorityLevel);
vbl = Screen('Flip', window);

% Make the image into a texture
for i = 1:length(mondrianMasks)
    imageTexture{i} = Screen('MakeTexture', window, mondrianMasks{i});
end

%Fixation Cross Disappearances
probabilityFixationCross = .6; %probability it will appear bright color during segment
durationBlackFixationCross = 0.5; %seconds
userThresholdResponse = 2; %seconds
segmentDuration = durationBlackFixationCross + userThresholdResponse;
fixationCrossColors = {[1 0 0], [0 1 0], [0 1 1], [1 1 1]}; %bright colors

trialCount = 0;

%Ask for observer
obsID = input('Enter observer ID (used for the file name): ', 's');
subjectRunNumber = input('Enter run number (e.g. 05): ', 's');

%Fixation Cross Coordinates
listOfFiles = dir('*.mat');
foundFile = false;
for file = listOfFiles'
    fileName = file.name;
    if strncmp(obsID, fileName, length(obsID)) && ~isempty(strfind(fileName,...
            '_fixationCrossCoordinates.mat'))
        load(fileName, 'xCenter', 'yCenter', 'fixationCrossDiameter');
        foundFile = true;
        break;
    end
end
if ~foundFile
    fprintf('Subject does not have fixation cross coordinates.\n');
end

%Open UDP connection w/ Mac Pro
if exist('instrfindall') && ~isempty(instrfindall)
    fclose(instrfindall);
end
theMacPro = '192.168.2.2';
theLaptop = '192.168.2.1';
udpPort = 2008;
udpMacPro = udp(theMacPro, udpPort, 'LocalPort', udpPort);
fopen(udpMacPro);
udpMacPro.ReadAsyncMode = 'continuous';

%confirm UDP connection w/ Mac Pro
fprintf('Waiting to confirm UDP connection with Mac Pro. \n');
while ~udpMacPro.BytesAvailable
    continue; 
end
if strtrim(fscanf(udpMacPro)) == '1'
    fprintf('UDP Connection with Mac Pro established. \n');
    fprintf(udpMacPro, '1');
else
    fprintf('Error in establishing UDP connection with Mac Pro. Retry. \n');
end
flushinput(udpMacPro);
flushoutput(udpMacPro);

trialType = 'c'; %initial setting
while true

    switch trialType
        
        case 'a' %static
            
            trialCount = trialCount + 1;
            fprintf('Trial %d started. \n', trialCount);
            
            % Initial flip
            Screen('DrawDots', window, [xCenter ; yCenter], [fixationCrossDiameter+marginOuterDiameter],...
                bgColor,[0,0],1); %dots are drawn over
            Screen('DrawDots', window, [xCenter ; yCenter], [fixationCrossDiameter], [0 0 0],[0,0],1);

            % Flip to the screen
            vbl = Screen('Flip', window);
            pause(.1);
            Priority(0);

            while ~udpMacPro.BytesAvailable
                continue; %wait for input
            end
            trialType = strtrim(fscanf(udpMacPro));
            fprintf(udpMacPro, '1');
            fprintf('Received signal from Mac Pro. Sending confirmation signal to Mac Pro. \n');

            fixationCrossStatistics(trialCount, 1) = NaN;
            fixationCrossStatistics(trialCount, 2) = NaN;
            fixationCrossStatistics(trialCount, 3) = NaN;
            
            fprintf('Trial %d ended. \n', trialCount);
            

        case 'b' %CFS
            
            %reset fixation cross statistics
            numFixationCrossBlack = 0;
            falseAlarms = 0;
            numUserFixationCross = 0;
            
            trialCount = trialCount + 1;
            fprintf('Trial %d started. \n', trialCount);
            
            continueCFS = true;
            while continueCFS
                
                segmentStart = mglGetSecs;
                
                %where fixation cross appears bright in segment or not
                fixationCrossBright = (rand < probabilityFixationCross);
                if ~fixationCrossBright
                    numFixationCrossBlack = numFixationCrossBlack + 1;
                end
                detect = true;
                    
                continueSegment = true;
                while continueSegment
                                        
                    sequence = Shuffle(1:length(mondrianMasks));
                    for s = 1:length(mondrianMasks)

                        randNow = sequence(s);
                        Screen('DrawTexture', window, imageTexture{randNow}, [], [], 0);
                        colorIndexOuterCircle = randi(length(fixationCrossColors), 1, 1);
                        Screen('DrawDots', window, [xCenter ; yCenter], [fixationCrossDiameter+marginOuterDiameter],...
                            fixationCrossColors{colorIndexOuterCircle},[0,0],1); %random color from input colors
                        if ~fixationCrossBright && (mglGetSecs(segmentStart) < durationBlackFixationCross) %draw black
                            Screen('DrawDots', window, [xCenter ; yCenter], [fixationCrossDiameter], [0 0 0],[0,0],1);
                        else
                            colorIndexInnerCircle = mod(colorIndexOuterCircle...
                                +round(rand*(length(fixationCrossColors)-2)),...
                                length(fixationCrossColors))+1; %guarantees different color than outer circle
                            Screen('DrawDots', window, [xCenter ; yCenter], [fixationCrossDiameter],...
                                fixationCrossColors{colorIndexInnerCircle},[0,0],1);
                        end

                        newKey = mglGetKeyEvent;
                        if ~isempty(newKey) && (detect == true)
                            detect = false;
                            if ~fixationCrossBright
                                numUserFixationCross = numUserFixationCross + 1;
                            else
                                falseAlarms = falseAlarms + 1;
                            end
                        end

                        % Tell PTB no more drawing commands will be issued until the next flip
                        Screen('DrawingFinished', window);

                        % Flip to the screen
                        vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
                        
                        if udpMacPro.BytesAvailable %signal to end trial
                            t0 = mglGetSecs();
                            continueCFS = false;
                            trialType = strtrim(fscanf(udpMacPro));
                            fprintf(udpMacPro, '1');
                            fprintf('Received signal from Mac Pro. Sending confirmation signal to Mac Pro. \n');
                            break;
                        
                        elseif mglGetSecs(segmentStart) > segmentDuration %end segment
                            continueSegment = false;
                            break; 
                        end

                    end
                    
                    if ~continueCFS %end segment and delete segment statistics
                        if ~fixationCrossBright
                            numFixationCrossBlack = numFixationCrossBlack - 1;
                            if ~detect
                                numUserFixationCross = numUserFixationCross - 1;
                            end
                        else %fixationCrossBright = true
                            if ~detect
                                falseAlarms = falseAlarms - 1;
                            end
                        end
                        continueSegment = false; %break out of segment
                    end                    
                end
            end
            
            fixationCrossStatistics(trialCount, 1) = numFixationCrossBlack;
            fixationCrossStatistics(trialCount, 2) = numUserFixationCross;
            fixationCrossStatistics(trialCount, 3) = falseAlarms;
            
            fprintf('Trial %d ended. \n', trialCount);
            
        case 'c' %rest between trials
            
            % Initial flip
            Screen('DrawDots', window, [xCenter ; yCenter], [fixationCrossDiameter+marginOuterDiameter],...
                bgColor,[0,0],1); %dots are drawn over
            Screen('DrawDots', window, [xCenter ; yCenter], [fixationCrossDiameter], [0 0 0],[0,0],1);

            % Flip to the screen
            vbl = Screen('Flip', window);
            pause(.1);
            Priority(0);

            while ~udpMacPro.BytesAvailable
                continue; %wait for input
            end
            trialType = strtrim(fscanf(udpMacPro));
            fprintf('Received trial start signal from MacPro. \n');
            
        case 'z' % end of experiment
            fprintf('Experiment has ended. \n');
            save([obsID '_fixationCrossStatistics_' subjectRunNumber '.mat'], 'fixationCrossStatistics');
            break;
            
        otherwise %invalid input
            while ~udpMacPro.BytesAvailable
                continue %wait for input
            end
            trialType = strtrim(fscanf(udpMacPro));
    end      
end


if exist('instrfindall') && ~isempty(instrfindall)
    fclose(instrfindall);
end
fclose(udpMacPro)
delete(udpMacPro)
clear udpMacPro
% Clear the screen
sca;