function CombineTTFs(BASE_PATH1, subjects1, direction1, BASE_PATH2, subjects2, direction2, fieldInnerRing, fieldOuterRing, controlFlag, protocolIterFlag1, protocolIterFlag2, controlLabels, area, savePath)

switch area
    case 'V1'
        %% Load first set
        for s = 1:length(subjects1)
            if ~controlFlag
                fileName = ['copes.osgm.ffx.results_cortex_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.csv'];
                thePath = fullfile(BASE_PATH1, subjects1{s}, 'BOLD', ['TTFMRFlicker' protocolIterFlag1 '_' direction1 '_xrun.feat'], 'stats', fileName);
            else
                fileName = ['copes.osgm.ffx.results_cortex_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.csv'];
                thePath = fullfile(BASE_PATH1, subjects1{s}, 'BOLD', ['TTFMRFlickerC1_xrun.feat'], 'stats', fileName);
            end
            M = csvread(thePath);
            
            if ~controlFlag
                frequencies{1} = M(:, 1);
                M(:, 1) = [];
            end
            V1_res{1}(:, s) = M(:, 1);
            V2_res{1}(:, s) = M(:, 3);
            V3_res{1}(:, s) = M(:, 5);
            V4_res{1}(:, s) = M(:, 7);
        end
        
        %% Load second set
        for s = 1:length(subjects2)
            if ~controlFlag
                fileName = ['copes.osgm.ffx.results_cortex_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.csv'];
                thePath = fullfile(BASE_PATH2, subjects2{s}, 'BOLD', ['TTFMRFlicker' protocolIterFlag2 '_s' direction2 '_xrun.feat'], 'stats', fileName);
            else
                fileName = ['copes.osgm.ffx.results_cortex_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.csv'];
                thePath = fullfile(BASE_PATH2, subjects2{s}, 'BOLD', ['TTFMRFlickerC1_xrun.feat'], 'stats', fileName);
            end
            M = csvread(thePath);
            
            if ~controlFlag
                frequencies{2} = M(:, 1);
                M(:, 1) = [];
            end
            V1_res{2}(:, s) = M(:, 1);
            V2_res{2}(:, s) = M(:, 3);
            V3_res{2}(:, s) = M(:, 5);
            V4_res{2}(:, s) = M(:, 7);
        end
        
        %% Combine
        V1_combined = [V1_res{1} ; V1_res{2}];
        V2_combined = [V2_res{1} ; V2_res{2}];
        V3_combined = [V3_res{1} ; V3_res{2}];
        V4_combined = [V4_res{1} ; V4_res{2}];
        frequencies_combined = [frequencies{1} ; frequencies{2}];
        
        %% Find duplicate (most likely at 2 Hz)
        [n, bin] = histc(frequencies_combined, unique(frequencies_combined));
        multiple = find(n > 1);
        index    = find(ismember(bin, multiple));
        
        %% Average across the duplicate (most likely 2 Hz)
        % Get the frequencies
        frequencies_combined_tmp = frequencies_combined;
        frequencies_combined(index, :) = [];
        frequencies_combined = [frequencies_combined ; unique(frequencies_combined_tmp(index, :))];
        
        % Average within subject
        V1_combined_tmp = V1_combined;
        V1_combined(index, :) = [];
        V1_combined = [V1_combined ; mean(V1_combined_tmp(index, :))];
        
        V2_combined_tmp = V2_combined;
        V2_combined(index, :) = [];
        V2_combined = [V2_combined ; mean(V2_combined_tmp(index, :))];
        
        V3_combined_tmp = V3_combined;
        V3_combined(index, :) = [];
        V3_combined = [V3_combined ; mean(V3_combined_tmp(index, :))];
        
        V4_combined_tmp = V4_combined;
        V4_combined(index, :) = [];
        V4_combined = [V4_combined ; mean(V4_combined_tmp(index, :))];
        
        %% Sort it according to frequency
        [frequencies_combined, order] = sort(frequencies_combined);
        V1_combined = V1_combined(order, :);
        V2_combined = V2_combined(order, :);
        V3_combined = V3_combined(order, :);
        V4_combined = V4_combined(order, :);
        
        %% Save out. Save for each sub individually
        nDataPoints = length(frequencies_combined);
        for s = 1:length(subjects1)
            outDir = fullfile(savePath, [subjects1{s}(1) subjects1{s}(end)], 'BOLD', ['TTFMRFlickerYFull_' direction1 '_xrun.feat'], 'stats');
            if ~isdir(outDir)
                mkdir(outDir);
            end
            M = [frequencies_combined V1_combined(:, s) zeros(nDataPoints, 1) V2_combined(:, s) zeros(nDataPoints, 1) V3_combined(:, s) zeros(nDataPoints, 1) V4_combined(:, s) zeros(nDataPoints, 1)];
            csvwrite(fullfile(outDir, ['copes.osgm.ffx.results_cortex_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing)  'deg.csv']), M);
        end
    case 'LGN'
        %% Load first set
        for s = 1:length(subjects1)
            if ~controlFlag
                fileName = ['copes.osgm.ffx.results_lgn_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.csv'];
                thePath = fullfile(BASE_PATH1, subjects1{s}, 'BOLD', ['TTFMRFlicker' protocolIterFlag1 '_' direction1 '_xrun.feat'], 'stats', fileName);
            else
                fileName = ['copes.osgm.ffx.results_lgn_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.csv'];
                thePath = fullfile(BASE_PATH1, subjects1{s}, 'BOLD', ['TTFMRFlickerC1_xrun.feat'], 'stats', fileName);
            end
            M = csvread(thePath);
            
            if ~controlFlag
                frequencies{1} = M(:, 1);
                M(:, 1) = [];
            end
            LGN_res{1}(:, s) = M(:, 1);
            
        end
        
        %% Load second set
        for s = 1:length(subjects2)
            if ~controlFlag
                fileName = ['copes.osgm.ffx.results_lgn_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.csv'];
                thePath = fullfile(BASE_PATH2, subjects2{s}, 'BOLD', ['TTFMRFlicker' protocolIterFlag2 '_s' direction1 '_xrun.feat'], 'stats', fileName);
            else
                fileName = ['copes.osgm.ffx.results_lgn_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.csv'];
                thePath = fullfile(BASE_PATH2, subjects2{s}, 'BOLD', ['TTFMRFlickerC1_xrun.feat'], 'stats', fileName);
            end
            M = csvread(thePath);
            
            if ~controlFlag
                frequencies{2} = M(:, 1);
                M(:, 1) = [];
            end
            LGN_res{2}(:, s) = M(:, 1);
            
        end
        
        %% Combine
        LGN_combined = [LGN_res{1} ; LGN_res{2}];
        
        frequencies_combined = [frequencies{1} ; frequencies{2}];
        
        %% Find duplicate (most likely at 2 Hz)
        [n, bin] = histc(frequencies_combined, unique(frequencies_combined));
        multiple = find(n > 1);
        index    = find(ismember(bin, multiple));
        
        %% Average across the duplicate (most likely 2 Hz)
        % Get the frequencies
        frequencies_combined_tmp = frequencies_combined;
        frequencies_combined(index, :) = [];
        frequencies_combined = [frequencies_combined ; unique(frequencies_combined_tmp(index, :))];
        
        % Average within subject
        LGN_combined_tmp = LGN_combined;
        LGN_combined(index, :) = [];
        LGN_combined = [LGN_combined ; mean(LGN_combined_tmp(index, :))];
        
        
        %% Sort it according to frequency
        [frequencies_combined, order] = sort(frequencies_combined);
        LGN_combined = LGN_combined(order, :);
        
        
        %% Save out. Save for each sub individually
        nDataPoints = length(frequencies_combined);
        for s = 1:length(subjects1)
            outDir = fullfile(savePath, [subjects1{s}(1) subjects1{s}(end)], 'BOLD', ['TTFMRFlickerYFull_' direction1 '_xrun.feat'], 'stats');
            if ~isdir(outDir)
                mkdir(outDir);
            end
            M = [frequencies_combined LGN_combined(:, s) zeros(nDataPoints, 1)];
            csvwrite(fullfile(outDir, ['copes.osgm.ffx.results_lgn_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing)  'deg.csv']), M);
        end
end