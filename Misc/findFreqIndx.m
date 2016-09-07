function [M_out, freq, freqindx] = findFreqIndx(L,fs,fmin,fmax,M)
%FINDFREQINDX finds the corresponding frequency indices for specific set of
%             parameters
%
%   If fmin and fmax as well as L (signal length) and fs are specified, not
%   all M are possible due to the discretization and the limits due to fs
%   and L. 
%   This function looks for a possible number of frequency bins M_out which
%   is close the specified number M
%
% Author: F. Lieb, February 2016
%

%get minimum freq resolution:
dfreq = fs/L;

%get indx of minimum frequency:
fminidx = floor(fmin/dfreq);
%get indx of maximum frequency:
fmaxidx = ceil(fmax/dfreq);

M_out = findFreqIndx_helper(fmaxidx,fminidx,M);
freq = linspace(fminidx*dfreq,fmaxidx*dfreq,M_out);
freqindx = linspace(fminidx,fmaxidx, M_out);