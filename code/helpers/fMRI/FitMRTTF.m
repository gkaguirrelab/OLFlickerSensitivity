function [theParams, theXDataToFit, theYAmpFit, theXInterp, theYAmpInterp] = FitMRTTF(theFrequenciesMTF, theYAmpDataToFit, theYErrToFit);
% [theParams, theXInterp, theYAmpInterp] = FitMRTTF(theFrequenciesMTF, theYAmpDataToFit, theYErrToFit);
%
% Fit MR TTF data with Watson center surround model.
%
% 5/5/14  ms      Wrote it.

% Define the optimization mode. Supported are:
%   - 'fmincon': Classical constrained minimization
%   - 'globalfmincon': Similar as fmincon but under global solver
%   - 'ga': Genetic algorithm. I don't undersetand it.
optimMode = 'patternsearch';

% Set any negative data to be zero.
theYAmpDataToFit(theYAmpDataToFit < 0) = 0;
%theYAmpDataToFit(end) = 0;

% Set up some further parameters
theXDataToFit = theFrequenciesMTF;
theXInterp = linspace(min(theXDataToFit(:)),max(theXDataToFit(:)),1000)';

%% fmincon setup
options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','sqp');

% Initial values.
fitParams0.centerAmp = max(theYAmpDataToFit);
fitParams0.centerTime = 0.1;
fitParams0.centerDelay = 0.004;
fitParams0.centerOrder = 1;
fitParams0.surroundAmp = max(theYAmpDataToFit);
fitParams0.surroundTime = 0.0016;
fitParams0.surroundDelay = 0.1;
fitParams0.surroundOrder = 9;
x0 = MRTTFParamsToX(fitParams0);

% Lower bounds
lbParams.centerAmp = -Inf;%max(theYAmpDataToFit(:))*10000;
lbParams.centerTime = 1e-5;
lbParams.centerDelay = 0;
lbParams.centerOrder = 0;
lbParams.surroundAmp = -Inf;%max(theYAmpDataToFit(:))*10000;;
lbParams.surroundTime = 0;
lbParams.surroundDelay = 0;
lbParams.surroundOrder = 1;
vlb = MRTTFParamsToX(lbParams);

% Upper bounds
ubParams.centerAmp = Inf;%max(theYAmpDataToFit(:))*10000;
ubParams.centerTime = Inf;
ubParams.centerDelay = Inf;
ubParams.centerOrder = Inf;
ubParams.surroundAmp = Inf;%max(theYAmpDataToFit(:))*10000;
ubParams.surroundTime = Inf;
ubParams.surroundDelay = Inf;
ubParams.surroundOrder = Inf;
vub = MRTTFParamsToX(ubParams);

% Locks
lockParams.centerAmp = 0;
lockParams.centerTime = 0;
lockParams.centerDelay = 0;
lockParams.centerOrder = 1;
lockParams.surroundAmp = 0;
lockParams.surroundTime = 0;
lockParams.surroundDelay = 0;
lockParams.surroundOrder = 1;

% Propagate parameters
AMPERRORONLY = 1;
YOKEDELAYS = 1;
modelType = 'Watson';
locks = MRTTFParamsToX(lockParams);
vlb = MRTTFParamsToX(lbParams);
vub = MRTTFParamsToX(ubParams);
vlb(locks == 1) = x0(locks == 1);
vub(locks == 1) = x0(locks == 1);

