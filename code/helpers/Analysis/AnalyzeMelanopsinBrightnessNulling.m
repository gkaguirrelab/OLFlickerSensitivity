%
% Loads and analyzes brightness rating and EMG data from the pilot
% brightness rating experiment
%
% 2015-04-10 AMS copied elements from AnalyzeMelanopsinBrightnessProject.m
% to analyze just the brightness estimation experiment data using subjects'
% nulled stimuli.

DataDir='/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/BrightnessRatingTaskNulled/';
PupilDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/BrightnessPupilNulled/';
OldDataDir='/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/BrightnessRatingTask/';
OldPupilDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/BrightnessPupil/';
NullingDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/Nulling/';

%% Setting subjects: separate entries in the subject list by semicolons

%Note that for subject A040815S_test,
%ModulationTrialSequenceBrightnessRatingNulled.m had unintentionally
%reversed cache file inputs for LMS and Mel, so the resulting data are
%opposite (Mel contrasts are reported as LMS contrasts and vice versa)
Subjects=cellstr(['MelBright_C002';'MelBright_C003';'MelBright_C004';'MelBright_C005';'MelBright_C006';'MelBright_C008';'MelBright_C009';'MelBright_C010';'MelBright_C011';'MelBright_C012';'MelBright_C013';'MelBright_C014';'MelBright_C015';'MelBright_C016';'MelBright_C017';'MelBright_C018';'MelBright_C019']);
nSubs=length(Subjects);

% Find the subjects for which we have nulled brightness estimation data

NulledIndices = zeros(nSubs,1);
for i = 1:nSubs
    if exist([char(DataDir),char(Subjects(i)),'/',char(Subjects(i)),'-BrightnessRatingTaskNulled-1.mat'])
        NulledIndices(i) = 1;
    end
end
NulledIndices = find(NulledIndices);
SubjectsNulled = Subjects(NulledIndices);
nSubsNulled = length(SubjectsNulled);

% Find the subjects for which we have unnulled brightness estimation data

UnNulledIndices = zeros(nSubs,1);
for i = 1:nSubs
    if exist([char(OldDataDir),char(Subjects(i)),'/',char(Subjects(i)),'-BrightnessRatingTask-1.mat'])
        UnNulledIndices(i) = 1;
    end
end
UnNulledIndices = find(UnNulledIndices);
SubjectsUnNulled = Subjects(UnNulledIndices);
nSubsUnNulled = length(SubjectsUnNulled);

% Find the subjects which have both nulled and unnulled data

SubjectsBoth = intersect(SubjectsNulled, SubjectsUnNulled);
nSubsBoth = length(SubjectsBoth);

% Hard-code the genotyping results. We'll set a vector such that CC = 0, CT
% = 1, TT = 2

Genotypes = [2, 2, 2, 2, 1, 2, 2, 1, 2, 0, 2, 1, 0, 0, 1, 1, 1];


%% Decide on analyzing EMG data with or without interaction term

EMGInteractionFlag = 1;

%% Defining variables for later analyses

BrightnessBetaData=zeros(nSubsNulled,3);
BrightnessBetaDataOld=zeros(nSubsUnNulled,3);

BrightnessIndividualFitQuality=zeros(nSubsNulled,1);
BrightnessIndividualFitQualityOld=zeros(nSubsUnNulled,1);

EachSubjectAverageBrightness=zeros(19,nSubsNulled);
EachSubjectAverageBrightnessOld=zeros(19,nSubsUnNulled);

EachSubjectAverageEMGVariance=zeros(19,nSubsNulled);
EachSubjectMedianEMGVariance=zeros(19,nSubsNulled);
EachSubjectAverageEMGVarianceOld=zeros(19,nSubsUnNulled);
EachSubjectMedianEMGVarianceOld=zeros(19,nSubsUnNulled);

EachSubjectPupilAmplitudeChangeLMS = zeros(nSubsNulled,1);
EachSubjectPupilAmplitudeChangeMel = zeros(nSubsNulled,1);
EachSubjectPupilPhaseLMS = zeros(nSubsNulled,1);
EachSubjectPupilPhaseMel = zeros(nSubsNulled,1);

EachSubjectPupilAmplitudeChangeLMSOld = zeros(nSubsUnNulled,1);
EachSubjectPupilAmplitudeChangeMelOld = zeros(nSubsUnNulled,1);
EachSubjectPupilPhaseLMSOld = zeros(nSubsUnNulled,1);
EachSubjectPupilPhaseMelOld = zeros(nSubsUnNulled,1);

EachSubjectChangetoMelPos = zeros(nSubsNulled,3);
EachSubjectChangetoMelNeg = zeros(nSubsNulled,3);
EachSubjectChangetoLMSPos = zeros(nSubsNulled,3);
EachSubjectChangetoLMSNeg = zeros(nSubsNulled,3);

