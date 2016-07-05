function obj = move(obj, params)
% move - Updates the position of the dots.
%
% Syntax:
% obj = obj.move(params.params.duration)
%
% Description:
% Updates the position of the dots on the patch based on the dot
% velocities, current positions, direction, and the specified params.params.duration.
%
% Input:
% params.params.duration (scalar) - The params.params.duration the dots should move.
%
% Output:
% obj (DotPatch) - The updated DotPatch object with the new dot positions.




if obj.NumCoherentDots >= 1
	% Update the lifetime tracker.
	obj.CoherentDotTimes = obj.CoherentDotTimes + params.duration;
	
	% Look for dots whose lifetime has been exceeded.
	dl = obj.CoherentDotTimes > obj.LifeTime;
	numReborn = sum(dl);
	
	% Wrap the dead dot lifetime clocks around to reset them.
	obj.CoherentDotTimes(dl) = obj.CoherentDotTimes(dl) - obj.LifeTime;
	
	% Randomize the position of the reborn dots.
	for i = 1:2
		obj.CoherentDots(dl,i) = rand(numReborn, 1) * obj.PatchDims(i);
	end
	
	% Calculate the component distant moved for our coherent dots.
	componentDist = obj.ComponentVelocity * params.duration;

	% Calculate the component distant moved for our coherent dots.
	componentDist = params.val;
	
	% Add this to our coherent dot positions.
	for i = 1:2
		%obj.CoherentDots(:,i) = obj.CoherentDots(:,i) + componentDist(i);
    end

    theX = obj.CoherentDots(:,1)-obj.PatchDims(1)/2;
    theY = obj.CoherentDots(:,2)-obj.PatchDims(2)/2;
    [theta,rho] = cart2pol(theX, theY);

    [theNewX,theNewY] = pol2cart(theta,rho+params.polarity*componentDist+unifrnd(-1, 1));
    
    obj.CoherentDots(:,1) = theNewX+obj.PatchDims(1)/2;
    obj.CoherentDots(:,2) = theNewY+obj.PatchDims(1)/2;
 
end
    
end