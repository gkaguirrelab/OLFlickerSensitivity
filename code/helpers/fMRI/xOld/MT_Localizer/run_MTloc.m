% MT Localizer
%
%159 TRs (2s TR)

PsychJavaTrouble;

%% Screen setup
subject = input('Subject: ','s');
global GL;
AssertOpenGL;
screenid = max(Screen('Screens')); % Choose screen with maximum id - the secondary display:
white = WhiteIndex(screenid);
black = BlackIndex(screenid);
grey = ceil((white+black)/2);
[win winRect]= Screen('OpenWindow', screenid, grey);
ifi = Screen('GetFlipInterval', win);
[tw, th] = Screen('WindowSize', win);

%% Parameter setup

% Scanning Parameters
TR = 3;
initFixation = 32;            % in seconds
postFixation = initFixation;
triggerKey = 't';
% Session Parameters
blockDur = 32;               % should be a multiple of osc
% createBlockOrderMTloc;
blockOrder = [2 3 2 3 2 3 2 3 2 3 2 3 2 3 2 3 2 3 2 3 2 3 2 3 2 3 2 3];

ibi = .5;                    % wait between blocks in seconds 
% (very rough) setting of oscillation frequency
osc = .8;                    % Oscillating in seconds
% Parameters for moving stripes
ringWidth = 64;
shift = 8;                  % in pixels per frame
innerRadius = 96;           % in pixels
degWidth = (40/360)*2*3.1415926536;     % width of stripes in radians

% FixationCross
xSize = [4 16];
fixCol = white;
% Task
cDecMin = 4;                % min time between two contrast Decrements
cDecMax = 8;                % max time    
cDecCol = grey+10;          % Color of low contrast flash

nframes     = floor((blockDur-ibi)/ifi); % number of animation frames in loop
mon_width   = 39;   % horizontal dimension of viewable screen (cm)
v_dist      = 60;   % viewing distance (cm)
dot_speed   = 7;    % dot speed (deg/sec)
ndots       = 500; % number of dots
max_d       = 15;   % maximum radius of  annulus (degrees)
min_d       = 1;    % minumum
dot_w       = 0.6;  % width of dot (deg)
fix_r       = 0.15; % radius of fixation point (deg)
f_kill      = 0.05; % fraction of dots to kill each frame (limited lifetime)    
differentcolors = 1; % Use a different color for each point if == 1. Use common color white if == 0.
differentsizes = 0; % Use different sizes for each point if >= 1. Use one common size if == 0.
waitframes = 1;     % Show new dot-images at each waitframes'th monitor refresh.

ppd = pi * (winRect(3)-winRect(1)) / atan(mon_width/v_dist/2) / 360;    % pixels per degree
pfs = dot_speed * ppd / (1/ifi);                            % dot speed (pixels/frame)
s = dot_w * ppd;                                        % dot size (pixels)
fix_cord = [[tw/2 th/2]-fix_r*ppd [tw/2 th/2]+fix_r*ppd];

%% Stimulus Preparation and Other Parameters
% set AlphaBlending
Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);


% Other Params / Counters
shiftvalue = 0;
count = 0;
keyIsDown = 0;
keyCode = zeros(1,256);
cFlag = 0;
result = [];
HideCursor;
FlushEvents;

%% Experiment loop

Screen('FillOval', win, uint8(white), fix_cord);	% draw fixation dot (flip erases it)

%Wait for first trigger
disp('Waiting for first trigger.\n');
GetChar;
vbl = Screen('Flip', win, 0, 1);
startTime = vbl;

% wait for initFixation
vbl = Screen('Flip', win, startTime + initFixation - ifi/2);

%trialNum = 1;
%trialDur = 0;

for block = 1 : length(blockOrder)
    trialDur = GetSecs();
    trialStartTime = vbl - startTime;
    %decode trialType
    switch blockOrder(block)
        case 1  % Fixation
        case 2
            show_MTloc_dirchange;
        case 3
            show_statDot;
    end
    Screen('FillOval', win, uint8(white), fix_cord);	% draw fixation dot (flip erases it)
    vbl = Screen('Flip', win);
    Screen('FillOval', win, uint8(white), fix_cord);	% draw fixation dot (flip erases it)
    vbl = Screen('Flip', win, startTime+trialStartTime + blockDur - ifi/2);
    
    %display(['This is trial number ' num2str(trialNum)]);
    %display(['This trial lasted ' num2str(getSecs()-trialDur) ' seconds']);
    %trialNum = trialNum+1;
end

% postFixation
WaitSecs(postFixation);    

save(subject)    

Screen('CloseAll');
    
    