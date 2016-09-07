function n = getcurrwinsize(c_idx,min_idx,deswinsize)
% GETCURRWINSIZE computes current window size
% 
% Description:
%   checks wether we can already use the desired window size (deswinsize)
%   or if we have to use a smaller one, due to the cutoff frequency in the
%   dgtsf_variableWinWidth
%
% Author: F. Lieb, February 2016
%

tmp = 2*(c_idx-min_idx);
if (tmp < deswinsize)
    n = tmp;
else
    n = deswinsize;
end
