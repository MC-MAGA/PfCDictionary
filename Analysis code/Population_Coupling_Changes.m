% changes in rate co-variation as captured by population coupling
% Using our definitions of population coupling:
%
% c_i = sum (fi - <fi>) . (P(not i) - <P(not i)>)
%     = 1/{#spikes from i} sum fi . Pn(not i)
%
% Where: fi is the SDF of neuron i
%        <fi> is the mean value of the SDF
%       Pn(not i) is the sum of all SDFs that are not neuron i, minus its mean
%
% Mark Humphries 26/4/2018


clear all; close all
 
Qt = 2; % 1 ms for convolution
window = 'Gaussian';
sd = 100; % 12 ms Gaussian width
bout_padding = 3;  % number of SDs to pad duration of each bout

cpletype = 'Pearson';  % population coupling correlation
lag = 0;
corrtype = 'Pearson';  % between epochs

type = 'Learn';  % 'Learn','Stable85'
N = 35;  % 35, 15
blnSaveSDF = 1;

load(['../Processed data/PartitionedSpike_Data_N' num2str(N) '_' type])
Nsessions = numel(Data);

%% get population coupling
for iS = 1:Nsessions
    iS
% for each session
    [Nneurons,Ntrials] = size(Data(iS).Trials);
    Nprebouts = size(Data(iS).PreEpoch,2);
    Npostbouts = size(Data(iS).PostEpoch,2);

   % for each neuron, convolve each bout, then stitch together
   SDF.Trial = []; SDF.PreEpoch = []; SDF.PostEpoch = [];
   for iN = 1:Nneurons    
            % for each trial
            sdf = [];
            for iT = 1:Ntrials
            % convolve and stitch
                T = [Times(iS).Trials(iT,1)-bout_padding*sd Times(iS).Trials(iT,2)+bout_padding*sd];  % pad to allow for spikes close to trial bounds 
                sdf = [sdf; convolve_spiketrains([Data(iS).Trials(iN,iT).spks(:,2) Data(iS).Trials(iN,iT).spks(:,1)],T,Qt,window,sd)]; % get spike-train density functions 
                %allsdf{iN,iT} = convolve_spiketrains([Data(iS).Trials(iN,iT).spks(:,2) Data(iS).Trials(iN,iT).spks(:,1)],T,Qt,window,sd);
            end 
            SDF.Trial(:,iN) = sdf;
            
            
            % for each pre-sleep bout
            sdf = [];
            for iP = 1:Nprebouts
            % convolve and stich
                T = [Times(iS).PreEpoch(iP,1)-bout_padding*sd Times(iS).PreEpoch(iP,2)+bout_padding*sd];  % pad to allow for spikes close to trial bounds 
                sdf = [sdf; convolve_spiketrains([Data(iS).PreEpoch(iN,iP).spks(:,2) Data(iS).PreEpoch(iN,iP).spks(:,1)],T,Qt,window,sd)]; % get spike-train density functions 
                
            end
            SDF.PreEpoch(:,iN) = sdf;
           
            % for each post-sleep bout
            sdf = [];
            for iP = 1:Npostbouts
            % convolve and stich
                T = [Times(iS).PostEpoch(iP,1)-bout_padding*sd Times(iS).PostEpoch(iP,2)+bout_padding*sd];  % pad to allow for spikes close to trial bounds 
                sdf = [sdf; convolve_spiketrains([Data(iS).PostEpoch(iN,iP).spks(:,2) Data(iS).PostEpoch(iN,iP).spks(:,1)],T,Qt,window,sd)]; % get spike-train density functions 
                
            end
            SDF.PostEpoch(:,iN) = sdf;
            
            
            if blnSaveSDF save(['SDF_Data_N' num2str(N) '_' type '_Session' num2str(iS) '_SD' num2str(sd) 'ms'],'SDF'); end

   end
   
   % compute population coupling per neuron
   PCple(iS).Trials = PopCouple(SDF.Trial,lag,cpletype);
   PCple(iS).Pre = PopCouple(SDF.PreEpoch,lag,cpletype);
   PCple(iS).Post = PopCouple(SDF.PostEpoch,lag,cpletype);
end

%% correlate and plot
for iS = 1:Nsessions
   relPre = PCple(iS).Pre./max(PCple(iS).Pre);
   relPost = PCple(iS).Post./max(PCple(iS).Post);
   relTrial = PCple(iS).Trials./max(PCple(iS).Trials);
   pltmin = min([min(relPre) min(relPost) min(relTrial)]);
   
   [PCple(iS).rho.relprepost,PCple(iS).p.relprepost] = corr(relPre,relPost,'type',corrtype);
   [PCple(iS).rho.reltrialpre,PCple(iS).p.reltrialpre] = corr(relTrial,relPre,'type',corrtype);
   [PCple(iS).rho.reltrialpost,PCple(iS).p.reltrialpost] = corr(relTrial,relPost,'type',corrtype);
 
   [PCple(iS).rho.prepost,PCple(iS).p.prepost] = corr(PCple(iS).Pre,PCple(iS).Post,'type',corrtype);
   [PCple(iS).rho.trialpre,PCple(iS).p.trialpre] = corr(PCple(iS).Trials,PCple(iS).Pre,'type',corrtype);
   [PCple(iS).rho.trialpost,PCple(iS).p.trialpost] = corr(PCple(iS).Trials,PCple(iS).Post,'type',corrtype);
   pltmin = 0;

  
   figure
   subplot(131),plot(PCple(iS).Pre,PCple(iS).Post,'ko')
   xlabel('Pre-training population coupling')
   ylabel('Post-training population coupling')
   title(['Rho = ' num2str(PCple(iS).rho.prepost)])
   axis square
   line([pltmin 1],[pltmin 1],'Color',[0.7 0.7 0.7])

   subplot(132),plot(PCple(iS).Trials,PCple(iS).Pre,'ro')
   xlabel('Trial population coupling')
   ylabel('Pre-training population coupling')
   title(['Rho = ' num2str(PCple(iS).rho.trialpre)])

   axis square
   line([pltmin 1],[pltmin 1],'Color',[0.7 0.7 0.7])
 
   subplot(133),plot(PCple(iS).Trials,PCple(iS).Post,'bo')
   xlabel('Trial population coupling')
   ylabel('Post-training population coupling')
   title(['Rho = ' num2str(PCple(iS).rho.trialpost)])
   axis square
   line([pltmin 1],[pltmin 1],'Color',[0.7 0.7 0.7])

end

save(['PopCouple_Data_N' num2str(N) '_' type '_SD' num2str(sd) 'ms'],'PCple','sd','lag','corrtype','Qt')
