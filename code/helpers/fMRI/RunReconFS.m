function RunReconFS(subject, protocol)

%------------ FreeSurfer -----------------------------%
fshome = getenv('FREESURFER_HOME');
fsmatlab = sprintf('%s/matlab',fshome);
if (exist(fsmatlab) == 7)
    path(path,fsmatlab);
end
clear fshome fsmatlab;
%-----------------------------------------------------%

%------------ FreeSurfer FAST ------------------------%
fsfasthome = getenv('FSFAST_HOME');
fsfasttoolbox = sprintf('%s/toolbox',fsfasthome);
if (exist(fsfasttoolbox) == 7)
    path(path,fsfasttoolbox);
end
clear fsfasthome fsfasttoolbox;
%-----------------------------------------------------%

setenv('BASH_ENV','~/.profile');

RunReconDriver(subject, protocol);

end

function RunReconDriver(subject, protocol)

cd('/private/tmp');

% Freesurfer subject directory
subjectsDIR = '/Applications/freesurfer/subjects';

% T1/T2 Vol source directory
baseDir = fullfile('/Data/Imaging/Protocols', protocol, 'Subjects');
anatomyDir = 'Anatomy';

%-------------------------------------------------
% Sets up the freesurfer subject directory tree
%-------------------------------------------------

commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
    'bin/recon-all ' ...
    '-i ' baseDir '/' subject '/' anatomyDir '/MPRAGE.nii ' ...
    '-s ' subject '-' protocol  ...
    ]);
[RuN o] = system(commandc);
if RuN ~= 0, disp (['WARNING:  reconal step 1 error']);
else disp ([subject '-' protocol ': recon all dir creation finished']);
end

%-------------------------------------------------
% Run Recon-all Sprotocoles 1-2-3
%-------------------------------------------------

commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
    'bin/recon-all ' ...
    '-autorecon-all -s ' subject '-' protocol ' ' ...
    ]);
[RuN o] = system(commandc);
if RuN ~= 0, disp (['WARNING:  reconal step 2 error']);
else disp ([subject '-' protocol ': recon all 123 finished']);
end

%-------------------------------------------------
% DONT USE THIS COMMAND FOR NOW
%-------------------------------------------------

% commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
%     'bin/recon-all ' ...
%     '-label_v1 -s ' subject '-' protocol ' ' ...
%     ]);
% [RuN o] = system(commandc);
% if RuN ~= 0, disp (['WARNING:  reconall v1 predict step1 error']);
% else disp (['recon v1 predict step1 successful']);
% end


%-------------------------------------
% Run Recon-all V1 Predict
%-------------------------------------

% commandc = (['export FREESURFER_HOME=/Applications/freesurfer4.4;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer4.4/bin:$PATH;/Applications/freesurfer4.4/' ...
%     'subjects/V1_average/scripts/predict_v1.sh ' subject '-' protocol ' ']);
% [RuN o] = system(commandc)
% if RuN ~= 0, disp (['WARNING:  reconal step v1predict shellscript error']);
% else disp (['reconal step v1predict shellscript finished']);
% end

%-----------------------------------
% Write the lh prob label as an mgh file
% with each vertex assigned with a
% probability of whether it belongs to V1
%-----------------------------------

% commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
%     'bin/mri_label2label ' ...
%     '--srclabel ' subjectsDIR '/' subject '-' protocol '/label/lh.v1.prob.label --outstat ' subjectsDIR '/' subject '-' protocol '/label/lh.v1-prob.mgh --s ' subject '-' protocol ' --regmethod surface --trglabel ' subjectsDIR '/' subject '-' protocol '/label/tmp.label --hemi lh ']);
% [RuN o] = system(commandc)
% if RuN ~= 0, disp (['WARNING: convert lh.v1.prob.label to lh.v1-prob.mgh error']);
% else disp (['convert lh.v1.prob.label to lh.v1-prob.mgh finished']);
% end

%-----------------------------------
% Write the rh prob label as an mgh file
% with each vertex assigned with a
% probability of whether it belongs to V1
%-----------------------------------

% commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
%     'bin/mri_label2label ' ...
%     '--srclabel ' subjectsDIR '/' subject '-' protocol '/label/rh.v1.prob.label --outstat ' subjectsDIR '/' subject '-' protocol '/label/rh.v1-prob.mgh --s ' subject '-' protocol ' --regmethod surface --trglabel ' subjectsDIR '/' subject '-' protocol '/label/tmp.label --hemi rh ']);
% [RuN o] = system(commandc)
% if RuN ~= 0, disp (['WARNING:  convert rh.v1.prob.label to rh.v1-prob.mgh error']);
% else disp (['convert rh.v1.prob.label to rh.v1-prob.mgh finished']);
% end