%% Within-subject brightness and EMG analyses

%% Start with nulled data
% Loop through the subjects, load the data, retain relevant values

for i=1:nSubsNulled
    
    
    % Assemble the filename of the data set for this subject
    
    DataFile=[char(DataDir),char(SubjectsNulled(i)),'/',char(SubjectsNulled(i)),'-BrightnessRatingTaskNulled-1.mat'];
    
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


%% Now unnulled data

% Loop through the subjects, load the data, retain relevant values

for i=1:nSubsUnNulled
    
    
    % Assemble the filename of the data set for this subject
    
    DataFile=[char(OldDataDir),char(SubjectsUnNulled(i)),'/',char(SubjectsUnNulled(i)),'-BrightnessRatingTask-1.mat'];
    
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
    BrightnessIndividualFitQualityOld(i)=VarianceExplained(1,2);
    BrightnessBetaDataOld(i,:)=IndividualBrightnessBetas;
    
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
    
    
    EachSubjectAverageBrightnessOld(:,i)=yconRating;
    EachSubjectAverageEMGVarianceOld(:,i)=yconEMGavg;
    EachSubjectMedianEMGVarianceOld(:,i)=yconEMGmed;
    
end

%% Load and record pupil data


% Load available unnulled pupil data, and if it doesn't exist put a
% NaN
for i = 1:nSubsUnNulled
    if exist([char(OldPupilDir) char(SubjectsUnNulled(i)) '-results.csv'])
        OldPupilDataRaw = csvread([char(OldPupilDir) char(SubjectsUnNulled(i)) '-results.csv'],1,1); %Load the data from the comma-delimited file
        EachSubjectPupilAmplitudeChangeLMSOld(i) = OldPupilDataRaw(1,4);
        EachSubjectPupilAmplitudeChangeMelOld(i) = OldPupilDataRaw(2,4);
        EachSubjectPupilPhaseLMSOld(i) = OldPupilDataRaw(1,5);
        EachSubjectPupilPhaseMelOld(i) = OldPupilDataRaw(2,5);
    else
        EachSubjectPupilAmplitudeChangeLMSOld(i) = NaN;
        EachSubjectPupilAmplitudeChangeMelOld(i) = NaN;
        EachSubjectPupilPhaseLMSOld(i) = NaN;
        EachSubjectPupilPhaseMelOld(i) = NaN;
    end
    
end

% Load available nulled pupil data, and if it doesn't exist put a
% NaN

for i = 1:nSubsNulled % Check if pupil data exist for each subject
    if exist([char(PupilDir) char(SubjectsNulled(i)) '-results.csv'])
        PupilDataRaw = csvread([char(PupilDir) char(SubjectsNulled(i)) '-results.csv'],1,1); %Load the data from the comma-delimited file
        EachSubjectPupilAmplitudeChangeLMS(i) = PupilDataRaw(1,4);
        EachSubjectPupilAmplitudeChangeMel(i) = PupilDataRaw(2,4);
        EachSubjectPupilPhaseLMS(i) = PupilDataRaw(1,5);
        EachSubjectPupilPhaseMel(i) = PupilDataRaw(2,5);
        EachSubjectPupilAmplitudeChangeLMSErr(i) = PupilDataRaw(1,6);
        EachSubjectPupilAmplitudeChangeMelErr(i) = PupilDataRaw(2,6);
        EachSubjectPupilPhaseLMSErr(i) = PupilDataRaw(1,7);
        EachSubjectPupilPhaseMelErr(i) = PupilDataRaw(2,7);
    else
        EachSubjectPupilAmplitudeChangeLMS(i) = NaN;
        EachSubjectPupilAmplitudeChangeMel(i) = NaN;
        EachSubjectPupilPhaseLMS(i) = NaN;
        EachSubjectPupilPhaseMel(i) = NaN;
    end
end


%% Preparing data for across-subject analyses


% Calculate the central tendency of the across-subject data

AcrossSubjectAverageBrightness=mean(EachSubjectAverageBrightness,2);
AcrossSubjectStdBrightness=std(EachSubjectAverageBrightness,0,2);
AcrossSubjectSEMBrightness=std(EachSubjectAverageBrightness,0,2)/sqrt(nSubsNulled);

AcrossSubjectAverageBrightnessOld=mean(EachSubjectAverageBrightnessOld,2);
AcrossSubjectStdBrightnessOld=std(EachSubjectAverageBrightnessOld,0,2);
AcrossSubjectSEMBrightnessOld=std(EachSubjectAverageBrightnessOld,0,2)/sqrt(nSubsUnNulled);

