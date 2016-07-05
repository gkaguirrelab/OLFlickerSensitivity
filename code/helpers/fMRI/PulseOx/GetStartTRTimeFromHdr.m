function [trTime, nTRs, trDur] = GetStartTRTimeFromHdr(pathToNIFTIHdr);
% Gets TR start time from a Nifti header.

% Load in the header
fid = fopen(pathToNIFTIHdr,'r');  % Open text file
InputText = textscan(fid,'%s',100,'delimiter','\n');
fclose(fid);

% Find the occasion of the 'Series time' entry.
tmp = strrep(InputText{1}(5), 'Series time: ', '');
tmp = char(tmp);

% Convert the timestamp from HHMMSS.SSSSSS to "msec since midnight"
hrsInMsec = 60*60*1000*str2double(tmp(1:2));
minsInMsec = 60*1000*str2double(tmp(3:4));
secInMsec = 1000*str2double(tmp(5:end));
trTime = hrsInMsec + minsInMsec + secInMsec;

% nTRs
tmp = strrep(InputText{1}(26), 'Number of volumes: ', '');
nTRs = str2num(tmp{1});

% trDur
tmp = strrep(InputText{1}(31), 'Volume interval (s): ', '');
trDur = round(str2num(tmp{1}));