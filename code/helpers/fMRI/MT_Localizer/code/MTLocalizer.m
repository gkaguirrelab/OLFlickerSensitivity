function MTLocalizer(subjID, runID);
% MovingDotsDemo - Demonstrates dot lifetime and coherence.
%
% Syntax:
% MovingDotsDemo
%
% Description:
% MovingDotsDemo is a program to demonstrate the effects of dot lifetime
% and coherence.  Dot coherences are specified in the same fashion as the
% DotThreshold experiment.  Dot lifetimes are specified as a vector of
% durations in seconds.
%
% Controls:
% Up/Down Arrow - Change the dot lifetime.
% Left/Right Arrow - Change the dot coherence.
% q - Quit the program.

exp.mFileName = mfilename;
exp.baseDir = fileparts(which(exp.mFileName));
exp.experimentTimeNow = now;
exp.experimentTimeDateString = datestr(exp.experimentTimeNow);

% Figure out the data directory path.  The data directory should be on the
% same level as the code directory.
i = strfind(exp.baseDir, '/code');
exp.dataDir = sprintf('%sdata', exp.baseDir(1:i));

% Grab the subversion information now.  We'll add it the 'params' variable
% later.  We do it here just in case we get an error with function which
% would cause the program to terminate.  If we did it after the experiment
% finished, we would get an error prior to saving, thus losing collected
% data.
svnInfo.(sprintf('%sSVNInfo', exp.mFileName)) = GetSVNInfo(exp.baseDir);
svnInfo.toolboxSVNInfo = GetBrainardLabStandardToolboxesSVNInfo;

exp.protocolName = 'MTLocalizer';
exp.subject = subjID;

exp.protocolDir = fullfile(exp.dataDir, exp.protocolName)
if ~isdir(exp.protocolDir)
    mkdir(exp.protocolDir);
end

exp.subjectDataDir = fullfile(exp.dataDir, exp.protocolName, exp.subject);
if ~isdir(exp.subjectDataDir)
    mkdir(exp.subjectDataDir);
end

exp.saveFileName = [exp.subject '-' exp.protocolName '-' num2str(runID)];

% List of available dot coherences.
params.dotCoherences = [1];

% List of available dot lifetimes.
params.dotLifetimes = [100];

% Indices into the coherence and lifetime arrays which select state of the
% dot patch currently being shown.
params.coherenceIndex = 1;
params.lifetimeIndex = 1;

% Toggles up/down or left/right coherent motion.  0 = left/right, 1 =
% up/down.
params.HorV = 0;

% Initialize the keyboard queue.
ListenChar(2);
mglGetKeyEvent;

% Create the dot patch and open the GLWindow.
[win, dotPatchMoving, screenDims] = initDisplay(params);

moveParams.duration = 0.5;

blockLength = 15;
sequence = [1,0,1,1,0,0,0,1,0,0,0,1,1,1,0,1,0,0,0,1,1];
nBlocks = length(sequence);


%% Now, create the outer mask
% Create a logical image of a circle with specified
% diameter, center, and image size.
% First create the image.
imageSizeX = screenDims(1);
imageSizeY = screenDims(2);
[columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);
% Next create the circle in the image.
centerX = screenDims(1)/2;
centerY = screenDims(2)/2;
radius = 200;
circlePixels = (rowsInImage - centerY).^2 ...
    + (columnsInImage - centerX).^2 <= radius.^2;

theImage = zeros(imageSizeY, imageSizeX, 4);
theImage(:, :, 4) = ~circlePixels;

win.addImage([0 0], [screenDims(1) screenDims(2)], theImage, 'Name', 'outerCircle');

% add fixation point
win.addOval([0 0], [10 10], [1 0 0], 'Name', 'fixationPoint');
win.enableObject('fixationPoint');
win.draw;
win.draw;

% Show the dots until aborted.
theFactor = 5;
theRange = [theFactor*ones(1, 10) -theFactor*ones(1, 10)];

moveParams.polarity = 1;

