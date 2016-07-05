function FSStriateTemplateToSubjAnat(subjectID, protocol, dispAreas)
% FSStriateTemplateToSubjAnat(subjectID, protocol, dispAreas)

FS_SUBJECT = [subjectID '-' protocol];

% Figure out the template dir for fsaverage_sym
SUBJECTS_DIR = getenv('SUBJECTS_DIR');
TEMPLATE_DIR = fullfile(SUBJECTS_DIR, 'fsaverage_sym', 'templates');

% Template files
templates = {'areas', 'eccen', 'angle'};

% Check if the subject template dir exists
if ~isdir(fullfile(SUBJECTS_DIR, FS_SUBJECT, 'templates'))
   mkdir(fullfile(SUBJECTS_DIR, FS_SUBJECT, 'templates'));
end

for t = 1:length(templates)
    temp0 = templates{t};
    
    % Left hemisphere from fsaverage_sym to subject surface
    [s, o] = system(['mri_surf2surf --srcsubject fsaverage_sym --srcsurfreg sphere.reg --trgsubject ' FS_SUBJECT ' --trgsurfreg fsaverage_sym.sphere.reg --hemi lh --sval ' fullfile(TEMPLATE_DIR, [temp0 '-template.sym.mgh']) ' --tval ' fullfile(SUBJECTS_DIR, FS_SUBJECT, 'templates', [temp0 '-template.lh.mgh'])]);
    disp(o);
    
    % Right hemisphere from fsaverage_sym to subject surface
    [s, o] = system(['mri_surf2surf --srcsubject fsaverage_sym --srcsurfreg sphere.reg --trgsubject ' FS_SUBJECT '/xhemi --trgsurfreg fsaverage_sym.sphere.reg --hemi lh --sval ' fullfile(TEMPLATE_DIR, [temp0 '-template.sym.mgh']) ' --tval ' fullfile(SUBJECTS_DIR, FS_SUBJECT, 'templates', [temp0 '-template.rh.mgh'])]);
    disp(o);
    
    % Left hemisphere from subject surface to subject volume
    [s, o] = system(['mri_surf2vol --projfrac 1 --fillribbon --surfval ' fullfile(SUBJECTS_DIR, FS_SUBJECT, 'templates', [temp0 '-template.lh.mgh']) ' --hemi lh --template ' fullfile(SUBJECTS_DIR, FS_SUBJECT, 'mri', 'orig.mgz') ' --outvol ' fullfile(SUBJECTS_DIR, FS_SUBJECT, 'templates', [temp0 '-template.lh.orig.mgh']) ' --volregidentity ' FS_SUBJECT]);
    disp(o);
    
    % Right hemisphere from subject surface to subject volume
    [s, o] = system(['mri_surf2vol --projfrac 1  --fillribbon  --surfval ' fullfile(SUBJECTS_DIR, FS_SUBJECT, 'templates', [temp0 '-template.rh.mgh']) ' --hemi rh --template ' fullfile(SUBJECTS_DIR, FS_SUBJECT, 'mri', 'orig.mgz') ' --outvol ' fullfile(SUBJECTS_DIR, FS_SUBJECT, 'templates', [temp0 '-template.rh.orig.mgh']) ' --volregidentity ' FS_SUBJECT]);
    disp(o);
    
    % Add the two hemisphere together
    [s, o] = system(['mri_concat --o ' fullfile(SUBJECTS_DIR, FS_SUBJECT, 'templates', [temp0 '-template.orig.mgh']) ' --i ' fullfile(SUBJECTS_DIR, FS_SUBJECT, 'templates', [temp0 '-template.lh.orig.mgh']) ' ' fullfile(SUBJECTS_DIR, FS_SUBJECT, 'templates', [temp0 '-template.rh.orig.mgh']) ' --paired-sum']);
    disp(o);
    
    % Display if desired
    if dispAreas
        [s, o] = system(['tkmedit ' FS_SUBJECT ' orig.mgz -aux ' fullfile(SUBJECTS_DIR, FS_SUBJECT, 'templates', [temp0 '-template.orig.mgh'])]);
        disp(o);
    end
end