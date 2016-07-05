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
% 2015-03-16 AMS added code to analyze the brightness estimation from the
% L-M chromatic control experiment
% 2015-03-17 AMS added code to correlate Mel contribution to pupil responses with brightness
% estimation
% 2015-03-18 AMS added code to compare Mel contribution to brightness
% estimation with L-M contribution to brightness estimation

DataDir='/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/BrightnessRatingTask/';
if ~exist(DataDir,'dir') % test for running on GKA's laptop
    DataDir='/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/trunk/data/BrightnessRatingTask/';
end
PupilDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/BrightnessPupil/';

DataDirChromatic='/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/BrightnessRatingTaskChromaticControl/';

%% Setting subjects: separate entries in the subject list by semicolons

Subjects=cellstr(['MelBright_C002';'MelBright_C003';'MelBright_C004';'MelBright_C005';'MelBright_C006';'MelBright_C008';'MelBright_C009';'MelBright_C010';'MelBright_C011';'MelBright_C012';'MelBright_C013';'MelBright_C014'])
%Subjects=cellstr(['MelBright_C002';'MelBright_C003';'MelBright_C004';'MelBright_C005';'MelBright_C006';'MelBright_C008';'MelBright_C011';'MelBright_C012';'MelBright_C013';'MelBright_C014'])
%Subjects=cellstr(['MelBright_C010'])
nSubs=length(Subjects);

%% Decide on analyzing EMG data with or without interaction term

EMGInteractionFlag = 1;

%% Defining variables for later analyses

% Visual sensitivity score and global seasonality score hard-coded from
% survey results

VisualSensitivityScore = [5; 2; 0; 7; 7; 7; 4; 3; 13; 8; 2; 6];
GlobalSeasonalityScore = [5; 9; 10; 10; 13; 2; 3; 14; 7; 6; 3; 8];

BrightnessBetaData=zeros(nSubs,3);
BrightnessBetaData2=zeros(nSubs,3);
BrightnessBetaDataTwoRuns = zeros(nSubs,3);
BrightnessBetaDataChromatic=zeros(nSubs,3);

BrightnessIndividualFitQuality=zeros(nSubs,1);
BrightnessIndividualFitQuality2=zeros(nSubs,1);
BrightnessIndividualFitQuality=zeros(nSubs,1);

EachSubjectAverageBrightness=zeros(19,nSubs);
EachSubjectAverageBrightness2=zeros(19, nSubs);
EachSubjectAverageBrightnessChromatic=zeros(19, nSubs);

EachSubjectAverageEMGVariance=zeros(19,nSubs);
EachSubjectMedianEMGVariance=zeros(19,nSubs);

EachSubjectAverageEMGVariance2=zeros(19,nSubs);
EachSubjectMedianEMGVariance2=zeros(19,nSubs);

EachSubjectAverageEMGVarianceChromatic=zeros(19,nSubs);
EachSubjectMedianEMGVarianceChromatic=zeros(19,nSubs);

EachSubjectAverageofAveragesEMGVarianceTwoRuns=zeros(19,nSubs);
EachSubjectAverageofMediansEMGVarianceTwoRuns=zeros(19,nSubs);
EachSubjectAverageBrightnessTwoRuns=zeros(19, nSubs);

EachSubjectAverageofAveragesEMGVarianceChromatic=zeros(19,nSubs);
EachSubjectAverageofMediansEMGVarianceChromatic=zeros(19,nSubs);
EachSubjectAverageBrightnessChromatic=zeros(19, nSubs);

EachSubjectPupilAmplitudeChangeLMS = zeros(nSubs,1);
EachSubjectPupilAmplitudeChangeMel = zeros(nSubs,1);
EachSubjectPupilPhaseLMS = zeros(nSubs,1);
EachSubjectPupilPhaseMel = zeros(nSubs,1);

%% Within-subject brightness and EMG analyses

% Loop through the subjects, load the data, retain relevant values