AcrossSubjectAverageofAveragesEMG=mean(EachSubjectAverageEMGVariance,2);
AcrossSubjectStdofAveragesEMG=std(EachSubjectAverageEMGVariance,0,2);
AcrossSubjectSEMofAveragesEMG=std(EachSubjectAverageEMGVariance,0,2)/sqrt(nSubsNulled);

AcrossSubjectAverageofMediansEMGOld=mean(EachSubjectMedianEMGVarianceOld,2);
AcrossSubjectStdofMediansEMGOld=std(EachSubjectMedianEMGVarianceOld,0,2);
AcrossSubjectSEMofMediansEMGOld=std(EachSubjectMedianEMGVarianceOld,0,2)/sqrt(nSubsUnNulled);

AcrossSubjectAverageofMediansEMG=mean(EachSubjectMedianEMGVariance,2);
AcrossSubjectStdofMediansEMG=std(EachSubjectMedianEMGVariance,0,2);
AcrossSubjectSEMofMediansEMG=std(EachSubjectMedianEMGVariance,0,2)/sqrt(nSubsNulled);

AcrossSubjectAverageofAveragesEMGOld=mean(EachSubjectAverageEMGVarianceOld,2);
AcrossSubjectStdofAveragesEMGOld=std(EachSubjectAverageEMGVarianceOld,0,2);
AcrossSubjectSEMofAveragesEMGOld=std(EachSubjectAverageEMGVarianceOld,0,2)/sqrt(nSubsUnNulled);

%% Brightness estimation analysis

% Fit a linear model of Mel and LMS contrast to the across subject nulled average
% rating data

X=[MelContrastForAverages,LMSContrastForAverages];
[AverageBrightnesBetas,~,AverageBrightnessStats]=glmfit(X,AcrossSubjectAverageBrightness);
AverageBrightnessFit=X*AverageBrightnesBetas(2:3)+AverageBrightnesBetas(1);
VarianceExplainedBrightness=corr([AverageBrightnessFit,AcrossSubjectAverageBrightness]).^2;
AverageBrightnessFitQuality=VarianceExplainedBrightness(1,2);

% Report some values from the brightness rating

fprintf('\n');
fprintf('==============Analysis of brightness estimation===========\n');
fprintf(['Nulled brightness rating -- \n']);
fprintf(['Number of subjects: ' num2str(nSubsNulled) '\n']);
fprintf(['Mel slope: ' num2str(AverageBrightnesBetas(2),'%1.2f') ', t(' num2str(AverageBrightnessStats.dfe,'%1.0f') ')=' num2str(AverageBrightnessStats.t(2),'%1.2f') ', p=' num2str(AverageBrightnessStats.p(2),'%1.2e') '\n']);
fprintf(['LMS slope: ' num2str(AverageBrightnesBetas(3),'%1.2f') ', t(' num2str(AverageBrightnessStats.dfe,'%1.0f') ')=' num2str(AverageBrightnessStats.t(3),'%1.2f') ', p=' num2str(AverageBrightnessStats.p(3),'%1.2e') '\n']);
fprintf('\n');


% Fit a linear model of Mel and LMS contrast to the across subject unnulled average
% rating data

X=[MelContrastForAverages,LMSContrastForAverages];
[AverageBrightnesBetasOld,~,AverageBrightnessStatsOld]=glmfit(X,AcrossSubjectAverageBrightnessOld);
AverageBrightnessFitOld=X*AverageBrightnesBetasOld(2:3)+AverageBrightnesBetasOld(1);
VarianceExplainedBrightnessOld=corr([AverageBrightnessFitOld,AcrossSubjectAverageBrightnessOld]).^2;
AverageBrightnessFitQualityOld=VarianceExplainedBrightnessOld(1,2);

% Report some values from the brightness rating

fprintf(['Unnulled brightness rating -- \n']);
fprintf(['Number of subjects: ' num2str(nSubsUnNulled) '\n']);
fprintf(['Mel slope: ' num2str(AverageBrightnesBetasOld(2),'%1.2f') ', t(' num2str(AverageBrightnessStatsOld.dfe,'%1.0f') ')=' num2str(AverageBrightnessStatsOld.t(2),'%1.2f') ', p=' num2str(AverageBrightnessStatsOld.p(2),'%1.2e') '\n']);
fprintf(['LMS slope: ' num2str(AverageBrightnesBetasOld(3),'%1.2f') ', t(' num2str(AverageBrightnessStatsOld.dfe,'%1.0f') ')=' num2str(AverageBrightnessStatsOld.t(3),'%1.2f') ', p=' num2str(AverageBrightnessStatsOld.p(3),'%1.2e') '\n']);
fprintf('\n');


%% Brightness estimation plots (nulled)

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
title('Brightness rating as a function of Mel contrast, nulled')
xlabel('Relative Mel contrast') % x-axis label
ylabel('Brightness rating [0-100]') % y-axis label
hold off

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
title('Distribution of Mel and LMS contributions to brightness ratings, nulled');
hold off

