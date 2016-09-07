function [c, freq] = dgtsf(f,g,a,fmin,fmax,M,fs,tinv)
%DGTSF Discrete Gabor transform with specified frequency range
%   Usage:  c = dgtsf(f,g,a,fmin,fmax,M,fs);
%           c = dgtsf(f,g,a,fmin,fmax,M,fs,'timeinv');
%           [c,freq] = dgtsf(f,g,a,fmin,fmax,M,fs);
%
%   Input parameters:
%       f    : Signal
%       a    : Length of time shifts
%       M    : Number of frequency channels
%       g    : Window function (currently supported: hanning window only)
%       fmin : Minimum frequency
%       fmax : Maximum frequency
%       tinv : Option to compute the time invariant version 
%
%   Output parameters:
%       c    : Time-Frequency respresentation
%       freq : Frequency axis ranging from [fmin fmax] 
%
%   Description:
%       dgtsf(f,g,a,fmin,fmax,M,fs) computes the time-frequency
%       represenation of f very efficiently if M is relatively small. The
%       option tinv computes the time-invariant phase (shift and modulation
%       operator are reversed). This phase option is requiered in the
%       spikeDetection Algorithm.
%
%       The window g can be a vector containing the window, or a cell array
%       where the first entry is the window type as a string. If the ltfat
%       toolbox is installed a variety of different windows are available,
%       if not only the hanning window is supported so far. The second
%       parameter in the cell array is the size of the window. For example
%       {'hann', 100} gives a hanning window with 100 datapoints. Please be
%       reminded that the windowing is done in the frequency domain, so a
%       narrow window will give a good frequency resolution.
%
%   
%   Dependencies:
%       findFreqIndx
%        ~gabwin if ltfat exists on path
%
%   Author: F. Lieb, Janurary 2016
%
if nargin<8
    tinv = '';
end

%get signal length
L=size(f,1);
if L == 1
    L = size(f,2);
    f = f';
end
    
numelectrodes = size(f,2);

%get window function
if (iscell(g))
    if exist('gabwin','file') == 2
        if strcmp(g{1},'gauss')
            winsize = L;
            glh = L/2;
            g2 = fftshift(gabwin(g,a,L,L));
        else
            winsize = ceil(g{2});
            glh=floor(winsize/2);
            g2 = fftshift(gabwin(g,a,winsize));
        end
        
    else
        winsize = ceil(g{2});
        glh = floor(winsize/2);
        g2 = hann(g{2},'periodic');
        g2 = g2./norm(g2);
    end
    offset = 0;
else
    g2 = g;
    winsize = length(g2);
    glh=floor(winsize/2);
    [~,ymaxidx] = max(g2);
    offset =  ymaxidx;
end

%number of time channels
N=L/a;

%find the most approriate M 
[M, freq,dfindx] = findFreqIndx(L,fs,fmin,fmax,M);

%container for result
if isa(f,'single')
    c=zeros(N,M,numelectrodes,'single');
else
    c=zeros(N,M,numelectrodes,'double');
end

%map to frq axis:
frqdst = fs/L;
fminidx = floor(fmin/frqdst);
if (iscell(g))
    win_range = fminidx-glh+1:fminidx+glh;
else
    win_range = fminidx-offset+1:fminidx+winsize-offset ;
end
win_range(win_range<1) = win_range(win_range<1)+L;

df = diff(dfindx);
df = df(1);

%fft of input signal
fhat = fft(f);

%loop over all frequency bins
for k = 1:M
    %pointwise multiplication
    c([end-floor(winsize/2)+1:end,1:ceil(winsize/2)],k,:) = bsxfun(@times,fhat(win_range,:),g2);
    %update window range
    win_range = win_range + df;
    win_range(win_range>L) = win_range(win_range>L)-L;
end
%ifft of output matrix
c = ifft(c);

%todo: do this computation inside the loop to save some comp time... 
% (couldnt get this to work...)
if (strcmp(tinv,'timeinv'))
    %apply time invariant factor:
    TimeInd = (0:(L/a-1))*a;
    phase = exp(2*pi*1i*(TimeInd'*dfindx)/L);
    c = bsxfun(@times,c,phase);
end