for i=1:nSubs
    
    % Assemble the filename of the data set for this subject
    
    DataFile=[char(DataDir),char(Subjects(i)),'/',char(Subjects(i)),'-BrightnessRatingTask-1.mat'];
    DataFile2=[char(DataDir),char(Subjects(i)),'/',char(Subjects(i)),'-BrightnessRatingTask-2.mat'];
    DataFileChromatic=[char(DataDirChromatic),char(Subjects(i)),'/',char(Subjects(i)),'-BrightnessRatingTaskChromaticControl-1.mat'];
        
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
    
    
    %% Repeat calculations for retest
    
    % load the data and split out the vectors for contrast, brightness
    % rating, and EMG variances
    
    
    load(DataFile2);
    data2=struct2cell(params.dataStruct);
    BrightnessVector2=cell2mat(data2(3,:,:));
    BrightnessVector2=reshape(BrightnessVector2,length(BrightnessVector2),1,1);
    
    MelContrastVector2=cell2mat(data(4,:,:));
    MelContrastVector2=reshape(MelContrastVector2,length(MelContrastVector2),1,1);
    
    LMSContrastVector2=cell2mat(data2(5,:,:));
    LMSContrastVector2=reshape(LMSContrastVector2,length(LMSContrastVector2),1,1);
    
    EMGCellArray2 = data2(2,:,:);
    EMGVarianceVector2 = zeros(length(EMGCellArray2),1);
    for k = 1:length(EMGCellArray2)
        EMGVarianceVector2(k) = var(EMGCellArray2{k});
    end
    
    % For any EMG variances that are more than 5 standard deviations
    % above the median, impute the median
    
    BadIndicesEMG2 = find(EMGVarianceVector2>(median(EMGVarianceVector2)+5*std(EMGVarianceVector2)));
    for k = 1:length(BadIndicesEMG2)
        EMGVarianceVector2(BadIndicesEMG2(k)) = median(EMGVarianceVector2);
    end  
    
    % Discard first three trials, which were calibrating the response scale
    
    MelContrastVector2=MelContrastVector2(4:end);
    LMSContrastVector2=LMSContrastVector2(4:end);
    BrightnessVector2=BrightnessVector2(4:end);
    EMGVarianceVector2=EMGVarianceVector2(4:end);
    
    % Sanity check rating data and remove out of bound ratings
    
    BadIndices2=find(BrightnessVector2>100);
    if ~isempty(BadIndices2)
        BrightnessVector2(BadIndices2)=[];
        MelContrastVector2(BadIndices2)=[];
        LMSContrastVector2(BadIndices2)=[];
        EMGVarianceVector2(BadIndices2)=[];
    end
    
    % Fit a linear model of Mel and LMS contrast to the rating
    
      
    X2=[MelContrastVector2,LMSContrastVector2];
    [IndividualBrightnessBetas2,~,~] = glmfit(X2,BrightnessVector2);
    Fit2=X2*IndividualBrightnessBetas2(2:3)+IndividualBrightnessBetas2(1);
    VarianceExplained2=corr([Fit2,BrightnessVector2]).^2;
    BrightnessIndividualFitQuality2(i)=VarianceExplained2(1,2);
    BrightnessBetaData2(i,:)=IndividualBrightnessBetas2;
        
%     % Normalize the EMG variance values by log transforming and then
%     % median centering
    
%     EMGVarianceVector2=log(EMGVarianceVector2);
%     EMGVarianceVector2=EMGVarianceVector2-median(EMGVarianceVector2);
    
   % Mean-center the variance values

    EMGVarianceVector2=EMGVarianceVector2-mean(EMGVarianceVector2);
    
    % Obtain the average rating and EMG variance by Mel and LMS contrast
    % crossing
    
    [xconRating2,yconRating2]=consolidator([MelContrastVector2,LMSContrastVector2],BrightnessVector2);
    [xconEMGavg2,yconEMGavg2]=consolidator([MelContrastVector2,LMSContrastVector2],EMGVarianceVector2);
    [xconEMGmed2,yconEMGmed2]=consolidator([MelContrastVector2,LMSContrastVector2],EMGVarianceVector2,@median);
    if i == 1
        MelContrastForAverages=xconRating2(:,1);
        LMSContrastForAverages=xconRating2(:,2);
    end
    
        
    EachSubjectAverageBrightness2(:,i)=yconRating2;
    EachSubjectAverageEMGVariance2(:,i)=yconEMGavg2;
    EachSubjectMedianEMGVariance2(:,i)=yconEMGmed2;
    
    
    
    %% Average the brightness ratings and EMG variances across the two runs for each subject
    
    EachSubjectAverageBrightnessTwoRuns(:,i) = mean([EachSubjectAverageBrightness(:,i) EachSubjectAverageBrightness2(:,i)], 2);
    EachSubjectAverageofAveragesEMGVarianceTwoRuns(:,i) = mean([EachSubjectAverageEMGVariance(:,i) EachSubjectAverageEMGVariance2(:,i)], 2);
    EachSubjectAverageofMediansEMGVarianceTwoRuns(:,i) = mean([EachSubjectMedianEMGVariance(:,i) EachSubjectMedianEMGVariance2(:,i)], 2);
       
%     % Plot a summary of EMG variances per subject
%     
%     figure
%     plot(linspace(1,178,178),EMGVarianceVector);
%     hold on
%     plot(linspace(1,178,178),EMGVarianceVector2,'-r');
%     hold off
%     

