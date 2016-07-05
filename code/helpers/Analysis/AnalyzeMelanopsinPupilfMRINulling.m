clear all;
run('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/code/helpers/Analysis/AnalyzeMelanopsinBrightnessNulling.m')
outputDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/fMRIPupilNullingFlickerPaper';

close all;
clc;

%% Key value pairs. Defines the associated handle for each of the additional 12 observers
origName{1} = 'MelBright_C002'; newName{1} = 'S04'; ageObs(1) = 28; female(1) = false;
origName{2} = 'MelBright_C003'; newName{2} = 'S05'; ageObs(2) = 26; female(2) = true;
origName{3} = 'MelBright_C004'; newName{3} = 'S06'; ageObs(3) = 32; female(3) = false;
origName{4} = 'MelBright_C005'; newName{4} = 'S07'; ageObs(4) = 30; female(4) = true;
origName{5} = 'MelBright_C008'; newName{5} = 'S08'; ageObs(5) = 29; female(5) = false;
origName{6} = 'MelBright_C010'; newName{6} = 'S09'; ageObs(6) = 28; female(6) = false;
origName{7} = 'MelBright_C014'; newName{7} = 'S10'; ageObs(7) = 30; female(7) = true;
origName{8} = 'MelBright_C015'; newName{8} = 'S11'; ageObs(8) = 30; female(8) = true;
origName{9} = 'MelBright_C016'; newName{9} = 'S12'; ageObs(9) = 35; female(9) = false;
origName{10} = 'MelBright_C017'; newName{10} = 'S13'; ageObs(10) = 32;female(10) = false;
origName{11} = 'MelBright_C018'; newName{11} = 'S14'; ageObs(11) = 29; female(11) = false;
origName{12} = 'MelBright_C019'; newName{12} = 'S15'; ageObs(12) = 31; female(12) = false;

heroOrigName{1} = 'GA'; heroNewName{1} = 'S01'; heroAgeObs(1) = 43; heroFemale(1) = false;
heroOrigName{2} = 'MS'; heroNewName{2} = 'S02'; heroAgeObs(2) = 26; heroFemale(2) = false;
heroOrigName{3} = 'MM'; heroNewName{3} = 'S03'; heroAgeObs(3) = 28; heroFemale(3) = false;

fid = fopen(fullfile(outputDir, 'PupilNulling_SubjectList.csv'), 'w');
for i = 1:length(heroOrigName);
    fprintf(fid, '%s,%s,%g,', heroNewName{i}, heroOrigName{i}, heroAgeObs(i));
    if heroFemale(i)
        fprintf(fid, 'F\n');
    else
        fprintf(fid, 'M\n');
    end
end
for i = 1:length(origName);
    fprintf(fid, '%s,%s,%g,', newName{i}, origName{i}, ageObs(i));
    if female(i)
        fprintf(fid, 'F\n');
    else
        fprintf(fid, 'M\n');
    end
end
fclose(fid);

%%
% Load in data from GA, MM, and MS.
a = csvread('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/PupilNulled0_1Hz/G081815A-results.csv', 1, 1);
theIdx = 1;
PupilAmplitudeChangeLMS(theIdx) = a(1, 4);
PupilAmplitudeChangeLightFlux(theIdx) = a(2, 4);
PupilAmplitudeChangeMel(theIdx) = a(3, 4);
PupilAmplitudeChangeLMSErr(theIdx) = a(1, 6);
PupilAmplitudeChangeLightFluxErr(theIdx) = a(2, 6);
PupilAmplitudeChangeMelErr(theIdx) = a(3, 6);
PupilPhaseLMS(theIdx) = a(1, 5);
PupilPhaseLightFlux(theIdx) = a(2, 5);
PupilPhaseMel(theIdx) = a(3, 5);
PupilPhaseLMSErr(theIdx) = a(1, 7);
PupilPhaseLightFluxErr(theIdx) = a(2, 7);
PupilPhaseMelErr(theIdx) = a(3, 7);

