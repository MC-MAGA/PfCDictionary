% jitter spikes and count distribution of K-words (K=0, K=1,...,K=N) 
%
% Mark Humphries 24/10/2017

clear all; close all

nJitters = 20;  % how many repeats of jitter
jittersize = [2 5 10 20 50];  % Gaussian sigma in milliseconds

type = 'Stable85';  % 'Learn','Stable85'
N = 35;

% load per-trial and per-bout spike and ISI data
load(['../Processed data/PartitionedSpike_Data_N' num2str(N) '_' type]);

%% for each session, jitter spikes
Nsessions = numel(Times);

% JData = emptyStruct({'Jitter'},[Nsessions,1]);
% store separately to reduce overhead
JTrials = emptyStruct({'Jitter'},[Nsessions,1]);
JPreEpoch = emptyStruct({'Jitter'},[Nsessions,1]);
JPostEpoch = emptyStruct({'Jitter'},[Nsessions,1]);

parfor iS = 1:Nsessions
    % for iS = 1:Nsessions
    % iS
    [nNeurons,nTrials] = size(Data(iS).Trials);
    nPre = size(Data(iS).PreEpoch,2);
    nPost = size(Data(iS).PostEpoch,2);
    
    %% for each level of jitter
    for iJ = 1:numel(jittersize)    

        %% for each jitter repeat 
        for iSh = 1:nJitters
            % iSh
            % for each neuron
            for iN = 1:nNeurons
                % jitter each trial
                for iT = 1:nTrials
                    thesespks = Data(iS).Trials(iN,iT).spks / 1e3;  % convert to seconds
                    T = Times(iS).Trials(iT,1:2) / 1e3;  % convert to seconds
                    % jitter spikes (separate function)
                    jspks = jitterspikes(thesespks(:,1),jittersize(iJ)/1e3,T) * 1e3; % convert back to ms
                    % store jittered data, in case we need it in further analyses
                    JTrials(iS).Jitter(iJ,iSh).Bout(iN,iT).spks = [jspks zeros(numel(jspks),1)+iN]; 
                    % Trials.JData(iS).Jitter(iJ,iSh).Trials(iN,iT).spks = [jspks zeros(numel(jspks),1)+iN]; 
                    % JData2(iS).JitterSpks{iJ,iSh,iN,iT} = [jspks
                    % zeros(numel(jspks),1)+iN]; %% cell arrary storage not noticeably smaller when saved??
                    
                end
                
                % each pre-bout
                for iP = 1:nPre
                    thesespks = Data(iS).PreEpoch(iN,iP).spks / 1e3;  % convert to seconds
                    T = Times(iS).PreEpoch(iP,1:2) / 1e3;  % convert to seconds
                    % jitter spikes (separate function)
                    jspks = jitterspikes(thesespks(:,1),jittersize(iJ)/1e3,T) * 1e3;  % convert back to ms...
                    % store jittered data, in case we need it in further analyses   
                    % JData(iS).Jitter(iJ,iSh).PreEpoch(iN,iP).spks = [jspks zeros(numel(jspks),1)+iN]; 
                    JPreEpoch(iS).Jitter(iJ,iSh).Bout(iN,iP).spks = [jspks zeros(numel(jspks),1)+iN]; 
                end
                % each post-bout
                for iP = 1:nPost
                    thesespks = Data(iS).PostEpoch(iN,iP).spks / 1e3;  % convert to seconds
                    T = Times(iS).PostEpoch(iP,1:2) / 1e3;  % convert to seconds
                    % jitter spikes (separate function)
                    jspks = jitterspikes(thesespks(:,1),jittersize(iJ)/1e3,T) * 1e3;  % convert back to ms...
                    % store jittered data, in case we need it in further analyses      
                    % JData(iS).Jitter(iJ,iSh).PostEpoch(iN,iP).spks  = [jspks zeros(numel(jspks),1)+iN]; 
                    JPostEpoch(iS).Jitter(iJ,iSh).Bout(iN,iP).spks = [jspks zeros(numel(jspks),1)+iN]; 
                end
            end
            
        end
    end
    
    end


save(['Jittered_TrialsSpike_Data_N' num2str(N) '_' type],'JTrials','jittersize');
save(['Jittered_PreSpike_Data_N' num2str(N) '_' type],'JPreEpoch','jittersize');
save(['Jittered_PostSpike_Data_N' num2str(N) '_' type],'JPostEpoch','jittersize');

    
% save(['Jittered_PartitionedSpike_Data_N' num2str(N) '_' type],'JData','-v7.3');