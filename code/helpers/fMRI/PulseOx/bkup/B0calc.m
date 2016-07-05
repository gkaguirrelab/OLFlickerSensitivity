function B0calc(outDir,magDicomDir,phaseDicomDir)
%   Calculate B0 map from double echo Siemens fieldmap sequence. Images are
%   phase unwrapped and in units of Hertz. 
%
%   Requires FSL and AFNI (dicom_hdr -sexinfo Siemens EXtra INFO text).
%   modified from scripts provided by Mark Elliot
%
%   Written by Andrew S Bock Feb 2014

fprintf('\nCREATING B0 FIELD MAP\n');
curr = cd;
%% Set up variables
magfile = fullfile(outDir,'mag_all.nii.gz');
phasefile = fullfile(outDir,'phase_all.nii.gz');
mag1file = fullfile(outDir,'mag1.nii.gz');
mag2file = fullfile(outDir,'mag2.nii.gz');
phase1file = fullfile(outDir,'phase1.nii.gz');
phase2file = fullfile(outDir,'phase2.nii.gz');
rad1file = fullfile(outDir,'rad1.nii.gz');
rad2file = fullfile(outDir,'rad2.nii.gz');
rad2rawfile = fullfile(outDir,'rad2raw.nii.gz');
rad2errfile = fullfile(outDir,'rad2err.nii.gz');
dradxfile = fullfile(outDir,'dradx.nii.gz');
brainfile = fullfile(outDir,'mag_brain.nii.gz');
maskfile = fullfile(outDir,'mag_brain_mask.nii.gz');
drad_unwrapfile = fullfile(outDir,'drad_unwrap.nii.gz');
drad_maskfile = fullfile(outDir,'drad_mask.nii.gz');
rpsmapfile = fullfile(outDir,'rpsmap.nii.gz');
rpsmap_prefillfile = fullfile(outDir,'rpsmap_prefill.nii.gz');
drad_mask_prefillfile = fullfile(outDir,'drad_mask_prefill.nii.gz');
rpsmap_nzmeanfile = fullfile(outDir,'rpsmap_nzmean.nii.gz');
tmp_fmapmaskedfile = fullfile(outDir,'tmp_fmapmasked.nii.gz');
rpsmap_predespikefile = fullfile(outDir,'rpsmap_predespike.nii.gz');
tmp_fmapfiltfile = fullfile(outDir,'tmp_fmapfilt.nii.gz');
tmp_eromaskfile = fullfile(outDir,'tmp_eromask.nii.gz');
tmp_edgemaskfile = fullfile(outDir,'tmp_edgemask.nii.gz');
tmp_fmapfiltedgefile = fullfile(outDir,'tmp_fmapfiltedge.nii.gz');
%% Determine type of B0 sequence
phaselist = listdir(phaseDicomDir,'files');
% monopolar vs bipolar
[~, result] = system(['dicom_hdr -sexinfo ' fullfile(phaseDicomDir,phaselist{1})]);
tmpstr1 = strfind(result,'ucReadOutMode');
ReadOutMode = result(tmpstr1+43:tmpstr1+45);
if strcmp(ReadOutMode,'0x1')
    readout = 'monopolar';
    fprintf('\nmonopolar read-out: OK\n')
elseif strcmp(ReadOutMode,'0x2')
    readout = 'bipolar';
    fprintf('\nbipolar read-out: OK\n')
else
    fprintf('\nERROR: unrecognized read-out mode\n')
end
% gre_field_mapping vs custom (most likely NOT gre_field_mapping)
[~, result] = system(['dicom_hdr -sexinfo ' fullfile(phaseDicomDir,phaselist{1})]);
fieldstr = strfind(result,'tSequenceFileName');
protostr = strfind(result,'tProtocolName');
Sequence = result(fieldstr:protostr-1);
if ~isempty(strfind(Sequence,'gre_field_mapping'))
    fprintf('\nSequence is gre_field_mapping sequence\n');
    Sequence = 'gre_field_mapping';
end
%% Get the TEs of each image, compute Echo Time difference
fprintf('\nComputing Echo Time difference\n');
EchoTimes = nan(1,length(phaselist));
for p = 1:length(phaselist)
    tmp = dicominfo(fullfile(phaseDicomDir,phaselist{p}));    
    EchoTimes(p) = tmp.EchoTime;
end
phase1 = min(EchoTimes);
phase2 = max(EchoTimes);
dTE = phase2 - phase1;
fprintf(['\nTE1 = ' num2str(phase1) ...
    '; TE2 = ' num2str(phase2)...
    '; dTE = ' num2str(dTE) '\n']);
%% If magnitude/phase volumes are 4D, separate into 3D volumes
mag = load_nifti(magfile);
if mag.dim(5) == 2
    fprintf('\nMagnitude image is 4D, creating 3D volumes\n')
    system(['fslroi ' magfile ' ' mag1file ' 0 1']);
    system(['fslroi ' magfile ' ' mag2file ' 1 1']);
    delete(magfile)
else
    fprintf('\nSingle magnitude image\n')
    movefile(magfile,mag1file);
end
phase = load_nifti(phasefile);
if phase.dim(5) == 2
    fprintf('\nPhase image is 4D, creating 3D volumes\n')
    system(['fslroi ' phasefile ' ' phase1file ' 0 1']);
    system(['fslroi ' phasefile ' ' phase2file ' 1 1']);
    delete(phasefile)
else
    fprintf('\nSingle phase image\n')
    movefile(phasefile,phase1file);
