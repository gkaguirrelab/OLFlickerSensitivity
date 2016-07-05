function [tritanShortWl tritanShortEnergy tritanLongWl tritanLongEnergy] = GetTritanPairs(tritanShortWl, whichCones, whichNomogram, makePlots)
% [tritanShortWl tritanShortEnergy tritanLongWl tritanLongEnergy] = GetTritanPairs(tritanShortWl, whichCones, whichNomogram, makePlots)
%
% Try to figure out what happens with the tritan pairs
% when we also consider melanopsin.
%
% This is relevant to Verdon and Howarth, 1988.
%
% 3/12/14  dhb  Wrote it.
% 5/11/15  ms   Turned into a function

% Fill in details if they have not been passed
if isempty(tritanShortWl)
    tritanShortWl = 440;
end
if isempty(whichCones)
    whichCones = 'CIE';
end
if isempty(whichNomogram)
    whichNomogram = 'StockmanSharpe';
end
if isempty(makePlots)
    makePlots = false;
end


%% Read in standard cone fundamentals and also snag melanopsin fundamental
%
% Smith-Pokorny gives tritan pair of 440 at 494.2, which is cloer to what is
% used in Verdon and Birch than whe we get with Stockman-Sharpe.
wls = (380:0.1:780)';
S = WlsToS(wls);
fieldSizeDeg = 2;
ageInYears = 32;
pupilSizeMm = 3;
switch (whichCones)
    case 'SmithPokorny'
        load T_cones_sp;
        T_energy1 = SplineCmf(S_cones_sp,T_cones_sp,S);
        clear T_cones_sp S_cones_sp
    case 'CIE'
        lambdaMax1 = [558.9, 530.3, 420.7];
        T_quanta1 = ComputeCIEConeFundamentals(S,fieldSizeDeg,ageInYears,pupilSizeMm,lambdaMax1,whichNomogram);
        T_energy1 = EnergyToQuanta(S,T_quanta1')';
end

% Melanopsin
lambdaMax2 = [558.9, 530.3, 480];
T_quanta2 = ComputeCIEConeFundamentals(S,fieldSizeDeg,ageInYears,pupilSizeMm,lambdaMax2,whichNomogram);
T_energy2 = EnergyToQuanta(S,T_quanta2')';
T_mel = T_energy2(3,:);

% Tack melanopsin onto cone fundamentals and normalize to max of 1 for each receptor.
T_receptors = [T_energy1(1:3,:) ; T_mel];
for i = 1:size(T_receptors,1)
    T_receptors(i,:) = T_receptors(i,:)/max(T_receptors(i,:));
end
T_LM = T_receptors(1:2,:);
receptorNames = {'L cones', 'M cones', 'S cones', 'Melanopsin'};

%% Define tritan pair short wavelength and energy, and
% find LM response to short member of pair
%tritanShortWl = 440;
tritanShortEnergy = 100;
[nil,index] = min(abs(wls-tritanShortWl));
tritanShortLMResp = tritanShortEnergy*T_LM(:,index);

%% Find tritan long wavelength wavelength and energy.
%
% We want to find wavelength and energy that minimizes
% difference in L and M cone responses with respect to
% the short wavelength member of the pair.
%
% We do this using numerical optimization of energy for
% each candidate wavelength, and then search over wavelengths
% for minimum.  Optimizing over both at once seemed get
% stuck in the wrong place.  Probably it could be tuned up
% to work with enough fussing, but this approach gives us
% the right answer.
vlb = [0.001];
vub = [10000];
options = optimset('fmincon');
options = optimset(options,'Diagnostics','off','Display','off','LargeScale','off','Algorithm','active-set');
testWls = (430:0.1:540)';
for i = 1:length(testWls)
    testWl = testWls(i);
    tritanLongEnergy0 = 100;
    x0 = [tritanLongEnergy0];
    x = fmincon(@(x)FindTritanPairFunction(x,testWl,tritanShortLMResp,wls,T_LM),x0,[],[],[],[],vlb,vub,[],options);
    testFs(i) = FindTritanPairFunction(x,testWl,tritanShortLMResp,wls,T_LM);
    tritanLongEnergies(i) = x(1);
end



% Find wavelength of minimum difference, avoiding the isomer.
minCheckWl = tritanShortWl + 10;
index = find(testWls > minCheckWl);
searchWls = testWls(index);
searchFs = testFs(index);
searchEnergies = tritanLongEnergies(index);
[nil,index1] = sort(searchFs);
tritanLongWl = searchWls(index1(1));
tritanLongEnergy = searchEnergies(index1(1));
tritanLongF = searchFs(index1(1));
fprintf('Short wl %0.1f, energy %0.2f; Long wl %0.1f, energy %0.2f; LM error: %0.3f\n',tritanShortWl,tritanShortEnergy,tritanLongWl,tritanLongEnergy,tritanLongF);

if makePlots
    % Plot of wavelength dependence of difference
    findTritanWlFig = figure; clf;
    set(gca,'FontName','Helvetica','FontSize',14);
    plot(testWls,testFs,'r');
    xlabel('Wavelength (nm)','FontName','Helvetica','FontSize',14);
    ylabel('LM error to short wl','FontName','Helvetica','FontSize',14);
    drawnow;
    
    %% Get contrast seen by each cone to the alternation with various perturbations around the tritan luminance
    logPerturbations = linspace(-0.3,0.3,100);
    perturbations = 10.^logPerturbations;
    [nil,index] = min(abs(wls-tritanShortWl));
    tritanShortResp = tritanShortEnergy*T_receptors(:,index);
    for i = 1:length(perturbations);
        [nil,index] = min(abs(wls-tritanLongWl));
        tritanLongResp = perturbations(i)*tritanLongEnergy*T_receptors(:,index);
        tritanContrast = (tritanShortResp-tritanLongResp) ./ (tritanShortResp + tritanLongResp);
        fprintf('Contrasts for tritan pair at log perturb %0.2f: L = %0.2f, M = %0.2f, S = %0.2f, Mel = %0.2f\n', ...
            logPerturbations(i),tritanContrast(1),tritanContrast(2),tritanContrast(3),tritanContrast(4));
        tritanContrasts(:,i) = tritanContrast;
    end
    contrastFigure = figure; clf; hold on
    set(gca,'FontName','Helvetica','FontSize',16);
    plot(logPerturbations,tritanContrasts(1,:),'r','LineWidth',3);
    plot(logPerturbations,tritanContrasts(2,:),'g','LineWidth',2);
    plot(logPerturbations,tritanContrasts(3,:),'b','LineWidth',2);
    plot(logPerturbations,tritanContrasts(4,:),'c','LineWidth',2);
    plot(logPerturbations,0*ones(size(logPerturbations)),'k:');
    plot([0 0],[-1 1],'k:');
    xlabel('Long wavelength log10 perturbation','FontName','Helvetica','FontSize',18);
    ylabel('Receptor contrast','FontName','Helvetica','FontSize',18);
    title('Verdon/Howarth Receptor Contrasts','FontName','Helvetica','FontSize',18);
    legend({'L', 'M', 'S', 'Mel'},'Location','SouthEast');
    savefig('tritanPairContrasts',contrastFigure,'png');
end

end


function f = FindTritanPairFunction(x,wl,tritanShortLMResp,wls,T_LM)

energy = x(1);
[nil,nearestWlIndex] = sort(abs(wls-wl));
nearestWl = wls(nearestWlIndex(1));
secondNearestWl = wls(nearestWlIndex(2));
if (nearestWl > secondNearestWl)
    lowWl = secondNearestWl;
    highWl = nearestWl;
else
    lowWl = nearestWl;
    highWl = secondNearestWl;
end
lambda = (wl-lowWl)/(highWl-lowWl);

[nil,index] = min(abs(wls-lowWl));
tritanLongLMRespLow = energy*T_LM(:,index);
[nil,index] = min(abs(wls-highWl));
tritanLongLMRespHigh = energy*T_LM(:,index);
tritanLongLMResp = (1-lambda)*tritanLongLMRespLow+lambda*tritanLongLMRespHigh;

diff = (tritanShortLMResp-tritanLongLMResp);
f = sqrt(sum(diff.^2)/length(diff));

end
