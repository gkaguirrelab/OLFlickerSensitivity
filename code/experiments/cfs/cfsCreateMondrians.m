% Clear the workspace
close all;
clear all;
% Screen('Close');

nMasks = 30;

% Here we call some default settings for setting up Psychtoolbox
% PsychDefaultSetup(2);
% Screen('Preference', 'SkipSyncTests', 1);
% 
% % Get the screen numbers
% screens = Screen('Screens');
% 
% % Draw to the external screen if avaliable
% screenNumber = max(screens);


% Open an on screen window
%[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Get the size of the on screen window
screenYpixels = 1080; screenXpixels = 1920;
%[screenXpixels, screenYpixels] = Screen('WindowSize', window);
mondrianMasks = make_mondrian_masks(screenXpixels,screenYpixels,nMasks,1,3);

%% Create anti-image
% For every image, create anti-image
mirrorMask = 0.5*ones(screenYpixels, screenXpixels,3);
for i = 1:nMasks
    mondrianMasks{i+nMasks} = (mirrorMask - (mondrianMasks{i} - mirrorMask));
end

%% Convert to device settings
% Load calibration filemondrianMasks = make_mondrian_masks(screenXpixels,screenYpixels,nMasks,1,1);
cal = LoadCalFile('ViewSonicCFS');
gammaInversionMethod = 0;
cal = SetGammaMethod(cal, gammaInversionMethod);


for i = 1:nMasks*2
            tmp0 = permute(mondrianMasks{i}, [3 1 2]);
            tmp0 = tmp0(:, :);
            tmp1 = PrimaryToSettings(cal, tmp0);
            tmp{i} = reshape(tmp1', screenYpixels, screenXpixels, 3);
end

% Save out
save('cfsCachedMasks.mat', 'mondrianMasks', '-v7.3');

% Clear the screen
%sca;