%     %% Repeat calculations for chromatic control
%     
%     % load the data and split out the vectors for contrast, brightness
%     % rating, and EMG variances
%     
% 
%     
%     load(DataFileChromatic);
%     dataChromatic=struct2cell(params.dataStruct);
%     BrightnessVectorChromatic=cell2mat(dataChromatic(3,:,:));
%     BrightnessVectorChromatic=reshape(BrightnessVectorChromatic,length(BrightnessVectorChromatic),1,1);
%     
%     MelContrastVectorChromatic=cell2mat(dataChromatic(4,:,:));
%     MelContrastVectorChromatic=reshape(MelContrastVectorChromatic,length(MelContrastVectorChromatic),1,1);
%     
%     LMSContrastVectorChromatic=cell2mat(dataChromatic(5,:,:));
%     LMSContrastVectorChromatic=reshape(LMSContrastVectorChromatic,length(LMSContrastVectorChromatic),1,1);
%     
%     EMGCellArrayChromatic = dataChromatic(2,:,:);
%     EMGVarianceVectorChromatic = zeros(length(EMGCellArrayChromatic),1);
%     for k = 1:length(EMGCellArrayChromatic)
%         EMGVarianceVectorChromatic(k) = var(EMGCellArrayChromatic{k});
%     end
%     
%     % For any EMG variances that are more than 5 standard deviations
%     % above the median, impute the median
%     
%     BadIndicesEMGChromatic = find(EMGVarianceVectorChromatic>(median(EMGVarianceVectorChromatic)+5*std(EMGVarianceVectorChromatic)));
%     for k = 1:length(BadIndicesEMGChromatic)
%         EMGVarianceVectorChromatic(BadIndicesEMGChromatic(k)) = median(EMGVarianceVectorChromatic);
%     end  
%     
%     % Discard first three trials, which were calibrating the response scale
%     
%     MelContrastVectorChromatic=MelContrastVectorChromatic(4:end);
%     LMSContrastVectorChromatic=LMSContrastVectorChromatic(4:end);
%     BrightnessVectorChromatic=BrightnessVectorChromatic(4:end);
%     EMGVarianceVectorChromatic=EMGVarianceVectorChromatic(4:end);
%     
%     % Sanity check rating data and remove out of bound ratings
%     
%     BadIndicesChromatic=find(BrightnessVectorChromatic>100);
%     if ~isempty(BadIndicesChromatic)
%         BrightnessVectorChromatic(BadIndicesChromatic)=[];
%         MelContrastVectorChromatic(BadIndicesChromatic)=[];
%         LMSContrastVectorChromatic(BadIndicesChromatic)=[];
%         EMGVarianceVectorChromatic(BadIndicesChromatic)=[];
%     end
%     
%     % Fit a linear model of Mel and LMS contrast to the rating
%     
%       
%     XChromatic=[MelContrastVectorChromatic,LMSContrastVectorChromatic];
%     [IndividualBrightnessBetasChromatic,~,~] = glmfit(XChromatic,BrightnessVectorChromatic);
%     FitChromatic=XChromatic*IndividualBrightnessBetasChromatic(2:3)+IndividualBrightnessBetasChromatic(1);
%     VarianceExplainedChromatic=corr([FitChromatic,BrightnessVectorChromatic]).^2;
%     BrightnessIndividualFitQualityChromatic(i)=VarianceExplainedChromatic(1,2);
%     BrightnessBetaDataChromatic(i,:)=IndividualBrightnessBetasChromatic;
%         
% %     % Normalize the EMG variance values by log transforming and then
% %     % median centering
%     
% %     EMGVarianceVectorChromatic=log(EMGVarianceVectorChromatic);
% %     EMGVarianceVectorChromatic=EMGVarianceVectorChromatic-median(EMGVarianceVectorChromatic);
%     
%    % Mean-center the variance values
% 
%     EMGVarianceVectorChromatic=EMGVarianceVectorChromatic-mean(EMGVarianceVectorChromatic);
%     
%     % Obtain the average rating and EMG variance by Mel and LMS contrast
%     % crossing
%     
%     [xconRatingChromatic,yconRatingChromatic]=consolidator([MelContrastVectorChromatic,LMSContrastVectorChromatic],BrightnessVectorChromatic);
%     [xconEMGavgChromatic,yconEMGavgChromatic]=consolidator([MelContrastVectorChromatic,LMSContrastVectorChromatic],EMGVarianceVectorChromatic);
%     [xconEMGmedChromatic,yconEMGmedChromatic]=consolidator([MelContrastVectorChromatic,LMSContrastVectorChromatic],EMGVarianceVectorChromatic,@median);
%     if i == 1
%         MelContrastForAverages=xconRatingChromatic(:,1);
%         LMSContrastForAverages=xconRatingChromatic(:,2);
%     end
%     
%         
%     EachSubjectAverageBrightnessChromatic(:,i)=yconRatingChromatic;
%     EachSubjectAverageEMGVarianceChromatic(:,i)=yconEMGavgChromatic;
%     EachSubjectMedianEMGVarianceChromatic(:,i)=yconEMGmedChromatic;
% 
%    
    
% Load available pupil data

    if exist([char(PupilDir) char(Subjects(i)) '-results.csv']);   % Check if pupil data exist for each subject
        PupilDataRaw = csvread([char(PupilDir) char(Subjects(i)) '-results.csv'],1,1); %Load the data from the comma-delimited file
        
        EachSubjectPupilAmplitudeChangeLMS(i) = PupilDataRaw(1,4);
        EachSubjectPupilAmplitudeChangeMel(i) = PupilDataRaw(2,4);
        EachSubjectPupilPhaseLMS(i) = PupilDataRaw(1,5);
        EachSubjectPupilPhaseMel(i) = PupilDataRaw(2,5);
        
    end
    
    
end

%% Preparing data for across-subject analyses

% Average the betas across the two runs for each subject

for i = 1:nSubs
    for j = 1:3
    BrightnessBetaDataTwoRuns(i,j) = mean([BrightnessBetaData(i,j), BrightnessBetaData2(i,j)]);
    end
end


% Calculate the central tendency of the across-subject data

AcrossSubjectAverageBrightness=mean(EachSubjectAverageBrightnessTwoRuns,2);
AcrossSubjectStdBrightness=std(EachSubjectAverageBrightnessTwoRuns,0,2);
AcrossSubjectSEMBrightness=std(EachSubjectAverageBrightnessTwoRuns,0,2)/sqrt(nSubs);