% Run a different optimization scheme.
switch optimMode
    case 'ga'
        opts = gaoptimset('PlotFcns',@gaplotbestf, 'Generations', 10000, 'TolCon', 1e-8, 'TolFun', 1e-8);
        IntCon = [4 8];
        [theParams,fval,exitflag] = ga(@(x)FitMRTTFErr(x,theXDataToFit,theYAmpDataToFit,theYErrToFit,AMPERRORONLY,YOKEDELAYS,modelType),8,[],[],[],[],vlb,vub,[],IntCon,opts);
        fitParams0 = MRTTFXToParams(theParams);
    case 'fmincon'
        % Call fmincon
        theParams = fmincon(@(x)FitMRTTFErr(x,theXDataToFit,theYAmpDataToFit,theYErrToFit,AMPERRORONLY,YOKEDELAYS,modelType),x0,[],[],[],[],vlb,vub,[],options);
    case 'globalfmincon'
        theParams = fmincon(@(x)FitMRTTFErr(x,theXDataToFit,theYAmpDataToFit,theYErrToFit,AMPERRORONLY,YOKEDELAYS,modelType),x0,[],[],[],[],vlb,vub,[],options);
        problem = createOptimProblem('fmincon','objective', @(x)FitMRTTFErr(theParams,theXDataToFit,theYAmpDataToFit,theYErrToFit,AMPERRORONLY,YOKEDELAYS,modelType),'x0',x0,'lb',vlb,'ub',vub,'options',options);
        gs = GlobalSearch('Display', 'iter');
        theParams = run(gs,problem);
    case 'patternsearch'
        theParams = patternsearch(@(x)FitMRTTFErr(x,theXDataToFit,theYAmpDataToFit,theYErrToFit,AMPERRORONLY,YOKEDELAYS,modelType),x0,[],[],[],[],vlb,vub,[],options);        
end

if (YOKEDELAYS)
    theParams(7) = theParams(3);
end

% Extract parameters
FitMRTTFErr(theParams,theXDataToFit,theYAmpDataToFit,theYErrToFit,0,YOKEDELAYS,modelType);
fitParams = MRTTFXToParams(theParams);
theYFit = ComputeModelMRTTF(fitParams,theXDataToFit,YOKEDELAYS,modelType);
theYAmpFit = abs(theYFit);
theYPhaseFit = angle(theYFit);
theYInterp = ComputeModelMRTTF(fitParams,theXInterp,YOKEDELAYS,modelType);
theYAmpInterp = abs(theYInterp);
theYPhaseInterp = angle(theYInterp);

end

function [f,predYData] = FitMRTTFErr(x,theXDataToFit,theYDataToFit,theYErrToFit,AMPERRORONLY,YOKEDELAYS,modelType)

% Make prediction based on parameters
params = MRTTFXToParams(x);
predYData = ComputeModelMRTTF(params,theXDataToFit,YOKEDELAYS,modelType);

% Compute error, weighting by SEM.  To
% stabilize a little, we add a term to the SEM
ampMeasErr = abs(theYErrToFit);
phaseMeasErr = angle(theYErrToFit);
ampMeasErr = ampMeasErr + mean(ampMeasErr)/2;
phaseMeasErr = phaseMeasErr + mean(phaseMeasErr)/2;

%ampMeasErr(:) = 1;
%phaseMeasErr(:) = 1;

% Make sure that the error is non zero
if all(~ampMeasErr)
    ampMeasErr(:) = 1;
    phaseMeasErr(:) = 1;
end

ampPredResid = (abs(predYData)-abs(theYDataToFit))./ampMeasErr;
ampPredResid = (abs(predYData)/max(abs(theYDataToFit))-abs(theYDataToFit)/max(abs(theYDataToFit)));

% Compute phase error, weighting by SEM.
% Need to deal with phase wrap.
phasePredResid = Inf*ones(size(predYData));
for i = 1:length(phasePredResid)
    for phase = [-2*pi 0 2*pi]
        tempPredY = angle(predYData(i))+phase;
        tempErr = abs(tempPredY-angle(theYDataToFit(i)))/phaseMeasErr(i);
        if (tempErr < phasePredResid(i))
            phasePredResid(i) = tempErr;
        end
    end
end

ampPredError = 100*sum( ampPredResid.^2 )/length(theXDataToFit);
phasePredError = sum(  phasePredResid.^2 )/length(theXDataToFit);


% Roughness penalty
theXInterp = linspace(min(theXDataToFit(:)),max(theXDataToFit(:)),1000)';
theYInterp = ComputeModelMRTTF(params,theXInterp,YOKEDELAYS,modelType);
theYAmpInterp = abs(theYInterp);
theYPhaseInterp = angle(theYInterp);
theAmpRoughness = 100*sum(diff(diff(theYAmpInterp)).^2);
thePhaseRoughness = 100*sum(diff(diff(theYPhaseInterp)).^2);