%------------------------------------
% binarize the lh output of the above step
% with a threshold of 0.8 ie
% only the vertices above 0.8
% will be included in V1 predict
% %------------------------------------
% 
% commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
%     'bin/mri_binarize ' ...
%     '--i ' subjectsDIR '/' subject '-' protocol '/label/lh.v1-prob.mgh --min 0.8 --o ' subjectsDIR '/' subject '-' protocol '/label/lh.v1-predict.mgh ']);
% [RuN o] = system(commandc)
% if RuN ~= 0, disp (['WARNING: binarize lh.v1-prob.mgh error']);
% else disp (['binarize lh.v1-prob.mgh finished']);
% end
% 
% %------------------------------------
% % binarize the rh output of the above step
% % with a threshold of 0.8 ie
% % only the vertices above 0.8
% % will be included in V1 predict
% %------------------------------------
% 
% commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
%     'bin/mri_binarize ' ...
%     '--i ' subjectsDIR '/' subject '-' protocol '/label/rh.v1-prob.mgh --min 0.8 --o ' subjectsDIR '/' subject '-' protocol '/label/rh.v1-predict.mgh ']);
% [RuN o] = system(commandc)
% if RuN ~= 0, disp (['WARNING: binarize rh.v1-prob.mgh error']);
% else disp (['binarize rh.v1-prob.mgh finished']);
% end
% 
% %------------------------------------
% % convert the lh output of the above step
% % to a label
% %------------------------------------
% 
% commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
%     'bin/mri_cor2label ' ...
%     '--i ' subjectsDIR '/' subject '-' protocol '/label/lh.v1-predict.mgh --id 1 --l ' subjectsDIR '/' subject '-' protocol '/label/lh.v1.predict.label --surf ' subject '-' protocol ' lh ' 'white']);
% [RuN o] = system(commandc)
% if RuN ~= 0, disp (['WARNING: convert to lh.v1.predict.label error']);
% else disp (['convert to lh.v1.predict.label finished']);
% end
% 
% %------------------------------------
% % convert the rh output of the above step
% % to a label
% %------------------------------------
% 
% commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
%     'bin/mri_cor2label ' ...
%     '--i ' subjectsDIR '/' subject '-' protocol '/label/rh.v1-predict.mgh --id 1 --l ' subjectsDIR '/' subject '-' protocol '/label/rh.v1.predict.label --surf ' subject '-' protocol ' rh ' 'white']);
% [RuN o] = system(commandc)
% if RuN ~= 0, disp (['WARNING: convert to rh.v1.predict.label error']);
% else disp (['convert to rh.v1.predict.label finished']);
% end
% 
% %------------------------------------
% % unite lh.v1.predict.label and lh.V1.label
% % to create lh.v1predict+V1.label
% %------------------------------------
% 
% commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
%     'bin/labels_union ' ...
%     ' ' subjectsDIR '/' subject '-' protocol '/label/lh.v1.predict.label ' ' ' subjectsDIR '/' subject '-' protocol '/label/lh.V1.label ' subjectsDIR '/' subject '-' protocol '/label/lh.v1predict+V1.label ']);
% [RuN o] = system(commandc)
% if RuN ~= 0, disp (['WARNING: unite lh.v1.predict.label and lh.V1.label error']);
% else disp (['unite lh.v1.predict.label and lh.V1.label finished']);
% end
% 
% %------------------------------------
% % unite rh.v1.predict.label and rh.V1.label
% % to create rh.v1predict+V1.label
% %------------------------------------
% 
% commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
%     'bin/labels_union ' ...
%     ' ' subjectsDIR '/' subject '-' protocol '/label/rh.v1.predict.label ' ' ' subjectsDIR '/' subject '-' protocol '/label/rh.V1.label ' subjectsDIR '/' subject '-' protocol '/label/rh.v1predict+V1.label ']);
% [RuN o] = system(commandc)
% if RuN ~= 0, disp (['WARNING: unite rh.v1.predict.label and rh.V1.label error']);
% else disp (['unite rh.v1.predict.label and rh.V1.label finished']);
% end
% 
% %------------------------------------
% % write morphometric stats from lh.v1predict.label
% %------------------------------------
% 
% commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
%     'bin/mris_anatomical_stats -l ' subjectsDIR '/' subject '-' protocol '/label/lh.v1.predict.label -t ' subjectsDIR '/' subject '-' protocol '/surf/lh.thickness -f ' subjectsDIR '/' subject '-' protocol '/stats/lh.v1predict-StrucMorpho.stats ' subject '-' protocol ' lh ']);
% [RuN o] = system(commandc)
% if RuN ~= 0, disp (['WARNING: lh v1predict morpho stats error']);
% else disp (['lh v1predict morpho stats finished']);
% end
% 
% %------------------------------------
% % write morphometric stats from rh.v1predict.label
% %------------------------------------
% 
% commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
%     'bin/mris_anatomical_stats -l ' subjectsDIR '/' subject '-' protocol '/label/rh.v1.predict.label -t ' subjectsDIR '/' subject '-' protocol '/surf/rh.thickness -f ' subjectsDIR '/' subject '-' protocol '/stats/rh.v1predict-StrucMorpho.stats ' subject '-' protocol ' rh ']);
% [RuN o] = system(commandc)
% if RuN ~= 0, disp (['WARNING: rh v1predict morpho stats error']);
% else disp (['rh v1predict morpho stats finished']);
% end
% 
% %------------------------------------
% % write morphometric stats from lh.v1predict+V1.label
% %------------------------------------
% 
% commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
%     'bin/mris_anatomical_stats -l ' subjectsDIR '/' subject '-' protocol '/label/lh.v1predict+V1.label -t ' subjectsDIR '/' subject '-' protocol '/surf/lh.thickness -f ' subjectsDIR '/' subject '-' protocol '/stats/lh.v1predict+V1-StrucMorpho.stats ' subject '-' protocol ' lh ']);
% [RuN o] = system(commandc)
% if RuN ~= 0, disp (['WARNING: lh v1predict+V1 morpho stats error']);
% else disp (['lh v1predict+V1 morpho stats finished']);
% end
% 
% %------------------------------------
% % write morphometric stats from rh.v1predict+V1.label
% %------------------------------------
% 
% commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
%     'bin/mris_anatomical_stats -l ' subjectsDIR '/' subject '-' protocol '/label/rh.v1predict+V1.label -t ' subjectsDIR '/' subject '-' protocol '/surf/rh.thickness -f ' subjectsDIR '/' subject '-' protocol '/stats/rh.v1predict+V1-StrucMorpho.stats ' subject '-' protocol ' rh ']);
% [RuN o] = system(commandc)
% if RuN ~= 0, disp (['WARNING: rh v1predict+V1 morpho stats error']);
% else disp (['rh v1predict+V1 morpho stats finished']);
% end