AcrossSubjectAverageofMediansEMG=mean(EachSubjectAverageofMediansEMGVarianceTwoRuns,2);
AcrossSubjectStdofMediansEMG=std(EachSubjectAverageofMediansEMGVarianceTwoRuns,0,2);
AcrossSubjectSEMofMediansEMG=std(EachSubjectAverageofMediansEMGVarianceTwoRuns,0,2)/sqrt(nSubs);

AcrossSubjectAverageofAveragesEMG=mean(EachSubjectAverageofAveragesEMGVarianceTwoRuns,2);
AcrossSubjectStdofAveragesEMG=std(EachSubjectAverageofAveragesEMGVarianceTwoRuns,0,2);
AcrossSubjectSEMofAveragesEMG=std(EachSubjectAverageofAveragesEMGVarianceTwoRuns,0,2)/sqrt(nSubs);

AcrossSubjectAverageBrightnessChromatic=mean(EachSubjectAverageBrightnessChromatic,2);
AcrossSubjectStdBrightnessChromatic=std(EachSubjectAverageBrightnessChromatic,0,2);
AcrossSubjectSEMBrightnessChromatic=std(EachSubjectAverageBrightnessChromatic,0,2)/sqrt(nSubs);

AcrossSubjectAverageofMediansEMGChromatic=mean(EachSubjectMedianEMGVarianceChromatic,2);
AcrossSubjectStdofMediansEMGChromatic=std(EachSubjectMedianEMGVarianceChromatic,0,2);
AcrossSubjectSEMofMediansEMGChromatic=std(EachSubjectMedianEMGVarianceChromatic,0,2)/sqrt(nSubs);

AcrossSubjectAverageofAveragesEMGChromatic=mean(EachSubjectAverageEMGVarianceChromatic,2);
AcrossSubjectStdofAveragesEMGChromatic=std(EachSubjectAverageEMGVarianceChromatic,0,2);
AcrossSubjectSEMofAveragesEMGChromatic=std(EachSubjectAverageEMGVarianceChromatic,0,2)/sqrt(nSubs);

%% Brightness estimation analysis

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

% Fit a linear model of L-M and LMS contrast to the across subject average
% rating data

X=[MelContrastForAverages,LMSContrastForAverages];
[AverageBrightnesBetasChromatic,~,AverageBrightnessStatsChromatic]=glmfit(X,AcrossSubjectAverageBrightnessChromatic);
AverageBrightnessFitChromatic=X*AverageBrightnesBetasChromatic(2:3)+AverageBrightnesBetasChromatic(1);
VarianceExplainedBrightnessChromatic=corr([AverageBrightnessFitChromatic,AcrossSubjectAverageBrightnessChromatic]).^2;
AverageBrightnessFitQualityChromatic=VarianceExplainedBrightnessChromatic(1,2);

% Report some values from the brightness rating

fprintf('\n');
fprintf(['Brightness rating -- \n']);
fprintf(['Number of subjects: ' num2str(nSubs) '\n']);
fprintf(['L-M slope: ' num2str(AverageBrightnesBetasChromatic(2),'%1.2f') ', t(' num2str(AverageBrightnessStatsChromatic.dfe,'%1.0f') ')=' num2str(AverageBrightnessStatsChromatic.t(2),'%1.2f') ', p=' num2str(AverageBrightnessStatsChromatic.p(2),'%1.2e') '\n']);
fprintf(['LMS slope: ' num2str(AverageBrightnesBetasChromatic(3),'%1.2f') ', t(' num2str(AverageBrightnessStatsChromatic.dfe,'%1.0f') ')=' num2str(AverageBrightnessStatsChromatic.t(3),'%1.2f') ', p=' num2str(AverageBrightnessStatsChromatic.p(3),'%1.2e') '\n']);
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
    plot(MelContrastForAverages(TargetIndices),AverageBrightnessFitChromatic(TargetIndices),'-r');
    if i==i
        hold on
    end
    ylim([0,100]);
    errorbar(MelContrastForAverages(TargetIndices),AcrossSubjectAverageBrightnessChromatic(TargetIndices),AcrossSubjectSEMBrightnessChromatic(TargetIndices),'Color',GrayTriplet,'Marker', 'none', 'LineStyle', 'none');
    plot(MelContrastForAverages(TargetIndices),AcrossSubjectAverageBrightnessChromatic(TargetIndices),'o','MarkerEdgeColor','none','MarkerFaceColor',GrayTriplet,'MarkerSize',10);
end
title('Brightness rating as a function of L-M contrast')
xlabel('Relative L-M contrast') % x-axis label
ylabel('Brightness rating [0-100]') % y-axis label
hold off

% Plot the individual subjects according to their slopes for Mel and LMS

figure
scatter(BrightnessBetaDataTwoRuns(:,2), BrightnessBetaDataTwoRuns(:,3));
xlim([-40 40]);
ylim([-60 60]);
hold on
plot([-100 100],[0 0],'--k');
plot([0 0],[-100 100],'--k');
xlabel('Mel slope');
ylabel('LMS slope');
title('Distribution of Mel and LMS contributions to brightness ratings');
hold off

% Plot the individual subjects in a test-retest reliability scatter plot