if (AMPERRORONLY)
    f = ampPredError;
else
    %phaseFrac = 0.6; % Geoff
    phaseFrac = 0.4; % Sandeep
    phaseFrac = 0.6;
    f = (ampPredError + phaseFrac*phasePredError);% + theAmpRoughness + thePhaseRoughness;
end
end

function predMTF = ComputeModelMRTTF(params,theFrequenciesHz,YOKEDELAYS,modelType)

% Treat center and surround as having same delay.
if (YOKEDELAYS)
    params.surroundDelay = params.centerDelay;
end


switch (modelType)
    case 'Gaussian'
        centerMTF = params.centerAmp * ComputeGaussianMTFAnalytical(params.centerTime,theFrequenciesHz) .* exp(-1i*2*pi*params.centerDelay*theFrequenciesHz);
        surroundMTF = params.surroundAmp * ComputeGaussianMTFAnalytical(params.surroundTime,theFrequenciesHz) .* exp(-1i*2*pi*params.surroundDelay*theFrequenciesHz);
    case 'GaussianNumeric'
        centerMTF = params.centerAmp * ComputeGaussianMTFNumeric(params.centerTime,theFrequenciesHz) .* exp(-1i*2*pi*params.centerDelay*theFrequenciesHz);
        surroundMTF = params.surroundAmp * ComputeGaussianMTFNumeric(params.surroundTime,theFrequenciesHz) .* exp(-1i*2*pi*params.surroundDelay*theFrequenciesHz);
    case 'Exponential'
        centerMTF = params.centerAmp * ComputeExponentialMTFNumeric(params.centerTime,theFrequenciesHz) .* exp(-1i*2*pi*params.centerDelay*theFrequenciesHz);
        surroundMTF = params.surroundAmp * ComputeExponentialMTFNumeric(params.surroundTime,theFrequenciesHz) .* exp(-1i*2*pi*params.surroundDelay*theFrequenciesHz);
    case 'Watson'
        centerMTF = params.centerAmp * ComputeWatsonAnalytical(params.centerTime,theFrequenciesHz,params.centerOrder) .* exp(-1i*2*pi*params.centerDelay*theFrequenciesHz);
        surroundMTF = params.surroundAmp * ComputeWatsonAnalytical(params.surroundTime,theFrequenciesHz,params.surroundOrder) .* exp(-1i*2*pi*params.surroundDelay*theFrequenciesHz);
end
predMTF = centerMTF - surroundMTF;

end

% Compute the MTF of Watson function analytically.
%
% The impulse response of an nth-order filter is of the form
% h1(t) = u(t) * (1/(tau*(n-1)!)) * (t/tau)^(n-1) * exp(-t/tau)
% The analytical Fourier transform is
% H(w) = (i*2*pi*w*tau + 1) ^ (-n)
% The magnitude component is
% |H(w)| = ((2*pi*w*tau)^2 + 1) ^ (-n/2)
% The phase component is:
% <H(w) = -n*arctan(2*pi*w*tau)
% This is a cascade of 1st-order filter and is normalized to have unit area
function MTF = ComputeWatsonAnalytical(timeConstant,frequenciesHz,filterOrder)
MTF = (1i*2*pi*frequenciesHz*timeConstant + 1) .^ (-filterOrder);
end

%% Parameter packing/unpacking
function x = MRTTFParamsToX(params)

x(1) = params.centerAmp;
x(2) = params.centerTime;
x(3) = params.centerDelay;
x(4) = params.centerOrder;
x(5) = params.surroundAmp;
x(6) = params.surroundTime;
x(7) = params.surroundDelay;
x(8) = params.surroundOrder;

end

%% Parameter packing/unpacking
function params = MRTTFXToParams(x)

params.centerAmp = x(1);
params.centerTime = x(2);
params.centerDelay = x(3);
params.centerOrder = x(4);
params.surroundAmp = x(5);
params.surroundTime = x(6);
params.surroundDelay = x(7);
params.surroundOrder = x(8);

end