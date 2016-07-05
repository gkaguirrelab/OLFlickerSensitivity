function [] = dicom_nii(dicomDir,outputDir,outputFile,varargin)
%
% Inputs:
%   -dicomDir = path to dicom directory (assumes single series)
%       -if directory has multiple serires, use dicom_sort.m first.
%   -outputDir = path to output directory for nifti file
%   -outputFile = name of output file, e.g. f.nii (must end in .nii)
%   -varargin = if 'B0', then does NOT save a 4D files
%
% Outputs:
%   calls mcverter with the following flag:
%       -o = output directory <dicomDir>
%       -f fsl = Ouput format: fsl
%           - 'fsl' is hard coded in this function, other options are:
%               spm, meta, nifti, analyze, or bv
%       -x = save each series to a seperate directory
%       -d = save output volumes as 4D files
%       -n = save files as .nii
%       -u = Use patient id instead of patient name for output file
%
% Written by Andrew S Bock Feb 2014
fprintf('\nConverting dicoms to nifti\n');
fprintf(['Input ' dicomDir '\n']);
fprintf(['Output ' fullfile(outputDir,outputFile) '\n']);
system(['mcverter -o ' outputDir ' -f fsl -x -d -n -u  ' dicomDir]);

% Find the name of the series directory created by mcverter
series = listdir(outputDir,'dirs');

% Find the name of the .nii file created by mcverter
nii = listdir(fullfile(outputDir,series{1}),'files');

% Rename the .nii file created by mcverter to desired <outputFile> name,
% in <outputDir>, and remove the series directory created by mcverter
movefile(fullfile(outputDir,series{1},nii{1}),...
    (fullfile(outputDir,outputFile)));
rmdir(fullfile(outputDir,series{1}),'s');
system(['gzip ' fullfile(outputDir, '*.nii')]);

