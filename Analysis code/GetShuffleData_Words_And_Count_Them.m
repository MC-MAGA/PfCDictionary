%% making and counting words in each epoch
% Mark Humphries 30/10/17

clear all; close all

% where are the large intermediate results files?
filepath = 'C:\Users\lpzmdh\Dropbox\My Papers\PfC sampling hypothesis\Dictionary version 2\figures\Large_Intermediate_Results\';

binsizes = [1 2 3 5 10 20 50 100];  % binsizes in milliseconds

type = 'Stable85'; % 'Learn';  % 'Learn','Stable85'
N = 35;  % 15, 35
%% count words in the data
load(['../Processed data/PartitionedSpike_Data_N' num2str(N) '_' type],'Times');
load([filepath 'Shuffled_PartitionedSpike_Data_N' num2str(N) '_' type]);  % get data partitions into trials and bouts
Nsessions = numel(Times);
Nshuffles = numel(SData(1).Shuffle);


CountData = emptyStruct({'Shuffle'},[Nsessions,1]);
WordData = emptyStruct({'Shuffle'},[Nsessions,1]);

CountTrials = emptyStruct({'Shuffle'},[Nsessions,1]);
WordTrials = emptyStruct({'Shuffle'},[Nsessions,1]);
CountPre = emptyStruct({'Shuffle'},[Nsessions,1]);
WordPre = emptyStruct({'Shuffle'},[Nsessions,1]);
CountPost = emptyStruct({'Shuffle'},[Nsessions,1]);
WordPost = emptyStruct({'Shuffle'},[Nsessions,1]);
CountAll = emptyStruct({'Shuffle'},[Nsessions,1]);    


tic
parfor iS = 1:Nsessions
% for iS = 1:Nsessions
    for iSh = 1:Nshuffles
        % count all words
        %tic
        for iB = 1:numel(binsizes)
            %tic
            switch type
                case 'Learn'
                    [WordData(iS).Shuffle(iSh).Bins(iB).Trials,CountData(iS).Shuffle(iSh).Bins(iB).Trials] = MakeAndCountWords(SData(iS).Shuffle(iSh).Trials,Times(iS).Trials,binsizes(iB));
                    [WordData(iS).Shuffle(iSh).Bins(iB).Pre,CountData(iS).Shuffle(iSh).Bins(iB).Pre] = MakeAndCountWords(SData(iS).Shuffle(iSh).PreEpoch,Times(iS).PreEpoch,binsizes(iB));
                    [WordData(iS).Shuffle(iSh).Bins(iB).Post,CountData(iS).Shuffle(iSh).Bins(iB).Post] = MakeAndCountWords(SData(iS).Shuffle(iSh).PostEpoch,Times(iS).PostEpoch,binsizes(iB));
                    CountData(iS).Shuffle(iSh).Bins(iB).All.K2 = CountData(iS).Shuffle(iSh).Bins(iB).Trials.K2 + CountData(iS).Shuffle(iSh).Bins(iB).Pre.K2 + CountData(iS).Shuffle(iSh).Bins(iB).Post.K2;
                    CountData(iS).Shuffle(iSh).Bins(iB).All.Nwords = CountData(iS).Shuffle(iSh).Bins(iB).Trials.Nwords + CountData(iS).Shuffle(iSh).Bins(iB).Pre.Nwords + CountData(iS).Shuffle(iSh).Bins(iB).Post.Nwords;
                case 'Stable85'
                    [WordTrials(iS).Shuffle(iSh).Bins(iB),CountTrials(iS).Shuffle(iSh).Bins(iB)] = MakeAndCountWords(SData(iS).Shuffle(iSh).Trials,Times(iS).Trials,binsizes(iB));
                    [WordPre(iS).Shuffle(iSh).Bins(iB),CountPre(iS).Shuffle(iSh).Bins(iB)] = MakeAndCountWords(SData(iS).Shuffle(iSh).PreEpoch,Times(iS).PreEpoch,binsizes(iB));
                    [WordPost(iS).Shuffle(iSh).Bins(iB),CountPost(iS).Shuffle(iSh).Bins(iB)] = MakeAndCountWords(SData(iS).Shuffle(iSh).PostEpoch,Times(iS).PostEpoch,binsizes(iB));
                    CountAll(iS).Shuffle(iSh).Bins(iB).K2 = CountTrials(iS).Shuffle(iSh).Bins(iB).K2 + CountPre(iS).Shuffle(iSh).Bins(iB).K2 + CountPost(iS).Shuffle(iSh).Bins(iB).K2;
                    CountAll(iS).Shuffle(iSh).Bins(iB).Nwords = CountTrials(iS).Shuffle(iSh).Bins(iB).Nwords + CountPre(iS).Shuffle(iSh).Bins(iB).Nwords + CountPost(iS).Shuffle(iSh).Bins(iB).Nwords;
            end
        end
        %toc
    end
end 
toc

% save data...
switch type
    case 'Learn'
        save(['Shuffled_Words_And_Counts_N' num2str(N) '_' type],'CountData','WordData','binsizes','-v7.3')
    case 'Stable85'
        save(['Shuffled_Trials_Words_And_Counts_N' num2str(N) '_' type],'CountTrials','WordTrials','binsizes','-v7.3')
        save(['Shuffled_Pre_Words_And_Counts_N' num2str(N) '_' type],'CountPre','WordPre','binsizes','-v7.3')
        save(['Shuffled_Post_Words_And_Counts_N' num2str(N) '_' type],'CountPost','WordPost','binsizes','-v7.3')
        save(['Shuffled_All_Counts_N' num2str(N) '_' type],'CountAll','binsizes') % ,'-v7.3')        
end