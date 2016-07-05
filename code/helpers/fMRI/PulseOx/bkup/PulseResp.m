function PulseResp(dicomDir,pulsFile,HRrate)
%   Reads the AcquisitionTime (AT) field from the dicom header, which is 
%   when the acquisition of data for each image started, and the 
%   'LogStartMDHTime', 'LogStopMDHTime' from the .puls file footer. 
%   Extracts the puls data during the DICOM acquistion interval (i.e. first
%   AT to last AT+TR).%
%   (Code adapted from scripts written by Joe McGuire)
%
%   Also computes a collection of regressors, based on 'PulseComplete.m'
%   written by Omar H Butt Aug 2010, for each individual run.  
%
%   Inputs:
%       -dicomDir = path to dicom directory of individual functional run
%       -pulsFile = path to .puls file with pulse oximetry data
%       -HRrate = 'low' <default> or 'high'
%           -0  = high average heartrate (>100) (e.g. canines)
%           -1  = low average HR rate (<100) (e.g. humans)
%
%   Outputs:
%       -.mat file containing the dicom, pulse, and output structures. 
%       Output structure contains sin and cos 1st and 2nd order 
%       physiological covariates
%
%   Written by Andrew S Bock Feb 2014
%% Get the acquistion time from the dicom files
series.List = dir(fullfile(dicomDir,'*'));
series.Names = {series.List(:).name}';
isHidden = strncmp('.',series.Names,1); % remove hidden files from the list
series.List(isHidden) = [];
nTRs = length(series.List);
fprintf('reading headers for %d dicom images...',nTRs);
dicom.TR_all = nan(nTRs,1); % TR from each image header
% Find the time of acquisition (info.AcquisitionTime) for all DICOMS
for t = 1:nTRs
    dicom.info = dicominfo(fullfile(dicomDir,series.List(t).name));
    dicom.TR_all(t,1) = dicom.info.RepetitionTime;
    dicom.timeStr = dicom.info.AcquisitionTime; % acquisition time
    % convert the timestamp from HHMMSS.SSSSSS to "msec since midnight"
    hrsInMsec = 60*60*1000*str2double(dicom.timeStr(1:2));
    minsInMsec = 60*1000*str2double(dicom.timeStr(3:4));
    secInMsec = 1000*str2double(dicom.timeStr(5:end));
    dicom.AT(t,1) = hrsInMsec + minsInMsec + secInMsec;
end
fprintf('done.\n');
dicom.TR = unique(dicom.TR_all); % confirm TR is consistent for all DICOMS
assert(numel(dicom.TR)==1,'Inconsistent TRs!');
fprintf('TR = %d (ms)\n',dicom.TR);
% verify that timestamps are non-decreasing across images
% (i.e., that dicoms were loaded in the correct order)
assert(all(diff(dicom.AT)>=0),'AcquisitionTime values are out of order');
%% Get the start and stop times from the .puls
% load the .puls file
fid = fopen(pulsFile);
textscan(fid,'%s',4); % Ignore first 4 values.
data = textscan(fid,'%u16'); % Read data until end of u16 data.
footer = textscan(fid,'%s');   % Read in remaining footer info
fclose(fid);
% Get timing information
footStampLabels = {'LogStartMDHTime', 'LogStopMDHTime'};
for i = 1:length(footStampLabels)
    labelStr = footStampLabels{i};
    labelIdx = find(strcmp(footer{1},[labelStr,':']))+1; % position of this timestamp in 'footer'
    pulse.(labelStr) = str2double(footer{1}{labelIdx}); % store the timestamp in a more convenient data structure
end
pulse.all = double(data{1}); % read in all values from data vector in .puls file
pulse.Idx = find(pulse.all<5000);% % Index of actual data values (i.e. not marker values >5000).
pulse.data = pulse.all(pulse.Idx); % actual data values
pulse.nSamps = length(pulse.Idx); % number of pulse values
pulse.dur = pulse.LogStopMDHTime - pulse.LogStartMDHTime; % Duration of pulse data (msec)
pulse.sampR = pulse.dur/(pulse.nSamps-1); % sampling rate in msec (~20 msec)
pulse.Hz = 1000/pulse.sampR; % Compute Hz from sampling rate (in msec)
assert(round(pulse.sampR)==20,'pulse sampling frequency is not 20 msec');
% Determine time stamp (tstmp) for each Pulse value
for i = 1:pulse.nSamps
    pulse.AT(i) = pulse.LogStartMDHTime + pulse.sampR*(i-1);
