%
% Loads and analyzes brightness rating and EMG data from the pilot
% brightness rating experiment
%
% 2015-01-27 AMS
% 2015-02-02 gka and AMS -- expanded to analyze pilot brightness data and
%   fit a linear model of mel and LMS effect
% 2015-02-03 AMS added analysis of EMG data
% 2015-02-03 gka added fit lines to the plots and removed the mean EMG
%   aggregation across trials, as only the median should be used. In fact,
%   further work will be needed to deal with the highly skewed distribution
%   of values we get from the EMG variance data. 
% 2015-02-23 AMS added code to analyze test-retest reliability. For now, simply
%   created a nSubs x 2 matrix with columns corresponding to test and retest.
%   This will produce an error when retest data are not available for any
%   subjects, so for now is commented out.
% 2015-02-25 AMS added code to plot test-retest data. 
% 2015-02-28 AMS hard-coded in the subject visual sensitivity and global
%   seasonality scores. Also added some plots and linear model fits of Mel
%   slopes to these data.
% 2015-03-02 AMS added code to plot the test-retest reliability with test
%   on one axis and retest on the other. Also added code that computes the
%   average of the test and retest brightness ratings and EMG variances, then
%   uses those for the subsequent linear modeling and plots.
% 2015-03-09 AMS added code to impute the median EMG variance for any
% trials in which the variance was greater than 5 standard deviations above
% the median for that experiment. Found upon examination that without this, occasional
% trials had huge spikes likely due to temporary loss of connection and not
% due to squint. After this, removed the log-transformation of values and
% used mean-centering instead of median for input into the linear model.
% 2015-03-10 AMS now have both mean of mean-centered and median of
% mean-centered EMG variances, as well as linear models and graphs for
% both. Also introduced interaction term into linear models for EMG data.
% Also removed interaction term from within-subject linear models of
% brightness ratings.


DataDir='/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/BrightnessRatingTaskDim/';

% separate entries in the subject list by semicolons

Subjects=cellstr(['A031115S'])
nSubs=length(Subjects);

% Visual sensitivity score and global seasonality score hard-coded from
% survey results

VisualSensitivityScore = [5; 2; 0; 7; 7; 7; 4; 3; 13; 8; 2; 6];
GlobalSeasonalityScore = [5; 9; 10; 10; 13; 2; 3; 14; 7; 6; 3; 8];

BrightnessBetaData=zeros(nSubs,3);

BrightnessIndividualFitQuality=zeros(nSubs,1);

EachSubjectAverageBrightness=zeros(19,nSubs);

EachSubjectAverageEMGVariance=zeros(19,nSubs);
EachSubjectMedianEMGVariance=zeros(19,nSubs);


% Loop through the subjects, load the data, retain relevant values

