% Clear the workspace
close all;
sca;
Screen('Close');
bgColor = [0.65 0.65 0.65];
trialDurationSecs = [0]+10; %seconds for different lengths of trials
numTrials = [1]; %corresponds to indices in trialDurationSecs
probabilityFixationCross = .6;
disappearanceFixationCross = 0.5; %seconds
commandwindow;

%Ask for observer
obsID = input('Enter observer ID (used for the file name): ', 's');


%%% Fixation cross
marginOuterDiameter = 20;

% Copy here
fixationCrossDiameter = 25.000000;
xCenter = 840;%%1020.000000;
yCenter = 420;%510.000000;

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

% Retreive the maximum priority number
topPriorityLevel = MaxPriority(window);

% Length of time and number of frames we will use for each drawing test
numSecs = 1/16;
numFrames = round(numSecs / ifi);

% Numer of frames to wait when specifying good timing
waitframes = 2;

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
%mondrianMasks = make_mondrian_masks(screenXpixels,screenYpixels,nMasks,1,1);
load('cfsCachedMasks.mat');

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Make the image into a texture
for i = 1:length(mondrianMasks)
    imageTexture{i} = Screen('MakeTexture', window, mondrianMasks{i});
end



% Finally we do the same as the last example except now we additionally
% tell PTB that no more drawing commands will be given between coloring the
% screen and the flip command. This, under some circumstances, can help
% acheive good timing.

% [xCenter, yCenter] = RectCenter(windowRect);
% Priority(topPriorityLevel);
% vbl = Screen('Flip', window);
% k = 1;
% while true
%     sequence = Shuffle(1:nMasks);
%     for s = 1:nMasks
%         randNow = sequence(s);
%         for i = 1:numFrames
%             % Color the screen red
%             Screen('DrawTexture', window, imageTexture{randNow}, [], [], 0);
%             Screen('DrawDots', window, [xCenter ; yCenter], [22], [0.65 0.65 0.65],[0,0],1);
%             Screen('DrawDots', window, [xCenter ; yCenter], [10], [0 0 0],[0,0],1);
%             
%             % Tell PTB no more drawing commands will be issued until the next flip
%             Screen('DrawingFinished', window);
%             
%             % Flip to the screen
%             vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
%         end
%         k = k+1;
%         
%     end
% end

thresholdUserResponseFixationCross = 2; %seconds
mglGetKeyEvent;
keyPress = [];
fixationCrossDisappearances = zeros(sum(numTrials), 3);