end
% Find pulse values that occur during the DICOMS acquistion interval (e.g. 
% start of first TR to end of last TR)
pulse.dicomIdx = find(dicom.AT(1) <= pulse.AT & pulse.AT <= (dicom.AT(end)+dicom.TR)); %Index of pulse data during DICOM interval
pulse.dicomAT = pulse.AT(pulse.dicomIdx); % extract pulse acquisition time during dicom acquisition time
pulse.signal = pulse.data(pulse.dicomIdx); % extract pulse signal during dicom acquistion time
% f = figure;plot(pulse.signal);
% set(f,'name',['Pulse data during ' dicom.info.ProtocolName]);%,'interpreter','none');
% xlabel('Acquisition Time (msec)');
% ylabel('Pulse Ox (Voltage)');
%% PulseComplete
if ~exist('HRrate','var')
    HRrate = 'low';
elseif HRrate == 0
    HRrate = 'high';
elseif HRrate == 1
    HRrate = 'low';
end
disp(['HRrate = ' HRrate]);
%% PulseSplitCore
n = 0; % Hard coded shift desired. Note, must be in multiples of 20ms.
spacer = n / 20;

arraylength=nTRs*dicom.TR/round(pulse.sampR); %note, rounded sampling rate to avoid interp error in 'sizecorrection'
tmpsignal = sizecorrection(pulse.signal,arraylength);
pulse.signal = tmpsignal;

Time = (1:length(pulse.signal))./pulse.Hz;
%Apply smoothing/filtering to the signal
[~, output.Hevents] = PhLEM_H(pulse.signal,pulse.Hz,HRrate);
[~, output.Levents] =  PhLEM_L(pulse.signal,pulse.Hz,HRrate);
output.Highes = PulseRegress(output.Hevents,Time,dicom.TR,spacer);
output.Lowes = PulseRegress(output.Levents,Time,dicom.TR,spacer);

output.Highrate = length(find(output.Hevents)) / Time(end) * 60;
disp([pulsFile sprintf(' Cardiac Rate (per min): %f',output.Highrate)]);
output.Lowrate = length(find(output.Levents)) / Time(end) * 60;
disp([pulsFile sprintf(' Resp Rate (per min): %f',output.Lowrate)]);

output.all = [output.Highes output.Lowes];
output.HSin1 = output.all(:,1);
output.HCos1 = output.all(:,2);
output.HSin2 = output.all(:,3);
output.HCos2 = output.all(:,4);
output.LSin1 = output.all(:,5);
output.LCos1 = output.all(:,6);
output.LSin2 = output.all(:,7);
output.LCos2 = output.all(:,8);
save([pulsFile '.mat'],'output','dicom','pulse');
disp(['Pulse data saved in ' pulsFile '.mat'])
function [outputsignal] = sizecorrection(signal,newlength)

x = 1:length(signal);
shifter = length(signal)/newlength;

outputsignal = zeros (1,newlength);

currentspot = 1;
for cc=1:newlength
    
    if currentspot > length(signal)
        currentspot = length(signal);
    else
        outputsignal(1,cc) = interp1(x,signal,currentspot,'linear');
        currentspot = currentspot + shifter;
    end
end

function writeme(CO,n,fname,HRF,LRF)
Hstring = [ ';VB98'; ';REF1'; ';    '; ];
ORs = sprintf('; Cardiac Rate: %f',HRF);
Ms = sprintf('; File length: %u',length(CO));
writetotext(CO(:,1),[sprintf('H-Sin1-(%u)-',n) fname],Hstring,ORs,Ms)
writetotext(CO(:,2),[sprintf('H-Cos1-(%u)-',n) fname],Hstring,ORs,Ms)
writetotext(CO(:,3),[sprintf('H-Sin2-(%u)-',n) fname],Hstring,ORs,Ms)
writetotext(CO(:,4),[sprintf('H-Cos2-(%u)-',n) fname],Hstring,ORs,Ms)
ORs = sprintf('; Resp Rate: %f',LRF);
writetotext(CO(:,5),[sprintf('L-Sin1-(%u)-',n) fname],Hstring,ORs,Ms)
writetotext(CO(:,6),[sprintf('L-Cos1-(%u)-',n) fname],Hstring,ORs,Ms)
writetotext(CO(:,7),[sprintf('L-Sin2-(%u)-',n) fname],Hstring,ORs,Ms)
writetotext(CO(:,8),[sprintf('L-Cos2-(%u)-',n) fname],Hstring,ORs,Ms)

%% PhLEM FUNCTIONS
%    delta         = search rate for looking for signal peaks
%    peak_rise     = amplitude threshold for looking for peaks
%    filter        = finter or smoothing type ('butter' or 'gaussian')
%    Wn            = filter/smoothing kernel.  If bandpass filter,
%                    normalized frequencies.  If gaussian smoothing,
%                    then kernel fwhm.
%    Hz            = Frequency of the sampled data signal

