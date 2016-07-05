function driftingGrating
% Demo MGL code for animation of a drifting Gabor.
%
% The code first does a simple test to check for glitches in the screen refresh. 
% Then it generates a sequence of Gabors with increasing spatial phase
% and animates it using texture blitting. A fixation cross is also displayed 
% at the center of the screen. Custom gamma tables are loaded. 
% At the end of the run, the original gamm table is restored and the the inter-stimulus 
% intervals are plotted to check for any glitches during the stimulus animation.
%
%
% 4/13/2013  npc  Wrote it.
% 4/14/2013  npc  Added code to load custom gamma tables 
%                 Added code to present info message to subject
%
    clear all; clear global;
    
    % OpenGL constants in the Matlab environment.
    global GL;
    
    % MGL constants
    global MGL;
    
    try
        % Initialize the OpenGL for Matlab wrapper 'mogl'.
        InitializeMatlabOpenGL;
         
        % get info about the attached displays
        displaySpecs = mglDescribeDisplays;

        % and report back what we found
        fprintf('Found %d displays.\n', length(displaySpecs))
        stimulationDisplay = length(displaySpecs);  % last attached display;
        fprintf('Will render in display #%d\n',  stimulationDisplay);

%         fprintf('Will check system for timing glitch\n');
%         fprintf('You will see a flashing yellow cross for several seconds\n');
%         fprintf('Hit enter to continue\n');
%         pause;

        screenWidth  = displaySpecs(stimulationDisplay).screenSizePixel(1);
        screenHeight = displaySpecs(stimulationDisplay).screenSizePixel(2);

        % Open a full-screen MGL window
        mglOpen(stimulationDisplay, screenWidth, screenHeight);

        % Use visual degree coordinates
        screenDistanceInCm = 57;
        screenWidthInCm    = displaySpecs(stimulationDisplay).screenSizeMM(1)/10.0;
        screenHeightInCm   = displaySpecs(stimulationDisplay).screenSizeMM(2)/10.0;
        mglVisualAngleCoordinates(screenDistanceInCm, [screenWidthInCm screenHeightInCm]);

        % Check for timing glitch for 2 seconds
%         checkForTimingGlitch(2);

      
    % Load custom display gamma tables (one for each channel)
  redGamma   = 0.8;
  greenGamma = 0.9;
  blueGamma  = 0.7;
  gammaTable(:,1) = (0:1/255:1).^redGamma;
  gammaTable(:,2) = (0:1/255:1).^greenGamma;
  gammaTable(:,3) = (0:1/255:1).^blueGamma;
  mglSetGammaTable(gammaTable);

        % Hide the mouse cursor
        mglDisplayCursor(0);
        
        % Generate info text for subject
        fontName = 'Helvetica';
        fontSize = 48;
        fontColor = [0 1 0];
        fontVerticalFlip = false;
        fontHorizontalFlip = false;
        fontRotation = 0;
        fontBold = false;
        fontItalic = false;
        fontUnderline = true;
        fontStrikeThrough = false;
        mglTextSet('Helvetica', fontSize, fontColor,fontVerticalFlip,fontHorizontalFlip,fontRotation,fontBold,fontItalic,fontUnderline ,fontStrikeThrough);
        
        % Fixation cross specs
        lineWidth = 5;  color = [1 0 0];
        width           = 1.5;   % In visual angles
        origin          = [0,0];  % In visual angles (0,0) is at the center of the screen
        
        % Show message to subject
        backgroundColor = [127 127 127]/255;
        mglClearScreen(backgroundColor);
        mglFixationCross(width, lineWidth, color, origin);
        mglTextDraw('The experiment is about to begin.',[0 -7]);
        mglFlush;
        
        
        fprintf('\nGenerating Gabor tetures...');
        % Generate Gabor textures
        
        tto = [ 0:45:180 0:45:180];
        finalorient = tto(randperm(length(tto))); clear tto
        
        
        for cor = 1:length(finalorient)  
           pixelSize = 500; contrast = 0.75; sf = 8; sigma = 0.1; orientation = finalorient(cor); phasesNum = 18;
            for phaseIndex = 0:phasesNum-1
                phase = phaseIndex * 2 * pi / phasesNum;
                image = 127.5 + 127.5 * createGabor(pixelSize,contrast,sf,orientation,phase,sigma); 
                iTex{cor}( phaseIndex+1) = mglCreateTexture(image);
            end
        end


%         
%         fprintf('... Done !\n');
        
        disp('Waiting for start t');
        
        % Save the existing gamma table (for restoration at the conclusion
        % of the experiment)
        originalGammaTable = mglGetGammaTable;
          
        
        
        
        ListenChar(2);
         
         
         waiter = 0;
         
         while waiter==0
             key = mglGetKeyEvent;
             if (~isempty(key))
                 if (key.charCode == 't')
                                  waiter=1;
                                  break;
                 end
             end             
         end
             
        
        
        
        stims = dlmread('blockstim.txt');
        %stims = [ 0 1 ]; % Short for debugging
        timeblk = zeros(size(stims));
        
        % Animation loop
        alltime = GetSecs;

        for tblock = 1:length(stims)
        
        inputstim = stims(tblock); 

        expectedtime = 30*(tblock-1);
        buffertime =   (GetSecs - alltime) - expectedtime;
        Gbreak= 0;
        
            switch inputstim    


                case 0

                    t1 = GetSecs;
                     
                    while (GetSecs-t1) < 29.95
                             
                            key = mglGetKeyEvent;
                            if (~isempty(key))
                               if (key.charCode == 'q')
                                   Gbreak = 99;
                                   break;
