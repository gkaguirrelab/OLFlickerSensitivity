
% Set up some variables

ContrastsPos = zeros(length(params.dataStruct),1);
RatingsPos = zeros(length(params.dataStruct),1);
ContrastsNeg = zeros(length(params.dataStruct),1);
RatingsNeg = zeros(length(params.dataStruct),1);

% Pull out the relevant contrast and rating data

for i = 1:length(params.dataStruct)
    ContrastsPos(i) = params.dataStruct(i,1).flickerContrast;
    RatingsPos(i) = params.dataStruct(i,1).rating;
        ContrastsNeg(i) = params.dataStruct(i,2).flickerContrast;
    RatingsNeg(i) = params.dataStruct(i,2).rating;
end

% Plot the rating data as a function of added LMS contrast for the positive
% and negative arms of the Mel modulation

figure
scatter(ContrastsPos, RatingsPos, 'ob')
hold on
scatter(ContrastsNeg, RatingsNeg, 'xr')
xlabel('LMS contrast added')
ylabel('Subjective flicker')
legend('Positive modulation','Negative modulation')
