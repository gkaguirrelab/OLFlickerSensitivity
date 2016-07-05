theProtocols = {'TTFMRFlickerX' ...
    'TTFMRFlickerY' ...
    'TTFMRFlickerYs' ...
    'TTFMRFlickerPurkinje'}
theSubjectsPerProtocol = {{'G031614A' 'L031614L' 'M031614S'} ; ...
    {'G042514A' 'L041714L' 'M041714M' 'M041814S'} ; ...
    {'G042614A' 'L042714L'} ; ...
    {'G042614A' 'M042714S'}};
theDirectionsPerProtocol = {{'LMDirected' 'LMinusMDirected' 'SDirected' 'MelanopsinDirected'} ; ...
    {'LMDirected' 'LMinusMDirected' 'SDirected' 'MelanopsinDirected'} ; ...
    {'sLMDirected' 'sLMinusMDirected' 'sSDirected' 'sMelanopsinDirected'} ; ...
    {'LMDirectedScaled' 'sLMDirectedScaled' 'LMPenumbraDirected'}};
copeName = 'cope1'; % Always look at COPE1
theHemis = {'lh', 'rh'};
nAreas = 3;

% Load the templates
%templateDir = '/Applications/freesurfer/subjects/fsaverage_sym/templates/';
%templateFile = 'areas-template.mgh.sym.mgh';
templateDir = '/Data/Imaging/Protocols/TTFMRFlickerX/Templates';
templateFile = 'Vx_masks_5-13deg.mgh';
template = load_mgh(fullfile(templateDir, templateFile));

% Iterate over protocols
for p = 1:length(theProtocols)
    for s = 1:length(theSubjectsPerProtocol{p})
        fprintf('%s, %s', theProtocols{p}, theSubjectsPerProtocol{p}{s});
        fprintf('\n\t\t\t\t\t\t\t');
        for i = 1:nAreas
            fprintf('V%g (LH/RH)\t', i);
        end
        fprintf('\n');
        
        for d = 1:length(theDirectionsPerProtocol{p})
            % Figure out the base dir
            subjectName = theSubjectsPerProtocol{p}{s};
            directionName = theDirectionsPerProtocol{p}{d};
            % Append some white space
            max_len = 50;
            spacing_arg = ['%-', num2str(max_len),'s'];
            directionNameForPrinting = sprintf(spacing_arg, directionName);
            
            % Construct the folder
            theBaseDir = fullfile('/Data/Imaging/Protocols', theProtocols{p}, 'Subjects', subjectName, 'BOLD', [theProtocols{p} '_' directionName '_xrun.feat'], 'stats');
            
            % Iterate over hemis, then areas
            for h = 1:length(theHemis)
                % Load the mask from the ffx GLM
                mghFile = fullfile(theBaseDir, [copeName '.' theHemis{h} '.osgm.ffx/mask.mgh']);
                mask = load_mgh(mghFile);
                
                
                for i = 1:nAreas
                    % Find the intersection
                    nVertMaskTemplateIntersect(h, i) = length(intersect(find(mask), find(template == i)));
                    nVertTemplate(h, i) = length(find(template == i));
                end
            end
            coverage = nVertMaskTemplateIntersect./nVertTemplate;
            fprintf('%s\t', directionNameForPrinting)
            % Print out some coverage statistics
            for i = 1:nAreas
                fprintf('%.2f/%.2f\t', coverage(1, i), coverage(2, i));
            end
            fprintf('\n');
        end
        fprintf('\n');
    end
end