% Load in data from GA, MM, and MS.
a = csvread('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/PupilNulled0_1Hz/M081815S-results.csv', 1, 1);
theIdx = 2;
PupilAmplitudeChangeLMS(theIdx) = a(1, 4);
PupilAmplitudeChangeLightFlux(theIdx) = a(2, 4);
PupilAmplitudeChangeMel(theIdx) = a(3, 4);
PupilAmplitudeChangeLMSErr(theIdx) = a(1, 6);
PupilAmplitudeChangeLightFluxErr(theIdx) = a(2, 6);
PupilAmplitudeChangeMelErr(theIdx) = a(3, 6);
PupilPhaseLMS(theIdx) = a(1, 5);
PupilPhaseLightFlux(theIdx) = a(2, 5);
PupilPhaseMel(theIdx) = a(3, 5);
PupilPhaseLMSErr(theIdx) = a(1, 7);
PupilPhaseLightFluxErr(theIdx) = a(2, 7);
PupilPhaseMelErr(theIdx) = a(3, 7);

% Load in data from GA, MM, and MS.
a = csvread('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/PupilNulled0_1Hz/M081915M-results.csv', 1, 1);
theIdx = 3;
PupilAmplitudeChangeLMS(theIdx) = a(1, 4);
PupilAmplitudeChangeLightFlux(theIdx) = a(2, 4);
PupilAmplitudeChangeMel(theIdx) = a(3, 4);
PupilAmplitudeChangeLMSErr(theIdx) = a(1, 6);
PupilAmplitudeChangeLightFluxErr(theIdx) = a(2, 6);
PupilAmplitudeChangeMelErr(theIdx) = a(3, 6);
PupilPhaseLMS(theIdx) = a(1, 5);
PupilPhaseLightFlux(theIdx) = a(2, 5);
PupilPhaseMel(theIdx) = a(3, 5);
PupilPhaseLMSErr(theIdx) = a(1, 7);
PupilPhaseLightFluxErr(theIdx) = a(2, 7);
PupilPhaseMelErr(theIdx) = a(3, 7);

%% Make some par plots
%bar([1 2 3], [PupilAmplitudeChangeLightFlux ; PupilAmplitudeChangeLMS]');
for i = 1:3
    h0 = bar(i-0.1, PupilAmplitudeChangeMel(i), 0.1, 'FaceColor',[0 .5 0]);  hold on;
    h1 = bar(i+0.1, PupilAmplitudeChangeLightFlux(i), 0.1, 'FaceColor',[0 .5 .5]); hold on;
    h2 = bar(i, PupilAmplitudeChangeLMS(i), 0.1); hold on;
    errorbar(i-0.1, PupilAmplitudeChangeMel(i), PupilAmplitudeChangeMelErr(i));
    errorbar(i+0.1, PupilAmplitudeChangeLightFlux(i), PupilAmplitudeChangeLightFluxErr(i));
    errorbar(i, PupilAmplitudeChangeLMS(i), PupilAmplitudeChangeLMSErr(i));
end
legend([h0 h1 h2], 'Mel', 'Light flux', 'LMS');
set(gca, 'XTick', [1 2 3]);
set(gca, 'XTickLabel', {'GA', 'MM', 'MS'});
pbaspect([1 1 1]);
title('Error bars are 1SEM across trial');
ylim([0 0.08]);
box off;
ylabel('Pupil amplitude [\Delta%]');
set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [5 5]); %Set the paper to have width 5 and height 5.
saveas(gcf, fullfile(outputDir, 'PupilNulling_LMSVsLightFlux.pdf'), 'pdf'); close (gcf);

%% Determine which subjects to include.
% In the data, MelBright_C013 has no LMS amplitude reported so that was a
% lot of noisy trials. We exlude his or her data her. It also turns out
% that in that subject's raw data file, the first line is L+M+S as opposed
% to Melanopsin.
NonZeroIndices = ~isnan(EachSubjectPupilAmplitudeChangeMel);

