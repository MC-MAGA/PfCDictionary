%% get P(words) and compute unique words
clear all; close all

type = 'Stable85'; % 'Learn'; % Stable85
N = 35;

% load words for data
load(['DataWords_And_Counts_N' num2str(N) '_' type]);

Nsessions = numel(CountData);

% count words in each epoch
PWord = emptyStruct({'Bins'},[Nsessions,1]);

%tic
parfor iS = 1:Nsessions
% for iS = 1:Nsessions    
    % iS
    %tic
    for iB = 1:numel(binsizes)
        [PWord(iS).Bins(iB).Trials.WordSet,PWord(iS).Bins(iB).Trials.P,PWord(iS).Bins(iB).Trials.binaryIDs,PWord(iS).Bins(iB).Trials.tsbinaryIDs] = ...
                                Pwords(WordData(iS).Bins(iB).Trials.binary_array,CountData(iS).Bins(iB).Trials.Nwords);
        [PWord(iS).Bins(iB).Pre.WordSet,PWord(iS).Bins(iB).Pre.P,PWord(iS).Bins(iB).Pre.binaryIDs,PWord(iS).Bins(iB).Pre.tsbinaryIDs] = ...
                                Pwords(WordData(iS).Bins(iB).Pre.binary_array,CountData(iS).Bins(iB).Pre.Nwords);
        [PWord(iS).Bins(iB).Post.WordSet,PWord(iS).Bins(iB).Post.P,PWord(iS).Bins(iB).Post.binaryIDs,PWord(iS).Bins(iB).Post.tsbinaryIDs] = ...
                                Pwords(WordData(iS).Bins(iB).Post.binary_array,CountData(iS).Bins(iB).Post.Nwords);
                     
    end
    %toc
end 
%toc


% save stuff
save(['Pword_Data_N' num2str(N) '_' type], 'PWord');

