%% 
% parameter sweep WTEO
%% plot Detection rate vs wavelets

clear all

wavesel = { 'db1',...
            'db7', ...
            'sym4',...
            'sym5',...
            'sym7',...
            'coif4',...
            'bior3.9',...
            'rbio3.9',...
         };

N = length(wavesel);     
     
L = 60000;
fs=10000;
numspikes = 100;
numruns = 10;

in.SaRa = fs;
params.method = 'numspikes';
params.numspikes = numspikes;
params.wavLevel = 2;
params.winlength = ceil(1.0e-3*fs);
params.filter = 0;

sigmavec = 1:1:11; %sigmavec = 1:0.4:11;
snr_vec = zeros(size(sigmavec));
res = zeros(N,length(sigmavec),numruns);
fprintf('Starting...\n');

for jj=1:length(sigmavec)
    
    sigma = sigmavec(jj);
    s_snr = zeros(numruns,1);
    
    for kk=1:numruns
        [s,t,sppos,s_snr(kk)] = genMEASignal(L,fs,sigma,numspikes,kk);
        in.M = s;
  
        for ii=1:N
            params.wavelet = wavesel{ii};
            spikepos2 = SWT2012(in,params);
            temp = evalPeakList(sppos,2,spikepos2);
            res(ii,jj,kk) = res(ii,jj,kk) + temp;
        end
    end
    fprintf('%d %% done \n',round(jj*100/length(sigmavec)));

    snr_vec(jj) = mean(s_snr);
end



resmean = mean(res,3);
resstd = std(res,1,3);

mean(resmean')


%% detection rate for different levels for the SWT algorithm.
clear;


L = 60000;
fs =10000;
numspikes = 100;
numruns = 10;

in.SaRa = fs;
params.method = 'numspikes';
params.numspikes = numspikes;
params.wavLevel = 0;
params.filter = 0;

N = 10;
sigmavec = 1:1:10;
res = zeros(N,length(sigmavec),numruns);
for jj=1:length(sigmavec)
    sigma = sigmavec(jj);
    for kk = 1:numruns
        [s,t,sppos] = genMEASignal(L,fs,sigma,numspikes,'randpos');
        in.M = s;
        for ii=1:N
            params.wavLevel = ii+2;
            spikepos2 = SWT2012(in,params);
            temp = evalPeakList(sppos,2,spikepos2);
            res(ii,jj,kk) = res(ii,jj,kk) + temp;
        end
    end
    fprintf('%d %% done \n',round(jj*100/length(sigmavec)));
end


resmean = mean(res,3);
tmp = mean(resmean');

for ii=1:N
    fprintf('Level: %d --> mDR: %2.3f\n',ii,tmp(ii));
end


%% detection rate for hbbsd filter length
clear;


L = 5000;
fs =10000;
numspikes = 40;
numruns = 1;

in.SaRa = fs;
params.method = 'numspikes';
params.numspikes = numspikes;
params.wavLevel = 0;
params.filter = 0;

N = 13;
sigmavec = 1;
res = zeros(length(N),length(sigmavec),numruns);
for jj=1:length(sigmavec)
    sigma = sigmavec(jj);
    for kk = 1:numruns
        [s,t,sppos] = genMEASignal(L,fs,sigma,numspikes,'randpos');
        in.M = s;
        for ii=1:length(N)
            params.spikelength = N(ii);
            spikepos2 = hbbsd(in,params);
            temp = evalPeakList(sppos,2,spikepos2);
            res(ii,jj,kk) = res(ii,jj,kk) + temp;
        end
    end
    fprintf('%d %% done \n',round(jj*100/length(sigmavec)));
end


resmean = mean(res,3);
mean(resmean')./numspikes * 100

%% parameter sweep for the ptsd


clear;


L = 60000;
fs =10000;
numspikes = 100;
numruns = 1;

in.SaRa = fs;
params.method = 'numspikes';
params.numspikes = numspikes;
params.wavLevel = 0;
params.filter = 0;

%plp = 3:7;
%
plp = [11 13 15 17 20 23 26];
sigmavec = 1:11; % sigmavec = 1:0.4:11;
res = zeros(length(plp),length(sigmavec),numruns);
for jj=1:length(sigmavec)
    sigma = sigmavec(jj);
    for kk = 1:numruns
        [s,t,sppos] = genMEASignal(L,fs,sigma,numspikes,'randpos');
        in.M = s;
        for ii=1:length(plp)
            params.rp = plp(ii);
            spikepos2 = ptsd(in,params);
            temp = evalPeakList(sppos,2,spikepos2);
            res(ii,jj,kk) = res(ii,jj,kk) + temp;
        end
    end
    fprintf('%d %% done \n',round(jj*100/length(sigmavec)));
end


resmean = mean(res,3);
mean(resmean')