try
    %% Code to wait for 't' -- the go-signal from the scanner
    triggerReceived = false;
    while ~triggerReceived
        key = mglGetKeyEvent;
        % If a key was pressed, get the key and exit.
        if ~isempty(key)
            keyPress = key.charCode;
            if (strcmp(keyPress,'t'))
                triggerReceived = true;
                fprintf('  * t received.\n');
                tBlockStart = mglGetSecs;
            end
        end
    end
    
    % Flush our keyboard queue.
    mglGetKeyEvent;
    
    % Stop receiving t
    fprintf('- Starting trials.\n');
    tBlocStart = mglGetSecs;
    
    for b = 1:nBlocks
        events(b).val = sequence(b);
        fprintf('* Start trial %i/%i.\n', b, nBlocks);
        events(b).tTrialStart = mglGetSecs;
        tic;
        switch sequence(b);
            case 0
                win.enableObject('dotPatchMoving');
                keepGoing = true;
                startTime = mglGetSecs;
                dotPatchMoving.Direction = randi(360, 1);
                while keepGoing
                    
                    moveParams.val = i;
                    %dotPatchMoving = dotPatchMoving.move(moveParams);
                    dotPatchMoving = dotPatchMoving.static_coherent(0.5);
                    win.setObjectProperty('dotPatchMoving', 'DotPositions', dotPatchMoving.Dots);
                    %win.enableObject('innerCircle');
                    win.enableObject('outerCircle');
                    win.enableObject('fixationPoint');
                    win.draw;
                    nowTime = mglGetSecs;
                    if nowTime-startTime >= blockLength-0.005;
                        keepGoing = false; win.disableObject('dotPatchMoving');; break;
                    end
                    
                end
            case 1
                win.enableObject('dotPatchMoving');
                keepGoing = true;
                startTime = mglGetSecs;
                dotPatchMoving.Direction = randi(360, 1);
                while keepGoing
                    moveParams.val = i;
                    %dotPatchMoving = dotPatchMoving.move(moveParams);
                    dotPatchMoving = dotPatchMoving.move_coherent(0.5);
                    win.setObjectProperty('dotPatchMoving', 'DotPositions', dotPatchMoving.Dots);
                    %win.enableObject('innerCircle');
                    win.enableObject('outerCircle');
                    win.enableObject('fixationPoint');
                    win.draw;
                    nowTime = mglGetSecs;
                    if nowTime-startTime >= blockLength-0.005;
                        keepGoing = false; win.disableObject('dotPatchMoving');; break;
                    end
                    
                end
        end
        events(b).tTrialEnd = mglGetSecs;
        toc;
    end
    tBlockEnd = mglGetSecs;
    
    disp(['Total time: ' num2str(tBlockEnd-tBlockStart)]);
    
    ListenChar(0);
    win.close;
    
    responseStruct.tBlockStart = tBlockStart;
    responseStruct.tBlockEnd = tBlockEnd;
    params.events = events;
    
    if isfile(fullfile(exp.subjectDataDir, [exp.saveFileName '.mat']))
        save(fullfile(exp.subjectDataDir, [exp.saveFileName '-tmp-' num2str(randi(1000))]), 'params', 'exp', 'svnInfo');
        fprintf('- Data saved to %s (alternative file)\n', exp.saveFileName);
    else
        save(fullfile(exp.subjectDataDir, exp.saveFileName), 'params', 'exp', 'svnInfo');
        fprintf('- Data saved to %s\n', exp.saveFileName);
    end
    
    clear all; close all;
    clear all; close all
catch e
    ListenChar(0);
    win.close;
    rethrow(e);
end


function [win, dotPatchMoving, screenDims] = initDisplay(params)
% Basic initialization
ClockRandSeed;

% Choose the last attached screen as our target screen, and figure out its
% screen dimensions in pixels.
d = mglDescribeDisplays;
screenDims = d(end).screenSizePixel;

close all;
% Open the window.
win = GLWindow('SceneDimensions', screenDims);
win.open;
win.open;
win.draw;


% Convert the patch coherence value into something usable with
% DotPatch.
[coherence, direction] = ConvertCoherence(params.dotCoherences(params.coherenceIndex), ...
    params.HorV);

% Create the Moving patch.
numDots = 500;
center = [0 0];
patchDims = [500 500];
dotVelocity = 7;
dotPatchMoving = DotPatch(numDots, center, patchDims, 'Velocity', dotVelocity, ...
    'Coherence', coherence, 'Direction', direction, 'LifeTime', ...
    params.dotLifetimes(params.lifetimeIndex));

% Add the patch to the GLWindow.
dotRGB = [1 1 1];
dotSize = 5;
win.addDotSet(dotPatchMoving.Dots, dotRGB, dotSize, 'Name', 'dotPatchMoving');
win.disableObject('dotPatchMoving');

