function MakeCortexMasks(fieldInnerRing, fieldOuterRing, outDir)

% Get the cortical ROIs in fsaverage_sym
templateDir = '/Applications/freesurfer/subjects/fsaverage_sym/templates';

%% Obtain the template
% Load in eccentricity template
eccen = MRIread(fullfile(templateDir, 'eccen-template.mgh.sym.mgh'));
eccen = eccen.vol;

% Load in area template
areas = MRIread(fullfile(templateDir, 'areas-template.mgh.sym.mgh'));
areas = areas.vol;

% Define an eccentricity mask
eccentricityMask = intersect(find(eccen < fieldOuterRing), find(eccen > fieldInnerRing));

% Get the area masks
for i = 1:3
    theVertices = intersect(eccentricityMask, find(areas == i));
    eval(['V' num2str(i) '_mask = theVertices;']);
end

% Load in hV4
tmp = csvread(fullfile(templateDir, 'hV4.csv'));
V4_mask = find(tmp(:, 1));


%% Save as MATLAB files
save(fullfile(outDir, ['V1_mask_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.mat']), 'V1_mask');
save(fullfile(outDir, ['V2_mask_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.mat']), 'V2_mask');
save(fullfile(outDir, ['V3_mask_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.mat']), 'V3_mask');
save(fullfile(outDir, ['hV4_mask_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.mat']), 'V4_mask');


%% Save out the masks as MGH
% Load in a scaffolding volume
areasMasked = MRIread(fullfile(templateDir, 'areas-template.mgh.sym.mgh'));
areasMasked.vol = zeros(size(areasMasked.vol));
areasMasked.vol(V1_mask) = 1;
areasMasked.vol(V2_mask) = 2;
areasMasked.vol(V3_mask) = 3;
areasMasked.vol(V4_mask) = 4;
MRIwrite(areasMasked, fullfile(outDir, ['Vx_masks_' num2str(fieldInnerRing) '-' num2str(fieldOuterRing) 'deg.mgh']));