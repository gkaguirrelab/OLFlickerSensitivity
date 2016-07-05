function AssembleDataMultiZMap(nSessions, theSubjectsPerSession, theDirectionPerSession, theProtocolPerSession, copeNum, nRunsPerSession);

% Make a new figure
nSubjects = length(theSubjectsPerSession{end}); % Assumes we have the same number of subjects in each session
% Iterate over sessions
for k = 1:nSessions
    for s = 1:length(theSubjectsPerSession{k})
        
        sessionSuffixes = {'A+', 'B+', 'C+', 'D+'};
        
        %% Load in the data
        for m = 1:nRunsPerSession
            %% Load in mean volumes
            sessionIdentifier = sessionSuffixes{m};
            %
            % Try some smoothing
            inFile1 = ['/Data/Imaging/Protocols/' theProtocolPerSession{k} '/Subjects/' theSubjectsPerSession{k}{s} '/BOLD/' theProtocolPerSession{k} '_' theDirectionPerSession{k} '_' sessionIdentifier '.feat/stats/zstat' num2str(copeNum{k}) '.diffeo.lh.sym.mgh'];
            outFile1 = ['/Data/Imaging/Protocols/' theProtocolPerSession{k} '/Subjects/' theSubjectsPerSession{k}{s} '/BOLD/' theProtocolPerSession{k} '_' theDirectionPerSession{k} '_' sessionIdentifier '.feat/stats/zstat' num2str(copeNum{k}) '.diffeo.lh.sym.smooth5mm.mgh'];
            
            commandc = ['mri_surf2surf --s fsaverage_sym --hemi lh --fwhm-src 3 --srcsurfval ' inFile1 ' --trgsurfval ' outFile1];
            system(commandc);
            
            % Try some smoothing
            inFile1 = ['/Data/Imaging/Protocols/' theProtocolPerSession{k} '/Subjects/' theSubjectsPerSession{k}{s} '/BOLD/' theProtocolPerSession{k} '_' theDirectionPerSession{k} '_' sessionIdentifier '.feat/stats/zstat' num2str(copeNum{k}) '.diffeo.rh.sym.mgh'];
            outFile1 = ['/Data/Imaging/Protocols/' theProtocolPerSession{k} '/Subjects/' theSubjectsPerSession{k}{s} '/BOLD/' theProtocolPerSession{k} '_' theDirectionPerSession{k} '_' sessionIdentifier '.feat/stats/zstat' num2str(copeNum{k}) '.diffeo.rh.sym.smooth5mm.mgh'];
            
            commandc = ['mri_surf2surf --s fsaverage_sym --hemi lh --fwhm-src 3 --srcsurfval ' inFile1 ' --trgsurfval ' outFile1];
            system(commandc);
            
            %% Load in mean volumes
            sessionIdentifier = sessionSuffixes{m};
            
            tmp = MRIread(['/Data/Imaging/Protocols/' theProtocolPerSession{k} '/Subjects/' theSubjectsPerSession{k}{s} '/BOLD/' theProtocolPerSession{k} '_' theDirectionPerSession{k} '_' sessionIdentifier '.feat/stats/zstat' num2str(copeNum{k}) '.diffeo.lh.sym.smooth5mm.mgh']);
            lh_zstat_func(s, k, m, :) = squeeze(tmp.vol)';
            
            tmp = MRIread(['/Data/Imaging/Protocols/' theProtocolPerSession{k} '/Subjects/' theSubjectsPerSession{k}{s} '/BOLD/' theProtocolPerSession{k} '_' theDirectionPerSession{k} '_' sessionIdentifier '.feat/stats/zstat' num2str(copeNum{k}) '.diffeo.rh.sym.smooth5mm.mgh']);
            rh_zstat_func(s, k, m, :) = squeeze(tmp.vol)';
            
            
            %             tmp = MRIread(['/Data/Imaging/Protocols/' theProtocolPerSession{k} '/Subjects/' theSubjectsPerSession{k}{s} '/BOLD/' theProtocolPerSession{k} '_' theDirectionPerSession{k} '_' sessionIdentifier '.feat/stats/zstat' num2str(copeNum{k}) '.diffeo.lh.sym.mgh']);
            %             lh_zstat_func(s, k, m, :) = squeeze(tmp.vol)';
            %
            %             tmp = MRIread(['/Data/Imaging/Protocols/' theProtocolPerSession{k} '/Subjects/' theSubjectsPerSession{k}{s} '/BOLD/' theProtocolPerSession{k} '_' theDirectionPerSession{k} '_' sessionIdentifier '.feat/stats/zstat' num2str(copeNum{k}) '.diffeo.rh.sym.mgh']);
            %             rh_zstat_func(s, k, m, :) = squeeze(tmp.vol)';
            
        end
    end
end

% Set some parameters for plotting
type = 'sig';
subject = 'fsaverage_sym';
hemi = 'lh';
surface = 'inflated';
trans = 1;
whichcolormap = 'autumn';
colorZmin = 0.5;
colorZmax = 1.5;
viewangle = 90;
zoomfigure = 3;
savefigure = true;

% Assemble the data in a different way
zstat_func_x{1} = [];
zstat_func_x{2} = [];
zstat_func_x{3} = [];

for s = 1:length(theSubjectsPerSession{k})
    for k = 1:nSessions
        
        for m = 1:nRunsPerSession
            zstat_func_x{s} = [zstat_func_x{s} squeeze(lh_zstat_func(s, k, m, :)) squeeze(rh_zstat_func(s, k, m, :))];
        end
    end
    outSaveDir = '/Users/Shared/Matlab/Experiments/OneLight/OLFlickerSensitivity/analysis/results/MRFlickerData';
    outFile = fullfile(outSaveDir, [theSubjectsPerSession{end}{s} '_' theProtocolPerSession{k} '_' theDirectionPerSession{k} '_xrun_xsession_max.zthresh1_5.smooth5mm.mgh']);
    
    % Save out the z stat
    zthresh = 0.5;
    tmp.vol = mean(zstat_func_x{s}, 2);
    tmp.vol(tmp.vol < zthresh) = NaN;
    MRIwrite(tmp, outFile);
    
    % Make plots and save them
    savefigpath = fullfile(outSaveDir, [theSubjectsPerSession{end}{s} '_' theProtocolPerSession{k} '_' theDirectionPerSession{k} '_xrun_xsession_max.zthresh1_5.smooth5mm.medial.pdf']);
    fig = surface_plot(type,outFile,subject,hemi,surface,trans,whichcolormap,colorZmin,colorZmax,viewangle,zoomfigure,savefigure,savefigpath);
    close(fig);
    
    savefigpath = fullfile(outSaveDir, [theSubjectsPerSession{end}{s} '_' theProtocolPerSession{k} '_' theDirectionPerSession{k} '_xrun_xsession_max.zthresh1_5.smooth5mm.lateral.pdf']);
    fig = surface_plot(type,outFile,subject,hemi,surface,trans,whichcolormap,colorZmin,colorZmax,-viewangle,zoomfigure,savefigure,savefigpath);
    close(fig);
end