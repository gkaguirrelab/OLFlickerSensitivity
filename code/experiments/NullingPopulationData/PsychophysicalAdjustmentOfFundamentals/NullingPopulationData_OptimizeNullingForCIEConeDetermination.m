function OptimizeNullingforCIEConeDetermination
% OptimizeNullingforCIEConeDetermination
%
% Try to find nulling directions that optimize power for determining individualized
% parameters of the CIE cone fundamentals.
%
% The logic loosely follows that introduced in Asano et al. (2015),
% "Color matching experiment for highlighting individual variability",
% Color Research and Application, published online March 2015, doi:
% 10.1002/col.21975.
%
% 12/28/15  dhb  Wrote it.

%% Clear and close
clear; close all;

%% Some figure parameters
doConeCheckFigure = false;
doModulationCheckFigure = true;

%% Set up base receptor sensitivities for nominal observer
%
% Nominal observer
S = [380 1 401];
photoreceptorClasses = {'LCone', 'MCone', 'SCone', 'Melanopsin'};

% Allowable types, 'CIE', 'SmithPokorny10'. 'StockmanSharpe10'
baseCones.type = 'CIE';
baseCones.fieldSizeDegrees = 27.5;
baseCones.observerAgeInYears = 32;
baseCones.pupilDiameterMm = 4.7;
baseCones.Lshift = 0;
baseCones.Mshift = 0;
baseCones.Sshift = 0;
baseCones.Melshift = 0;

%% Define device primaries and some modulation parametres
% These are taken from the OneLight demo file in the SilentSubstitutionToolbox.
% We also set here the parameters for our receptor isolation code that work
% reasonably well for these primaries.
%
% Get a OneLight calibration file, stored here for demo purposes.
% Extract the descrption of spectral primaries, which is what we
% need for this demo.  Gamma correction of primary values to
% settings would need to be handled to get the device to actually
% produce the spectrum, but here we are just finding the desired
% modulation.
calPath = fullfile(fileparts(which('ReceptorIsolateDemo')), 'ReceptorIsolateDemoData', []);
cal = LoadCalFile('OneLightDemoCal.mat',[],calPath);
B_primary = SplineSpd(cal.describe.S,cal.computed.pr650M,S);
ambientSpd = SplineSpd(cal.describe.S,cal.computed.pr650MeanDark,S);

% Background is half on in primary space
backgroundPrimary = 0.5*ones(size(B_primary,2),1);
backgroundSpd = B_primary*backgroundPrimary;

%% Find modulation for each observer age.
%
% This modulation should be in the nullspace for the cones for that age
% and have a large effect on DE for cones from nearby ages.
observerAges = 20:70;
nAges = length(observerAges);
if (doConeCheckFigure)
    coneFigure = figure; clf;
end
if (doModulationCheckFigure)
    modulationFigure = figure; clf;
