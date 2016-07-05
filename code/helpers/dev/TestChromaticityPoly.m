function test

maxPerturb = 0.1;

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

x0 = [0 0 0];

t = linspace(-1, 1, size(B_primary, 2))';
options = optimset('fmincon');
options = optimset(options,'Diagnostics','on','Display','iter','LargeScale','off','Algorithm','active-set', 'MaxFunEvals', 100000, 'TolFun', 1e-10, 'TolCon', 1e-10, 'TolX', 1e-10);
x = fmincon(@(x) IsolateFunction(x,B_primary,ambientSpd,T_xyz,targetX,targetY,photopicLuminanceCdM2),x0,[],[],[],[],-1000*ones(size(x0)),1000*ones(size(x0)),[],options);
isolatingPrimary = x;


%% Evaluate x
backgroundSpd = B_primary*(backgroundPrimary + maxPerturb*polyval(x, t)) + ambientSpd;
chromaticityXY = T_xyz(1:2,:)*backgroundSpd/sum(T_xyz*backgroundSpd);
photopicLuminanceCdM2 = T_xyz(2,:)*backgroundSpd;
fprintf('x: %.2f, y: %.2f, Y: %2.f\n', chromaticityXY(1), chromaticityXY(2), photopicLuminanceCdM2);

plot(wls, backgroundSpd);

function f = IsolateFunction(x,B_primary,ambientSpd,T_xyz,targetX,targetY,targetLum)
operatingPoint = 0.5;
t = linspace(-1, 1, size(B_primary, 2))';
maxPerturb = 0.05;
backgroundPrimary = operatingPoint*ones(size(B_primary,2),1);

% Compute background including ambient
backgroundSpd = B_primary*(backgroundPrimary + maxPerturb*polyval(x, t)) + ambientSpd;

% Compute chromaticity of that
chromaticityXY = T_xyz(1:2,:)*backgroundSpd/sum(T_xyz*backgroundSpd);
photopicLuminanceCdM2 = T_xyz(2,:)*backgroundSpd;

f = 1000*sum((chromaticityXY(1)-targetX)^2 + (chromaticityXY(2)-targetY)^2 + (targetLum-photopicLuminanceCdM2)^2);