%                                elseif GetSecs - stopwatchtime  < .5
%                                   response = response + 1
                               end
                            end
                        
                             mglClearScreen(backgroundColor);  
                             if mod(round((GetSecs-t1)*10),23),color = [ 1 0 0]; else color = [1 1 0]; end
                             mglFixationCross(width, lineWidth, color, origin);
                             mglFlush;
                     
                    end
                    timeblock(tblock) = GetSecs-t1 ;

                otherwise

                    t1 = GetSecs;
                    
                    repeats = 10;
                    intervals = repeats*phasesNum;
                    intervalIndex = 1;
                    
                    for ots = 1:length(finalorient)

                        imageTexture = iTex{ots};

                            for k = 1:repeats

                                    for phaseIndex = 1:phasesNum
                                        flushStart = mglGetSecs;
                                        
                                                key = mglGetKeyEvent;
                                                if (~isempty(key))
                                                    if (key.charCode == 'q')
                                                        Gbreak = 99;
                                                        break;
 %                                                  elseif GetSecs - stopwatchtime  < .5
 %                                                  response = response + 1
                                                    end
                                                end
                                        
                                        mglClearScreen(backgroundColor);
                                        mglBltTexture(imageTexture(phaseIndex),inputstim*[7 0]);
                                         if mod(round((GetSecs-t1)*10),23),color = [ 1 0 0]; else color = [1 1 0]; end
                                        mglFixationCross(width, lineWidth, color, origin);
                                        mglFlush();
                                        intervals(intervalIndex) = mglGetSecs(flushStart); 
                                        intervalIndex = intervalIndex + 1;

                                        if GetSecs-t1 > 29.95 - buffertime
                                           break
                                        end

                                    end

                            end

                    end
                    
                    timeblock(tblock) = GetSecs-t1 ;
                     
            end
            
            if  Gbreak == 99, break; end
           
        end
  
        
      timeblock
        
        ListenChar(0);
        
%         pause(1);

        % cleanup

        % delete textures
        for phaseIndex = 1:phasesNum
            mglDeleteTexture(imageTexture(phaseIndex));
        end

        % Restore original gammma table
        mglSetGammaTable(originalGammaTable);
        
        % Unhide the mouse cursor
        mglDisplayCursor(1);
%         mglSetMousePosition(512, 512, 1);

        % Close all displays
        mglSwitchDisplay(-1);
        
        %Terminate keyboard and mouse event tap
        mglListener('quit');

        %Display refresh intervals to see if we missed a deadline
        figure(2);
        clf;
        intervalsInMsec = intervals*1000;
        plot((1:length(intervalsInMsec))/MGL.frameRate, intervalsInMsec, 'ks', 'MarkerFaceColor',[1.0 0.0 0.1]);
        hold on;
        plot([1 length(intervalsInMsec)]/MGL.frameRate, (min(intervalsInMsec)-1)*[1 1], 'k:');
        plot([1 length(intervalsInMsec)]/MGL.frameRate, (max(intervalsInMsec)+1)*[1 1], 'k:');
        set(gca, 'YLim', [round(min(intervalsInMsec)-5) round(max(intervalsInMsec)+5)]);
        xlabel('Time (seconds)', 'FontSize', 12, 'FontName', 'Helvetica');
        ylabel('Frame refresh interval (msec)', 'FontSize', 12, 'FontName', 'Helvetica');
        title('Timing Glitch Analysis (during stimulus animation)');
        zoom on;
    
    % Error handler
    catch e
        if (isempty(MGL) == 0) 
            % Unhide the mouse cursor
            mglDisplayCursor(1);
%             mglSetMousePosition(512, 512, 1);
            
            % Close all displays
            mglSwitchDisplay(-1);
        end
        rethrow(e);
    end
end


function theGabor = createGabor(meshSize,contrast,sf,theta,phase,sigma)
%
% Input
%   meshSize: size of meshgrid (and ultimately size of image).
%       Must be an even integer
%   contrast: contrast on a 0-1 scale
%   sf: spatial frequency in cycles/image
%          cycles/pixel = sf/meshSize
%   theta: gabor orientation in degrees, clockwise relative to positive x axis.
%          theta = 0 means horizontal grating
%   phase: gabor phase in degrees.
%          phase = 0 means sin phase at center, 90 means cosine phase at center
%   sigma: standard deviation of the gaussian filter expressed as fraction of image
%
% Output
%   theGabor: the gabor patch as rgb primary (not gamma corrected) image

    % Create a mesh on which to compute the gabor
    if rem(meshSize,2) ~= 0
        error('meshSize must be an even integer');
    end
    res = [meshSize meshSize];
    xCenter=res(1)/2;
    yCenter=res(2)/2;
    [gab_x gab_y] = meshgrid(0:(res(1)-1), 0:(res(2)-1));

    % Compute the oriented sinusoidal grating
    a=cos(theta/180*pi);
    b=sin(theta/180*pi);
    sinWave=sin((2*pi/meshSize)*sf*(b*(gab_x - xCenter) - a*(gab_y - yCenter)) + phase);

    % Compute the Gaussian window
    x_factor=-1*(gab_x-xCenter).^2;
    y_factor=-1*(gab_y-yCenter).^2;
    varScale=2*(sigma*meshSize)^2;
    gaussianWindow = exp(x_factor/varScale+y_factor/varScale);

    % Compute gabor.  Numbers here run from -1 to 1.
    theGabor=gaussianWindow.*sinWave;

    % Convert to contrast
    theGabor = contrast*theGabor;

    % Convert single plane to rgb
    theGabor = repmat(theGabor,[1 1 3]);

end