end
deltaYearsForAgeDeriviative = 1;
deltaFieldSizeForAgeCalc = 0;
deltaLshiftForAgeCalc = 0;
for a = 1:nAges
    % Get age for this time through the loop
    theAge = observerAges(a);
    
    % Get nominal CIE cones for this age
    nominalCones = baseCones;
    nominalCones.observerAgeInYears = theAge;
    T_nominalReceptors = GetReceptorsFromStruct(S, photoreceptorClasses, nominalCones);
    T_nominalCones = T_nominalReceptors(1:3,:);
    if (doConeCheckFigure);
        figure(coneFigure); hold on;
        plot(SToWls(S),T_nominalCones','r','LineWidth',1);
        title(sprintf('Age = %d',theAge))
        drawnow;
    end

    % Set up conversion to XYZ and Lab from nominal cones
    load T_xyz1931
    T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);
    M_LMSToXYZ = (T_nominalCones'\T_xyz')';
    T_xyzCheck = M_LMSToXYZ*T_nominalCones;
    if (false)
        figure; clf; hold on
        plot(SToWls(S),T_xyz','k','LineWidth',2);
        plot(SToWls(S),T_xyzCheck','r','LineWidth',1);
        xlabel('Wavelength (nm)'); ylabel('CMF value');
        title('Check of conversion from LMS to XYZ');
    end

    % Find basis for nullspace of the nominal receptors
    %
    % If we were exactly right with our nominal receptors, then any
    % linear combination of these would be invisible.
    %
    % We find the basis within the device primary space and then convert
    % to spectra.  The spectra are not orthogonormal as they come
    % out of routine null(), it is the device primaries that are orthonormal.
    % But we then make the spectra orthonormal, so that each basis spectrum
    % is equated in L2 norm power.
    %
    % The scale of the basis spectra is arbitrary with respect to our device
    % power, we scale all of them back into a reasonable range by hand
    basisScaleFactor = 20;
    nullModulationPrimaryBasis = null(T_nominalReceptors*B_primary);
    nullModulationSpectralBasis = orth(B_primary*nullModulationPrimaryBasis)/basisScaleFactor;

    % Perturbed observer.  We want the modulation to be as visible to this observer
    % as we can make it, while keeping it within the null space of the nominal receptors.
    perturbedCones = nominalCones;
    perturbedCones.observerAgeInYears = perturbedCones.observerAgeInYears + deltaYearsForAgeDeriviative;
    perturbedCones.fieldSizeDegrees = perturbedCones.fieldSizeDegrees + deltaFieldSizeForAgeCalc;
    perturbedCones.Lshift = perturbedCones.Lshift + deltaLshiftForAgeCalc;
    T_perturbedReceptors = GetReceptorsFromStruct(S, photoreceptorClasses, perturbedCones);
    T_perturbedCones = T_perturbedReceptors(1:3,:);

    % Background coordinates with repsect to perturbed cones
    backgroundLMS = T_perturbedCones*B_primary*backgroundPrimary;
    backgroundXYZ = M_LMSToXYZ*backgroundLMS;
    backgroundLab = XYZToLab(backgroundXYZ,backgroundXYZ);

    % Find modulation in null space with maximal DE effect.
    % First we just look at each basis function and sort to find
    % the largest.  We could do better by searching within the null space,
    % subject to device constraints.
    thePlusDEs = zeros(size(nullModulationSpectralBasis,2),1);
    for s = 1:size(nullModulationSpectralBasis,2)
        thePlusNullSpectrum = backgroundSpd+nullModulationSpectralBasis(:,s);
        thePlusNullLMS = T_perturbedCones*thePlusNullSpectrum;
        thePlusNullXYZ = M_LMSToXYZ*thePlusNullLMS;
        thePlusNullLab = XYZToLab(thePlusNullXYZ,backgroundXYZ);
        thePlusDEs(s) = norm(thePlusNullLab-backgroundLab);
    end
    [~,sortIndex] = sort(thePlusDEs,1,'descend');
    theOptimalModulation0(:,a) = nullModulationSpectralBasis(:,sortIndex(1));
    theOptimalSpectrum = backgroundSpd+theOptimalModulation0(:,a);
    theOptimalLMS = T_perturbedCones*theOptimalSpectrum;
    theOptimalXYZ = M_LMSToXYZ*theOptimalLMS;
    theOptimalLab = XYZToLab(theOptimalXYZ,backgroundXYZ);
    theOptimalDE0 = norm(theOptimalLab-backgroundLab);
    
    % Then we search, using the above or the result at the previous
    % base age as the starting point.  This probably doesn't find the
    % global optimum, but it does a bit better than just taking the best
    % single basis function.
    options = optimset('fmincon');
    options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');
    if (a == 1)
        x0 = nullModulationSpectralBasis\theOptimalModulation0(:,a);
    else
        x0 = nullModulationSpectralBasis\theOptimalModulation(:,a-1);
    end
    vlb = -1000*ones(size(x0));
    vub = 1000*ones(size(x0));
    x = fmincon(@(x)OptimalModulationSearchFun(x,backgroundSpd,backgroundXYZ,backgroundLab,T_perturbedCones,M_LMSToXYZ,...
        B_primary,nullModulationSpectralBasis),...    
        x0,[],[],[],[],vlb,vub,[],options);
    theOptimalModulation(:,a) = nullModulationSpectralBasis*x;
    theOptimalSpectrum = backgroundSpd+theOptimalModulation(:,a);
    theOptimalLMS = T_perturbedCones*theOptimalSpectrum;
    theOptimalXYZ = M_LMSToXYZ*theOptimalLMS;
    theOptimalLab = XYZToLab(theOptimalXYZ,backgroundXYZ);
    theOptimalDE = norm(theOptimalLab-backgroundLab);

    % Optional plot of the modulation around the background.  This is useful to
    % check that we've gotten the scaling about right.
    if (doModulationCheckFigure)
        figure(modulationFigure); hold on
        plot(SToWls(S),backgroundSpd+theOptimalModulation(:,a),'r');
        title(sprintf('Age = %d, DE0 = %0.2f, DE = %0.2f',theAge,theOptimalDE0,theOptimalDE))
        drawnow;
    end
end

%% Plot DE versus modulation observer age, for various nominal observer ages.
plotBaseAges = 25:10:65;
deltaFieldSizeForPlot = 0;
deltaLshiftForPlot = 0;
deFigure = figure; clf;
theColors = ['r' 'g' 'b' 'k' 'c'];
nColors = length(theColors);
whichColor = 1;
for i = 1:length(plotBaseAges)
    % Get CIE cones for this base age
    nominalCones = baseCones;
    nominalCones.observerAgeInYears = plotBaseAges(i);
    nominalCones.fieldSizeDegrees = perturbedCones.fieldSizeDegrees + deltaFieldSizeForPlot;
    nominalCones.Lshift = perturbedCones.Lshift + deltaLshiftForPlot;
    T_nominalReceptors = GetReceptorsFromStruct(S, photoreceptorClasses, nominalCones);
    T_nominalCones = T_nominalReceptors(1:3,:);

    % Set up conversion to XYZ and Lab from nominal cones
    load T_xyz1931
    T_xyz = SplineCmf(S_xyz1931,683*T_xyz1931,S);
    M_LMSToXYZ = (T_nominalCones'\T_xyz')';

    % Get DE for each of our modulations
    for a = 1:length(observerAges)
        % Background coordinates with repsect to nominal cones
        backgroundLMS = T_nominalCones*B_primary*backgroundPrimary;
        backgroundXYZ = M_LMSToXYZ*backgroundLMS;
        backgroundLab = XYZToLab(backgroundXYZ,backgroundXYZ);
        
        % Find modulation in null space with maximal DE effect.
        theOptimalNullSpectrum = backgroundSpd+theOptimalModulation(:,a);
        theOptimalNullLMS = T_nominalCones*theOptimalNullSpectrum;
        theOptimalNullXYZ = M_LMSToXYZ*theOptimalNullLMS;
        theOptimalNullLab = XYZToLab(theOptimalNullXYZ,backgroundXYZ);
        theOptimalDEs(i,a) = norm(theOptimalNullLab-backgroundLab);
    end

    % Plot DE for this base age
    figure(deFigure); hold on;
    plot(observerAges,theOptimalDEs(i,:),[theColors(whichColor) 'o'],'MarkerFaceColor',theColors(whichColor),'MarkerSize',8);
    plot(observerAges,theOptimalDEs(i,:),theColors(whichColor));
    index = find(observerAges == plotBaseAges(i));
    if (~isempty(index))
        plot([plotBaseAges(i) plotBaseAges(i)],[0 theOptimalDEs(i,index)],theColors(whichColor),'LineWidth',2);
    end
    xlabel('Modulation Observer Age');
    ylabel('Match Delta E');
    title(sprintf('Field Size Shift: %d; L Cone Shift: %d',deltaFieldSizeForPlot,deltaLshiftForPlot));
    whichColor = whichColor + 1;
    if (whichColor > nColors)
        whichColor = 1;
    end
    drawnow;
    FigureSave('OptimizeForAgeParam',deFigure,'pdf');
end

end

%% Optimize DE function
function f = OptimalModulationSearchFun(x,backgroundSpd,backgroundXYZ,backgroundLab,T_perturbedCones,M_LMSToXYZ,B_primary,nullModulationSpectralBasis)

% Compute DE.  We want this big.
theSpectrum = backgroundSpd + nullModulationSpectralBasis*x;
theLMS = T_perturbedCones*theSpectrum;
theXYZ = M_LMSToXYZ*theLMS;
theLab = XYZToLab(theXYZ,backgroundXYZ);
theDE = norm(theLab-backgroundLab);

% Compute device primaries and penalty
thePrimaries = B_primary\theSpectrum;
maxPrimary = max(thePrimaries);
minPrimary = min(thePrimaries);
penalty = 0;
if (maxPrimary > 1)
    penalty = penalty + (maxPrimary-1);
end
if (minPrimary < 0)
    penalty = penalty - minPrimary;
end

% Compound error measure
penaltyWeight = 10;
f = -theDE + penaltyWeight*penalty;

end
