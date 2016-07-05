% Make covariates for 312s runs
dt = 0.01;
t = 0:dt:312-dt;

f = 1/48;
squareWave = square(2*pi*1/48*t);

% Rectify the square wave
squareWave(squareWave < 0) = 0;
plot(squareWave)

% Delete the first 'ON' part since we through that away

ylim([-0.1 1.1]);

% How many periods are there?
t1 = 0:48:312
x1 = ones(1, length(t1))
cov = [t1' 24*x1' x1'] ;

dlmwrite('ON_sustained.csv', cov, '\t');

% Make the delta functions
t2 = t1;
x2 = x1;
cov = [t2' 0.1*x2' x2'] ;
dlmwrite('ON_transient.csv', cov, '\t');

% Make the delta functions
t3 = 24:48:311
x3 = ones(1, length(t3))
cov = [t3' 0.1*x3' x3'] ;
dlmwrite('OFF_transient.csv', cov, '\t');

% Throaway
%cov = [0 24 1];
%dlmwrite('ON_first.csv', cov, '\t');