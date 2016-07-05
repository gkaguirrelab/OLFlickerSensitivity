function DotThresholdDrvr(params)
% DotThresholdDrvr - Driver program for motion aftereffect experiment.
%
% Syntax:
% DotThresholdDrvr(params)

error(nargchk(1, 1, nargin));

% Make sure we have a positive number of test dots.
if params.test.nDots <= 0
	error('Number of test dots must be >= 0.');
end

% Convenience parameters
nTests = size(params.test.dotCoherence, 2);	% Number of test correlations

% Setup the response data.  This will store all the responses.
responseData = zeros(nTests, params.nBlocks);

% Get the keyboard listener ready.
mglGetKeyEvent;

% Open the experimental window and create the dot patch objects.
[win, adaptPatch, testPatch] = OpenEXPWindow(params);
if (params.fpSize > 0)
    win.enableObject('fp');
end

% Eat up keyboard input.
ListenChar(2);

try	
	% Clear out any previous keypresses.
	FlushEvents;
	
	% Show the adaptation dots and wait for a keypress to start.
    win.enableObject('startText');
	win.BackgroundColor = params.adapt.bgRGB;
	win.enableObject('adaptPatch');
	win.draw;
	
	% This will block until a key is pressed.
	FlushEvents;
	GetChar;
    win.disableObject('startText');

	% Do the initial dot adaptation.
	adaptPatch = MoveTheDots(win, params, 'adaptPatch', adaptPatch, params.initialAdaptTime);
	
	% Turn the adapt dots off.
	win.disableObject('adaptPatch');
	win.draw;
	
	% Now run the trials.
	for i = 1:params.nBlocks
		trialOrder = Shuffle(1:nTests);
		
		for j = 1:nTests
			% Explicit trial index
			index = trialOrder(j);
			
			% Set some parameters for the test patch for this trial.
			win.BackgroundColor = params.test.bgRGB;
			[testPatch.Coherence, testPatch.Direction] = ...
				ConvertCoherence(params.test.dotCoherence(index), params.test.HorV);
			
			% Show the test dots.
			win.enableObject('testPatch');
			testPatch = MoveTheDots(win, params, 'testPatch', testPatch, params.trialDuration);
			win.disableObject('testPatch');
			
			% If there are no adapter dots, don't bother showing them.
			if params.adapt.nDots > 0
				win.enableObject('adaptPatch');
			end
			
			% Top-up adaptation.  Adaption dots are show a minimum
			% amount of time and proceed forever until a response is given.
			win.BackgroundColor = params.adapt.bgRGB;
			[adaptPatch, response] = MoveTheDots(win, params, 'adaptPatch', adaptPatch, ...
				params.topupAdaptTime, true);
			
			% Show the feedback if enabled.
            %
            % Feedback parameter of 1 means give feedback on direction
			if params.enableFeedback == 1
				% Stick our trial coherence and the response in an array.
				m = [params.test.dotCoherence(index), response];
				
				% Trials where both values are of the same polarity implies
				% correct trials.  But, need to special case when coherence
                % is 0, since there is no right answer for such trials.  We
                % say correct with probability 0.5 on trials where coherence
                % is 0.
                if (params.test.dotCoherence(index) == 0)
                    if (CoinFlip(1,0.5))
                        textTag = 'correctText';
                    else
                        textTag = 'incorrectText';
                    end
                else
                    if all(m < 0) || all(m > 0)
                        textTag = 'correctText';
                    else
                        textTag = 'incorrectText';
                    end
                end
				
				% Enable the appropriate feedback text.
				win.enableObject(textTag);
				
				% Move the adapation dots for the feedback duration.
				adaptPatch = MoveTheDots(win, params, 'adaptPatch', adaptPatch, ...
					params.feedbackDuration);
				
				% Turn off the feedback text.
				win.disableObject(textTag);
            
            % Feedback parameter of 2 measn give feedback on absence/presence
            % of motion
            elseif params.enableFeedback == 2
                if (params.test.dotCoherence(index) == 0 & response == -1)
                    textTag = 'correctText';
                elseif (params.test.dotCoherence(index) ~= 0 & response == 1)
                    textTag = 'correctText';
                else
                    textTag = 'incorrectText';
                end
                
                % Enable the appropriate feedback text.
				win.enableObject(textTag);
				
				% Move the adapation dots for the feedback duration.
				adaptPatch = MoveTheDots(win, params, 'adaptPatch', adaptPatch, ...
					params.feedbackDuration);
				
				% Turn off the feedback text.
				win.disableObject(textTag);      
            end
			
			% Now do the iti.
			if params.iti > 0
				adaptPatch = MoveTheDots(win, params, 'adaptPatch', adaptPatch, params.iti);
			end
		
			% Turn off the adapation patch.
			win.disableObject('adaptPatch');
				
			% Store the response.
			responseData(index, i) = response;
		end
	end
	
	% Close everything down.
	ListenChar(0);
	win.close;
	
	% Figure out some data saving parameters.
	dataFolder = sprintf('%s/data/%s/%s/%s', fileparts(fileparts(which('DotThreshold'))), ...
		params.experimenter, params.experimentName, params.subject);
	if ~exist(dataFolder, 'dir')
		mkdir(dataFolder);
	end
	dataFile = sprintf('%s/%s-%d.csv', dataFolder, params.experimentName, GetNextDataFileNumber(dataFolder, '.csv'));
	
	% Stick the data into a CSV file in the data folder..
	c = CSVFile(dataFile, true);
	c = c.addColumn('Coherence', 'g');
	c = c.setColumnData('Coherence', params.test.dotCoherence');
	for i = 1:params.nBlocks
		cName = sprintf('Response %d', i);
		c = c.addColumn(cName, 'd');
		c = c.setColumnData(cName, responseData(:,i));
	end
	c.write;
	
catch e
	ListenChar(0);
	win.close;
	
	if strcmp(e.message, 'abort')
		fprintf('- Experiment aborted, nothing saved.\n');
	else
		rethrow(e);
	end
end