function [x,events] = PhLEM_H(TS,Hz, HRrate)
% Filter and smoothing function for HIGH frequencies
if strcmp(HRrate,'low')
    delta = Hz/3.5;
    Wn = [1 10]/Hz;
else
    delta = Hz/6;
    Wn = [1 14]/Hz; % Default [ 1 12]; a range from 9 to 12 works for second number
end
peak_rise = 0.1;
%Transform via ABS
x = abs(TS);
x = x - mean(x);
% Use butter filter
if ~isempty(Wn)
    [b a] = butter(1,Wn);
    xbutter = filter(b,a,x);
end
% -- Schlerf (Jul 24, 2008)
% Take a first pass at peak detection:
mxtb  = peakdet(x,1e-14);
% set the threshold based on the 20th highest rather than the highest:
sorted_peaks = sort(mxtb(:,2));
if length(sorted_peaks) > 20
    peak_resp=sorted_peaks(end-20);
else
    if length(sorted_peaks) > 15
        peak_resp=sorted_peaks(end-15);
    else
        if length(sorted_peaks) > 10
            peak_resp=sorted_peaks(end-10);
        else
            if length(sorted_peaks) > 5
                peak_resp=sorted_peaks(end-5);
            else
                peak_resp = sorted_peaks(1);
            end
        end
    end