figure
scatter(BrightnessBetaData(:,2), BrightnessBetaData2(:,2));
xlabel('Mel slope (Test)')
ylabel('Mel slope (Retest)')
title('Test-Retest reliability of Mel contribution to brightness rating task')
hold on
a=linspace(-100,100);
b=a;
plot(a,b,'--k');
ylim([-40 40]);
xlim([-40 40]);
hold off

figure
scatter(BrightnessBetaData(:,3), BrightnessBetaData2(:,3));
xlabel('LMS slope (Test)')
ylabel('LMS slope (Retest)')
title('Test-Retest reliability of LMS contribution to brightness rating task')
hold on
a=linspace(-100,100);
b=a;
plot(a,b,'--k');
ylim([-60 60]);
xlim([-60 60]);
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

% Plot Mel slopes versus individual fit quality

BrightnessIndividualFitQualityTwoRuns = [BrightnessIndividualFitQuality BrightnessIndividualFitQuality2];
BrightnessIndividualMeanFitQuality = mean(BrightnessIndividualFitQualityTwoRuns,2);
figure
scatter(BrightnessBetaDataTwoRuns(:,2),BrightnessIndividualMeanFitQuality)
xlabel('Mel slope');
ylabel('Individual fit of linear model');
title('Correlation of fit quality of linear model to brightness rating with Mel slope')

% Create plots comparing Mel to L-M responses


figure
MelChromaticComparisonXAxis = [1 2];
SlopesforControlComparison = [(BrightnessBetaDataTwoRuns(:,2)./BrightnessBetaDataTwoRuns(:,3)) (BrightnessBetaDataChromatic(:,2)./BrightnessBetaDataChromatic(:,3))];
for i=1:nSubs
    plot(MelChromaticComparisonXAxis, SlopesforControlComparison(i,:), '-o')
    hold on
end
plot([-100 100],[0 0],'--k');
xlim([0.5 2.5]);
ylim([-1 2]);
title('Comparison of Mel slope to L-M slope');
ylabel('Ratio to LMS slope');
ax = gca;
set(ax, 'XTick', [1 2]);
set(ax, 'XTickLabel',{'Mel slope','L-M slope'});
hold off

%% EMG Data Analysis

if EMGInteractionFlag == 1
    
    % Fit a linear model of Mel and LMS contrast to the median EMG variances
    % with interaction term
    
    interact=(MelContrastForAverages+1).*(LMSContrastForAverages+1);
    X=[MelContrastForAverages, LMSContrastForAverages,interact];
    [AverageEMGBetas,~,AverageEMGStats] = glmfit(X,AcrossSubjectAverageofMediansEMG);
    AverageEMGFit=X*AverageEMGBetas(2:4)+AverageEMGBetas(1);
    EMGVarianceExplained=corr([AverageEMGFit,AcrossSubjectAverageofMediansEMG]).^2;
    AverageEMGDataFitQuality=EMGVarianceExplained(1,2);
    
    % Report some values from the median EMG variance with interaction term
    
    fprintf(['EMG Variance [across-subject mean of within-subject median of mean-centered variance] -- \n']);
    fprintf(['Number of subjects: ' num2str(nSubs) '\n']);
    fprintf(['Mel slope: ' num2str(AverageEMGBetas(2),'%1.2e') ', t(' num2str(AverageEMGStats.dfe,'%1.0f') ')=' num2str(AverageEMGStats.t(2),'%1.2f') ', p=' num2str(AverageEMGStats.p(2),'%1.2e') '\n']);
    fprintf(['LMS slope: ' num2str(AverageEMGBetas(3),'%1.2e') ', t(' num2str(AverageEMGStats.dfe,'%1.0f') ')=' num2str(AverageEMGStats.t(3),'%1.2f') ', p=' num2str(AverageEMGStats.p(3),'%1.2e') '\n']);
    fprintf(['Interaction slope: ' num2str(AverageEMGBetas(4),'%1.2e') ', t(' num2str(AverageEMGStats.dfe,'%1.0f') ')=' num2str(AverageEMGStats.t(4),'%1.2f') ', p=' num2str(AverageEMGStats.p(4),'%1.2e') '\n']);
    fprintf('\n');
    
else
    
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
    
end

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

if EMGInteractionFlag == 1
    
    % Fit a linear model of Mel and LMS contrast to the mean EMG variances with
    % interaction term
    
    interact=(MelContrastForAverages+1).*(LMSContrastForAverages+1);
    X=[MelContrastForAverages, LMSContrastForAverages,interact];
    [AverageEMGBetas,~,AverageEMGStats] = glmfit(X,AcrossSubjectAverageofAveragesEMG);
    AverageEMGFit=X*AverageEMGBetas(2:4)+AverageEMGBetas(1);
    EMGVarianceExplained=corr([AverageEMGFit,AcrossSubjectAverageofAveragesEMG]).^2;
    AverageEMGDataFitQuality=EMGVarianceExplained(1,2);
    
    % Report some values from the mean EMG variance with interaction term
    
    fprintf(['EMG Variance [across-subject mean of within-subject mean of mean-centered variance] -- \n']);
    fprintf(['Number of subjects: ' num2str(nSubs) '\n']);
    fprintf(['Mel slope: ' num2str(AverageEMGBetas(2),'%1.2e') ', t(' num2str(AverageEMGStats.dfe,'%1.0f') ')=' num2str(AverageEMGStats.t(2),'%1.2f') ', p=' num2str(AverageEMGStats.p(2),'%1.2e') '\n']);
    fprintf(['LMS slope: ' num2str(AverageEMGBetas(3),'%1.2e') ', t(' num2str(AverageEMGStats.dfe,'%1.0f') ')=' num2str(AverageEMGStats.t(3),'%1.2f') ', p=' num2str(AverageEMGStats.p(3),'%1.2e') '\n']);
    fprintf(['Interaction slope: ' num2str(AverageEMGBetas(4),'%1.2e') ', t(' num2str(AverageEMGStats.dfe,'%1.0f') ')=' num2str(AverageEMGStats.t(4),'%1.2f') ', p=' num2str(AverageEMGStats.p(4),'%1.2e') '\n']);
    fprintf('\n');
    