for i=1:nSubs
    
    % Assemble the filename of the data set for this subject
    
    DataFile=[char(DataDir),char(Subjects(i)),'/',char(Subjects(i)),'-BrightnessRatingTaskDim-1.mat'];
    
    % load the data and split out the vectors for contrast, brightness
    % rating, and EMG variances
    
    load(DataFile);
    data=struct2cell(params.dataStruct);
    BrightnessVector=cell2mat(data(3,:,:));
    BrightnessVector=reshape(BrightnessVector,length(BrightnessVector),1,1);
    
    MelContrastVector=cell2mat(data(4,:,:));
    MelContrastVector=reshape(MelContrastVector,length(MelContrastVector),1,1);
    
    LMSContrastVector=cell2mat(data(5,:,:));
    LMSContrastVector=reshape(LMSContrastVector,length(LMSContrastVector),1,1);
    
    EMGCellArray = data(2,:,:);
    EMGVarianceVector = zeros(length(EMGCellArray),1);
    for k = 1:length(EMGCellArray)
        EMGVarianceVector(k) = var(EMGCellArray{k});
    end
    
    % For any EMG variances that are more than 5 standard deviations
    % above the median, impute the median
    
    BadIndicesEMG = find(EMGVarianceVector>(median(EMGVarianceVector)+5*std(EMGVarianceVector)));
    for k = 1:length(BadIndicesEMG)
        EMGVarianceVector(BadIndicesEMG(k)) = median(EMGVarianceVector);
    end  
    
    % Discard first three trials, which were calibrating the response scale
    
    MelContrastVector=MelContrastVector(4:end);
    LMSContrastVector=LMSContrastVector(4:end);
    BrightnessVector=BrightnessVector(4:end);
    EMGVarianceVector=EMGVarianceVector(4:end);
    
    % Sanity check rating data and remove out of bound ratings
    
    BadIndices=find(BrightnessVector>100);
    if ~isempty(BadIndices)
        BrightnessVector(BadIndices)=[];
        MelContrastVector(BadIndices)=[];
        LMSContrastVector(BadIndices)=[];
        EMGVarianceVector(BadIndices)=[];
    end
    
    % Fit a linear model of Mel and LMS contrast to the rating
    
   
    X=[MelContrastVector,LMSContrastVector];
    [IndividualBrightnessBetas,~,~] = glmfit(X,BrightnessVector);
    Fit=X*IndividualBrightnessBetas(2:3)+IndividualBrightnessBetas(1);
    VarianceExplained=corr([Fit,BrightnessVector]).^2;
    BrightnessIndividualFitQuality(i)=VarianceExplained(1,2);
    BrightnessBetaData(i,:)=IndividualBrightnessBetas;
        
%     % Normalize the EMG variance values by log transforming and then
%     % median centering
    
%     EMGVarianceVector=log(EMGVarianceVector);
%     EMGVarianceVector=EMGVarianceVector-median(EMGVarianceVector);
    
   % Mean-center the variance values


    EMGVarianceVector=EMGVarianceVector-mean(EMGVarianceVector);
    
    % Obtain the average rating and EMG variance by Mel and LMS contrast
    % crossing, as well as median EMG variance
    
    [xconRating,yconRating]=consolidator([MelContrastVector,LMSContrastVector],BrightnessVector);
    [xconEMGavg,yconEMGavg]=consolidator([MelContrastVector,LMSContrastVector],EMGVarianceVector);
    [xconEMGmed,yconEMGmed]=consolidator([MelContrastVector,LMSContrastVector],EMGVarianceVector,@median);
    if i == 1
        MelContrastForAverages=xconRating(:,1);
        LMSContrastForAverages=xconRating(:,2);
    end
    
        
    EachSubjectAverageBrightness(:,i)=yconRating;
    EachSubjectAverageEMGVariance(:,i)=yconEMGavg;
    EachSubjectMedianEMGVariance(:,i)=yconEMGmed;
    
    
    
end

       
%     % Plot a summary of EMG variances per subject
%     
%     figure
%     plot(linspace(1,178,178),EMGVarianceVector);
%     hold on
%     plot(linspace(1,178,178),EMGVarianceVector2,'-r');
%     hold off


% Calculate the central tendency of the across-subject data

AcrossSubjectAverageBrightness=mean(EachSubjectAverageBrightness,2);
AcrossSubjectStdBrightness=std(EachSubjectAverageBrightness,0,2);
AcrossSubjectSEMBrightness=std(EachSubjectAverageBrightness,0,2)/sqrt(nSubs);

AcrossSubjectAverageofMediansEMG=mean(EachSubjectMedianEMGVariance,2);
AcrossSubjectStdofMediansEMG=std(EachSubjectMedianEMGVariance,0,2);
AcrossSubjectSEMofMediansEMG=std(EachSubjectMedianEMGVariance,0,2)/sqrt(nSubs);

AcrossSubjectAverageofAveragesEMG=mean(EachSubjectAverageEMGVariance,2);
AcrossSubjectStdofAveragesEMG=std(EachSubjectAverageEMGVariance,0,2);
AcrossSubjectSEMofAveragesEMG=std(EachSubjectAverageEMGVariance,0,2)/sqrt(nSubs);