% We check that the subjects that we think are 'good' subjects (as defined
% explicitly in the beginning here) corresponding to the set of those that
% we haven't exlucded.
if ~isequal(origName, {SubjectsNulled{NonZeroIndices}})
    error('Check that all subjects you want to include are the correct subjects.');
else
    SubjectsNulled = {SubjectsNulled{NonZeroIndices}};
end


EachSubjectPupilAmplitudeChangeLMS = EachSubjectPupilAmplitudeChangeLMS(NonZeroIndices);
EachSubjectPupilPhaseLMS = EachSubjectPupilPhaseLMS(NonZeroIndices);
EachSubjectPupilAmplitudeChangeMel = EachSubjectPupilAmplitudeChangeMel(NonZeroIndices)
EachSubjectPupilPhaseMel = EachSubjectPupilPhaseMel(NonZeroIndices);

EachSubjectPupilAmplitudeChangeLMSErr = EachSubjectPupilAmplitudeChangeLMSErr(NonZeroIndices);
EachSubjectPupilPhaseLMSErr = EachSubjectPupilPhaseLMSErr(NonZeroIndices);
EachSubjectPupilAmplitudeChangeMelErr = EachSubjectPupilAmplitudeChangeMelErr(NonZeroIndices);
EachSubjectPupilPhaseMelErr = EachSubjectPupilPhaseMelErr(NonZeroIndices);

