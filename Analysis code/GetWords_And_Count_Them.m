%% making and counting words in each epoch
% Mark Humphries 30/10/17

clear all; close all

binsizes = [1 2 3 5 10 20 50 100];  % binsizes in milliseconds

type = 'Stable85';  % 'Learn','Stable85'
N = 35;

%% count words in the data
load(['../Processed data/PartitionedSpike_Data_N' num2str(N) '_' type]);  % get data partitions into trials and bouts
Nsessions = numel(Times);
CountData = emptyStruct({'Bins'},[Nsessions,1]);
WordData = emptyStruct({'Bins'},[Nsessions,1]);

tic
% parfor iS = 1:Nsessions
for iS = 1:Nsessions    
    % count all words
    %tic
    for iB = 1:numel(binsizes)
        %tic
        [WordData(iS).Bins(iB).Trials,CountData(iS).Bins(iB).Trials] = MakeAndCountWords(Data(iS).Trials,Times(iS).Trials,binsizes(iB));
        %toc
        
        [WordData(iS).Bins(iB).Pre,CountData(iS).Bins(iB).Pre] = MakeAndCountWords(Data(iS).PreEpoch,Times(iS).PreEpoch,binsizes(iB));
        [WordData(iS).Bins(iB).Post,CountData(iS).Bins(iB).Post] = MakeAndCountWords(Data(iS).PostEpoch,Times(iS).PostEpoch,binsizes(iB));
        CountData(iS).Bins(iB).All.K2 = CountData(iS).Bins(iB).Trials.K2 + CountData(iS).Bins(iB).Pre.K2 + CountData(iS).Bins(iB).Post.K2;
        CountData(iS).Bins(iB).All.Nwords = CountData(iS).Bins(iB).Trials.Nwords + CountData(iS).Bins(iB).Pre.Nwords + CountData(iS).Bins(iB).Post.Nwords;
    end
    %toc
end 
toc

% save data...
save(['DataWords_And_Counts_N' num2str(N) '_' type],'CountData','WordData','binsizes')

