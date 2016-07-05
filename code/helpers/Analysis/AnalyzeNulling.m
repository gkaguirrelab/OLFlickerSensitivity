%% Set the data directory

dataDir='/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/Nulling/';

%% Setting subjects: separate entries in the subject list by semicolons

Subjects=cellstr(['MelBright_C002';'MelBright_C003';'MelBright_C004';'MelBright_C005';'MelBright_C010';'MelBright_C013';'MelBright_C014';'MelBright_C015';'MelBright_C016';'MelBright_C017';'MelBright_C018';'MelBright_C019']);
nSubs=length(Subjects);

%% Set up variables for analyses

EachSubjectChangetoMelPos = zeros(nSubs,3);
EachSubjectChangetoMelNeg = zeros(nSubs,3);
EachSubjectChangetoLMSPos = zeros(nSubs,3);
EachSubjectChangetoLMSNeg = zeros(nSubs,3);


%% Loop through the subjects, load the data

for i = 1:nSubs
    
    % Assemble the filename of the data set for this subject
    
    dataFile = [char(dataDir), char(Subjects(i)), '_nulling.mat'];
    
    load(dataFile);
    
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

fprintf('Number of subjects: %i\n', nSubs);
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


% %% Scatter plot by subject of the contrast added to positive and negative arms of each modulation with 95% confidence interval error ellipse
% 
% data = [100*EachSubjectChangetoMelPos(:,1), 100*EachSubjectChangetoMelNeg(:,1)];
% 
% % Calculate the eigenvectors and eigenvalues
% covariance = cov(data);
% [eigenvec, eigenval ] = eig(covariance);
% 
% % Get the index of the largest eigenvector
% [largest_eigenvec_ind_c, r] = find(eigenval == max(max(eigenval)));
% largest_eigenvec = eigenvec(:, largest_eigenvec_ind_c);
% 
% % Get the largest eigenvalue
% largest_eigenval = max(max(eigenval));
% 
% % Get the smallest eigenvector and eigenvalue
% if(largest_eigenvec_ind_c == 1)
%     smallest_eigenval = max(eigenval(:,2))
%     smallest_eigenvec = eigenvec(:,2);
% else
%     smallest_eigenval = max(eigenval(:,1))
%     smallest_eigenvec = eigenvec(1,:);
% end
% 
% % Calculate the angle between the x-axis and the largest eigenvector
% angle = atan2(largest_eigenvec(2), largest_eigenvec(1));
% 
% % This angle is between -pi and pi.
% % Let's shift it such that the angle is between 0 and 2pi
% if(angle < 0)
%     angle = angle + 2*pi;
% end
% 
% % Get the coordinates of the data mean
% avg = mean(data);
% 
% % Get the 95% confidence interval error ellipse
% chisquare_val = 2.4477;
% theta_grid = linspace(0,2*pi);
% phi = angle;
% X0=avg(1);
% Y0=avg(2);
% a=chisquare_val*sqrt(largest_eigenval);
% b=chisquare_val*sqrt(smallest_eigenval);
% 
% % the ellipse in x and y coordinates 
% ellipse_x_r  = a*cos( theta_grid );
% ellipse_y_r  = b*sin( theta_grid );
% 
% %Define a rotation matrix
% R = [ cos(phi) sin(phi); -sin(phi) cos(phi) ];
% 
% %let's rotate the ellipse to some angle phi
% r_ellipse = [ellipse_x_r;ellipse_y_r]' * R;
% 
% % Draw the error ellipse
% figure
% plot(r_ellipse(:,1) + X0,r_ellipse(:,2) + Y0,'-')
% hold on;
% 
% % Plot the original data
% plot(data(:,1), data(:,2), '.');
% mindata = min(min(data));
% maxdata = max(max(data));
% Xlim([mindata-3, maxdata+3]);
% Ylim([mindata-3, maxdata+3]);
% hold on;
% 
% % Plot the eigenvectors
% quiver(X0, Y0, largest_eigenvec(1)*sqrt(largest_eigenval), largest_eigenvec(2)*sqrt(largest_eigenval), '-m', 'LineWidth',2);
% quiver(X0, Y0, smallest_eigenvec(1)*sqrt(smallest_eigenval), smallest_eigenvec(2)*sqrt(smallest_eigenval), '-g', 'LineWidth',2);
% hold on;
% 
% % Set the axis labels
% hXLabel = xlabel('LMS contrast added to positive Mel stimulus (%)');
% hYLabel = ylabel('LMS contrast added to negative Mel stimulus (%)');
% 
% hold off
% 
% 
% data = [100*EachSubjectChangetoMelPos(:,2), 100*EachSubjectChangetoMelNeg(:,2)];
% 
% % Calculate the eigenvectors and eigenvalues
% covariance = cov(data);
% [eigenvec, eigenval ] = eig(covariance);
% 
% % Get the index of the largest eigenvector
% [largest_eigenvec_ind_c, r] = find(eigenval == max(max(eigenval)));
% largest_eigenvec = eigenvec(:, largest_eigenvec_ind_c);
% 
% % Get the largest eigenvalue
% largest_eigenval = max(max(eigenval));
% 
% % Get the smallest eigenvector and eigenvalue
% if(largest_eigenvec_ind_c == 1)
%     smallest_eigenval = max(eigenval(:,2))
%     smallest_eigenvec = eigenvec(:,2);
% else
%     smallest_eigenval = max(eigenval(:,1))
%     smallest_eigenvec = eigenvec(1,:);
% end
% 
% % Calculate the angle between the x-axis and the largest eigenvector
% angle = atan2(largest_eigenvec(2), largest_eigenvec(1));
% 
% % This angle is between -pi and pi.
% % Let's shift it such that the angle is between 0 and 2pi
% if(angle < 0)
%     angle = angle + 2*pi;
% end
% 
% % Get the coordinates of the data mean
% avg = mean(data);
% 
% % Get the 95% confidence interval error ellipse
% chisquare_val = 2.4477;
% theta_grid = linspace(0,2*pi);
% phi = angle;
% X0=avg(1);
% Y0=avg(2);
% a=chisquare_val*sqrt(largest_eigenval);
% b=chisquare_val*sqrt(smallest_eigenval);
% 
% % the ellipse in x and y coordinates 
% ellipse_x_r  = a*cos( theta_grid );
% ellipse_y_r  = b*sin( theta_grid );
% 
% %Define a rotation matrix
% R = [ cos(phi) sin(phi); -sin(phi) cos(phi) ];
% 
% %let's rotate the ellipse to some angle phi
% r_ellipse = [ellipse_x_r;ellipse_y_r]' * R;
% 
% % Draw the error ellipse
% figure
% plot(r_ellipse(:,1) + X0,r_ellipse(:,2) + Y0,'-')
% hold on;
% 
% % Plot the original data
% plot(data(:,1), data(:,2), '.');
% mindata = min(min(data));
% maxdata = max(max(data));
% Xlim([mindata-3, maxdata+3]);
% Ylim([mindata-3, maxdata+3]);
% hold on;
% 
% % Plot the eigenvectors
% quiver(X0, Y0, largest_eigenvec(1)*sqrt(largest_eigenval), largest_eigenvec(2)*sqrt(largest_eigenval), '-m', 'LineWidth',2);
% quiver(X0, Y0, smallest_eigenvec(1)*sqrt(smallest_eigenval), smallest_eigenvec(2)*sqrt(smallest_eigenval), '-g', 'LineWidth',2);
% hold on;
% 
% % Set the axis labels
% hXLabel = xlabel('L-M contrast added to positive Mel stimulus (%)');
% hYLabel = ylabel('L-M contrast added to negative Mel stimulus (%)');
% 
% hold off
% 
% 
% 
% data = [100*EachSubjectChangetoLMSPos(:,2), 100*EachSubjectChangetoLMSNeg(:,2)];
% 
% % Calculate the eigenvectors and eigenvalues
% covariance = cov(data);
% [eigenvec, eigenval ] = eig(covariance);
% 
% % Get the index of the largest eigenvector
% [largest_eigenvec_ind_c, r] = find(eigenval == max(max(eigenval)));
% largest_eigenvec = eigenvec(:, largest_eigenvec_ind_c);
% 
% % Get the largest eigenvalue
% largest_eigenval = max(max(eigenval));
% 
% % Get the smallest eigenvector and eigenvalue
% if(largest_eigenvec_ind_c == 1)
%     smallest_eigenval = max(eigenval(:,2))
%     smallest_eigenvec = eigenvec(:,2);
% else
%     smallest_eigenval = max(eigenval(:,1))
%     smallest_eigenvec = eigenvec(1,:);
% end
% 
% % Calculate the angle between the x-axis and the largest eigenvector
% angle = atan2(largest_eigenvec(2), largest_eigenvec(1));
% 
% % This angle is between -pi and pi.
% % Let's shift it such that the angle is between 0 and 2pi
% if(angle < 0)
%     angle = angle + 2*pi;
% end
% 
% % Get the coordinates of the data mean
% avg = mean(data);
% 
% % Get the 95% confidence interval error ellipse
% chisquare_val = 2.4477;
% theta_grid = linspace(0,2*pi);
% phi = angle;
% X0=avg(1);
% Y0=avg(2);
% a=chisquare_val*sqrt(largest_eigenval);
% b=chisquare_val*sqrt(smallest_eigenval);
% 
% % the ellipse in x and y coordinates 
% ellipse_x_r  = a*cos( theta_grid );
% ellipse_y_r  = b*sin( theta_grid );
% 
% %Define a rotation matrix
% R = [ cos(phi) sin(phi); -sin(phi) cos(phi) ];
% 
% %let's rotate the ellipse to some angle phi
% r_ellipse = [ellipse_x_r;ellipse_y_r]' * R;
% 
% % Draw the error ellipse
% figure
% plot(r_ellipse(:,1) + X0,r_ellipse(:,2) + Y0,'-')
% hold on;
% 
% % Plot the original data
% plot(data(:,1), data(:,2), '.');
% mindata = min(min(data));
% maxdata = max(max(data));
% Xlim([mindata-3, maxdata+3]);
% Ylim([mindata-3, maxdata+3]);
% hold on;
% 
% % Plot the eigenvectors
% quiver(X0, Y0, largest_eigenvec(1)*sqrt(largest_eigenval), largest_eigenvec(2)*sqrt(largest_eigenval), '-m', 'LineWidth',2);
% quiver(X0, Y0, smallest_eigenvec(1)*sqrt(smallest_eigenval), smallest_eigenvec(2)*sqrt(smallest_eigenval), '-g', 'LineWidth',2);
% hold on;
% 
% % Set the axis labels
% hXLabel = xlabel('L-M contrast added to positive LMS stimulus (%)');
% hYLabel = ylabel('L-M contrast added to negative LMS stimulus (%)');
