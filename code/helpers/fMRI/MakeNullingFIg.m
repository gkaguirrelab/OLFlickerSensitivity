
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
a = csvread('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/PupilNulled0_1Hz/M081915M-results.csv', 1, 1);
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
a = csvread('/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/PupilNulled0_1Hz/M081815S-results.csv', 1, 1);
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

%% Use the Stern data
figure
PlotRadius = 0.08; % Create a dummy data point to set the radius axis limit
h0 = polar(PlotRadius, '.k');
set(h0, 'MarkerSize', 0.000001);
% hold on
% h1 = polar(EachSubjectPupilPhaseLMS, EachSubjectPupilAmplitudeChangeLMS, '.r');
% set(h1, 'MarkerSize', 20);
% hold on
% h2 = polar(EachSubjectPupilPhaseMel, EachSubjectPupilAmplitudeChangeMel, '.b');
% set(h2, 'MarkerSize', 20);
title('Mel and LMS nulled pupil responses')
%legend([h1, h2], 'LMS', 'Mel', 'Location', 'NorthEastOutside')
hold on;

theMarkers = {'s', '^', '>'};
for i = 1:3 % GA, MM, MS
    t1 = polar(PupilPhaseLMS(i), PupilAmplitudeChangeLMS(i), [theMarkers{i} 'k']);
    set(t1, 'MarkerSize', 13); set(t1, 'MarkerFaceColor', 'r');
    t1 = polar(PupilPhaseMel(i), PupilAmplitudeChangeMel(i), [theMarkers{i} 'k']);
    set(t1, 'MarkerSize', 13); set(t1, 'MarkerFaceColor', 'b');
    t1 = polar(PupilPhaseLightFlux(i), PupilAmplitudeChangeLightFlux(i), [theMarkers{i} 'k']);
    set(t1, 'MarkerSize', 13); set(t1, 'MarkerFaceColor', 'k');
end


NonZeroIndices = ~isnan(EachSubjectPupilAmplitudeChangeMel);
EachSubjectPupilAmplitudeChangeLMS = EachSubjectPupilAmplitudeChangeLMS(NonZeroIndices);
EachSubjectPupilPhaseLMS = EachSubjectPupilPhaseLMS(NonZeroIndices);
EachSubjectPupilAmplitudeChangeMel = EachSubjectPupilAmplitudeChangeMel(NonZeroIndices)
EachSubjectPupilPhaseMel = EachSubjectPupilPhaseMel(NonZeroIndices);

meanPupilPhaseLMS = circ_mean(EachSubjectPupilPhaseLMS(~isnan(EachSubjectPupilPhaseLMS)));
meanPupilPhaseMel = circ_mean(EachSubjectPupilPhaseMel(~isnan(EachSubjectPupilPhaseMel)));

meanPupilAmplitudeLMS = mean(EachSubjectPupilAmplitudeChangeLMS);
meanPupilAmplitudeMel = mean(EachSubjectPupilAmplitudeChangeMel );
semPupilAmplitudeLMS = std(EachSubjectPupilAmplitudeChangeLMS)/sqrt(length(EachSubjectPupilAmplitudeChangeLMS));
semPupilAmplitudeMel = std(EachSubjectPupilAmplitudeChangeMel)/sqrt(length(EachSubjectPupilAmplitudeChangeMel));

h3 = polar(meanPupilPhaseLMS, meanPupilAmplitudeLMS, 'or')
set(h3, 'MarkerSize', 20);


h3 = polar(meanPupilPhaseMel, meanPupilAmplitudeMel, 'ob')
set(h3, 'MarkerSize', 20);


%% Sort
theOrder = 1:length(NonZeroIndices)
h1 = plot(5+[1:length(NonZeroIndices)], 100*EachSubjectPupilAmplitudeChangeLMS(theOrder), 'or', 'MarkerFaceColor', 'r'); hold on;
h2 = plot(5+[1:length(NonZeroIndices)], 100*EachSubjectPupilAmplitudeChangeMel(theOrder), 'ob', 'MarkerFaceColor', 'b')
errorbar(5, 100*meanPupilAmplitudeMel, 100*2*semPupilAmplitudeMel, 'ob', 'MarkerFaceColor', 'b')
errorbar(5, 100*meanPupilAmplitudeMel, 100*2*semPupilAmplitudeMel)
errorbar(5, 100*meanPupilAmplitudeLMS, 100*2*semPupilAmplitudeLMS, 'or', 'MarkerFaceColor', 'r')
errorbar(5, 100*meanPupilAmplitudeLMS, 100*2*semPupilAmplitudeLMS)

set(gca, 'XTick', [1 2 3 5:16]);
set(gca, 'XTickLabel', {'GA', 'MM', 'MS', 'G', 's01', 's02' 's03', 's04' 's05', 's06' 's07', 's08', 's09' 's10', 's11'});