% Plot Mel slopes versus individual fit quality

figure
scatter(BrightnessBetaData(:,2),BrightnessIndividualFitQuality)
xlabel('Mel slope');
ylabel('Individual fit of linear model');
title('Correlation of fit quality of linear model to brightness rating with Mel slope, nulled')

%% Brightness estimation plots (unnulled)

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
    plot(MelContrastForAverages(TargetIndices),AverageBrightnessFitOld(TargetIndices),'-r');
    if i==i
        hold on
    end
    ylim([0,100]);
    errorbar(MelContrastForAverages(TargetIndices),AcrossSubjectAverageBrightnessOld(TargetIndices),AcrossSubjectSEMBrightnessOld(TargetIndices),'Color',GrayTriplet,'Marker', 'none', 'LineStyle', 'none');
    plot(MelContrastForAverages(TargetIndices),AcrossSubjectAverageBrightnessOld(TargetIndices),'o','MarkerEdgeColor','none','MarkerFaceColor',GrayTriplet,'MarkerSize',10);
end
title('Brightness rating as a function of Mel contrast, unnulled')
xlabel('Relative Mel contrast') % x-axis label
ylabel('Brightness rating [0-100]') % y-axis label
hold off

% Plot the individual subjects according to their slopes for Mel and LMS

figure
scatter(BrightnessBetaDataOld(:,2), BrightnessBetaDataOld(:,3));
xlim([-40 40]);
ylim([-60 60]);
hold on
plot([-100 100],[0 0],'--k');
plot([0 0],[-100 100],'--k');
xlabel('Mel slope');
ylabel('LMS slope');
title('Distribution of Mel and LMS contributions to brightness ratings, unnulled');
hold off

% Plot Mel slopes versus individual fit quality

figure
scatter(BrightnessBetaDataOld(:,2),BrightnessIndividualFitQualityOld)
xlabel('Mel slope');
ylabel('Individual fit of linear model');
title('Correlation of fit quality of linear model to brightness rating with Mel slope, unnulled')

%% Comparison of nulled and unnulled brightness estimation

% For the next few graphs, find slopes for those subjects who completed nulled and unnulled
% estimation experiments.

BrightnessBetaDataBoth = zeros(nSubsBoth,3);
BrightnessBetaDataBothOld = zeros(nSubsBoth,3);
for i = 1:nSubsBoth
    TheSubject = SubjectsBoth(i);
    NulledIndex(i) = find(ismember(SubjectsNulled,char(TheSubject)));
    BrightnessBetaDataBoth(i,:) = BrightnessBetaData(NulledIndex(i),:);
    UnNulledIndex(i) = find(ismember(SubjectsUnNulled,char(TheSubject)));
    BrightnessBetaDataBothOld(i,:) = BrightnessBetaDataOld(UnNulledIndex(i),:);
end

% Plot slopes nulled and unnulled, including black lines connecting
% unnulled to nulled data for subjects who completed both experiments.

figure
for i = 1:nSubsBoth
    X = [BrightnessBetaDataBothOld(i,2) BrightnessBetaDataBoth(i,2)];
    Y = [BrightnessBetaDataBothOld(i,3) BrightnessBetaDataBoth(i,3)];
    h0 = plot(X, Y,'-k');
    hold on
end
hold on
h1 = scatter(BrightnessBetaDataOld(:,2), BrightnessBetaDataOld(:,3), 'xr')
hold on
h2 = scatter(BrightnessBetaData(:,2),BrightnessBetaData(:,3),'ob')
hold on
plot([0 0], [-100 100],'--k')
xlim([-40 40]);
ylim([0 60]);
xlabel('Mel slope');
ylabel('LMS slope');
title('Comparison of nulled to unnulled slopes')
legend([h1 h2 h0], 'Unnulled', 'Nulled', 'Same subject')
hold off

% Plot unnulled versus nulled slopes for Mel and LMS

figure
scatter(BrightnessBetaDataBothOld(:,2), BrightnessBetaDataBoth(:,2))
hold on
plot([-100 100], [-100 100], '--k')
xlim([-40 40]);
ylim([-40 40]);
xlabel('Unnulled Mel slope');
ylabel('Nulled Mel slope');
title('Unnulled vs. Nulled Mel Slopes')
hold off

figure
scatter(BrightnessBetaDataBothOld(:,3), BrightnessBetaDataBoth(:,3))
hold on
plot([-100 100], [-100 100], '--k')
xlim([0 60]);
ylim([0 60]);
xlabel('Unnulled LMS slope');
ylabel('Nulled LMS slope');
title('Unnulled vs. Nulled LMS Slopes')
hold off

