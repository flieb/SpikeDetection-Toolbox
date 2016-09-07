
function [ spikepos, t2, Diff2] = PTSD( in, params)
%PTSD computes the timestamps of detected spikes in timedomain using a
%modified thresholding method.
%
%   Input parameters:
%       in_struc:   Input structure which contains
%                       M:      Matrix with data, stored columnwise
%                       SaRa:   Sampling frequency
%                       t:      Time vector
%       optional input parameters:
%                       none
%   Output parameters:
%       spikepos:   Timestamps of the detected spikes stored columnwise
%       
%   Description: 
    %   This method is based on the work of A.Maccione, M.Gandolfo, P. Massobrio, S.Martinoia,
    %   and M.Chiappalone "A novel algorithm for precise identification of spikes in extracellularly
    %   recorded neuronal signals". The PTSD calculates the differences between Maxima and Minima and 
    %   stores them in an indicator signal. Those difference are then thresholded und the location of 
    %   spikes are indicated in spikepos
%   
%   Dependencies:
%              
%
%   Author: M. Pissulla, September 2016



s = in.M;
fs = in.SaRa;
L = length(s);

t= (1:L)./fs; 

plp = 0.5e-3*fs; %peak-lifetime-period
plp = round(plp);
rp = 2.0e-3*fs;  %refractory period
rp = round(rp);

[Diff2,t2] = mexPTSD(s,fs,plp,rp); %call mex-file

spikepos = getSpikePositions(Diff2,fs,s,params);
end