for trialCount = 1:sum(numTrials)
    % compute time for current trial
    for k = 1:length(trialDurationSecs)
        if trialCount <= sum(numTrials(1:k))
            currentTrialDuration = trialDurationSecs(k);
            break;
        end
    end
    
    %reset fixation cross statistics
    numFixationCrossDisappearances = 0;
    falseAlarms = 0;
    numUserFixationCross = 0;
    
    numSegments = currentTrialDuration/(thresholdUserResponseFixationCross+disappearanceFixationCross);

    
    while true
        Screen('DrawDots', window, [xCenter ; yCenter], [fixationCrossDiameter+marginOuterDiameter], [0.65 0.65 0.65],[0,0],1);
        Screen('DrawDots', window, [xCenter ; yCenter], [fixationCrossDiameter], [0 0 0],[0,0],1);
        pause(.1);
        Priority(topPriorityLevel);
        vbl = Screen('Flip', window);
        key = mglGetKeyEvent;
        if ~isempty(key) %start displaying mondrian
            t0 = mglGetSecs;
            counter = 1;%%%%%%
            while mglGetSecs(t0) < currentTrialDuration
                    
                    for currentSegment = 1:numSegments
                        segmentStart = mglGetSecs();
                        fixationCrossAppear = (rand < probabilityFixationCross);
                        
                        if ~fixationCrossAppear
                            numFixationCrossDisappearances = numFixationCrossDisappearances + 1;
                        end
                        detect = true;
                        
                        while mglGetSecs(segmentStart) < (thresholdUserResponseFixationCross + disappearanceFixationCross)
                            sequence = Shuffle(1:length(mondrianMasks));
                            for s = 1:length(mondrianMasks)
                                randNow = sequence(s);
                                Screen('DrawTexture', window, imageTexture{randNow}, [], [], 0);
                                Screen('DrawDots', window, [xCenter ; yCenter], [fixationCrossDiameter+marginOuterDiameter], [0.65 0.65 0.65],[0,0],1);
                                if fixationCrossAppear || (mglGetSecs(segmentStart) > disappearanceFixationCross)
                                    Screen('DrawDots', window, [xCenter ; yCenter], [fixationCrossDiameter], [0 0 0],[0,0],1);
                                end
                                
                                newKey = mglGetKeyEvent;
                                if ~isempty(newKey) && (detect == true)
                                    detect = false;
                                    if ~fixationCrossAppear
                                        numUserFixationCross = numUserFixationCross + 1;
                                    else
                                        falseAlarms = falseAlarms + 1;
                                    end
                                end

                                % Tell PTB no more drawing commands will be issued until the next flip
                                Screen('DrawingFinished', window);

                                % Flip to the screen
                                vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);   
                                test(counter) = mglGetSecs(t0); %%%%%
                                counter = counter + 1; %%%%%
                            end
                        end  
                        
%                     for i = 1:numFrames
%                         % Color the screen red
%                         Screen('DrawTexture', window, imageTexture{randNow}, [], [], 0);
%                         Screen('DrawDots', window, [xCenter ; yCenter], [fixationCrossDiameter+marginOuterDiameter], [0.65 0.65 0.65],[0,0],1); %dots are drawn over
%                         if (fixationCrossAppear) && (rand > probabilityFixationCross) && ...
%                             (mglGetSecs(timeDisappearance) > (thresholdUserResponseFixationCross + disappearanceFixationCross)) &&...
%                             ((currentTrialDuration - mglGetSecs(t0)) > (thresholdUserResponseFixationCross + disappearanceFixationCross))
%                             
%                             fixationCrossAppear = false;
%                             numFixationCrossDisappearances = numFixationCrossDisappearances + 1;
%                             timeDisappearance = mglGetSecs;
%                             detect = true;
%                         end
%                         if ~fixationCrossAppear && (mglGetSecs(timeDisappearance) > disappearanceFixationCross) %if it's past disappearance time
%                             fixationCrossAppear = true;
%                         end
%                         if fixationCrossAppear
%                             Screen('DrawDots', window, [xCenter ; yCenter], [fixationCrossDiameter], [0 0 0],[0,0],1);
%                         end
%                         
%                         newKey = mglGetKeyEvent;
%                         if ~isempty(newKey) && (detect == true)
%                             if mglGetSecs(timeDisappearance) < (thresholdUserResponseFixationCross + disappearanceFixationCross)
%                                 numUserFixationCross = numUserFixationCross + 1;
%                                 detect = false;
%                             else
%                                 falseAlarms = falseAlarms + 1;
%                             end
%                         end
%                         
%                         % Tell PTB no more drawing commands will be issued until the next flip
%                         Screen('DrawingFinished', window);
% 
%                         % Flip to the screen
%                         vbl = Screen('Flip', window);%;, vbl + (waitframes - 0.5) * ifi);
                    end
                    %k = k+1;

            end
            break;
        end
    end
    fixationCrossDisappearances(trialCount, 1) = numFixationCrossDisappearances;
    fixationCrossDisappearances(trialCount, 2) = numUserFixationCross;
    fixationCrossDisappearances(trialCount, 3) = falseAlarms;
end

Priority(0);

save('~/Desktop/test.mat', 'test');

% Clear the screen
sca;
clear all;
close all;
