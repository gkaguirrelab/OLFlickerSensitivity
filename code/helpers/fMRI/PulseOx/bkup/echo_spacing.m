function echo_spacing(dicomDir,outDir)

%   Gets the echo-spacing (msec) and EPI TE (msec) from an EPI dicom file.
%   Requires AFNI (dicom_hdr -sexinfo Siemens EXtra INFO text).
%
%   Outputs the Echo Spacing and EPI TE as text files.
%
%   Written by Andrew S Bock Feb 2014

%% Get Dicoms
dicomlist = listdir(dicomDir,'files');
[~, result] = system(['dicom_hdr -sexinfo ' fullfile(dicomDir,dicomlist{1})]);
split_result = regexp(result,'\n','split');
%% Find acceleration factor
tmpaf = split_result(find(not(cellfun('isempty',strfind(split_result,'sPat.lAccelFactPE')))));
if ~isempty(tmpaf)
AF = tmpaf{1}(cell2mat(strfind(tmpaf,'='))+1:end);
AF = str2double(AF);
else
AF = [];
end
%% Find if Echo Spacing was stored in header (must have been manually set)
tmpes = split_result(find(not(cellfun('isempty',strfind(split_result,'lEchoSpacing')))));
if ~isempty(tmpes)
ESP = tmpes{1}(cell2mat(strfind(tmpes,'='))+1:end);
ESP = str2double(ESP);
else
ESP = [];
end
%% Find the pixel bandwidth
tmppb = split_result(find(not(cellfun('isempty',strfind(split_result,'Pixel Bandwidth')))));
if ~isempty(tmppb)
PBW = tmppb{1}(cell2mat(strfind(tmppb,'Bandwidth//'))+11:end);
PBW = str2double(PBW);
else
PBW = [];
end
%% Calculate Echo Spacing (msec)
if ~isempty(ESP); % Echo spacing stored in header (rare)
EchoSpacing = ESP/1000; % convert usec to msec
else
ESP = (1/PBW + .000082)*1000; % convert to echo spacing in msec
EchoSpacing= ESP/AF; % divide by acceleration factor
end
%% Find EPI TE
EPI_TE = dicominfo(fullfile(dicomDir,dicomlist{1}));
EPI_TE = EPI_TE.EchoTime;
%% Find Acquisution Type (acsending, descending, interleaved)
tmpaq = split_result(find(not(cellfun('isempty',strfind(split_result,'sSliceArray.ucMode')))));
if ~isempty(tmpaq)
AT = tmpaq{1}(cell2mat(strfind(tmpaq,'='))+2:end);
if strcmp(AT,'0x1')
AcquisitionType = 'Ascending';
elseif strcmp(AT,'0x2')
AcquisitionType = 'Descending';
elseif strcmp(AT,'0x4')
AcquisitionType = 'Interleaved';
else
AcquisitionType = 'Type_not_recognized';
end
else
AcquisitionType = 'sSliceArray.ucMode was empty';
end
%% Save echo spacing and EPI TE as text files
dicomDir
system(['echo ' num2str(EchoSpacing) ' > ' fullfile(outDir,'EchoSpacing')]);
system(['echo ' num2str(EPI_TE) ' > ' fullfile(outDir,'EPI_TE')]);
system(['echo ' AcquisitionType ' > ' fullfile(outDir,'AcquisitionType')]);