xlim([0 18]);
ylim([0 10]);
xlabel('Subjects');
ylabel('% change');
legend([h1, h2], 'LMS', 'Mel', 'Location', 'NorthEast'); legend boxoff;
box off;



%% Get some info on the nulling
theNullingDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/Nulling';
for i = 1:length(SubjectsNulled)
    tmp = load(fullfile(theNullingDir, [SubjectsNulled{i} '_nulling.mat']));
    
    LMScontrastAddedToMel(i) = mean([tmp.nulling{1, 1}.modulationArm*tmp.nulling{1, 1}.LMScontrastadded tmp.nulling{1, 2}.modulationArm*tmp.nulling{1, 2}.LMScontrastadded]);
    LMinusMcontrastAddedToMel(i) = mean([tmp.nulling{1, 1}.modulationArm*tmp.nulling{1, 1}.LMinusMcontrastadded tmp.nulling{1, 2}.modulationArm*tmp.nulling{1, 2}.LMinusMcontrastadded]);
    LMinusMcontrastAddedToLMS(i) = mean([tmp.nulling{2, 1}.modulationArm*tmp.nulling{2, 1}.LMinusMcontrastadded tmp.nulling{2, 2}.modulationArm*tmp.nulling{2, 2}.LMinusMcontrastadded]);
end

ProSubs = {'G081815A' 'M081815S' 'M081915M'};
theNullingDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/Nulling';
for i = 1:length(ProSubs)
    tmp = load(fullfile(theNullingDir, [ProSubs{i} '_nulling.mat']));
    
    ProLMScontrastAddedToMel(i) = mean([tmp.nulling{1, 1}.modulationArm*tmp.nulling{1, 1}.LMScontrastadded tmp.nulling{1, 2}.modulationArm*tmp.nulling{1, 2}.LMScontrastadded]);
    ProLMinusMcontrastAddedToMel(i) = mean([tmp.nulling{1, 1}.modulationArm*tmp.nulling{1, 1}.LMinusMcontrastadded tmp.nulling{1, 2}.modulationArm*tmp.nulling{1, 2}.LMinusMcontrastadded]);
    ProLMinusMcontrastAddedToLMS(i) = mean([tmp.nulling{2, 1}.modulationArm*tmp.nulling{2, 1}.LMinusMcontrastadded tmp.nulling{2, 2}.modulationArm*tmp.nulling{2, 2}.LMinusMcontrastadded]);
end



%%

plot(ProLMScontrastAddedToMel, ProLMinusMcontrastAddedToMel, 'sk', 'MarkerFaceColor', 'k', 'MarkerSize', 10); hold on;
plot(LMScontrastAddedToMel, LMinusMcontrastAddedToMel, 'sk', 'MarkerFaceColor', [0.5 0.5 0.5]); hold on;

xlim([-0.05 0.05]);
ylim([-0.05 0.05]);
set(gca, 'XTick', [-0.05:0.025:0.05]);
set(gca, 'YTick', [-0.05:0.025:0.05]);
plot([0 0], [-0.05 0.05], '-', 'Color', [0.8 0.8 0.8]);
plot([-0.05 0.05], [0 0], '-', 'Color', [0.8 0.8 0.8]);
box off;

ylabel('L-M contrast added to Mel');
xlabel('L+M+S contrast added to Mel');
pbaspect([1 1 1]);

X = [LMScontrastAddedToMel ProLMScontrastAddedToMel], [LMinusMcontrastAddedToMel ProLMinusMcontrastAddedToMel];

    %# indices of points in this group
    %# substract mean
    idx = length(X);
    Mu = mean( X(idx,:) );
    X0 = bsxfun(@minus, X(idx,:), Mu);

    %# eigen decomposition [sorted by eigen values]
    [V D] = eig( X0'*X0 ./ (sum(idx)-1) );     %#' cov(X0)
    [D order] = sort(diag(D), 'descend');
    D = diag(D);
    V = V(:, order);

    t = linspace(0,2*pi,100);
    e = [cos(t) ; sin(t)];        %# unit circle
    VV = V*sqrt(D);               %# scale eigenvectors
    e = bsxfun(@plus, VV*e, Mu'); %#' project circle back to orig space

    %# plot cov and major/minor axes
    plot(e(1,:), e(2,:), 'Color','k');
    %#quiver(Mu(1),Mu(2), VV(1,1),VV(2,1), 'Color','k')
    %#quiver(Mu(1),Mu(2), VV(1,2),VV(2,2), 'Color','k')



STD = 2;                     %# 2 standard deviations
conf = 2*normcdf(STD)-1;     %# covers around 95% of population
scale = chi2inv(conf,2);     %# inverse chi-squared with dof=#dimensions

Cov = cov(X0) * scale;
[V D] = eig(Cov);

set(gcf, 'PaperPosition', [0 0 5 5]); %Position plot at left hand corner with width 5 and height 5.
set(gcf, 'PaperSize', [5 5]); %Set the paper to have width 5 and height 5.
saveas(gcf, 'nullingFig.pdf', 'pdf');
