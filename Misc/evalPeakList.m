function [out] = evalPeakList (sp_pos,offset,varargin)
%EVALPEAKLIST function to evaluate peak lists.
% Usage: out = evalPeakList(sp_pos,offset, spikepos1);
%        out = evalPeakList(sp_pos,offset, spikepos1, spikepos2);
%
%   Input parameters:
%       sp_pos : original list with spike positions
%       offset : possible offset of spike positions
%
%   Output parameters:
%       out    : number of correctly identified spikes for each of the
%                specified inputs 
%
%   Description:
%       evalPeakList(sp_pos, offset, vargargin) evaluates the spike
%       positions for the in varargin specified spike positions. Returned
%       are the number of correctly identified spikes, where sp_pos are the
%       original spike positions (see genTestMEASignal in the demo section)
%
% Author: F. Lieb, February 2016
%



out = zeros(1,length(varargin));

for c_pos=sp_pos
    out = out + evalSinglePeak(c_pos,offset,varargin);
end
