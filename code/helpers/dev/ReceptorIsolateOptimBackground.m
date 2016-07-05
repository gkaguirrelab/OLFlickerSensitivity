function [isolatingPrimary, backgroundPrimary] = ReceptorIsolateOptimBackground(T_receptors,whichReceptorsToIsolate,whichReceptorsToIgnore,whichReceptorsToMinimize,B_primary,backgroundPrimary,initialPrimary,whichPrimariesToPin,primaryHeadRoom,maxPowerDiff,desiredContrasts,ambientSpd)
% [isolatingPrimaries] = ReceptorIsolate(T_receptors,whichReceptorsToIsolate,whichReceptorsToIgnore,whichReceptorsToMinimize,B_primary,backgroundPrimary,initialPrimary,whichPrimariesToPin,primaryHeadRoom,maxPowerDiff,[desiredContrasts],[ambientSpd])
%
% Find the best isolating modulation around a given background.  This is a very general routine,
% with inputs as follows.
%
% T_receptors -             Spectral sensitivities of all receptors being considered, in standard PTB format.
% whichReceptorsToIsolate - Index vector specifying which receptors we want to modulate.
% whichReceptorsToIgnore -  Index vector specifying receptors where we don't care what they do. Can be the empty matrix.
%                           Why, you ask, might you want to do this?  Maybe if T_receptors contains the rods but you're
%                           working at high light levels.
% whichReceptorsToMinimize  Index vector specifying which receptors we want to minimize (i.e. not 0, but get close to it).
%                           This is a vestigal argument.  Receptors listed here are actually ignored, rather than minimized.
% B_primary -               These calculations are device dependent.  B_primary is a set of basis vectors for the lights
%                           that the device can produce, scaled so that the gamut is for the range [0-1] on each primary.
% backgroundPrimary -       Background around which modulation will occur, in primary space.
% initialPrimary -          There are cases in which we want to enforce specific values on certain primaries in the modulation spectra.
%                           This is done here. In most cases, this primary vector is the background but not necessarily.
% whichPrimariesToPin -     We can force some primaries not to be modulated.
%                           Why, you ask, might you want to do this?  We can't exactly remember now, but it isn't doing
%                           any harm to have the option.  Pass empty vector when you don't want to impose such a constraint.
% primaryHeadRoom -         If you don't want to modulate all the way to the edge of the device gamut, pass a number in the
%                           range [0-1] here.  This constrains the primary settings to be within [0+primaryHeadRoom,1-primaryHeadRoom].
%                           This can be useful for anticipating the fact that the device may get dimmer over time, so that the
%                           stimulus you compute at time 0 remains in gamut after a subsequent calibration.
% maxPowerDiff -            This enforces a smoothness constraint on the spectrum of the computed modulation.  You wouldn't
%                           use this for a device like a monitor, but for our OneLight device this prevents solutions that
%                           wiggle rapdily as a function of wavelength.  Our intuition is that such wiggly spectra are not
%                           as robust in their isolationg properties as smooth spectra.  Pass Inf to ignore.
% desiredContrasts -        Vector of target contrasts for receptors that will be isolated.  This is useful, for example,
%                           if you want to do something like produce a modulation with equal L and M cone contrasts with
%                           opposite signs while at the same time silencing the S cones.  This vector should have the same
%                           length as whichReceptorsToIsolate.  It can be the empty vector, in which case the routine maximizes
%                           the sum of the contrasts of the receptors in whichReceptorsToIsolate.
% ambientSpd -              Spectral power distribution of the ambient light.  Optional.  Defaults to zero.
%
% Contrast held at zero for any receptor classes not in the lists.
%
% Notes:
%   A) We don't pass the spectral sampling information, because this
%   routine does not need it.  The spectral sampling is assumed to match
%   across all spectral functions (receptor sensitivities, spectral
%   primaries, and ambientSpd), and the smoothness constraint is enforced in
%   wavelength sampling steps not absolute wavelength.
%
% Known Bugs:
%   A) It looks like the code that enforces gamut limitations in a manner that
%   handles backgrounds that do not correspond to device primary settings
%   of 0.5 only works just right if no primaries are being pinned.  There
%   is an error check at the end of the function which throws an error if
%   any of the primary values returned are outside the range [0-1], so our
%   motivation for thinking about this will only cross threshold if this
%   error ever gets thrown.
%
% 4/1/12   dhb      Wrote it.
% 11/15/12 dhb, ms  Remove upperVaryFactor arg.  Bound between 0 and 1-primaryHeadRoom.
% 12/4/12  ms       Fixed a bug in the optimization object, added case
%                   handling for smoothing spd or primaries.
% 4/19/13  dhb, ms  Added lots of comments.  Change behavior when desiredContrasts not passed, so as to maximize sum of contrasts
%                   of modulations, rather than sum of activations.
%          dhb      Change error function a little to avoid numerical issues.
% 8/27/13  ll       Fix minor typo in variable name
% 12/12/13 dhb      Clean up comments etc.

% Check whether the desired contrasts were passed, and if so check
% consistency of its dimensions.
if (nargin < 10)
    desiredContrasts = [];
end
if ~isempty(desiredContrasts)
    if length(whichReceptorsToIsolate) ~= length(desiredContrasts)
        error('Size of whichReceptorsToIsolate and of desired contrasts vector do not line up')
    end
end

%% Default for ambientSpd
if (nargin < 11 || isempty(ambientSpd))
    ambientSpd = zeros(size(B_primary,1),1);
end

%% Initial guess for modulation
x = [initialPrimary initialPrimary];