else
    
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
    
end


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

if EMGInteractionFlag == 1
    
    % Fit a linear model of L-M and LMS contrast to the median EMG variances
    % with interaction term
    
    interact=(MelContrastForAverages+1).*(LMSContrastForAverages+1);
    X=[MelContrastForAverages, LMSContrastForAverages,interact];
    [AverageEMGBetasChromatic,~,AverageEMGStatsChromatic] = glmfit(X,AcrossSubjectAverageofMediansEMGChromatic);
    AverageEMGFitChromatic=X*AverageEMGBetasChromatic(2:4)+AverageEMGBetasChromatic(1);
    EMGVarianceExplainedChromatic=corr([AverageEMGFitChromatic,AcrossSubjectAverageofMediansEMGChromatic]).^2;
    AverageEMGDataFitQualityChromatic=EMGVarianceExplainedChromatic(1,2);
    
    % Report some values from the median EMG variance with interaction term
    
    fprintf(['Chromatic EMG Variance [across-subject mean of within-subject median of mean-centered variance] -- \n']);
    fprintf(['Number of subjects: ' num2str(nSubs) '\n']);
    fprintf(['L-M slope: ' num2str(AverageEMGBetasChromatic(2),'%1.2e') ', t(' num2str(AverageEMGStatsChromatic.dfe,'%1.0f') ')=' num2str(AverageEMGStatsChromatic.t(2),'%1.2f') ', p=' num2str(AverageEMGStatsChromatic.p(2),'%1.2e') '\n']);
    fprintf(['LMS slope: ' num2str(AverageEMGBetasChromatic(3),'%1.2e') ', t(' num2str(AverageEMGStatsChromatic.dfe,'%1.0f') ')=' num2str(AverageEMGStatsChromatic.t(3),'%1.2f') ', p=' num2str(AverageEMGStatsChromatic.p(3),'%1.2e') '\n']);
    fprintf(['Interaction slope: ' num2str(AverageEMGBetasChromatic(4),'%1.2e') ', t(' num2str(AverageEMGStatsChromatic.dfe,'%1.0f') ')=' num2str(AverageEMGStatsChromatic.t(4),'%1.2f') ', p=' num2str(AverageEMGStatsChromatic.p(4),'%1.2e') '\n']);
    fprintf('\n');
    
else
    
    % Fit a linear model of Mel and LMS contrast to the median EMG variances
    % without interaction term
    
    X=[MelContrastForAverages, LMSContrastForAverages];
    [AverageEMGBetasChromatic,~,AverageEMGStatsChromatic] = glmfit(X,AcrossSubjectAverageofMediansEMGChromatic);
    AverageEMGFitChromatic=X*AverageEMGBetasChromatic(2:3)+AverageEMGBetasChromatic(1);
    EMGVarianceExplainedChromatic=corr([AverageEMGFitChromatic,AcrossSubjectAverageofMediansEMGChromatic]).^2;
    AverageEMGDataFitQualityChromatic=EMGVarianceExplainedChromatic(1,2);
    
    % Report some values from the median EMG variance without interaction term
    
    fprintf(['Chromatic EMG Variance [across-subject mean of within-subject median of mean-centered variance] -- \n']);
    fprintf(['Number of subjects: ' num2str(nSubs) '\n']);
    fprintf(['L-M slope: ' num2str(AverageEMGBetasChromatic(2),'%1.2e') ', t(' num2str(AverageEMGStatsChromatic.dfe,'%1.0f') ')=' num2str(AverageEMGStatsChromatic.t(2),'%1.2f') ', p=' num2str(AverageEMGStatsChromatic.p(2),'%1.2e') '\n']);
    fprintf(['LMS slope: ' num2str(AverageEMGBetasChromatic(3),'%1.2e') ', t(' num2str(AverageEMGStatsChromatic.dfe,'%1.0f') ')=' num2str(AverageEMGStatsChromatic.t(3),'%1.2f') ', p=' num2str(AverageEMGStatsChromatic.p(3),'%1.2e') '\n']);
    fprintf('\n');
    
end

% Create a plot of the average (across subjects) of median EMG variance
% (per subject) as a function of L-M contrast, with separate lines for each
% level of LMS contrast studied

figure
for i=1:length(UniqueLMSContrastLevels)
    TheShadeofGray=1*((i-1)/length(UniqueLMSContrastLevels));
    GrayTriplet=[TheShadeofGray TheShadeofGray TheShadeofGray];
    TargetIndices=find(LMSContrastForAverages==UniqueLMSContrastLevels(i));
    plot(MelContrastForAverages(TargetIndices),AverageEMGFitChromatic(TargetIndices),'-r');
    if i==i
        hold on
    end
