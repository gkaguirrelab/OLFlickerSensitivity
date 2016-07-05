% Clear the workspace
close all;
clear all;
sca;
Screen('Close');
bgColor = [0.65 0.65 0.65];
commandwindow;

% Define step sizes for the navigation
fineStepSize = 1;
coarseStepSize = 30;

% Fixation cross
marginOuterDiameter = 20;

% Copy here
fixationCrossDiameter = 25.000000;
xCenter = 1020.000000;
yCenter = 510.000000;


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

pause;

Priority(0);


% Clear the screen
sca;