% Fit a linear model of Mel and LMS contrast to the across subject average
% rating data

X=[MelContrastForAverages,LMSContrastForAverages];
[AverageBrightnesBetas,~,AverageBrightnessStats]=glmfit(X,AcrossSubjectAverageBrightness);
AverageBrightnessFit=X*AverageBrightnesBetas(2:3)+AverageBrightnesBetas(1);
VarianceExplainedBrightness=corr([AverageBrightnessFit,AcrossSubjectAverageBrightness]).^2;
AverageBrightnessFitQuality=VarianceExplainedBrightness(1,2);

% Report some values from the brightness rating

fprintf('\n');
fprintf(['Brightness rating -- \n']);
fprintf(['Number of subjects: ' num2str(nSubs) '\n']);
fprintf(['Mel slope: ' num2str(AverageBrightnesBetas(2),'%1.2f') ', t(' num2str(AverageBrightnessStats.dfe,'%1.0f') ')=' num2str(AverageBrightnessStats.t(2),'%1.2f') ', p=' num2str(AverageBrightnessStats.p(2),'%1.2e') '\n']);
fprintf(['LMS slope: ' num2str(AverageBrightnesBetas(3),'%1.2f') ', t(' num2str(AverageBrightnessStats.dfe,'%1.0f') ')=' num2str(AverageBrightnessStats.t(3),'%1.2f') ', p=' num2str(AverageBrightnessStats.p(3),'%1.2e') '\n']);
fprintf('\n');

    
% Identify the set of contrast levels used

UniqueMelContrastLevels=unique(MelContrastForAverages);
UniqueLMSContrastLevels=unique(LMSContrastForAverages);

% Create a plot of brightness rating as a function of Mel contrast, with
% separate lines for each level of LMS contrast studied

figure
for i=1:length(UniqueLMSContrastLevels)
    TheShadeofGray=1*((i-1)/length(UniqueLMSContrastLevels));
    GrayTriplet=[TheShadeofGray TheShadeofGray TheShadeofGray];
    TargetIndices=find(LMSContrastForAverages==UniqueLMSContrastLevels(i));
    plot(MelContrastForAverages(TargetIndices),AverageBrightnessFit(TargetIndices),'-r');
    if i==i
        hold on
    end
    ylim([0,100]);
    errorbar(MelContrastForAverages(TargetIndices),AcrossSubjectAverageBrightness(TargetIndices),AcrossSubjectSEMBrightness(TargetIndices),'Color',GrayTriplet,'Marker', 'none', 'LineStyle', 'none');
    plot(MelContrastForAverages(TargetIndices),AcrossSubjectAverageBrightness(TargetIndices),'o','MarkerEdgeColor','none','MarkerFaceColor',GrayTriplet,'MarkerSize',10);
end
title('Brightness rating as a function of Mel contrast')
xlabel('Relative Mel contrast') % x-axis label
ylabel('Brightness rating [0-100]') % y-axis label
hold off
% 
% % Fit a linear model of Mel and LMS contrast to the median EMG variances
% with interaction term
% 
% interact=(MelContrastForAverages+1).*(LMSContrastForAverages+1);
% X=[MelContrastForAverages, LMSContrastForAverages,interact];
% [AverageEMGBetas,~,AverageEMGStats] = glmfit(X,AcrossSubjectAverageofMediansEMG);
% AverageEMGFit=X*AverageEMGBetas(2:4)+AverageEMGBetas(1);
% EMGVarianceExplained=corr([AverageEMGFit,AcrossSubjectAverageofMediansEMG]).^2;
% AverageEMGDataFitQuality=EMGVarianceExplained(1,2);
% 
% % Report some values from the median EMG variance with interaction term
% 
% fprintf(['EMG Variance [across-subject mean of within-subject median of mean-centered variance] -- \n']);
% fprintf(['Number of subjects: ' num2str(nSubs) '\n']);
% fprintf(['Mel slope: ' num2str(AverageEMGBetas(2),'%1.2e') ', t(' num2str(AverageEMGStats.dfe,'%1.0f') ')=' num2str(AverageEMGStats.t(2),'%1.2f') ', p=' num2str(AverageEMGStats.p(2),'%1.2e') '\n']);
% fprintf(['LMS slope: ' num2str(AverageEMGBetas(3),'%1.2e') ', t(' num2str(AverageEMGStats.dfe,'%1.0f') ')=' num2str(AverageEMGStats.t(3),'%1.2f') ', p=' num2str(AverageEMGStats.p(3),'%1.2e') '\n']);
% fprintf(['Interaction slope: ' num2str(AverageEMGBetas(4),'%1.2e') ', t(' num2str(AverageEMGStats.dfe,'%1.0f') ')=' num2str(AverageEMGStats.t(4),'%1.2f') ', p=' num2str(AverageEMGStats.p(4),'%1.2e') '\n']);
% fprintf('\n');


