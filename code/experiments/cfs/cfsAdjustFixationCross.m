% Clear the workspace
close all;
clear all;
sca;
Screen('Close');
bgColor = [.5 .5 .5];
commandwindow;

% Define step sizes for the navigation
fineStepSize = 1;
coarseStepSize = 30;

% Fixation cross
fixationCrossDiameter = 25;
marginOuterDiameter = 20;

%Ask for observer
obsID = input('Enter observer ID (used for the file name): ', 's');

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
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, bgColor);


% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', window);

% Retreive the maximum priority number
topPriorityLevel = MaxPriority(window);

% Length of time and number of frames we will use for each drawing test
numSecs = 0.1;
numFrames = round(numSecs / ifi);

% Numer of frames to wait when specifying good timing
waitframes = 1;

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Finally we do the same as the last example except now we additionally
% tell PTB that no more drawing commands will be given between coloring the
% screen and the flip command. This, under some circumstances, can help
% acheive good timing.

[xCenter, yCenter] = RectCenter(windowRect);
Priority(topPriorityLevel);
vbl = Screen('Flip', window);

% Initial flip
Screen('DrawDots', window, [xCenter ; yCenter], [fixationCrossDiameter+marginOuterDiameter], [0.65 0.65 0.65],[0,0],1); %dots are drawn over
Screen('DrawDots', window, [xCenter ; yCenter], [fixationCrossDiameter], [0 0 0],[0,0],1);

% Flip to the screen
vbl = Screen('Flip', window);

stepSize = coarseStepSize;
keepLooping = true;
drawDot = true;
while (keepLooping)
    if CharAvail
        % Get the key
        theKey = GetChar(false, true);
        
        if (theKey == 'q')
            keepLooping = false;
        end
        
        % Navigate: Coarse adjustment
        if (theKey == 's')
            yCenter = yCenter + stepSize;
        end
        
        if (theKey == 'w')
            yCenter = yCenter - stepSize;
        end
        
        if (theKey == 'a')
            xCenter = xCenter - stepSize;
        end
        
        if (theKey == 'd')
            xCenter = xCenter + stepSize;
        end
        
        
        % Increase/decrease size of diameters
        if (theKey == '1')
            fixationCrossDiameter = fixationCrossDiameter-stepSize;
        end
        
        if (theKey == '6')
            fixationCrossDiameter = fixationCrossDiameter+stepSize;
        end
        
        % Toggles stepsize
        if (theKey == '2')
            if stepSize == coarseStepSize
                stepSize = fineStepSize;
            elseif stepSize == fineStepSize
                stepSize = coarseStepSize;
            end
        end
        
        if (theKey == '3')
            drawDot = ~drawDot;
        end
        
        if (theKey == '4')
           keepLooping = false; 
        end
        
        % Make sure that the diameters are not 0
        if fixationCrossDiameter <= 0
            fixationCrossDiameter = 1;
        end
        
        if fixationCrossDiameter > 189.75-marginOuterDiameter
            fixationCrossDiameter = 189.75-marginOuterDiameter;
        end
        
        % Print out the position of the annulus
        fprintf('Diameter d: %g,x: %g, y: %g\n', fixationCrossDiameter, xCenter, yCenter);
        
        
        Screen('DrawDots', window, [xCenter ; yCenter], [fixationCrossDiameter+marginOuterDiameter], [0.65 0.65 0.65],[0,0],1); %dots are drawn over
        if drawDot
            Screen('DrawDots', window, [xCenter ; yCenter], [fixationCrossDiameter], [0 0 0],[0,0],1);
        end
        % Flip to the screen
        vbl = Screen('Flip', window);
    end
end

fprintf('\n********************* \n');
fprintf('fixationCrossDiameter = %f;\n', fixationCrossDiameter)
fprintf('xCenter = %f;\n', xCenter)
fprintf('yCenter = %f;', yCenter)
fprintf('\n********************* \n');

Priority(0);

save([obsID '_fixationCrossCoordinates.mat'], 'xCenter', 'yCenter', 'fixationCrossDiameter', '-v7.3');


% Clear the screen
sca;
