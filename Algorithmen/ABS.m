function [spikepos,y] = ABS(in, params)
%SCHWELLWERT computes the timestamps of detected spikes in timedomain
%
%   Input parameters:
%       in_struc:   Input structure which contains
%                       M:      Matrix with data, stored columnwise
%                       SaRa:   Sampling frequency
%                       t:      Time vector
%       optional input parameters:
%
%
%   Output parameters:
%       spikepos:   Timestamps of the detected spikes stored columnwise
%
%   Description: 
%       This Algorithm computes the timestamps of detected spikes in
%       timedomain. Therefor it uses a thresholding method. The spike
%       locations of the thresholded signal are indicated in spikepos. 
%   
%   Dependencies:
%              
%
%   Author: F. Lieb, Janurary 2016



fs = in.SaRa;
s = in.M;
[L,c] = size(s);

%prefilter signal
if params.filter
    if ~isfield(params,'F1')
        params.Fstop = 100;
        params.Fpass = 200;
        Apass = 0.2;
        Astop = 80;
        params.F1 = designfilt(   'highpassiir',...
                                  'StopbandFrequency',params.Fstop ,...
                                  'PassbandFrequency',params.Fpass,...
                                  'StopbandAttenuation',Astop, ...
                                  'PassbandRipple',Apass,...
                                  'SampleRate',fs,...
                                  'DesignMethod','butter');
    end
    f = filtfilt(params.F1,s);
else
    f = s;
end

y = abs(f);

switch params.method
    case 'numspikes'
        spikepos = getSpikePositions(abs(f),fs,s,params);
    case 'auto'
        global_fac = 7.8;
        if c==1
            [CC,LL] = wavedec(f,5,'sym5');
            lambda = global_fac*wnoisest(CC,LL,1);
            thout = wthresh(f,'h',lambda);
            spikepos=getSpikePositions(thout,fs,s,params);
            %[ppeaks, npeaks] = findmypeaks(abs(f),lambda,-lambda,s);
            %spikepos = sort([ppeaks npeaks]);
        else
            spikepos = cell(c,1);
            for jj=1:c
                [CC,LL] = wavedec(f(:,jj),5,'sym5');
                lambda = global_fac*wnoisest(CC,LL,1);
                thout = wthresh(f(:,jj),'h',lambda);
                spikepos{jj}=getSpikePositions(thout,fs,s(:,jj),params);
                %[ppeaks, npeaks] = findmypeaks(abs(f(:,jj)),lambda,-lambda,s(:,jj));
                %spikepos{jj} = sort([ppeaks npeaks]);
            end
        end
end