% Fit a linear model of Mel and LMS contrast to the median EMG variances
% without interaction term

X=[MelContrastForAverages, LMSContrastForAverages];
[AverageEMGBetas,~,AverageEMGStats] = glmfit(X,AcrossSubjectAverageofMediansEMG);
AverageEMGFit=X*AverageEMGBetas(2:3)+AverageEMGBetas(1);
EMGVarianceExplained=corr([AverageEMGFit,AcrossSubjectAverageofMediansEMG]).^2;
AverageEMGDataFitQuality=EMGVarianceExplained(1,2);

% Report some values from the median EMG variance without interaction term

fprintf(['EMG Variance [across-subject mean of within-subject median of mean-centered variance] -- \n']);
fprintf(['Number of subjects: ' num2str(nSubs) '\n']);
fprintf(['Mel slope: ' num2str(AverageEMGBetas(2),'%1.2e') ', t(' num2str(AverageEMGStats.dfe,'%1.0f') ')=' num2str(AverageEMGStats.t(2),'%1.2f') ', p=' num2str(AverageEMGStats.p(2),'%1.2e') '\n']);
fprintf(['LMS slope: ' num2str(AverageEMGBetas(3),'%1.2e') ', t(' num2str(AverageEMGStats.dfe,'%1.0f') ')=' num2str(AverageEMGStats.t(3),'%1.2f') ', p=' num2str(AverageEMGStats.p(3),'%1.2e') '\n']);
fprintf('\n');


% Create a plot of the average (across subjects) of median EMG variance
% (per subject) as a function of Mel contrast, with separate lines for each
% level of LMS contrast studied

figure
for i=1:length(UniqueLMSContrastLevels)
    TheShadeofGray=1*((i-1)/length(UniqueLMSContrastLevels));
    GrayTriplet=[TheShadeofGray TheShadeofGray TheShadeofGray];
    TargetIndices=find(LMSContrastForAverages==UniqueLMSContrastLevels(i));
    plot(MelContrastForAverages(TargetIndices),AverageEMGFit(TargetIndices),'-r');
    if i==i
        hold on
    end
%    ylim([0,0.002]);
    errorbar(MelContrastForAverages(TargetIndices),AcrossSubjectAverageofMediansEMG(TargetIndices),AcrossSubjectSEMofMediansEMG(TargetIndices),'Color',GrayTriplet,'Marker', 'none', 'LineStyle', 'none');
    plot(MelContrastForAverages(TargetIndices),AcrossSubjectAverageofMediansEMG(TargetIndices),'o','MarkerEdgeColor','none','MarkerFaceColor',GrayTriplet,'MarkerSize',10);
end
title('Orbicularis EMG variance as a function of Mel contrast')
xlabel('Relative Mel contrast') % x-axis label
ylabel('EMG variance [across-subject mean of within-subject median of mean-centered variance]') % y-axis label
hold off

