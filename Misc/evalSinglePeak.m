function out = evalSinglePeak(c_pos,offset,varargin)
%EVALSINGLEPEAK evaluates if a single spike position is present
%
% Description:
%   evalSinglePeak is a helper function for evalPeakList
%
% Author: F. Lieb, February 2016
%

%parse input correctly...
tmpvarargin = varargin{1};
n=length(tmpvarargin);

out = zeros(1,n);

for kk = 1:n
    vec = tmpvarargin{kk};
    out(kk) = any(abs(vec-c_pos)<=offset);
end

