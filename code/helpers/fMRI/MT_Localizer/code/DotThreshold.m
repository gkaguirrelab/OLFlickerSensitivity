function DotThreshold
% DotThreshold - Program to measure psychometric function for direction of dot movement.
%
% Syntax:
% DotThreshold
%
% Description:
% Program to measure psychometric function for direction of dot movement.
% The program uses the method of constant stimuli.
%
% The program also allows one to play "adapting" dots in between the trials.
% This can be used to measure a motion aftereffect, which will show up as
% a shift of the psychometric function.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% EXPERIMENTAL PARAMETERS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Test parameteters.  These determine the properties of the test stimuli.
%
% The list dotCoherence determines what dot
% coherences you will be tested on.  The numbers must be between
% -1 and 1.  Negative numbers move to left/down, positive numbers move
% to the right/up depending on the value of the HOrV field.
%
% Note that when dots reach the edge of their rectangle, they wrap 
% around.
params.test.dotCoherence = [-1 -0.6 -0.3 -0.15, 0 0.15 0.3 0.6 1];
params.test.nDots = 150;				% Number of test dots
params.test.rectSize = [250 250];		% (width,height) of test dot array rectangle in pixels.
params.test.dotSize = 5;				% Size of test dots in pixels.
params.test.dotSpeed = 250;				% Dot movement speed in pixels/second.
params.test.HorV = 0;					% Direction of dot motion, 0=left/right, 1=up/down
params.test.lifetime = 0.1;				% Lifetime of the dots in seconds (Inf for forever).
params.test.bgRGB = [0 0 0];			% Background color for the test dots.
params.test.dotRGB = [1 1 1];			% Dots RGB

% Adaptation parameters.  You can have some dots playing at the beginning of the
% experiment, and between trials.  The parameters below determine the properties
% of these dots.  If you don't want any to be there, set the number of adapter
% dots to be 0.
%
% The adaptor dot correlation determines how strong the net motion of the adapting stimulus is.
% The number must between  -1 and 1.  Negative numbers move to the left, positive numbers moveDot
% to the right (when adaptHOrV = 0).
params.adapt.dotCoherence = 0.0;		% Adapter dot dotCoherence.
params.adapt.nDots = 0;                 % Number of adapter dots.  0 -> means no adapter
params.adapt.rectSize = [500 500];		% (width,height) of adapter dot array rectangle in pixels.
params.adapt.dotSize = 5;				% Size of adapter dots in pixels.
params.adapt.dotSpeed = 250;			% Dot movement speed in pixels/second.
params.adapt.HorV = 1;					% Direction of dot motion, 0=left/right, 1=up/down
params.adapt.lifetime = 0.1;			% Lifetime of the dots in seconds (Inf for forever).
params.adapt.bgRGB = [0 0 0];			% Background RGB for the adapter dots.
params.adapt.dotRGB = [1 1 1];			% Dots RGB

% Experimental parameters.
params.nBlocks = 2;                     % Number of blocks
params.trialDuration = 0.5;				% Trial duration (seconds)
params.initialAdaptTime = 1;			% Time for initial adaptation (seconds)
params.topupAdaptTime = 0.3;			% Top-up adapt time. (seconds)
params.enableFeedback = 1;				% Enable/disable trial feedback
                                        %   0 -> no feedback
                                        %   1 -> feedback on direction
                                        %   2 -> feedback on motion vs non-motion
params.feedbackDuration = 0.3;			% Duration of feedback (seconds)
params.iti = 0.5;						% Inter-trial interval (seconds)

% Fixation point
params.fpSize = 4;                      % Fixation point size in pixels (0 -> no fixation point)
params.fpColor = [0 1 0];               % Fixation point RGB

% Key mappings
params.leftKey = {'d' '1'};             % Keys accepted for left/up/absent response
params.rightKey = {'k' '2'};            % Keys accepted for right/down/present response

params.experimenter = 'dummy';          % Experimenter
params.subject = 'subject1';            % Name of the subject.
params.experimentName = 'DotThreshold'; % Root name of the experiment and data file.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Call the driver.
DotThresholdDrvr(params);