% % Fit a linear model of Mel and LMS contrast to the mean EMG variances with
% % interaction term
% 
% interact=(MelContrastForAverages+1).*(LMSContrastForAverages+1);
% X=[MelContrastForAverages, LMSContrastForAverages,interact];
% [AverageEMGBetas,~,AverageEMGStats] = glmfit(X,AcrossSubjectAverageofAveragesEMG);
% AverageEMGFit=X*AverageEMGBetas(2:4)+AverageEMGBetas(1);
% EMGVarianceExplained=corr([AverageEMGFit,AcrossSubjectAverageofAveragesEMG]).^2;
% AverageEMGDataFitQuality=EMGVarianceExplained(1,2);
% 
% % Report some values from the mean EMG variance with interaction term
% 
% fprintf(['EMG Variance [across-subject mean of within-subject mean of mean-centered variance] -- \n']);
% fprintf(['Number of subjects: ' num2str(nSubs) '\n']);
% fprintf(['Mel slope: ' num2str(AverageEMGBetas(2),'%1.2e') ', t(' num2str(AverageEMGStats.dfe,'%1.0f') ')=' num2str(AverageEMGStats.t(2),'%1.2f') ', p=' num2str(AverageEMGStats.p(2),'%1.2e') '\n']);
% fprintf(['LMS slope: ' num2str(AverageEMGBetas(3),'%1.2e') ', t(' num2str(AverageEMGStats.dfe,'%1.0f') ')=' num2str(AverageEMGStats.t(3),'%1.2f') ', p=' num2str(AverageEMGStats.p(3),'%1.2e') '\n']);
% fprintf(['Interaction slope: ' num2str(AverageEMGBetas(4),'%1.2e') ', t(' num2str(AverageEMGStats.dfe,'%1.0f') ')=' num2str(AverageEMGStats.t(4),'%1.2f') ', p=' num2str(AverageEMGStats.p(4),'%1.2e') '\n']);
% fprintf('\n');

% Fit a linear model of Mel and LMS contrast to the mean EMG variances
% without interaction term

X=[MelContrastForAverages, LMSContrastForAverages];
[AverageEMGBetas,~,AverageEMGStats] = glmfit(X,AcrossSubjectAverageofAveragesEMG);
AverageEMGFit=X*AverageEMGBetas(2:3)+AverageEMGBetas(1);
EMGVarianceExplained=corr([AverageEMGFit,AcrossSubjectAverageofAveragesEMG]).^2;
AverageEMGDataFitQuality=EMGVarianceExplained(1,2);

% Report some values from the mean EMG variance without interaction term

fprintf(['EMG Variance [across-subject mean of within-subject mean of mean-centered variance] -- \n']);
fprintf(['Number of subjects: ' num2str(nSubs) '\n']);
fprintf(['Mel slope: ' num2str(AverageEMGBetas(2),'%1.2e') ', t(' num2str(AverageEMGStats.dfe,'%1.0f') ')=' num2str(AverageEMGStats.t(2),'%1.2f') ', p=' num2str(AverageEMGStats.p(2),'%1.2e') '\n']);
fprintf(['LMS slope: ' num2str(AverageEMGBetas(3),'%1.2e') ', t(' num2str(AverageEMGStats.dfe,'%1.0f') ')=' num2str(AverageEMGStats.t(3),'%1.2f') ', p=' num2str(AverageEMGStats.p(3),'%1.2e') '\n']);
fprintf('\n');

% Create a plot of the average (across subjects) of mean EMG variance
% (per subject) as a function of Mel contrast, with separate lines for each
% level of LMS contrast studied

figure
for i=1:length(UniqueLMSContrastLevels)
    TheShadeofGray=1*((i-1)/length(UniqueLMSContrastLevels));
    GrayTriplet=[TheShadeofGray TheShadeofGray TheShadeofGray];
    TargetIndices=find(LMSContrastForAverages==UniqueLMSContrastLevels(i));
    plot(MelContrastForAverages(TargetIndices),AverageEMGFit(TargetIndices),'-r');
    if i==i
        hold on
    end