end
%% Compute fieldmap
% Convert integer phase images to radians
% Note: FSL's prelude doesn't care if maps are [0,2pi] or [-pi,pi])
fprintf('\nCalculating fieldmap\n')
% NOT Siemens "gre_field_mapping" sequence
if isempty(strfind(Sequence,'gre_field_mapping'))
    if strcmp(readout,'monopolar')
        system(['fslmaths ' phase1file ...
            ' -mul 3.14159 -div 2048 -sub 3.14159 ' ...
            rad1file ' -odt float']);
        system(['fslmaths ' phase2file ...
            ' -mul 3.14159 -div 2048 -sub 3.14159 ' ...
            rad2file ' -odt float']);
    elseif strcmp(readout,'bipolar')
        system(['fslmaths ' phase1file ...
            ' -mul 3.14159 -div 2048 -sub 3.14159 ' ...
            rad1file ' -odt float']);
        system(['fslmaths ' phase2file ...
            ' -mul 3.14159 -div 2048 -sub 3.14159 ' ...
            rad2rawfile ' -odt float']);
        [~,NP] = system(['fslval ' rad2rawfile ' dim1']); NP = str2double(NP);
        raw = load_nifti(rad2rawfile);
        for i=1:NP
            % this is the error in rad2 due to bipolar readout
            raw.vol(i,:,:) = ((i-1)-NP/2-1)*3.14159/NP/2; % i starts at 1, not 0, so subtract 1
        end
        save_nifti(raw,rad2errfile)
        system(['fslmaths ' rad2rawfile ' -sub ' rad2errfile ' ' rad2file]);
    else
        fprintf('\nERROR: unrecognized read-out mode\n')
    end
    % Siemens "gre_field_mapping" sequence
elseif ~isempty(strfind(Sequence,'gre_field_mapping'))
    system(['fslmaths ' phase1file ' -mul 3.14159 -div 2048 -sub 3.14159 ' ...
        dradxfile ' -odt float']);
end
%% Skull strip with BET ---
fprintf('\nSkull stripping with BET\n')
system(['bet ' mag1file ' ' brainfile ' -m -f 0.3 -R']);
%% Compute complex ratio of TE1 and TE2 images
% doing only one Prelude call works better (less wrap boundary errors)
if isempty(strfind(Sequence,'gre_field_mapping'))
    fprintf('\nComputing complex ratio of TE1 and TE2 images\n');
    brain = load_nifti(brainfile);
    rad1 = load_nifti(rad1file);
    rad2 = load_nifti(rad2file);
    tmp = brain;
    tmp.vol = -atan2((brain.vol.*sin(rad1.vol)).*(brain.vol.*cos(rad2.vol))...
        -(brain.vol.*cos(rad1.vol)).*(brain.vol.*sin(rad2.vol)),...
        (brain.vol.*cos(rad1.vol)).*(brain.vol.*cos(rad2.vol))+...
        (brain.vol.*sin(rad1.vol)).*(brain.vol.*sin(rad2.vol)));
    save_nifti(tmp,dradxfile);
end
%% Unwrap delta_phase image ---
prelude_option='';
if exist(maskfile,'file')
    prelude_option = (['--mask=' maskfile]);
end
system(['prelude -a ' brainfile ' -p ' dradxfile ' -o ' drad_unwrapfile ...
    ' ' prelude_option ' --savemask=' drad_maskfile]);
%% Convert phase difference image to Hz and radians/sec (x1000/msec = radians/sec)
system(['fslmaths ' drad_unwrapfile ' -mul 1000 -div ' num2str(dTE) ' ' rpsmapfile ' -odt float']);
%% Use FUGUE to fill holes
system(['immv ' rpsmapfile ' ' rpsmap_prefillfile]);
system(['fugue --loadfmap=' rpsmap_prefillfile ' --mask=' drad_maskfile ...
    ' --savefmap=' rpsmapfile]);
system(['immv ' drad_maskfile ' '   drad_mask_prefillfile]);
system(['fugue --loadfmap=' drad_mask_prefillfile ' --mask=' ...
    drad_mask_prefillfile ' --savefmap=' drad_maskfile]);
%% Remove mean from rpsmap
system(['immv ' rpsmapfile ' '  rpsmap_nzmeanfile]);
system(['fslmaths ' rpsmap_nzmeanfile ' -mas ' drad_maskfile ...
    ' ' tmp_fmapmaskedfile]);
[~, result] = system(['fslstats ' tmp_fmapmaskedfile ' -k ' drad_maskfile ' -P 50']);
result = str2double(result);result = num2str(result); % cleans up string
system(['fslmaths ' rpsmap_nzmeanfile ' -sub ' result ' -mas ' drad_maskfile ' ' rpsmapfile ' -odt float']);
%% Remove spikes from the edges of the rpsmap
system(['immv ' rpsmapfile ' ' rpsmap_predespikefile]);
system(['fugue --loadfmap=' rpsmap_predespikefile ' --savefmap=' ...
    tmp_fmapfiltfile ' --mask=' drad_maskfile ' --despike --despikethreshold=2.1']);
system(['fslmaths ' drad_maskfile ' -kernel 2D -ero ' tmp_eromaskfile]);
system(['fslmaths ' drad_maskfile ' -sub ' tmp_eromaskfile ' -thr 0.5 -bin ' ...
    tmp_edgemaskfile]);
system(['fslmaths ' tmp_fmapfiltfile ' -mas ' tmp_edgemaskfile ' ' tmp_fmapfiltedgefile]);
system(['fslmaths ' rpsmap_predespikefile ' -mas ' tmp_eromaskfile ...
    ' -add ' tmp_fmapfiltedgefile ' ' rpsmapfile]);
%% clean up file
cd(outDir)
fprintf('\nCleaning up files\n')
delete ./tmp* ./*rad* ./rpsmap_* ./*brain*
cd(curr)
fprintf('\ndone.\n')