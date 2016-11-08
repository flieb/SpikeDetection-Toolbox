%this script reproduces the main plots in our paper

%% ROC Curves for specific sigma
clear all;

L = 60000;
fs = 10000;
sigma = 4;
numspikes = 100;
numruns = 20;

in.SaRa = fs;
params.method = 'numspikes';
params.numspikes = 1;
params.filter = 0;
params.windowidth = 1760;
params.fmax = 3500;
params.fmin = 500;
params.F1 = designfilt('highpassiir','StopbandFrequency',100 ,...
          'PassbandFrequency',200,'StopbandAttenuation',80, ...
          'PassbandRipple',0.2,'SampleRate',fs,'DesignMethod','butter');

FPvec = 1:40;
N = length(FPvec);
TPR = zeros(N,numruns);
FPR = zeros(N,numruns);


funlist = { 
            @(x,params) SWTTEO(x,params)
            @(x,params,sx) GABOR(x,params,sx)
            @(x,params) MTEO(x,[1 3 5],params)
            @(x,params) SWT2012(x,params)
            @(x,params) ABS(x,params)
            @(x,params) WTEO(x,params)
            @(x,params,Filt) hbbsd(x,params,Filt)
            @(x,params,rmm,rmmpos) PTSD(x,params,rmm,rmmpos)
            };
        
TPr = zeros(N,length(funlist));
TPs = zeros(N,length(funlist));

for jj=1:length(funlist)
    fprintf('%d:  ',jj);
    ffun = funlist{jj};
    for ii=1:numruns

        [s,t,sppos,snr] = genMEASignal(L,fs,sigma,numspikes,ii);
        in.M = s;
        params.numspikes = 1;
        sx = [];
        sx1=[];
        sx2=[];
        for kk = 1:N
            res = 1;
            FP = FPvec(kk);
            while(1)
                %fprintf('.');
                if jj==2 || jj==7 
                    [spikepos,sx] = ffun(in,params,sx);
                elseif jj==8
                    [spikepos,sx1,sx2] = ffun(in,params,sx1,sx2);
                    
                else
                    
                    spikepos = ffun(in,params);
                    
                end
                
                res = evalPeakList(sppos,2,spikepos);
                temp = (length(spikepos) - res)/numspikes*100;
                if abs(temp-FP)<0.5
                    FPR(kk,ii) = temp;
                    TPR(kk,ii) = res;
                    break;
                elseif temp>FP
                    params.numspikes = params.numspikes-1;
                elseif temp<FP
                    params.numspikes = params.numspikes+1;
                else
                    fprintf('shouldnt be here...!');
                end
            end

        end
        fprintf('%d ',ii);
    end
    fprintf('\n ');
    TPr(:,jj) = mean(TPR,2);
    TPs(:,jj) = std(TPR,0,2);
    
end


figure(sigma)
plot(TPr(:,1),'-s','LineWidth',1.0); hold on;
plot(TPr(:,2),'-*','LineWidth',1.0);
plot(TPr(:,3),'-x','LineWidth',1.0);
plot(TPr(:,4),'-o','LineWidth',1.0);
plot(TPr(:,5),'-+','LineWidth',1.0);
plot(TPr(:,6),'-diamond','LineWidth',1.0);
plot(TPr(:,7),'-v','LineWidth',1.0);
plot(TPr(:,8),'-p','LineWidth',1.0);
hold off;
xlabel('False Positive Rate (\%)');
ylabel('True Positive Rate (\%)');
title(['L=60000, fs=10k, \#spikes=100, sigma=' num2str(sigma) ', ' num2str(numruns) ' runs, genMEASignal(..ii)'])
legend('SWTTEO','GABOR','MTEO','SWT','ABS','WTEO','HBBSD','PTSD','Location','best');
ax20
%% Detection Rate for varying sigma

clear;

L = 60000;
fs = 10000;
numspikes = 100;
numruns = 20;

in.SaRa = fs;
params.method = 'numspikes';
params.windowidth = 1760;
params.fmin = 500;
params.fmax = 3500;
params.numspikes = numspikes;
params.filter = 0;
params.F1 = designfilt('highpassiir','StopbandFrequency',100 ,...
          'PassbandFrequency',200,'StopbandAttenuation',80, ...
          'PassbandRipple',0.2,'SampleRate',fs,'DesignMethod','butter');


sigmavec = 1:0.4:11;
snr_vec = zeros(size(sigmavec));
res = zeros(7,length(sigmavec),numruns);
fprintf('Starting...\n');