%    ylim([0,0.002]);
    errorbar(MelContrastForAverages(TargetIndices),AcrossSubjectAverageofAveragesEMG(TargetIndices),AcrossSubjectSEMofAveragesEMG(TargetIndices),'Color',GrayTriplet,'Marker', 'none', 'LineStyle', 'none');
    plot(MelContrastForAverages(TargetIndices),AcrossSubjectAverageofAveragesEMG(TargetIndices),'o','MarkerEdgeColor','none','MarkerFaceColor',GrayTriplet,'MarkerSize',10);
end
title('Orbicularis EMG variance as a function of Mel contrast')
xlabel('Relative Mel contrast') % x-axis label
ylabel('EMG variance [across-subject mean of within-subject mean of mean-centered variance]') % y-axis label
hold off


% % Create plots of the test-retest brightness rating data with separate
% % lines for each subject
% 
% figure
% TestRetestXAxis = [1 2];
% for i=1:nSubs
%     plot(TestRetestXAxis, TestRetestMelBrightnessSlope(i,:), '-or')
%     hold on
% end
% xlim([0.5 2.5]);
% ylim([-50 50]);
% title('Test-retest reliability of melanopsin brightness slope');
% ylabel('Mel slope');
% ax = gca;
% set(ax, 'XTick', [1 2]);
% set(ax, 'XTickLabel',{'Test','Retest'});
% hold off
% 
% figure
% for i=1:nSubs
%     plot(TestRetestXAxis, TestRetestLMSBrightnessSlope(i,:), '-o')
%     hold on
% end
% xlim([0.5 2.5]);
% ylim([-50 50]);
% title('Test-retest reliability of LMS brightness slope');
% ylabel('LMS slope');
% ax = gca;
% set(ax, 'XTick', [1 2]);
% set(ax, 'XTickLabel',{'Test','Retest'});
% hold off
% 
% TestRetestRatio = TestRetestMelBrightnessSlope./TestRetestLMSBrightnessSlope;
% figure
% for i=1:nSubs
%     plot(TestRetestXAxis, TestRetestRatio(i,:), '-og')
%     hold on
% end
% xlim([0.5 2.5]);
% ylim([-2 2]);
% title('Test-retest reliability of ratio of Mel to LMS brightness slope');
% ylabel('Ratio of Mel/LMS slopes');
% ax = gca;
% set(ax, 'XTick', [1 2]);
% set(ax, 'XTickLabel',{'Test','Retest'});
% hold off

% Plot the individual subjects according to their slopes for Mel and LMS

figure
scatter(BrightnessBetaData(:,2), BrightnessBetaData(:,3));
xlim([-40 40]);
ylim([-60 60]);
hold on
plot([-100 100],[0 0],'--k');
plot([0 0],[-100 100],'--k');
xlabel('Mel slope');
ylabel('LMS slope');
title('Distribution of Mel and LMS contributions to brightness ratings');
hold off


% % Fit a linear model and plot Mel scores versus visual sensitivity and seasonality
% 
% [bVSS, devVSS, statsVSS] = glmfit(BrightnessBetaDataTwoRuns(:,2),VisualSensitivityScore);
% figure
% scatter(BrightnessBetaDataTwoRuns(:,2), VisualSensitivityScore);
% xlabel('Mel slope');
% ylabel('Visual sensitivity score');
% title('Correlation of visual sensitivity score with Mel slope')
% 
% [bGSS, devGSS, statsGSS] = glmfit(BrightnessBetaDataTwoRuns(:,2),GlobalSeasonalityScore);
% figure
% scatter(BrightnessBetaDataTwoRuns(:,2), GlobalSeasonalityScore);
% xlabel('Mel slope');
% ylabel('Global seasonality score');
% title('Correlation of global seasonality score with Mel slope')

%Plot Mel slopes versus individual fit quality

figure
scatter(BrightnessBetaData(:,2),BrightnessIndividualFitQuality)
xlabel('Mel slope');
ylabel('Individual fit of linear model');
title('Correlation of fit quality of linear model to brightness rating with Mel slope')
