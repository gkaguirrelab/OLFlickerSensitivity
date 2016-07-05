function [win, adaptPatch, testPatch] = OpenEXPWindow(params)
% OpenEXPWindow - Open the experimental window and create the dot patches.
%
% Syntax:
% win = OpenEXPWindow(params)
%
% Input:
% params (struct) - Experimental parameters struct.
%
% Output:
% win (GLWindow) - GLWindow object that represents the experimental window.

% Basic initialization
ClockRandSeed;

% Choose the last attached screen as our target screen, and figure out its
% screen dimensions in pixels.
d = mglDescribeDisplays;
screenDims = d(end).screenSizePixel;

% Open the window.
win = GLWindow('SceneDimensions', screenDims);
win.open;
win.draw;

% Conver the adapth patch coherence value into something usable with
% DotPatch.
[coherence, direction] = ConvertCoherence(params.adapt.dotCoherence(1), ...
	params.adapt.HorV);

% Create the adapt patch.
adaptPatch = DotPatch(params.adapt.nDots, [0 0], params.adapt.rectSize, ...
	'LifeTime', params.adapt.lifetime, 'Coherence', coherence, ...
	'Velocity', params.adapt.dotSpeed, 'Direction', direction);

% Create the test patch.  The coherence and direction values will be set
% each trial of the experiment.
testPatch = DotPatch(params.test.nDots, [0 0], params.test.rectSize, ...
	'LifeTime', params.test.lifetime, 'Velocity', params.test.dotSpeed);

% Add the patches to the GLWindow.
win.addDotSet(adaptPatch.Dots, params.adapt.dotRGB, params.adapt.dotSize, ...
	'Name', 'adaptPatch');
win.addDotSet(testPatch.Dots, params.test.dotRGB, params.test.dotSize, ...
	'Name', 'testPatch');

% Add the feedback text.  Place it just over the top of the adapation
% patch.
win.addText('Correct', 'Name', 'correctText', 'Center', [0 params.adapt.rectSize(2)/2+100], ...
	'FontSize', 80, 'Color', [0 1 0]);
win.addText('Incorrect', 'Name', 'incorrectText', 'Center', [0 params.adapt.rectSize(2)/2+100], ...
	'FontSize', 80, 'Color', [1 0 0]);

% Add the start text
win.addText('Hit Any Key To Start', 'Name', 'startText', 'Center', [0 params.adapt.rectSize(2)/2+100], ...
	'FontSize', 80, 'Color', [1 1 1]);

% Add a fixation point
if (params.fpSize > 0)
    win.addOval([0 0], [params.fpSize params.fpSize], params.fpColor, 'Name', 'fp');
end

% Don't show the patches initially.
win.disableAllObjects;