%    ylim([0,0.002]);
    errorbar(MelContrastForAverages(TargetIndices),AcrossSubjectAverageofMediansEMGChromatic(TargetIndices),AcrossSubjectSEMofMediansEMGChromatic(TargetIndices),'Color',GrayTriplet,'Marker', 'none', 'LineStyle', 'none');
    plot(MelContrastForAverages(TargetIndices),AcrossSubjectAverageofMediansEMGChromatic(TargetIndices),'o','MarkerEdgeColor','none','MarkerFaceColor',GrayTriplet,'MarkerSize',10);
end
title('Orbicularis EMG variance as a function of L-M contrast')
xlabel('Relative L-M contrast') % x-axis label
ylabel('EMG variance [across-subject mean of within-subject median of mean-centered variance]') % y-axis label
hold off

if EMGInteractionFlag == 1
    
    % Fit a linear model of L-M and LMS contrast to the mean EMG variances with
    % interaction term
    
    interact=(MelContrastForAverages+1).*(LMSContrastForAverages+1);
    X=[MelContrastForAverages, LMSContrastForAverages,interact];
    [AverageEMGBetasChromatic,~,AverageEMGStatsChromatic] = glmfit(X,AcrossSubjectAverageofAveragesEMGChromatic);
    AverageEMGFitChromatic=X*AverageEMGBetasChromatic(2:4)+AverageEMGBetasChromatic(1);
    EMGVarianceExplainedChromatic=corr([AverageEMGFitChromatic,AcrossSubjectAverageofAveragesEMGChromatic]).^2;
    AverageEMGDataFitQualityChromatic=EMGVarianceExplainedChromatic(1,2);
    
    % Report some values from the mean EMG variance with interaction term
    
    fprintf(['EMG Variance [across-subject mean of within-subject mean of mean-centered variance] -- \n']);
    fprintf(['Number of subjects: ' num2str(nSubs) '\n']);
    fprintf(['L-M slope: ' num2str(AverageEMGBetasChromatic(2),'%1.2e') ', t(' num2str(AverageEMGStatsChromatic.dfe,'%1.0f') ')=' num2str(AverageEMGStatsChromatic.t(2),'%1.2f') ', p=' num2str(AverageEMGStatsChromatic.p(2),'%1.2e') '\n']);
    fprintf(['LMS slope: ' num2str(AverageEMGBetasChromatic(3),'%1.2e') ', t(' num2str(AverageEMGStatsChromatic.dfe,'%1.0f') ')=' num2str(AverageEMGStatsChromatic.t(3),'%1.2f') ', p=' num2str(AverageEMGStatsChromatic.p(3),'%1.2e') '\n']);
    fprintf(['Interaction slope: ' num2str(AverageEMGBetasChromatic(4),'%1.2e') ', t(' num2str(AverageEMGStatsChromatic.dfe,'%1.0f') ')=' num2str(AverageEMGStatsChromatic.t(4),'%1.2f') ', p=' num2str(AverageEMGStatsChromatic.p(4),'%1.2e') '\n']);
    fprintf('\n');
    
else
    
    % Fit a linear model of L-M and LMS contrast to the mean EMG variances
    % without interaction term
    
    X=[MelContrastForAverages, LMSContrastForAverages];
    [AverageEMGBetasChromatic,~,AverageEMGStatsChromatic] = glmfit(X,AcrossSubjectAverageofAveragesEMGChromatic);
    AverageEMGFitChromatic=X*AverageEMGBetasChromatic(2:3)+AverageEMGBetasChromatic(1);
    EMGVarianceExplainedChromatic=corr([AverageEMGFitChromatic,AcrossSubjectAverageofAveragesEMGChromatic]).^2;
    AverageEMGDataFitQualityChromatic=EMGVarianceExplainedChromatic(1,2);
    
    % Report some values from the mean EMG variance without interaction term
    
    fprintf(['Chromatic EMG Variance [across-subject mean of within-subject mean of mean-centered variance] -- \n']);
    fprintf(['Number of subjects: ' num2str(nSubs) '\n']);
    fprintf(['L-M slope: ' num2str(AverageEMGBetasChromatic(2),'%1.2e') ', t(' num2str(AverageEMGStatsChromatic.dfe,'%1.0f') ')=' num2str(AverageEMGStatsChromatic.t(2),'%1.2f') ', p=' num2str(AverageEMGStatsChromatic.p(2),'%1.2e') '\n']);
    fprintf(['LMS slope: ' num2str(AverageEMGBetasChromatic(3),'%1.2e') ', t(' num2str(AverageEMGStatsChromatic.dfe,'%1.0f') ')=' num2str(AverageEMGStatsChromatic.t(3),'%1.2f') ', p=' num2str(AverageEMGStatsChromatic.p(3),'%1.2e') '\n']);
    fprintf('\n');

end

% Create a plot of the average (across subjects) of mean EMG variance
% (per subject) as a function of L-M contrast, with separate lines for each
% level of LMS contrast studied

figure
for i=1:length(UniqueLMSContrastLevels)
    TheShadeofGray=1*((i-1)/length(UniqueLMSContrastLevels));
    GrayTriplet=[TheShadeofGray TheShadeofGray TheShadeofGray];
    TargetIndices=find(LMSContrastForAverages==UniqueLMSContrastLevels(i));
    plot(MelContrastForAverages(TargetIndices),AverageEMGFitChromatic(TargetIndices),'-r');
    if i==i
        hold on
    end
