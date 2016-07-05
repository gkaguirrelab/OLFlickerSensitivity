function lgn = GetFSLGNTemplate(subjectID, protocol)
% lgn = GetFSLGNTemplate(subjectID, protocol)
%
% Returns LGN ROI.
%
% See also GetFSStriateTemplate, GetEccenBandFromFSSTriateTemplate

%% Aseemble paths, etc.
FS_SUBJECT = [subjectID '-' protocol];

% Figure out the template dir for fsaverage_sym
SUBJECTS_DIR = getenv('SUBJECTS_DIR');

% Assemble template dir
TEMPLATE_DIR = fullfile(SUBJECTS_DIR, FS_SUBJECT, 'mri', 'roi');

if ~isdir(TEMPLATE_DIR)
    error([TEMPLATE_DIR ' does not exist. Run scripts to generate it.']);
end

%% Load the files
if ~exist(fullfile(TEMPLATE_DIR, ['lgn-native-bin.mgh']), 'file')
    [s, o] = system(['mri_convert ' fullfile(TEMPLATE_DIR, ['lgn-native-bin.nii.gz']) ' ' fullfile(TEMPLATE_DIR, ['lgn-native-bin.mgh'])]);
end

tmp = load_mgh(fullfile(TEMPLATE_DIR, ['lgn-native-bin.mgh']));

% Assemble struct
lgn.mask = tmp(:);
lgn.mask_ind = find(lgn.mask);