%% Pupil plots

% Polar plot of only nulled pupil responses

figure
PlotRadius = 0.08; % Create a dummy data point to set the radius axis limit
h0 = polar(PlotRadius, '.k');
set(h0, 'MarkerSize', 0.000001);
hold on
h1 = polar(EachSubjectPupilPhaseLMS, EachSubjectPupilAmplitudeChangeLMS, '.r');
set(h1, 'MarkerSize', 12);
hold on
h2 = polar(EachSubjectPupilPhaseMel, EachSubjectPupilAmplitudeChangeMel, '.b');
set(h2, 'MarkerSize', 12);
title('Mel and LMS nulled pupil responses')
legend([h1, h2], 'LMS', 'Mel', 'Location', 'NorthEastOutside')
hold off

% Plot Mel slopes versus Mel pupil response for nulled data

NonZeroIndices = find(EachSubjectPupilAmplitudeChangeMel);
PupilAmplitudeRatio = EachSubjectPupilAmplitudeChangeMel./EachSubjectPupilAmplitudeChangeLMS;
BrightnessSlopeRatio = BrightnessBetaData(:,2)./BrightnessBetaData(:,3);
figure
scatter(BrightnessSlopeRatio(NonZeroIndices), PupilAmplitudeRatio(NonZeroIndices))
xlim([-1 1]);
ylim([0 1]);
xlabel('Brightness estimation slope (Mel/LMS)');
ylabel('Pupil amplitude change (Mel/LMS)');
title('Correlation of nulled Mel brightness estimation with pupil response');

% Polar plot of only unnulled pupil responses

figure
PlotRadius = 0.08; % Create a dummy data point to set the radius axis limit
h0 = polar(PlotRadius, '.k');
set(h0, 'MarkerSize', 0.000001);
hold on
h1 = polar(EachSubjectPupilPhaseLMSOld, EachSubjectPupilAmplitudeChangeLMSOld, '.r');
set(h1, 'MarkerSize', 12);
hold on
h2 = polar(EachSubjectPupilPhaseMelOld, EachSubjectPupilAmplitudeChangeMelOld, '.b');
set(h2, 'MarkerSize', 12);
title('Mel and LMS unnulled pupil responses')
legend([h1 h2], 'LMS', 'Mel', 'Location', 'NorthEastOutside')
hold off

% Polar plot of both nulled and unnulled pupil responses, Mel and LMS
% separately

figure
PlotRadius = 0.08; % Create a dummy data point to set the radius axis limit
h0 = polar(PlotRadius, '.k');
set(h0, 'MarkerSize', 0.000001);
hold on
NonZeroIndices = find(EachSubjectPupilAmplitudeChangeLMS);
NonZeroIndicesOld = find(EachSubjectPupilAmplitudeChangeLMSOld);
h1 = polar(EachSubjectPupilPhaseLMS(NonZeroIndices), EachSubjectPupilAmplitudeChangeLMS(NonZeroIndices), '.r');
set(h1, 'MarkerSize', 12);
hold on
h2 = polar(EachSubjectPupilPhaseLMSOld(NonZeroIndicesOld), EachSubjectPupilAmplitudeChangeLMSOld(NonZeroIndicesOld), 'xr');
set(h2, 'MarkerSize', 12);
title('Comparison of nulled and unnulled LMS pupil responses')
legend([h1 h2], 'LMS (nulled)', 'LMS (unnulled)', 'Location', 'NorthEastOutside')
hold off

figure
PlotRadius = 0.08; % Create a dummy data point to set the radius axis limit
h0 = polar(PlotRadius, '.k');
set(h0, 'MarkerSize', 0.000001);
hold on
NonZeroIndices = find(EachSubjectPupilAmplitudeChangeMel);
NonZeroIndicesOld = find(EachSubjectPupilAmplitudeChangeMelOld);
h1 = polar(EachSubjectPupilPhaseMel(NonZeroIndices), EachSubjectPupilAmplitudeChangeMel(NonZeroIndices), '.b');
set(h1, 'MarkerSize', 12);
hold on
h2 = polar(EachSubjectPupilPhaseMelOld(NonZeroIndicesOld), EachSubjectPupilAmplitudeChangeMelOld(NonZeroIndicesOld), 'xb');
set(h2, 'MarkerSize', 12);
title('Comparison of nulled and unnulled Mel nulled pupil responses')
legend([h1 h2], 'Mel (nulled)', 'Mel (unnulled)', 'Location', 'NorthEastOutside')
hold off

%% Analysis of genotyping response

% First gather and sort the results by genotype

GenotypesNulled = zeros(nSubsNulled,1);
for i = 1:nSubsNulled
    TheSubject = SubjectsNulled(i);
    Index(i) = find(ismember(Subjects,char(TheSubject)));
    GenotypesNulled(i) = Genotypes(Index(i));
