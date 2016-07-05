function roi = GetEccenBandFromFSSTriateTemplate(roi, id, od)
% roi = GetEccenBandFromFSSTriateTemplate(roi, id, od)
%
% Returns the roi passed in but only in the eccentricity band specified by
% the inner diameter (id) and the outer diameter (od). This assumes that
% 'roi' was produced by GetFSStriateTemplate, which has already split up
% V1, V2, and V3 into separate variables.

% Perform a couple of basic checks
if id > od
   error('Inner diameter larger then outer diameter.'); 
end

if id == od
   error('Inner diameter the same as outer diameter.'); 
end

if ~isempty(setxor(fieldnames(roi), {'mask', 'mask_ind', 'angle', 'angle_ind', 'eccen', 'eccen_ind'}))
   error('roi struct not produced in format assumed in GetFSStriateTemplate (...)'); 
end

%% Now, let's extract the numbers we want
% Generate the ccentricity
tmp = (roi.eccen > id & roi.eccen < od);
roi.eccen = roi.eccen .* tmp;
roi.eccen_ind = find(roi.eccen);

% Update the mask
roi.mask = and(tmp, roi.mask);
roi.mask_ind = find(roi.mask);

% Update the angle
roi.angle = roi.angle .* roi.mask;
roi.angle_ind = find(roi.angle);