meanPupilPhaseLMS = circ_mean([EachSubjectPupilPhaseLMS' PupilPhaseLMS]');
meanPupilPhaseMel = circ_mean([EachSubjectPupilPhaseMel' PupilPhaseMel]');
stdPupilPhaseLMS = circ_std([EachSubjectPupilPhaseLMS' PupilPhaseLMS]');
stdPupilPhaseMel = circ_std([EachSubjectPupilPhaseMel' PupilPhaseMel]');

meanPupilAmplitudeLMS = mean([EachSubjectPupilAmplitudeChangeLMS' PupilAmplitudeChangeLMS]);
meanPupilAmplitudeMel = mean([EachSubjectPupilAmplitudeChangeMel' PupilAmplitudeChangeMel]);
stdPupilAmplitudeLMS = std([EachSubjectPupilAmplitudeChangeLMS' PupilAmplitudeChangeLMS]);
stdPupilAmplitudeMel = std([EachSubjectPupilAmplitudeChangeMel' PupilAmplitudeChangeMel]);



%% Use the Stern data
figure
PlotRadius = 0.08; % Create a dummy data point to set the radius axis limit
h0 = polar(PlotRadius, '.k');
set(h0, 'MarkerSize', 0.000001);
hold on
h1 = polar(EachSubjectPupilPhaseLMS, EachSubjectPupilAmplitudeChangeLMS, '.r');
set(h1, 'MarkerSize', 15);
hold on
h2 = polar(EachSubjectPupilPhaseMel, EachSubjectPupilAmplitudeChangeMel, '.b');
set(h2, 'MarkerSize', 15);
%legend([h1, h2], 'LMS', 'Mel', 'Location', 'NorthEastOutside')
hold on;

pbaspect([1 1 1]);
set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [5 5]); %Set the paper to have width 5 and height 5.
saveas(gcf, fullfile(outputDir, 'PupilNulling_PolarPlotSternSubjects.pdf'), 'pdf');
close(gcf);

%%
PlotRadius = 0.08; % Create a dummy data point to set the radius axis limit
h0 = polar(PlotRadius, '.k');
set(h0, 'MarkerSize', 0.000001);
hold on
theMarkers = {'.', '.', '.'};
for i = 1:3 % GA, MM, MS
    t1 = polar(PupilPhaseLMS(i), PupilAmplitudeChangeLMS(i), [theMarkers{i} 'r']);
    set(t1, 'MarkerSize', 15); set(t1, 'MarkerFaceColor', 'r');
    t1 = polar(PupilPhaseMel(i), PupilAmplitudeChangeMel(i), [theMarkers{i} 'b']);
    set(t1, 'MarkerSize', 15); set(t1, 'MarkerFaceColor', 'b');
    %t1 = polar(PupilPhaseLightFlux(i), PupilAmplitudeChangeLightFlux(i), [theMarkers{i} 'k']);
    %set(t1, 'MarkerSize', 13); set(t1, 'MarkerFaceColor', 'k');
end

pbaspect([1 1 1]);
set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [5 5]); %Set the paper to have width 5 and height 5.
saveas(gcf, fullfile(outputDir, 'PupilNulling_PolarPlotHeroSubjects.pdf'), 'pdf');
close(gcf);



%% Make a polar plot
PlotRadius = 0.08; % Create a dummy data point to set the radius axis limit
h0 = polar(PlotRadius, '.k');
set(h0, 'MarkerSize', 0.000001);
hold on

h3 = polar(meanPupilPhaseLMS, meanPupilAmplitudeLMS, '.r')
polar([meanPupilPhaseLMS meanPupilPhaseLMS], [meanPupilAmplitudeLMS-stdPupilAmplitudeLMS meanPupilAmplitudeLMS+stdPupilAmplitudeLMS], '-r');
polar([meanPupilPhaseLMS-stdPupilPhaseLMS meanPupilPhaseLMS meanPupilPhaseLMS+stdPupilPhaseLMS], [meanPupilAmplitudeLMS meanPupilAmplitudeLMS meanPupilAmplitudeLMS], '-r');
set(h3, 'MarkerSize', 20);

h3 = polar(meanPupilPhaseMel, meanPupilAmplitudeMel, '.b')
polar([meanPupilPhaseMel meanPupilPhaseMel], [meanPupilAmplitudeMel-stdPupilAmplitudeMel meanPupilAmplitudeMel+stdPupilAmplitudeMel], '-b');
polar([meanPupilPhaseMel-stdPupilPhaseMel meanPupilPhaseMel meanPupilPhaseMel+stdPupilPhaseMel], [meanPupilAmplitudeMel meanPupilAmplitudeMel meanPupilAmplitudeMel], '-b');
set(h3, 'MarkerSize', 20);
title('Error bars are 1SD');
pbaspect([1 1 1]);
set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [5 5]); %Set the paper to have width 5 and height 5.
saveas(gcf, fullfile(outputDir, 'PupilNulling_PolarPlotAvgSubjects.pdf'), 'pdf');
close(gcf);

%% Save out the data in csv form
% Order is
% LMS Amp, LMS Amp Err, LMS Phase, LMS Phase Err, Mel Amp, Mel Amp Err, Mel
% Phase, Mel Phase Err
HeroSubjects = [PupilAmplitudeChangeLMS' PupilAmplitudeChangeLMSErr' PupilPhaseLMS' PupilPhaseLMSErr' PupilAmplitudeChangeMel' PupilAmplitudeChangeMelErr' PupilPhaseMel' PupilPhaseMelErr' PupilAmplitudeChangeLightFlux' PupilAmplitudeChangeLightFluxErr' PupilPhaseLightFlux' PupilPhaseLightFluxErr']
SternSubjects = [EachSubjectPupilAmplitudeChangeLMS EachSubjectPupilAmplitudeChangeLMSErr' EachSubjectPupilPhaseLMS EachSubjectPupilPhaseLMSErr' EachSubjectPupilAmplitudeChangeMel EachSubjectPupilAmplitudeChangeMelErr' EachSubjectPupilPhaseMel EachSubjectPupilPhaseMelErr']
dlmwrite(fullfile(outputDir, 'PupilNulling_DataTable.csv'), HeroSubjects);
dlmwrite(fullfile(outputDir, 'PupilNulling_DataTable.csv'), SternSubjects ,'-append');


%% Get some info on the nulling
theNullingDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/Nulling';
for i = 1:length(SubjectsNulled)
    tmp = load(fullfile(theNullingDir, [SubjectsNulled{i} '_nulling.mat']));
    
    LMScontrastAddedToMel(i) = mean([tmp.nulling{1, 1}.modulationArm*tmp.nulling{1, 1}.LMScontrastadded tmp.nulling{1, 2}.modulationArm*tmp.nulling{1, 2}.LMScontrastadded]);
    LMinusMcontrastAddedToMel(i) = mean([tmp.nulling{1, 1}.modulationArm*tmp.nulling{1, 1}.LMinusMcontrastadded tmp.nulling{1, 2}.modulationArm*tmp.nulling{1, 2}.LMinusMcontrastadded]);
    LMinusMcontrastAddedToLMS(i) = mean([tmp.nulling{2, 1}.modulationArm*tmp.nulling{2, 1}.LMinusMcontrastadded tmp.nulling{2, 2}.modulationArm*tmp.nulling{2, 2}.LMinusMcontrastadded]);
    
    LMScontrastAddedToMelPos(i) = tmp.nulling{1, 1}.LMScontrastadded;
    LMinusMcontrastAddedToMelPos(i) = tmp.nulling{1, 1}.LMinusMcontrastadded;
    LMinusMcontrastAddedToLMSPos(i) = tmp.nulling{2, 1}.LMinusMcontrastadded;
    
    LMScontrastAddedToMelNeg(i) = tmp.nulling{1, 2}.LMScontrastadded;
    LMinusMcontrastAddedToMelNeg(i) = tmp.nulling{1, 2}.LMinusMcontrastadded;
    LMinusMcontrastAddedToLMSNeg(i) = tmp.nulling{2, 2}.LMinusMcontrastadded;
end

ProSubs = {'G081815A' 'M081815S' 'M081915M'};
theNullingDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/Nulling';
for i = 1:length(ProSubs)
    tmp = load(fullfile(theNullingDir, [ProSubs{i} '_nulling.mat']));
    
    ProLMScontrastAddedToMel(i) = mean([tmp.nulling{1, 1}.modulationArm*tmp.nulling{1, 1}.LMScontrastadded tmp.nulling{1, 2}.modulationArm*tmp.nulling{1, 2}.LMScontrastadded]);
    ProLMinusMcontrastAddedToMel(i) = mean([tmp.nulling{1, 1}.modulationArm*tmp.nulling{1, 1}.LMinusMcontrastadded tmp.nulling{1, 2}.modulationArm*tmp.nulling{1, 2}.LMinusMcontrastadded]);
    ProLMinusMcontrastAddedToLMS(i) = mean([tmp.nulling{2, 1}.modulationArm*tmp.nulling{2, 1}.LMinusMcontrastadded tmp.nulling{2, 2}.modulationArm*tmp.nulling{2, 2}.LMinusMcontrastadded]);
    
    ProLMScontrastAddedToMelPos(i) = tmp.nulling{1, 1}.LMScontrastadded;
    ProLMinusMcontrastAddedToMelPos(i) = tmp.nulling{1, 1}.LMinusMcontrastadded;
    ProLMinusMcontrastAddedToLMSPos(i) = tmp.nulling{2, 1}.LMinusMcontrastadded;
    
    ProLMScontrastAddedToMelNeg(i) = tmp.nulling{1, 2}.LMScontrastadded;
    ProLMinusMcontrastAddedToMelNeg(i) = tmp.nulling{1, 2}.LMinusMcontrastadded;
    ProLMinusMcontrastAddedToLMSNeg(i) = tmp.nulling{2, 2}.LMinusMcontrastadded;
end

HeroSubjects = [ProLMScontrastAddedToMelPos' ProLMinusMcontrastAddedToMelPos' ProLMinusMcontrastAddedToLMSPos' ProLMScontrastAddedToMelNeg' ProLMinusMcontrastAddedToMelNeg' ProLMinusMcontrastAddedToLMSNeg'  ProLMScontrastAddedToMel' ProLMinusMcontrastAddedToMel' ProLMinusMcontrastAddedToLMS'];
SternSubjects = [LMScontrastAddedToMelPos' LMinusMcontrastAddedToMelPos' LMinusMcontrastAddedToLMSPos' LMScontrastAddedToMelNeg' LMinusMcontrastAddedToMelNeg' LMinusMcontrastAddedToLMSNeg'  LMScontrastAddedToMel' LMinusMcontrastAddedToMel' LMinusMcontrastAddedToLMS']
avgSubjects = mean([HeroSubjects ; SternSubjects]);

dlmwrite(fullfile(outputDir, 'PupilNulling_NullingValues.csv'), HeroSubjects);
dlmwrite(fullfile(outputDir, 'PupilNulling_NullingValues.csv'), SternSubjects ,'-append');
dlmwrite(fullfile(outputDir, 'PupilNulling_NullingValues.csv'), avgSubjects ,'-append');

%%
subplot(1, 2, 1);
plot(ProLMScontrastAddedToMel, ProLMinusMcontrastAddedToMel, '.', 'Color', 'k', 'MarkerSize', 10); hold on;
plot(LMScontrastAddedToMel, LMinusMcontrastAddedToMel, '.', 'Color', [0.5 0.5 0.5], 'MarkerSize', 10); hold on;
plot([LMScontrastAddedToMelPos ; LMScontrastAddedToMel ; -LMScontrastAddedToMelNeg], [LMinusMcontrastAddedToMelPos ; LMinusMcontrastAddedToMel ; -LMinusMcontrastAddedToMelNeg], '-ok')
xlim([-0.065 0.065]);
ylim([-0.065 0.065]);
set(gca, 'XTick', [-0.05:0.025:0.05]);
set(gca, 'YTick', [-0.05:0.025:0.05]);
plot([0 0], [-0.065 0.065], '-', 'Color', [0.8 0.8 0.8]);
plot([-0.065 0.065], [0 0], '-', 'Color', [0.8 0.8 0.8]);
box off;

ylabel('L-M contrast added to Mel');
xlabel('L+M+S contrast added to Mel');
pbaspect([1 1 1]);

X = [[ProLMScontrastAddedToMel LMScontrastAddedToMel] ;  [ProLMinusMcontrastAddedToMel LMinusMcontrastAddedToMel]]';

%# indices of points in this group
%# substract mean
idx = 1:length(X);
Mu = mean( X(idx,:) );
X0 = bsxfun(@minus, X(idx,:), Mu);

%# eigen decomposition [sorted by eigen values]
[V D] = eig( X0'*X0 ./ (sum(idx)-1) );     %#' cov(X0)
[D order] = sort(diag(D), 'descend');
D = diag(D);
V = V(:, order);

STD = 2;                     %# 2 standard deviations
conf = 2*normcdf(STD)-1;     %# covers around 95% of population
scale = chi2inv(conf,2);     %# inverse chi-squared with dof=#dimensions

Cov = cov(X0) * scale;
[V D] = eig(Cov);

t = linspace(0,2*pi,100);
e = [cos(t) ; sin(t)];        %# unit circle
VV = V*sqrt(D);               %# scale eigenvectors
e = bsxfun(@plus, VV*e, Mu'); %#' project circle back to orig space

%# plot cov and major/minor axes
%plot(e(1,:), e(2,:), 'Color','k');
%plot(Mu(1), Mu(2), 'ok')
[h, xreturn, yreturn] =error_ellipse(cov(X), mean(X), 'conf', 0.95)

%#quiver(Mu(1),Mu(2), VV(1,1),VV(2,1), 'Color','k')
%#quiver(Mu(1),Mu(2), VV(1,2),VV(2,2), 'Color','k')
title('Error ellipse is 1SD');

subplot(1, 2, 2);
plot(0, ProLMinusMcontrastAddedToLMS, '.', 'Color', 'k', 'MarkerSize', 10); hold on;
plot(0, LMinusMcontrastAddedToLMS, '.', 'Color', [0.5 0.5 0.5], 'MarkerSize', 10); hold on;
plot(-0.005, mean([ProLMinusMcontrastAddedToLMS LMinusMcontrastAddedToLMS]), '.k', 'MarkerSize', 20);
errorbar(-0.005, mean([ProLMinusMcontrastAddedToLMS LMinusMcontrastAddedToLMS]), std([ProLMinusMcontrastAddedToLMS LMinusMcontrastAddedToLMS]));
xlim([-0.01 0.01]);
ylim([-0.065 0.065]);
set(gca, 'XTick', [-0.05:0.025:0.05]);
set(gca, 'YTick', [-0.05:0.025:0.05]);
set(gca, 'XTick', [-0.05:0.025:0.05]);
set(gca, 'YTick', [-0.05:0.025:0.05]);
plot([-0.05 0.05], [0 0], '-', 'Color', [0.8 0.8 0.8]);
box off;
title('Error bar is 1SD');
ylabel('L-M contrast added to LMS');
pbaspect([0.2 0.2 1]);
set(gcf, 'PaperPosition', [0 0 8 5]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [8 5]); %Set the paper to have width 5 and height 5.
saveas(gcf, fullfile(outputDir, 'PupilNulling_NullingData.pdf'), 'pdf');
close(gcf);

%% Plot the two for negative and positive arms
subplot(1, 2, 1);
plot(ProLMScontrastAddedToMelPos, ProLMinusMcontrastAddedToMelPos, '.', 'Color', 'r', 'MarkerSize', 10); hold on;
plot(LMScontrastAddedToMelPos, LMinusMcontrastAddedToMelPos, '.', 'Color', [0.5 0 0], 'MarkerSize', 10); hold on;
X = [[ProLMScontrastAddedToMelPos LMScontrastAddedToMelPos] ;  [ProLMinusMcontrastAddedToMelPos LMinusMcontrastAddedToMelPos]]';
[h, xreturn, yreturn] =error_ellipse(cov(X), mean(X), 'conf', 0.6827)
mu = mean(X);
plot(mu(1), mu(2), '.k', 'MarkerSize', 20);

plot(ProLMScontrastAddedToMelNeg, ProLMinusMcontrastAddedToMelNeg, '.', 'Color', 'b', 'MarkerSize', 10); hold on;
plot(LMScontrastAddedToMelNeg, LMinusMcontrastAddedToMelNeg, '.', 'Color', [0 0 0.5], 'MarkerSize', 10); hold on;
X = [[ProLMScontrastAddedToMelNeg LMScontrastAddedToMelNeg] ;  [ProLMinusMcontrastAddedToMelNeg LMinusMcontrastAddedToMelNeg]]';
[h, xreturn, yreturn] =error_ellipse(cov(X), mean(X), 'conf', 0.6827)
mu = mean(X);
plot(mu(1), mu(2), '.k', 'MarkerSize', 20);

xlim([-0.065 0.065]);
ylim([-0.065 0.065]);
set(gca, 'XTick', [-0.05:0.025:0.05]);
set(gca, 'YTick', [-0.05:0.025:0.05]);
plot([0 0], [-0.065 0.065], '-', 'Color', [0.8 0.8 0.8]);
plot([-0.065 0.065], [0 0], '-', 'Color', [0.8 0.8 0.8]);
box off;

ylabel('L-M contrast added to Mel');
xlabel('L+M+S contrast added to Mel');
pbaspect([1 1 1]);




title('Error ellipse is 1SD');

subplot(1, 2, 2);
plot(0, ProLMinusMcontrastAddedToLMSPos, '.', 'Color', 'r', 'MarkerSize', 10); hold on;
plot(0, LMinusMcontrastAddedToLMSPos, '.', 'Color', [0.5 0 0], 'MarkerSize', 10); hold on;
plot(0, ProLMinusMcontrastAddedToLMSNeg, '.', 'Color', 'b', 'MarkerSize', 10); hold on;
plot(0, LMinusMcontrastAddedToLMSNeg, '.', 'Color', [0 0 0.5], 'MarkerSize', 10); hold on;
plot(-0.005, mean([ProLMinusMcontrastAddedToLMSPos LMinusMcontrastAddedToLMSPos]), '.k', 'MarkerSize', 20);
errorbar(-0.005, mean([ProLMinusMcontrastAddedToLMSPos LMinusMcontrastAddedToLMSPos]), std([ProLMinusMcontrastAddedToLMSPos LMinusMcontrastAddedToLMSPos]));

plot(-0.005, mean([ProLMinusMcontrastAddedToLMSNeg LMinusMcontrastAddedToLMSNeg]), '.k', 'MarkerSize', 20);
errorbar(-0.005, mean([ProLMinusMcontrastAddedToLMSNeg LMinusMcontrastAddedToLMSNeg]), std([ProLMinusMcontrastAddedToLMSNeg LMinusMcontrastAddedToLMSNeg]));

xlim([-0.01 0.01]);
ylim([-0.065 0.065]);
set(gca, 'XTick', [-0.05:0.025:0.05]);
set(gca, 'YTick', [-0.05:0.025:0.05]);
set(gca, 'XTick', [-0.05:0.025:0.05]);
set(gca, 'YTick', [-0.05:0.025:0.05]);
plot([-0.05 0.05], [0 0], '-', 'Color', [0.8 0.8 0.8]);
box off;
title('Error bar is 1SD');
ylabel('L-M contrast added to LMS');
pbaspect([0.2 0.2 1]);
set(gcf, 'PaperPosition', [0 0 8 5]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [8 5]); %Set the paper to have width 5 and height 5.
saveas(gcf, fullfile(outputDir, 'PupilNulling_NullingDataPosAndNeg.pdf'), 'pdf');
close(gcf);

%% Nulling data for the fMRI experiments in July
fMRISubs = {'G071715A' 'M071715S' 'M071715M'}
theNullingDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/Nulling';
for i = 1:length(fMRISubs);
    tmp = load(fullfile(theNullingDir, [fMRISubs{i} '_nulling.mat']));
    
    ProLMScontrastAddedToMel(i) = mean([tmp.nulling{1, 1}.modulationArm*tmp.nulling{1, 1}.LMScontrastadded tmp.nulling{1, 2}.modulationArm*tmp.nulling{1, 2}.LMScontrastadded]);
    ProLMinusMcontrastAddedToMel(i) = mean([tmp.nulling{1, 1}.modulationArm*tmp.nulling{1, 1}.LMinusMcontrastadded tmp.nulling{1, 2}.modulationArm*tmp.nulling{1, 2}.LMinusMcontrastadded]);
    
    ProLMScontrastAddedToMelPos(i) = tmp.nulling{1, 1}.LMScontrastadded;
    ProLMinusMcontrastAddedToMelPos(i) = tmp.nulling{1, 1}.LMinusMcontrastadded;
    
    ProLMScontrastAddedToMelNeg(i) = tmp.nulling{1, 2}.LMScontrastadded;
    ProLMinusMcontrastAddedToMelNeg(i) = tmp.nulling{1, 2}.LMinusMcontrastadded;
end
HeroSubjects = [ProLMScontrastAddedToMelPos' ProLMinusMcontrastAddedToMelPos' ProLMScontrastAddedToMelNeg' ProLMinusMcontrastAddedToMelNeg'  ProLMScontrastAddedToMel' ProLMinusMcontrastAddedToMel'];
dlmwrite(fullfile(outputDir, 'PupilNulling_NullingValues_071715.csv'), HeroSubjects ,'-append');