end

CCAmplitudeChangeMel = [];
CCAmplitudeChangeLMS = [];
CTAmplitudeChangeMel = [];
CTAmplitudeChangeLMS = [];
TTAmplitudeChangeMel = [];
TTAmplitudeChangeLMS = [];
CCPhaseMel = [];
CCPhaseLMS = [];
CTPhaseMel = [];
CTPhaseLMS = [];
TTPhaseMel = [];
TTPhaseLMS = [];

for i = 1:nSubsNulled
    TheSubject = SubjectsNulled(i);
    if GenotypesNulled(i) == 0
        CCAmplitudeChangeMel = [CCAmplitudeChangeMel; EachSubjectPupilAmplitudeChangeMel(i)];
        CCAmplitudeChangeLMS = [CCAmplitudeChangeLMS; EachSubjectPupilAmplitudeChangeLMS(i)];
        CCPhaseMel = [CCPhaseMel; EachSubjectPupilPhaseMel(i)];
        CCPhaseLMS = [CCPhaseLMS; EachSubjectPupilPhaseLMS(i)];
    elseif GenotypesNulled(i) == 1
        CTAmplitudeChangeMel = [CTAmplitudeChangeMel; EachSubjectPupilAmplitudeChangeMel(i)];
        CTAmplitudeChangeLMS = [CTAmplitudeChangeLMS; EachSubjectPupilAmplitudeChangeLMS(i)];
        CTPhaseMel = [CTPhaseMel; EachSubjectPupilPhaseMel(i)];
        CTPhaseLMS = [CTPhaseLMS; EachSubjectPupilPhaseLMS(i)];
    elseif GenotypesNulled(i) == 2
        TTAmplitudeChangeMel = [TTAmplitudeChangeMel; EachSubjectPupilAmplitudeChangeMel(i)];
        TTAmplitudeChangeLMS = [TTAmplitudeChangeLMS; EachSubjectPupilAmplitudeChangeLMS(i)];
        TTPhaseMel = [TTPhaseMel; EachSubjectPupilPhaseMel(i)];
        TTPhaseLMS = [TTPhaseLMS; EachSubjectPupilPhaseLMS(i)];
    end
end


% Plot the brightness estimation slopes for each genotype

figure
scatter(GenotypesNulled, BrightnessSlopeRatio);
xlabel('Genotype');
ylabel('Brightness estimation slope (Mel/LMS)');
xlim([-1 3]);
set(gca, 'XTick',[0 1 2]);
set(gca, 'XTickLabel', ['CC';'CT';'TT']);

% Plot the pupil amplitude change ratio by genotype

figure
scatter(GenotypesNulled, PupilAmplitudeRatio);
xlabel('Genotype');
ylabel('Pupil amplitude change (Mel/LMS)');
xlim([-1 3]);
ylim([0 0.6]);
set(gca, 'XTick',[0 1 2]);
set(gca, 'XTickLabel', ['CC';'CT';'TT']);


% Polar plot of the Mel pupil responses by genotype

figure
PlotRadius = 0.04; % Create a dummy data point to set the radius axis limit
h0 = polar(PlotRadius, '.k');
set(h0, 'MarkerSize', 0.000001);
hold on
h1 = polar(CCPhaseMel, CCAmplitudeChangeMel, '.b');
set(h1, 'MarkerSize', 12);
hold on
h2 = polar(CTPhaseMel, CTAmplitudeChangeMel, '.r');
set(h2, 'MarkerSize', 12);
h3 = polar(TTPhaseMel, TTAmplitudeChangeMel, '.g');
set(h3, 'MarkerSize', 12);
title('Comparison of nulled Mel pupil responses by genotype')
legend([h1 h2 h3], 'CC', 'CT', 'TT', 'Location', 'NorthEastOutside')
hold off


%% Analysis and plotting of the nulling itself

%Loop through the subjects, load the data

for i = 1:nSubsNulled
    
    % Assemble the filename of the data set for this subject
    
    DataFileNulling = [char(NullingDir), char(SubjectsNulled(i)), '_nulling.mat'];
    
    load(DataFileNulling);
    
    % Extract the contrast added to the Mel and LMS positive and negative
    % modulations for each subject
    
    EachSubjectChangetoMelPos(i,1) = nulling{1,1}.LMScontrastadded;
    EachSubjectChangetoMelPos(i,2) = nulling{1,1}.LMinusMcontrastadded;
    EachSubjectChangetoMelPos(i,3) = nulling{1,1}.Scontrastadded;
    
    EachSubjectChangetoMelNeg(i,1) = nulling{1,2}.LMScontrastadded;
    EachSubjectChangetoMelNeg(i,2) = nulling{1,2}.LMinusMcontrastadded;
    EachSubjectChangetoMelNeg(i,3) = nulling{1,2}.Scontrastadded;
    
    EachSubjectChangetoLMSPos(i,1) = nulling{2,1}.LMScontrastadded;
    EachSubjectChangetoLMSPos(i,2) = nulling{2,1}.LMinusMcontrastadded;
    EachSubjectChangetoLMSPos(i,3) = nulling{2,1}.Scontrastadded;
    
    EachSubjectChangetoLMSNeg(i,1) = nulling{2,2}.LMScontrastadded;
    EachSubjectChangetoLMSNeg(i,2) = nulling{2,2}.LMinusMcontrastadded;
    EachSubjectChangetoLMSNeg(i,3) = nulling{2,2}.Scontrastadded;
    
