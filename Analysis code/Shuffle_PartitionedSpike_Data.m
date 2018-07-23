% create shuffled spike data 
%
% Mark Humphries 30/10/2017

clear all; close all

nShuffles = 20;

type = 'Stable85';  % 'Learn','Stable85'
N = 35;

load(['../Processed data/PartitionedSpike_Data_N' num2str(N) '_' type]);

Nsessions = numel(Data);

%% now count data and get shuffled and count that too
% SData = emptyStruct({'Trials','PreEpoch','PostEpoch'},[Nsessions,1]);
SData = emptyStruct({'Shuffle'},[Nsessions,1]);

parfor iS = 1:Nsessions

    [nNeurons,nTrials] = size(Data(iS).Trials);
    nPre = size(Data(iS).PreEpoch,2);
    nPost = size(Data(iS).PostEpoch,2);
    
    % shuffle ISIs within each chunk
   for iSh = 1:nShuffles
        % iSh
         % shuffle ISIs within chunks - produce new shuffled datasets as above
        for iN = 1:nNeurons
            for iT = 1:nTrials
                thesespks = Data(iS).Trials(iN,iT).spks; thesespks(:,1) = thesespks(:,1) / 1e3;  % convert time-base
                T = Times(iS).Trials(iT,1:2) / 1e3;
                ctrlspkts = shuffle_intervals(thesespks(:,[2,1]),T,1e-4);
                ctrlspkts(:,2) = ctrlspkts(:,2) * 1e3;  % convert time-base
                SData(iS).Shuffle(iSh).Trials(iN,iT).spks =  ctrlspkts(:,[2,1]);
            end
            for iP = 1:nPre
                thesespks = Data(iS).PreEpoch(iN,iP).spks; thesespks(:,1) = thesespks(:,1) / 1e3;
                T = Times(iS).PreEpoch(iP,1:2) / 1e3;
                ctrlspkts = shuffle_intervals(thesespks(:,[2,1]),T,1e-4);
                ctrlspkts(:,2) = ctrlspkts(:,2) * 1e3;  % convert time-base
                SData(iS).Shuffle(iSh).PreEpoch(iN,iP).spks =  ctrlspkts(:,[2,1]);
            end
            for iP = 1:nPost
                thesespks = Data(iS).PostEpoch(iN,iP).spks; thesespks(:,1) = thesespks(:,1) / 1e3;
                T = Times(iS).PostEpoch(iP,1:2) / 1e3;
                ctrlspkts = shuffle_intervals(thesespks(:,[2,1]),T,1e-4);
                ctrlspkts(:,2) = ctrlspkts(:,2) * 1e3;  % convert time-base
                SData(iS).Shuffle(iSh).PostEpoch(iN,iP).spks =  ctrlspkts(:,[2,1]);
            end
        end

   end
end

save(['Shuffled_PartitionedSpike_Data_N' num2str(N) '_' type],'SData');