%    ylim([0,0.002]);
    errorbar(MelContrastForAverages(TargetIndices),AcrossSubjectAverageofAveragesEMGChromatic(TargetIndices),AcrossSubjectSEMofAveragesEMGChromatic(TargetIndices),'Color',GrayTriplet,'Marker', 'none', 'LineStyle', 'none');
    plot(MelContrastForAverages(TargetIndices),AcrossSubjectAverageofAveragesEMGChromatic(TargetIndices),'o','MarkerEdgeColor','none','MarkerFaceColor',GrayTriplet,'MarkerSize',10);
end
title('Orbicularis EMG variance as a function of L-M contrast')
xlabel('Relative L-M contrast') % x-axis label
ylabel('EMG variance [across-subject mean of within-subject mean of mean-centered variance]') % y-axis label
hold off


%% Combined analyses


% Calculate the contribution of mel to brightness rating and to pupil
% response

MelContributionBrightness = BrightnessBetaDataTwoRuns(:,2)./BrightnessBetaDataTwoRuns(:,3);
ChromaticContributionBrightness = BrightnessBetaDataChromatic(:,2)./BrightnessBetaDataChromatic(:,3);
MelMinusChromaticContributionBrightness = MelContributionBrightness - ChromaticContributionBrightness;
MelRatioPupilResponse = EachSubjectPupilAmplitudeChangeMel./EachSubjectPupilAmplitudeChangeLMS;

% Create scatter plot of the Mel contributions to brightness rating and
% pupil response and perform a simple linear regression

figure
scatter(MelContributionBrightness, MelRatioPupilResponse)
hold on
plot([0 0],[-100 100],'--k');
lsline;
xlim([-1 2]);
ylim([0 1.2]);
xlabel('Mel contribution to brightness rating (Mel/LMS)');
ylabel('Pupil amplitude proportion change (Mel/LMS)');
title('Correlation of Mel contributions to brightness rating and pupil response');
[PupilBrightnessCorrelation, PupilBrightnessCorrelationP] = corrcoef(MelContributionBrightness, MelRatioPupilResponse);
text(-0.8, 1.0, ['P = ' num2str(PupilBrightnessCorrelationP(1,2))]);
hold off

% Create scatter plot of the Mel slope minus the L-M slope and
% pupil response and perform a simple linear regression

figure
scatter(MelMinusChromaticContributionBrightness, MelRatioPupilResponse)
hold on
plot([0 0],[-100 100],'--k');
lsline;
xlim([-1 2]);
ylim([0 1.2]);
xlabel('Mel contribution to brightness rating [(Mel/LMS) - ((L-M)/LMS)]');
ylabel('Pupil amplitude proportion change (Mel/LMS)');
title('Correlation of Mel-(L-M) contributions to brightness rating and pupil response');
[PupilBrightnessDifferenceCorrelation, PupilBrightnessDifferenceCorrelationP] = corrcoef(MelMinusChromaticContributionBrightness, MelRatioPupilResponse);
text(-0.8, 1.0, ['P = ' num2str(PupilBrightnessDifferenceCorrelationP(1,2))]);
hold off

% Create a scatter plot of the Mel slope and pupil phase response

PupilPhaseShift = EachSubjectPupilPhaseLMS - EachSubjectPupilPhaseMel;
figure
scatter(MelContributionBrightness, PupilPhaseShift)
hold on
plot([0 0],[-100 100],'--k');
lsline;
xlim([-1 2]);
ylim([-1 1]);
xlabel('Mel contribution to brightness rating (Mel/LMS)');
ylabel('Pupil phase shift (LMS - Mel)');
title('Correlation of Mel contributions to brightness rating and pupil phase shift');
[PhaseBrightnessCorrelation, PhaseBrightnessCorrelationP] = corrcoef(MelContributionBrightness, PupilPhaseShift);
text(-0.8, 0.8, ['P = ' num2str(PupilBrightnessCorrelationP(1,2))]);
hold off



% % Create scatter plot of the Mel contributions to brightness rating and
% % pupil response and perform a simple linear regression after reassigning
% % negative slopes to zero
% 
% NegativeIndices = find(MelContributionBrightness < 0);
% MelContributionBrightnessZeroed = MelContributionBrightness;
% MelContributionBrightnessZeroed(NegativeIndices) = 0;
% figure
% scatter(MelContributionBrightnessZeroed, MelRatioPupilResponse)
% hold on
% plot([0 0],[-100 100],'--k');
% lsline;
% xlim([-1 1]);
% ylim([0 1.2]);
% xlabel('Mel contribution to brightness rating, corrected (Mel/LMS)');
% ylabel('Pupil amplitude proportion change (Mel/LMS)');
% title('Correlation of corrected Mel contributions to brightness rating and pupil response');
% [PupilBrightnessCorrelationZeroed, PupilBrightnessCorrelationZeroedP] = corrcoef(MelContributionBrightnessZeroed, MelRatioPupilResponse);
% text(-0.8, 1.0, ['P = ' num2str(PupilBrightnessCorrelationZeroedP(1,2))]);
% hold off

