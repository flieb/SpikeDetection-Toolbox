function W2 = convFreqWeights(coeff, numfn, numtn)
%CONVFREQWEIGHTS sliding window neighborhood
%   Usage: W = convFreqWeights(coeff,numfn, numtn);
%
%   Input parameters:
%       coeff : Time-Frequency matrix with columnwise frequency content
%       numfn : Number of neighbors in frequency direction
%       numtn : Number of neighbors in time direction
%
%   Output parameters:
%       W2    : Convolved Time Frequency respresentation
%
%   Description:
%       convFreqWeights(coeff,numfn,numtn) computes the convolution of a 
%       mean-window with neighboring tf-coefficients
%
%   Author: F. Lieb, February 2016
%

%get inputsize
[cm, cn] = size(coeff);

if cn > cm
    coeff = coeff.';
end

factor = 2;
%get kernel
neigh = ones(numtn,numfn);
neigh = neigh./(norm(neigh(:),1));
windowcenter = ceil(numtn/2);
windowcenter2= ceil(numfn/2);

%container
if isa(coeff,'single')
    W = zeros(cm+numtn-1,cn + numfn-1,'single');
else
    W = zeros(cm+numtn-1,cn + numfn-1,'double');
end

%extend the borders
W(windowcenter:cm+windowcenter-1,windowcenter2:cn+windowcenter2-1)=abs(coeff).^factor;%abs(coeff).^2;
W(1:windowcenter-1,:) = flipud( W(windowcenter:2*(windowcenter-1),:) );
W(cm+windowcenter:end,:) = flipud( W(cm-numtn+2*windowcenter :cm+windowcenter-1,:) );
W(:,1:windowcenter2-1)= fliplr( W(:,windowcenter2:2*(windowcenter2-1)));
W(:,cn+windowcenter2:end)= fliplr( W(:,cn-numfn+2*windowcenter2:cn+windowcenter2-1));

%do convolution
W2 = (conv2(W,neigh,'valid')).^(1/factor);
%W2 =(conv2(W,neigh,'valid'));

