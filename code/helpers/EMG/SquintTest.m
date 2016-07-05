
durationInSeconds=2;
i=1;
a='';
SquintStd=0;
while isempty(a)
    [time,data]=LabJackSample(durationInSeconds);
    SquintStd(i)=std(data);
    plot(time,data);
    a=input('Press return to obain the next sample, q to quit: ','s');
    i=i+1;
end
    
1000.*(SquintStd.^2)
1000.*mean(SquintStd.^2)
1000.*std(SquintStd.^2)