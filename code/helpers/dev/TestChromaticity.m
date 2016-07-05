function test

targetX = 0.33;
targetY = 0.33;

maxPowerDiff = 0.01;

S = [380 2 201];
wls = SToWls(S);
load('/Users/Shared/Matlab/Toolboxes/PsychCalLocalData/OneLight/OLBoxAShortCableBEyePiece2.mat')
cal = cals{end};

ambientSpd = cal.computed.pr650MeanDark;
B_primary = cal.computed.pr650M;

operatingPoint = 0.5;
backgroundPrimary = operatingPoint*ones(size(B_primary,2),1);

backgroundSpd = B_primary*backgroundPrimary + ambientSpd;

plot(wls, backgroundSpd); hold on;


%% Load CIE functions.
load T_xyz1931
T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);
photopicLuminanceCdM2 = T_xyz(2,:)*backgroundSpd;
chromaticityXY = T_xyz(1:2,:)*backgroundSpd/sum(T_xyz*backgroundSpd);
fprintf('x: %.2f, y: %.2f, Y: %2.f\n', chromaticityXY(1), chromaticityXY(2), photopicLuminanceCdM2);

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

primaryHeadRoom = 0.2;
Q = ones(2*(vectorLength-1), 1)*maxPowerDiff;

vub = ones(size(B_primary,2),1) - primaryHeadRoom;
vlb = zeros(size(B_primary,2),1) + primaryHeadRoom;


options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set', 'MaxFunEvals', 100000, 'TolFun', 1e-10, 'TolCon', 1e-10, 'TolX', 1e-10);
%x = fmincon(@(x) IsolateFunction(x,B_primary,ambientSpd,T_xyz,targetX,targetY,photopicLuminanceCdM2),backgroundPrimary,C,Q,[],[],vlb,vub,[],options);
problem = createOptimProblem('fmincon', 'objective', @(x) IsolateFunction(x,B_primary,ambientSpd,T_xyz,targetX,targetY,photopicLuminanceCdM2), 'x0', backgroundPrimary, 'lb', vlb, 'ub', vub, 'Aineq', C, 'bineq', Q);
gs = GlobalSearch;
[x,f] = run(gs,problem)

isolatingPrimary = x;

if any(isolatingPrimary > 1)
    error('Primary values > 1');
end

if any(isolatingPrimary < 0)
    error('Primary values < 0');
end

%% Evaluate x
backgroundSpd = B_primary*x + ambientSpd;
chromaticityXY = T_xyz(1:2,:)*backgroundSpd/sum(T_xyz*backgroundSpd);
photopicLuminanceCdM2 = T_xyz(2,:)*backgroundSpd;
fprintf('x: %.2f, y: %.2f, Y: %2.f\n', chromaticityXY(1), chromaticityXY(2), photopicLuminanceCdM2);

plot(wls, backgroundSpd);

keyboard;

function f = IsolateFunction(x,B_primary,ambientSpd,T_xyz,targetX,targetY,targetLum)

% Compute background including ambient
backgroundSpd = B_primary*x + ambientSpd;

% Compute chromaticity of that
chromaticityXY = T_xyz(1:2,:)*backgroundSpd/sum(T_xyz*backgroundSpd);
photopicLuminanceCdM2 = T_xyz(2,:)*backgroundSpd;

f = sum((chromaticityXY(1)-targetX)^2 + (chromaticityXY(2)-targetY)^2);