for jj=1:length(sigmavec)
    
    sigma = sigmavec(jj);
    s_snr = zeros(numruns,1);
    
    for kk=1:numruns
        [s,t,sppos,s_snr(kk)] = genMEASignal(L,fs,sigma,numspikes,kk);
        in.M = s;
        
  
        spikepos1 = WTEO(in,params);
        spikepos2 = SWTTEO(in,params);
        spikepos3 = MTEO(in,[1,3,5],params);
        spikepos4 = SWT2012(in, params);
        spikepos5 = ABS(in,params);
        spikepos6 = GABOR(in,params);
        spikepos7 = hbbsd(in,params);
        spikepos8 = PTSD(in,params);
             
        temp = evalPeakList(sppos,2,spikepos1,spikepos2,spikepos3,spikepos4,spikepos5,spikepos6,spikepos7,spikepos8)';
        res(:,jj,kk) = res(:,jj,kk) + temp;
    end
    fprintf('%d %% done \n',round(jj*100/length(sigmavec)));

    snr_vec(jj) = mean(s_snr);
end



resmean = mean(res,3);
resstd = std(res,1,3);

figure(2),
plot(snr_vec, resmean(2,:)./numspikes*100,'-s','LineWidth',1.5); hold on;
plot(snr_vec, resmean(6,:)./numspikes*100,'-*','LineWidth',1.5);
plot(snr_vec, resmean(3,:)./numspikes*100,'-x','LineWidth',1.5);
plot(snr_vec, resmean(4,:)./numspikes*100,'-o','LineWidth',1.5);
plot(snr_vec, resmean(5,:)./numspikes*100,'-+','LineWidth',1.5);
plot(snr_vec, resmean(1,:)./numspikes*100,'-d','LineWidth',1.5);
plot(snr_vec, resmean(7,:)./numspikes*100,'-v','LineWidth',1.5);
plot(snr_vec, resmean(8,:)./numspikes*100,'-p','LineWidth',1.5);

hold off;
xlabel('SNR'); ylabel('Detection Rate (DR)');
set(gca,'XDir','reverse');
legend('SWTTEO','GABOR','MTEO','SWT','ABS','WTEO','HBBSD','PTSD','Location','southwest');
%title(['Comparison of both methods. L=' num2str(L) ', No. of spikes=' num2str(numspikes) ', ' num2str(numruns) ' runs each'])
ax20



figure(3),hold off;
errorbar(snr_vec, resmean(2,:)./numspikes*100,resstd(2,:)./numspikes*100,'-s','LineWidth',1); hold on, 
errorbar(snr_vec, resmean(6,:)./numspikes*100,resstd(6,:)./numspikes*100,'-*','LineWidth',1); 
errorbar(snr_vec, resmean(3,:)./numspikes*100,resstd(3,:)./numspikes*100,'-x','LineWidth',1);
errorbar(snr_vec, resmean(4,:)./numspikes*100,resstd(4,:)./numspikes*100,'-o','LineWidth',1);
errorbar(snr_vec, resmean(5,:)./numspikes*100,resstd(5,:)./numspikes*100,'-+','LineWidth',1);
errorbar(snr_vec, resmean(1,:)./numspikes*100,resstd(1,:)./numspikes*100,'-d','LineWidth',1);
errorbar(snr_vec, resmean(7,:)./numspikes*100,resstd(7,:)./numspikes*100,'-v','LineWidth',1);
errorbar(snr_vec, resmean(8,:)./numspikes*100,resstd(8,:)./numspikes*100,'-p','LineWidth',1);
hold off;
ax20;
xlabel('SNR'); ylabel('Percentage of correctly found peaks');
set(gca,'XDir','reverse');
legend('SWTTEO','GABOR','MTEO','SWT','ABS','WTEO','HBBSD','PTSD','Location','southwest');
%title(['Comparison of both methods. L=' num2str(L) ', No. of spikes=' num2str(numspikes) ', ' num2str(numruns) ' runs each'])

figure(4), hold off;
plot(snr_vec, resstd(2,:)./numspikes*100,'-s','LineWidth',1.5); hold on;
plot(snr_vec, resstd(6,:)./numspikes*100,'-*','LineWidth',1.5);
plot(snr_vec, resstd(3,:)./numspikes*100,'-x','LineWidth',1.5);
plot(snr_vec, resstd(4,:)./numspikes*100,'-o','LineWidth',1.5);
plot(snr_vec, resstd(5,:)./numspikes*100,'-+','LineWidth',1.5);
plot(snr_vec, resstd(1,:)./numspikes*100,'-d','LineWidth',1.5);
plot(snr_vec, resstd(7,:)./numspikes*100,'-v','LineWidth',1.5);
plot(snr_vec, resstd(8,:)./numspikes*100,'-p','LineWidth',1.5);
xlabel('SNR');ylabel('Standard deviation (\%)');
set(gca,'XDir','reverse');
legend('SWTTEO','GABOR','MTEO','SWT','ABS','WTEO','HBBSD','PTSD','Location','best');