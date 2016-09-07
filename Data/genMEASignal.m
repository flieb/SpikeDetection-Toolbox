function [s,t,sp_pos,snr,s0] = genMEASignal(L,fs,sigma,numspikes,spikepos)

t = 0:1/fs:(L-1)/fs;

s0  = zeros(L,1);

if strcmp(spikepos,'randpos')
    rng('shuffle');
else
    rng(spikepos);
end

testspikes = importdata('testspikes2.mat');
noisedata = importdata('noisefilter10kHz_APMethod.mat');

u = sqrt(sigma*noisedata.sigma)*randn(L,1);
noise = filter(1,noisedata.d,u);

sp_width = size(testspikes,1);
[~,maxpos] = max(abs(testspikes),[],1);
apos = sp_width;
epos = L-sp_width-1;


sp_pos = [];
indx = 1;
while(length(sp_pos) ~= numspikes)
    tmp = ceil(apos + (epos-apos).*rand(1,1));
    if (min(abs(sp_pos-tmp))< sp_width + 50)
        continue;
    end
    
    %r = randi( [1,size(testspikes,1)],1,1);
    r = mod(indx,size(testspikes,2))+1;
    s0(tmp:tmp+sp_width-1) = testspikes(:,r);
    sp_pos(indx) = tmp + maxpos(r)-1;
    indx = indx + 1;
end

s = s0 + noise;

%snr = 20 *log10(std(s0)/std(s-s0));

snr= max(s0)/std(noise);


snr3  = 20*log10(peak2peak(s0)/peak2peak(noise));

offset = 5;

for kk=1:length(sp_pos)
    search_intervall = sp_pos(kk)-offset:sp_pos(kk)+offset;
    search_intervall = max(1,search_intervall);
    search_intervall = min(L,search_intervall);
    idxx = find(abs(s(search_intervall)) == max( abs(s(search_intervall) )),1,'first');
    sp_pos(kk) = sp_pos(kk)-offset+idxx-1;
end
sp_pos = sort(sp_pos);