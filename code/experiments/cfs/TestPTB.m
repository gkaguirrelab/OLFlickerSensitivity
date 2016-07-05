clear all;
bgColor = [0.65 0.65 0.65];
nMasks = 20;
nX = 400;
nY = nX;

try
    commandwindow;
    
    mondrianMasks = make_mondrian_masks(nX,nY,nMasks,1,1)
    
    myimgfile='example.jpg';
    nr=max(Screen('Screens'));
    Screen('Preference', 'SkipSyncTests', 1); 
    [w, screenRect]=Screen('OpenWindow',nr, 0,[],32,2); % open screen
    
    while true
        randNow = randi(nMasks);
        Screen('PutImage', w, mondrianMasks{randNow}); % put image on screen
        Screen('Flip',w); % now visible on screen
    end
    Screen('CloseAll'); % close screen
catch
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    Screen('CloseAll');
    rethrow(lasterror);
end %try..catch..
