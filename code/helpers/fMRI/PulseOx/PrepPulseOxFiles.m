%% TTFMRFlickerY
theProtocol = 'TTFMRFlickerY';
theSubjects = {'G042514A' 'M041714M' 'M041814S'};

nRuns = 9;
for s = 1:length(theSubjects)
    for i = 1:nRuns
        niftiHdr = ['/Data/Imaging/Protocols/' theProtocol '/Subjects/' theSubjects{s} '/BOLD/_raw/' theProtocol '_' num2str(i) '.txt'];
        pulsFile = ['/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/Pulse-Ox/' theProtocol '/' theProtocol '_' theSubjects{s} '_' num2str(i, '%02.0f') '.puls'];
        HRrate = [];
        saveFSL = 1;
        try
            MakePulseRegressors(niftiHdr, pulsFile, HRrate, saveFSL);
        end
    end
end

%% TTFMRFlickerYs
theProtocol = 'TTFMRFlickerYs';
theSubjects = {'G042614A' 'M042914M' 'M042914S'};

nRuns = 9;
for s = 1:length(theSubjects)
    for i = 1:nRuns
        niftiHdr = ['/Data/Imaging/Protocols/' theProtocol '/Subjects/' theSubjects{s} '/BOLD/_raw/' theProtocol '_' num2str(i) '.txt'];
        pulsFile = ['/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/Pulse-Ox/' theProtocol '/' theProtocol '_' theSubjects{s} '_' num2str(i, '%02.0f') '.puls'];
        HRrate = [];
        saveFSL = 1;
        try
            MakePulseRegressors(niftiHdr, pulsFile, HRrate, saveFSL);
        end
    end
end

%% TTFMRFlickerPurkinje
theProtocol = 'TTFMRFlickerPurkinje';
theSubjects = {'G042614A' 'M043014M' 'M042714S'};

nRuns = 6;
for s = 1:length(theSubjects)
    for i = 1:nRuns
        niftiHdr = ['/Data/Imaging/Protocols/' theProtocol '/Subjects/' theSubjects{s} '/BOLD/_raw/' theProtocol '_' num2str(i) '.txt'];
        pulsFile = ['/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/data/Pulse-Ox/' theProtocol '/' theProtocol '_' theSubjects{s} '_' num2str(i, '%02.0f') '.puls'];
        HRrate = [];
        saveFSL = 1;
        try
            MakePulseRegressors(niftiHdr, pulsFile, HRrate, saveFSL);
        end
    end
end