end
% And now do a second pass, more robustly filtered, to get the actual peaks:
mxtb  = peakdet(x,peak_rise*peak_resp);
events = zeros(size(TS));
peaks = mxtb(:,1);
dpeaks = diff(peaks);
kppeaks = find(dpeaks > delta);
newpeaks = peaks([1 kppeaks'+1]);
events(newpeaks) = 1;
% DEBUG CATCH:
if length(newpeaks) < 5;
    warning('Program Crash: High Freq peaks hard to detect; try different HRrate field?')
    keyboard;
end

function [x,events] = PhLEM_L(TS,Hz,HRrate)
% Filter and smoothing function for LOW frequencies
if strcmp(HRrate,'low')
    delta = Hz*1.5;
    Wn = Hz*0.3;
else
    delta = Hz*1.5; %Default is Hz*1.5
    Wn = Hz*0.35; %Default is Hz*0.4
end
peak_rise = 0.5;
% Transform via ABS
x = abs(TS);
x = x - mean(x);
% Use Gaussian Filter
x = smooth_kernel(x(:),Wn);
x = x';
% -- Schlerf (Jul 24, 2008)
% Take a first pass at peak detection:
[mxtb,mntb] = peakdet(x,1e-14);
% set the threshold based on the 20th highest rather than the highest:
sorted_peaks = sort(mxtb(:,2));
if length(sorted_peaks) > 20
    peak_resp=sorted_peaks(end-20);
else
    if length(sorted_peaks) > 15
        peak_resp=sorted_peaks(end-15);
    else
        if length(sorted_peaks) > 10
            peak_resp=sorted_peaks(end-10);
        else
            if length(sorted_peaks) > 5
                peak_resp=sorted_peaks(end-5);
            else
                peak_resp = sorted_peaks(1);
            end
        end
    end
end
% And now do a second pass, more robustly filtered, to get the actual peaks:
[mxtb,mntb] = peakdet(x,peak_rise*peak_resp);
events = zeros(size(TS));
peaks = mxtb(:,1);
dpeaks = diff(peaks);
kppeaks = find(dpeaks > delta);
newpeaks = peaks([1 kppeaks'+1]);
events(newpeaks) = 1;
% DEBUG CATCH:
if length(newpeaks) < 5;
    delta = Hz*1.275;
    [mxtb,mntb] = peakdet(x,1e-14);
    % set the threshold based on the 20th highest rather than the highest:
    sorted_peaks = sort(mxtb(:,2));
    if length(sorted_peaks) > 20
        peak_resp=sorted_peaks(end-20);
    else
        if length(sorted_peaks) > 15
            peak_resp=sorted_peaks(end-15);
        else
            if length(sorted_peaks) > 10
                peak_resp=sorted_peaks(end-10);
            else
                if length(sorted_peaks) > 5
                    peak_resp=sorted_peaks(end-5);
                else
                    peak_resp = sorted_peaks(1);
                end
            end
        end
    end
    % And now do a second pass, more robustly filtered, to get the actual peaks:
    [mxtb,mntb] = peakdet(x,peak_rise*peak_resp);
    events = zeros(size(TS));
    peaks = mxtb(:,1);
    dpeaks = diff(peaks);
    kppeaks = find(dpeaks > delta);
    newpeaks = peaks([1 kppeaks'+1]);
    events(newpeaks) = 1;
    disp('Low Freq peaks hard to detect, switching delta')
    if length(newpeaks) < 5;
        warning('Program Crash: Low Freq peaks still hard to detect; Bad Data?')
    end
    %   keyboard;
end

function y=smooth_kernel(y,sigma)
% To run a gaussian smoothing kernel over the data
N=round(sigma*5)*2;
x=[1:N];
v=normpdf(x,(N+1)/2,sigma);
pb(1:length(v)-1)=y(1);
pe(1:length(v)-1)=y(end);
y=[pb';y;pe'];
y=conv(y,v);
cut=round(1.5*N);
y=y(cut-1:end-cut+1);

function [maxtab, mintab]=peakdet(v, delta)
%   PEAKDET Detect peaks in a vector
%   [MAXTAB, MINTAB] = PEAKDET(V, DELTA) finds the local
%   maxima and minima ("peaks") in the vector V.
%   A point is considered a maximum peak if it has the maximal
%   value, and was preceded (to the left) by a value lower by
%   DELTA. MAXTAB and MINTAB consists of two columns. Column 1
%   contains indices in V, and column 2 the found values.
%   Eli Billauer, 3.4.05 (Explicitly not copyrighted).
%   This function is released to the public domain; Any use is allowed.
maxtab = [];
mintab = [];
v = v(:); % Just in case this wasn't a proper vector
if (length(delta(:)))>1
    error('Input argument DELTA must be a scalar');
end
if delta <= 0
    error('Input argument DELTA must be positive');
end
mn = Inf; mx = -Inf;
mnpos = NaN; mxpos = NaN;
lookformax = 1;
for i=1:length(v)
    this = v(i);
    if this > mx, mx = this; mxpos = i; end
    if this < mn, mn = this; mnpos = i; end
    if lookformax
        if this < mx-delta
            maxtab = [maxtab ; mxpos mx];
            mn = this; mnpos = i;
            lookformax = 0;
        end
    else
        if this > mn+delta
            mintab = [mintab ; mnpos mn];
            mx = this; mxpos = i;
            lookformax = 1;
        end
    end
end

function phase = Ph_expand(event_series,time)
% function phase = PhLEM_phase_expand(event_series,time);
% Takes a series of events defined as 1's or 0's, and an index vector
% for real time (in seconds), and returns the unwarped phase between
% the events. Works by assuming that the distance between consecutive
% events is 2pi.
%
% Inputs:
%   event_series  = 1xN array of 1's (events) or 0's (non-events);
%   time          = 1xN array of timestamps in real time (seconds);
%
% Written by T. Verstynen (November 2007)
%
% Liscensed under the GPL public license (version 3.0)

% Time Stamps of Events
events = find(event_series);
% Phase Interpolation
uwp_phase = [0:length(events)-1];
uwp_phase = 2*pi.*uwp_phase;
phase = interp1(time(events),uwp_phase,time,'spline','extrap');

function [C] = PulseRegress(events,Time,TR,spacer)
phase = [ 1 2 ];
for p = phase
    tmp_phase = Ph_expand(events,Time);
    eval(sprintf('dphase%d = %d*tmp_phase;',p,phase(p)));
end
A = dphase1;
B = dphase2;
TR=TR/1000;
% Setup TR markers
bottom = mean(diff(Time));
ender= Time(end)-(TR/(2));
tr_timestamps = (0:TR:ender);
tr_timestamps = tr_timestamps./bottom;
%Analysis
if (spacer ~= 0) && (spacer > 0)
    fillerA = A(1,end-spacer+1:end);
    fillerB = B(1,end-spacer+1:end);
    phasev1 = [ fillerA A(1,1:end-spacer) ];
    phasev2 = [ fillerB B(1,1:end-spacer) ];
else if (spacer ~= 0) && (spacer < 0)
        fillerA = A(1,1:abs(spacer));
        fillerB = B(1,1:abs(spacer));
        phasev1 = [  A(1,1+abs(spacer):end) fillerA ];
        phasev2 = [  B(1,1+abs(spacer):end) fillerB ];
    else
        phasev1 = A;
        phasev2 = B;
    end
end
C = [];
for exp = phase
    zz= eval(sprintf('phasev%d', phase(exp)));
    nphs = interp1(zz,tr_timestamps,'linear','extrap');
    C = [C [sin(nphs)]'];
    C = [C [cos(nphs)]'];
end