%% Figure out which receptors get zero modulation and set up constraint for this.
whichReceptorsToZero = setdiff(1:size(T_receptors,1),[whichReceptorsToIsolate whichReceptorsToIgnore whichReceptorsToMinimize]);
backgroundReceptors = T_receptors*B_primary*backgroundPrimary;
backgroundReceptorsZero = backgroundReceptors(whichReceptorsToZero);
Aeq = T_receptors(whichReceptorsToZero,:)*B_primary;
beq = backgroundReceptorsZero;

%% Set up constraints on primary variation, some may stay pinned at their
% background values.  For example, for spectral
% functions we may not want big wiggles at the ends of the visible
% spectrum, where the sensitivities are low.
whichPrimariesToVary = setdiff(1:size(B_primary,2),whichPrimariesToPin);
boundIndex = [whichPrimariesToPin whichPrimariesToVary];
[~,sortIndex] = sort(boundIndex);

% Since our modulations are symmetric, we need to make sure that we're not
% out of gamut if our background is not constant across wl band. For a
% half-on background, both the positive and the negative poles of a
% modulation will be in gamut, but that's not necessary the case if the
% background is not 0.5 for all wl bands.
%
% The following piece of code may also only works just right if we're
% not pinning primaries.
if isempty(whichPrimariesToPin)
    vub = 2*backgroundPrimary;
    vub(vub > 1) = 1;   vlb = backgroundPrimary-(vub-backgroundPrimary); 
    vlb(vlb < primaryHeadRoom) = primaryHeadRoom;
    vub(vub > 1-primaryHeadRoom) = 1-primaryHeadRoom;
else
    vlb = [initialPrimary(whichPrimariesToPin) ; ones(size(backgroundPrimary(whichPrimariesToVary)))*primaryHeadRoom];
    vub = [initialPrimary(whichPrimariesToPin) ; ones(size(backgroundPrimary(whichPrimariesToVary)))-primaryHeadRoom];
    vlb = vlb(sortIndex);
    vub = vub(sortIndex);
end

%% Construct constraint matrix.  This enforces the
% smoothness constraint on the spectrum, ensuring that
% the maximum difference between power at adjacent wavelengths
% is less than passed value maxPowerDiff.
%
% We use two tacked matrices, C1 and C2, so that we can express
% the desired absolute value constraint in terms of a set of
% linear inequalities.
vectorLength = size(B_primary, 1);
C1 = zeros(vectorLength-1, vectorLength);
for i = 1:vectorLength-1
    C1(i,i) = 1;
    C1(i,i+1) = -1;
end

C2 = zeros(vectorLength-1, vectorLength);
for i = 1:vectorLength-1
    C2(i,i) = -1;
    C2(i,i+1) = 1;
end

% Stack the two constraint matrices and premultiply
% by the primary basis.
C = [C1 ; C2]*B_primary;

% Tolerance vector, just expand passed maxPowerDiff.
Q = ones(2*(vectorLength-1), 1)*maxPowerDiff;

%% Optimize.
% Progressive smoothing seems to work better than providing final value all
% at once.
options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','sqp', 'MaxFunEvals', 100000, 'TolFun', 1e-10, 'TolCon', 1e-10, 'TolX', 1e-10);
x = fmincon(@(x) IsolateFunction(x,B_primary,[ambientSpd],T_receptors,whichReceptorsToIsolate,whichReceptorsToZero,desiredContrasts,whichReceptorsToMinimize),x,blkdiag(C, C),[Q Q],[],[],[vlb vlb],[vub vub],[],options);
isolatingPrimary = x(:, 2);
backgroundPrimary = x(:, 1);

if any(isolatingPrimary > 1)
    error('Primary values > 1');
end

if any(isolatingPrimary < 0)
    error('Primary values < 0');
end

end

% f = IsolateFunction(x,B_primary,backgroundPrimary,T_receptors,whichReceptorsToIsolate,C,lambda)
%
% Optimization subfunction.  This mixes maximizing response of isolated
% receptors with smoothness.
function f = IsolateFunction(x,B_primary,ambientSpd,T_receptors,whichReceptorsToIsolate,whichReceptorsToZero,desiredContrasts,whichReceptorsToMinimize)

% Compute background including ambient
backgroundSpd = B_primary*x(:, 1) + ambientSpd;

% Comptue contrasts for receptors we want to isolate.
modulationSpd = B_primary*(x(:, 2)-x(:, 1));
isolateContrasts = T_receptors(whichReceptorsToIsolate,:)*modulationSpd ./ (T_receptors(whichReceptorsToIsolate,:)*backgroundSpd);
zeroContrasts = T_receptors(whichReceptorsToZero,:)*modulationSpd ./ (T_receptors(whichReceptorsToZero,:)*backgroundSpd);

% We once used whichReceptorsToMinimize, but not currently.  This is here
% to remind us that we could stick a term back in the error function that
% uses it, if we ever need to.
% minimizeContrasts = T_receptors(whichReceptorsToMinimize,:)*modulationSpd ./ (T_receptors(whichReceptorsToMinimize,:)*backgroundSpd);

if isempty(desiredContrasts)
    % Want the sum of the isolated receptor contrasts to be big. fmincon
    % minimizes, hence the negative sign.  Acheive this by minimizing
    % the difference between the isolatedContrasts and unity.  For
    % reasons not fully understood, this works better numerically than
    % simply minimizing the negative sum of squared contrasts.
    f = sum((isolateContrasts-1).^2) + sum(zeroContrasts.^2);
else
    % Minimize difference between desired and what we get
    f = sum((isolateContrasts-desiredContrasts').^2) + sum(zeroContrasts.^2);
end

end