function checkForTimingGlitch(seconds)
    global MGL
    
    backgroundColor = [0.5 0.5 0.5];
    mglClearScreen(backgroundColor);
  
    % add a fixation cross
    lineWidth = 4.0;
    color     = [1 1 0];
    width     = 12.0;   % In visual angles
    origin    = [0,0];  % In visual angles (0,0) is at the center of the screen
    mglFixationCross(width, lineWidth, color, origin);
    
    % Display message about what is happening
    fontName = 'Helvetica';
    fontSize = 32;
    fontColor = [0 0 1];
    fontVerticalFlip = false;
    fontHorizontalFlip = false;
    fontRotation = 0;
    fontBold = false;
    fontItalic = false;
    fontUnderline = true;
    fontStrikeThrough = false;
    mglTextSet('Helvetica', fontSize, fontColor,fontVerticalFlip,fontHorizontalFlip,fontRotation,fontBold,fontItalic,fontUnderline ,fontStrikeThrough);
    mglTextDraw('Checking for timing glitches. The screen will flash for several seconds',[0 -7]);
    mglFlush();

   
    checksNum = seconds*MGL.frameRate;
    intervals = zeros(1,checksNum); 
    mglFlush;
    
    for k = 1:checksNum
        flushStart = mglGetSecs;
        mglFlush;
        intervals(k) = mglGetSecs(flushStart);
    end 
    
    mglClearScreen(backgroundColor);
    mglFlush;
    
    intervalsInMsec = intervals(2:end)*1000;
    
    figure(1);
    clf;
    plot((1:length(intervalsInMsec))/MGL.frameRate, intervalsInMsec, 'ks', 'MarkerFaceColor',[1.0 0.0 0.1]);
    hold on;
    plot([1 length(intervalsInMsec)]/MGL.frameRate, min(intervalsInMsec)*[1 1], 'k:');
    plot([1 length(intervalsInMsec)]/MGL.frameRate, max(intervalsInMsec)*[1 1], 'k:');
    set(gca, 'YLim', [round(min(intervalsInMsec)-5) round(max(intervalsInMsec)+5)]);
    xlabel('Time (seconds)', 'FontSize', 12, 'FontName', 'Helvetica');
    ylabel('Frame refresh interval (msec)', 'FontSize', 12, 'FontName', 'Helvetica');
    title('Timing Glitch Analysis');
    zoom on;
    
end
