wls = SToWls([380 2 201]);
plot(wls, nulling{1, 1}.meas.modulationRaw.predictedSpd, '-k'); hold on;
plot(wls, nulling{1, 1}.meas.modulation.predictedSpd, '-r')
plot(wls, nulling{1, 1}.meas.modulationRaw.pr670.spectrum, '-g')
plot(wls, nulling{1, 1}.meas.modulation.pr670.spectrum, 'b')
legend('Predicted raw', 'Predicted nulled', 'Measured raw', 'Measured nulled');