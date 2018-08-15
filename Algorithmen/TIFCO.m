function [spikepos,sx1,c] = TIFCO(in,params,sx)
%GABOR computes the timestamps of detected spikes in timedomain using a
%Gabor Transform based spike detection.
%
%   Input parameters:
%       in_struc:   Input structure which contains
%                       M:      Matrix with data, stored columnwise
%                       SaRa:   Sampling frequency
%       optional input parameters:
%                       sx: 
%   Output parameters:
%       spikepos:   Timestamps of the detected spikes stored columnwise
%       
%   Description: 
    %         This method is based on the work F.Lieb "...". This algorithm uses 
    %         a special case of Short-Time-Fourier Transform using a filter. As spikes 
    %         can be specified by a certain time-frequency behavior, frequencies below
    %         and above a certain level will be ignored by specifying them within the
    %         GABOR transform. By applying a moving average to the time-frequency
    %         coefficients the spike form is enforced. Then a STF is used on the singal
    %         generating an indicator signal indicated in spikepos. 
            % %   Dependencies:
%              
%
%   Author: f. Lieb, September 2016

if nargin<3
    sx = [];
end

s = in.M;
fs = in.SaRa;
L = length(s);

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

windowidth = round(1760*L/fs);%4000 for new quiroga data -- 3000 for old quiroga data -- 1760 for my data
if mod(windowidth,2)
    windowidth = windowidth - 1;
end
g = {'hann', windowidth}; 
a = 1;
M = 100;
fmin = 500;      %500 for simulation_1... %1000 for quirogaEasy1005-04
fmax = 3500;      %6000 for simulation_1 %8000 for quirogaEasy1005-04

if isempty(sx)

    c = dgtsf(f,g,a,fmin,fmax,M,fs);

    numt = 1;
    numf = size(c,2);
    %numf = 100;
    
    W = convFreqWeights(c,numf,numt);


    sx1 = sum(W,2);
else
    sx1 = sx;
end

switch params.method
    case 'numspikes'
        spikepos = getSpikePositions(sx1,fs,s,params);
    case 'auto'
        global_fac = 3.244; %change this
        [CC,LL] = wavedec(f,5,'sym5');
        lambda = global_fac*wnoisest(CC,LL,1);
        thout = wthresh(sx1,'h',lambda);
        %figure(4), plot(thout); lambda
        spikepos = getSpikePositions(thout,fs,s,params);
    case 'auto2'
        params.method = 'auto';
        global_fac = 2.24e+03; %change this
        [CC,LL] = wavedec(sx1,5,'sym5');
        lambda = global_fac*wnoisest(CC,LL,1);
        thout = wthresh(sx1,'h',lambda);
        spikepos = getSpikePositions(thout,fs,s,params);
    case 'energy'
        params.p = 0.80;
        params.rel_norm = 2.7e-3;%1.445e-4;
        %wavelet denoising
        wdenoising = 0;
        n = 9;
        w = 'sym5';
        tptr = 'sqtwolog'; %'rigrsure','heursure','sqtwolog','minimaxi'
        
        %high frequencies, decision variable
        %         c = dgtreal(xd,{'hann',20},1,200);
        %         y = sum(abs(cccc).^2,1);
     
        if wdenoising == 1
            xd = wden(sx1,tptr,'h','mln',n,w);
        else
            xd = sx1;
        end
        spikepos = getSpikePositions(xd,fs,s,params);
    otherwise
        warning('method not supported yet');
        spikepos = [];
end