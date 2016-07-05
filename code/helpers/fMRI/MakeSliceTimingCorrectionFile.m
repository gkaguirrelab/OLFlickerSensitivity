function MakeSliceTimingCorrectionFile(nSlices, protocolName)
% MakeSliceTimingCorrectionFile(nSlices, protocolName)
%
% Example:
%   - ONELIGHT protocol has 34 slices
%   - MakeSliceTimingCorrectionFile(34, 'ONELIGHT') produces a text file with
%   the right slice folder
% 
% Construct a slice timing correction file for FSL. FSL starts indexing
% with 1 (not 0), i.e. the first slice is 1, the second slice is 2.
%
% Emailf rom Mark Elliot regarding slices:
%
% "My notes on how the scheme works are as follows (note my slice numbering
% starts at 0, not 1):
% 
% for an ODD number of slices (example=9): 
%    0 2 4 6 8 1 3 5 7
% 
% for an EVEN number of slices (example=8) 
%    1 3 5 7 0 2 4 6
% 
% This is for axial slices, where 0 is the most inferior slice #, and the
% slice numbers go from 0,1,2,.,N-1 for N slices."

if nSlices < 1
    error('Number of slices must be bigger than 0');
end

if mod(nSlices, 2) == 0 % Even
    sliceOrder = [2:2:nSlices 1:2:nSlices];
else % Odd
    sliceOrder = [1:2:nSlices 2:2:nSlices];
end

% Save out
dlmwrite([protocolName '-SliceTimingCorrection.txt'], sliceOrder')