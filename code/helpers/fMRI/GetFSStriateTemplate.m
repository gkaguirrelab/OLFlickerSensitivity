function [v1 v2 v3] = GetFSStriateTemplate(subjectID, protocol, surf)
% [v1 v2 v3] = GetFSStriateTemplate(subjectID, protocol, surf)
%
% Returns Benson's templates.
%
% See also GetEccenBandFromFSSTriateTemplate

%% Aseemble paths, etc.
FS_SUBJECT = [subjectID '-' protocol];

% Figure out the template dir for fsaverage_sym
SUBJECTS_DIR = getenv('SUBJECTS_DIR');

% Assemble template dir
TEMPLATE_DIR = fullfile(SUBJECTS_DIR, FS_SUBJECT, 'templates');

if ~isdir(TEMPLATE_DIR)
    error([TEMPLATE_DIR ' does not exist. Run FSStriateTemplateToSubjAnat(...)']);
end

%% Load the files
areas = load_mgh(fullfile(TEMPLATE_DIR, ['areas-template.' surf '.mgh']));
eccen = load_mgh(fullfile(TEMPLATE_DIR, ['eccen-template.' surf '.mgh']));
angle = load_mgh(fullfile(TEMPLATE_DIR, ['angle-template.' surf '.mgh']));

%% Make a big vector
areas = areas(:);
eccen = eccen(:);
angle = angle(:);

%% V1
% Mask
v1.mask = (areas == 1);
v1.mask_ind = find(v1.mask);

% Angle
v1.angle = angle .* v1.mask;
v1.angle_ind = angle(v1.mask_ind);

% Eccentricity
v1.eccen = eccen .* v1.mask;
v1.eccen_ind = eccen(v1.mask_ind);

%% V2
% Mask
v2.mask = (areas == 2);
v2.mask_ind = find(v2.mask);

% Angle
v2.angle = angle .* v2.mask;
v2.angle_ind = angle(v2.mask_ind);

% Eccentricity
v2.eccen = eccen .* v2.mask;
v2.eccen_ind = eccen(v2.mask_ind);

%% V3
% Mask
v3.mask = (areas == 3);
v3.mask_ind = find(v3.mask);

% Angle
v3.angle = angle .* v3.mask;
v3.angle_ind = angle(v3.mask_ind);

% Eccentricity
v3.eccen = eccen .* v3.mask;
v3.eccen_ind = eccen(v3.mask_ind);