end

% Calculate and report the median contrasts added

AcrossSubjectsMedianChangetoMelPos = median(EachSubjectChangetoMelPos,1);
AcrossSubjectsMedianChangetoMelNeg = median(EachSubjectChangetoMelNeg,1);
AcrossSubjectsMedianChangetoLMSPos = median(EachSubjectChangetoLMSPos,1);
AcrossSubjectsMedianChangetoLMSNeg = median(EachSubjectChangetoLMSNeg,1);

fprintf('=========Analysis of the nulling procedure==========\n')
fprintf('Number of subjects: %i\n', nSubsNulled);
fprintf('Median contrast added to positive Mel modulation [ LMS | L-M | S ]: [ %0.3f | %0.3f | %0.3f ]\n',  AcrossSubjectsMedianChangetoMelPos(1), AcrossSubjectsMedianChangetoMelPos(2), AcrossSubjectsMedianChangetoMelPos(3));
fprintf('Median contrast added to negative Mel modulation [ LMS | L-M | S ]: [ %0.3f | %0.3f | %0.3f ]\n',  AcrossSubjectsMedianChangetoMelNeg(1), AcrossSubjectsMedianChangetoMelNeg(2), AcrossSubjectsMedianChangetoMelNeg(3));
fprintf('Median contrast added to positive LMS modulation [ LMS | L-M | S ]: [ %0.3f | %0.3f | %0.3f ]\n',  AcrossSubjectsMedianChangetoLMSPos(1), AcrossSubjectsMedianChangetoLMSPos(2), AcrossSubjectsMedianChangetoLMSPos(3));
fprintf('Median contrast added to negative LMS modulation [ LMS | L-M | S ]: [ %0.3f | %0.3f | %0.3f ]\n',  AcrossSubjectsMedianChangetoLMSNeg(1), AcrossSubjectsMedianChangetoLMSNeg(2), AcrossSubjectsMedianChangetoLMSNeg(3));


% Plot the contrasts added to positive and negative Mel modulations

figure
scatter(100*EachSubjectChangetoMelPos(:,1), 100*EachSubjectChangetoMelNeg(:,1))
hold on
plot([-100 100], [0 0], '--k')
hold on
plot([0 0], [-100 100], '--k')
xlabel('LMS contrast added to positive Mel modulation (%)');
ylabel('LMS contrast added to negative Mel modulation (%)');
xlim([-10 10]);
ylim([-10 10]);

figure
scatter(100*EachSubjectChangetoMelPos(:,2), 100*EachSubjectChangetoMelNeg(:,2))
hold on
plot([-100 100], [0 0], '--k')
hold on
plot([0 0], [-100 100], '--k')
xlabel('L-M contrast added to positive Mel modulation (%)');
ylabel('L-M contrast added to negative Mel modulation (%)');
xlim([-5 5]);
ylim([-5 5]);


figure
scatter(100*EachSubjectChangetoLMSPos(:,2), 100*EachSubjectChangetoLMSNeg(:,2))
hold on
plot([-100 100], [0 0], '--k')
hold on
plot([0 0], [-100 100], '--k')
xlabel('L-M contrast added to positive LMS modulation (%)');
ylabel('L-M contrast added to negative LMS modulation (%)');
xlim([-5 5]);
ylim([-5 5]);


%% EMG Data Analysis and Plotting
%% First the nulled data


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
    fprintf(['\n===========EMG Analysis==========\n'])
    fprintf(['EMG Variance [across-subject mean of within-subject mean of mean-centered variance] -- \n']);
    fprintf(['Number of subjects: ' num2str(nSubsNulled) '\n']);
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
    fprintf(['Number of subjects: ' num2str(nSubsNulled) '\n']);
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
title('Orbicularis EMG variance as a function of Mel contrast, nulled')
xlabel('Relative Mel contrast') % x-axis label
ylabel('EMG variance [across-subject mean of within-subject mean of mean-centered variance]') % y-axis label
hold off

%% Then the unnulled data


