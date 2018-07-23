%% making and counting words in each epoch
% Mark Humphries 30/10/17

clear all; close all

binsize = 5;  % chosen binsize in milliseconds

% where are the large intermediate results files?
filepath = 'C:\Users\lpzmdh\Dropbox\My Papers\PfC sampling hypothesis\Dictionary version 2\figures\Large_Intermediate_Results\';

type = 'Stable85';  % 'Learn','Stable85'
N = 35;  % 15, 35
%% load partitioned data
load(['../Processed data/PartitionedSpike_Data_N' num2str(N) '_' type],'Times');
load([filepath 'Jittered_TrialsSpike_Data_N' num2str(N) '_' type]);  % get data partitions into trials and bouts
load([filepath 'Jittered_PreSpike_Data_N' num2str(N) '_' type]);  % get data partitions into trials and bouts
load([filepath 'Jittered_PostSpike_Data_N' num2str(N) '_' type]);  % get data partitions into trials and bouts

%% count words
Nsessions = numel(Times);
Njitters = size(JTrials(1).Jitter,2);

CountTrials = emptyStruct({'Jitter'},[Nsessions,1]);
WordTrials = emptyStruct({'Jitter'},[Nsessions,1]);
CountPre = emptyStruct({'Jitter'},[Nsessions,1]);
WordPre = emptyStruct({'Jitter'},[Nsessions,1]);
CountPost = emptyStruct({'Jitter'},[Nsessions,1]);
WordPost = emptyStruct({'Jitter'},[Nsessions,1]);
CountAll = emptyStruct({'Jitter'},[Nsessions,1]);

%tic
parfor iS = 1:Nsessions
% sfor iS = 1:Nsessions
    for iJ = 1:numel(jittersize)
        for iSh = 1:Njitters
            %iSh
        % count all words
            %tic
            [WordTrials(iS).Jitter(iJ).Shuffle(iSh),CountTrials(iS).Jitter(iJ).Shuffle(iSh)] = MakeAndCountWords(JTrials(iS).Jitter(iJ,iSh).Bout,Times(iS).Trials,binsize);
            % toc

            [WordPre(iS).Jitter(iJ).Shuffle(iSh),CountPre(iS).Jitter(iJ).Shuffle(iSh)] = MakeAndCountWords(JPreEpoch(iS).Jitter(iJ,iSh).Bout,Times(iS).PreEpoch,binsize);
            [WordPost(iS).Jitter(iJ).Shuffle(iSh),CountPost(iS).Jitter(iJ).Shuffle(iSh)] = MakeAndCountWords(JPostEpoch(iS).Jitter(iJ,iSh).Bout,Times(iS).PostEpoch,binsize);
            CountAll(iS).Jitter(iJ).Shuffle(iSh).K2 = CountTrials(iS).Jitter(iJ).Shuffle(iSh).K2 + CountPre(iS).Jitter(iJ).Shuffle(iSh).K2 + CountPost(iS).Jitter(iJ).Shuffle(iSh).K2;
            CountAll(iS).Jitter(iJ).Shuffle(iSh).Nwords = CountTrials(iS).Jitter(iJ).Shuffle(iSh).Nwords + CountPre(iS).Jitter(iJ).Shuffle(iSh).Nwords + CountPost(iS).Jitter(iJ).Shuffle(iSh).Nwords;
        end
        %toc
    end
end 
%toc

% save data...
save(['Jittered_Trials_Words_And_Counts_N' num2str(N) '_' type '_binsize_' num2str(binsize)],'CountTrials','WordTrials','binsize') % ,'-v7.3')
save(['Jittered_Pre_Words_And_Counts_N' num2str(N) '_' type '_binsize_' num2str(binsize)],'CountPre','WordPre','binsize','-v7.3')
save(['Jittered_Post_Words_And_Counts_N' num2str(N) '_' type '_binsize_' num2str(binsize)],'CountPost','WordPost','binsize','-v7.3')
save(['Jittered_All_Counts_N' num2str(N) '_' type '_binsize_' num2str(binsize)],'CountAll','binsize') % ,'-v7.3')