%------------------------------------
% run recon-all qcache
%------------------------------------

% commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
%     'bin/recon-all -s ' subject '-' protocol ' -qcache ']);
% [RuN o] = system(commandc)
% if RuN ~= 0, disp (['WARNING:  recon step qcache error']);
% else disp (['recon step qcache finished']);
% end

%------------------------------------
% run surfreg Step 1 to register rh to lh
%------------------------------------

commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
    'bin/surfreg --s ' subject '-' protocol ' --t fsaverage_sym --lh '])
[RuN o] = system(commandc)
if RuN ~= 0, disp (['WARNING: surfreg Step1 error']);
else disp ([subject '-' protocol ': surfreg Step1 finished']);
end

%------------------------------------
% run surfreg Step 2 to register rh to lh
%------------------------------------

commandc = (['export FREESURFER_HOME=/Applications/freesurfer;export SUBJECTS_DIR=' subjectsDIR ';export PATH=/Applications/freesurfer/bin:$PATH;/Applications/freesurfer/' ...
    'bin/surfreg --s ' subject '-' protocol ' --t fsaverage_sym --lh --xhemi '])
[RuN o] = system(commandc)
if RuN ~= 0, disp (['WARNING: surfreg Step2 error']);
else disp ([subject '-' protocol ': surfreg Step2 finished']);
end

%------------------------------------
% run surfreg Step 2 to register rh to lh
%------------------------------------

%commandc = (['mv ' hdir '' subject ' ' hdir 'Processed '])
%[RuN o] = system(commandc)
%if RuN ~= 0, disp (['WARNING: mv raw directory to Processed  error']);
%else disp (['mv raw directory to Processed successful']);
%end

end
