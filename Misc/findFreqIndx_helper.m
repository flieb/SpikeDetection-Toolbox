function out = findFreqIndx_helper(io,iu,M)
%FINDFREQINDX_HELPER helper function for findFreqIndx
%
% looks for an equidistant discretization of the intervall [iu io] with M
% elements or some number close to M.
%
% Author: F. Lieb, February 2016
%

isize = io-iu;

%alldiv(isize)
d=isize./(isize:-1:2);
d=d(d==round(d));

tmp = isize./d + 1;

%find element closest to M
[~,idx] = min(abs(tmp-M));
out = tmp(idx(1));