if EMGInteractionFlag == 1
    
    % Fit a linear model of Mel and LMS contrast to the mean EMG variances with
    % interaction term
    
    interact=(MelContrastForAverages+1).*(LMSContrastForAverages+1);
    X=[MelContrastForAverages, LMSContrastForAverages,interact];
    [AverageEMGBetasOld,~,AverageEMGStatsOld] = glmfit(X,AcrossSubjectAverageofAveragesEMGOld);
    AverageEMGFitOld=X*AverageEMGBetasOld(2:4)+AverageEMGBetasOld(1);
    EMGVarianceExplainedOld=corr([AverageEMGFitOld,AcrossSubjectAverageofAveragesEMGOld]).^2;
    AverageEMGDataFitQualityOld=EMGVarianceExplainedOld(1,2);
    
    % Report some values from the mean EMG variance with interaction term
    
    fprintf(['Unnulled EMG Variance [across-subject mean of within-subject mean of mean-centered variance] -- \n']);
    fprintf(['Number of subjects: ' num2str(nSubsUnNulled) '\n']);
    fprintf(['Mel slope: ' num2str(AverageEMGBetasOld(2),'%1.2e') ', t(' num2str(AverageEMGStatsOld.dfe,'%1.0f') ')=' num2str(AverageEMGStatsOld.t(2),'%1.2f') ', p=' num2str(AverageEMGStatsOld.p(2),'%1.2e') '\n']);
    fprintf(['LMS slope: ' num2str(AverageEMGBetasOld(3),'%1.2e') ', t(' num2str(AverageEMGStatsOld.dfe,'%1.0f') ')=' num2str(AverageEMGStatsOld.t(3),'%1.2f') ', p=' num2str(AverageEMGStatsOld.p(3),'%1.2e') '\n']);
    fprintf(['Interaction slope: ' num2str(AverageEMGBetasOld(4),'%1.2e') ', t(' num2str(AverageEMGStatsOld.dfe,'%1.0f') ')=' num2str(AverageEMGStatsOld.t(4),'%1.2f') ', p=' num2str(AverageEMGStatsOld.p(4),'%1.2e') '\n']);
    fprintf('\n');
    
else
    
    % Fit a linear model of Mel and LMS contrast to the mean EMG variances
    % without interaction term
    
    X=[MelContrastForAverages, LMSContrastForAverages];
    [AverageEMGBetasOld,~,AverageEMGStatsOld] = glmfit(X,AcrossSubjectAverageofAveragesEMGOld);
    AverageEMGFitOld=X*AverageEMGBetasOld(2:3)+AverageEMGBetasOld(1);
    EMGVarianceExplainedOld=corr([AverageEMGFitOld,AcrossSubjectAverageofAveragesEMGOld]).^2;
    AverageEMGDataFitQualityOld=EMGVarianceExplainedOld(1,2);
    
    % Report some values from the mean EMG variance without interaction term
    
    fprintf(['Unnulled EMG Variance [across-subject mean of within-subject mean of mean-centered variance] -- \n']);
    fprintf(['Number of subjects: ' num2str(nSubsUnNulled) '\n']);
    fprintf(['Mel slope: ' num2str(AverageEMGBetasOld(2),'%1.2e') ', t(' num2str(AverageEMGStatsOld.dfe,'%1.0f') ')=' num2str(AverageEMGStatsOld.t(2),'%1.2f') ', p=' num2str(AverageEMGStatsOld.p(2),'%1.2e') '\n']);
    fprintf(['LMS slope: ' num2str(AverageEMGBetasOld(3),'%1.2e') ', t(' num2str(AverageEMGStatsOld.dfe,'%1.0f') ')=' num2str(AverageEMGStatsOld.t(3),'%1.2f') ', p=' num2str(AverageEMGStatsOld.p(3),'%1.2e') '\n']);
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
    plot(MelContrastForAverages(TargetIndices),AverageEMGFitOld(TargetIndices),'-r');
    if i==i
        hold on
    end
    %    ylim([0,0.002]);
    errorbar(MelContrastForAverages(TargetIndices),AcrossSubjectAverageofAveragesEMGOld(TargetIndices),AcrossSubjectSEMofAveragesEMGOld(TargetIndices),'Color',GrayTriplet,'Marker', 'none', 'LineStyle', 'none');
    plot(MelContrastForAverages(TargetIndices),AcrossSubjectAverageofAveragesEMGOld(TargetIndices),'o','MarkerEdgeColor','none','MarkerFaceColor',GrayTriplet,'MarkerSize',10);
end
title('Orbicularis EMG variance as a function of Mel contrast, unnulled')
xlabel('Relative Mel contrast') % x-axis label
ylabel('EMG variance [across-subject mean of within-subject mean of mean-centered variance]') % y-axis label
hold off
