%% get P(words) and compute unique words
clear all; close all

type = 'Stable85'; % Stable85
N = 35;

% load words for data
load(['Jittered_Trials_Words_And_Counts_N' num2str(N) '_' type '_binsize_5'])
load(['Jittered_Pre_Words_And_Counts_N' num2str(N) '_' type '_binsize_5'])
load(['Jittered_Post_Words_And_Counts_N' num2str(N) '_' type '_binsize_5'])

Nsessions = numel(CountTrials);
Njitters = numel(WordTrials(1).Jitter);
Nshuffles = numel(WordTrials(1).Jitter(1).Shuffle);

% count words in each epoch
PWord = emptyStruct({'Jitter'},[Nsessions,1]);

%tic
parfor iS = 1:Nsessions
% for iS = 1:Nsessions    
    % iS
    %tic
    for iJ = 1:Njitters
       
        for iSh = 1:Nshuffles

            [PWord(iS).Jitter(iJ).Shuffle(iSh).Trials.WordSet,PWord(iS).Jitter(iJ).Shuffle(iSh).Trials.P,PWord(iS).Jitter(iJ).Shuffle(iSh).Trials.binaryIDs,PWord(iS).Jitter(iJ).Shuffle(iSh).Trials.tsbinaryIDs] = ...
                                Pwords(WordTrials(iS).Jitter(iJ).Shuffle(iSh).binary_array,CountTrials(iS).Jitter(iJ).Shuffle(iSh).Nwords);
            [PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.WordSet,PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.P,PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.binaryIDs,PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.tsbinaryIDs] = ...
                                Pwords(WordPre(iS).Jitter(iJ).Shuffle(iSh).binary_array,CountPre(iS).Jitter(iJ).Shuffle(iSh).Nwords);
            [PWord(iS).Jitter(iJ).Shuffle(iSh).Post.WordSet,PWord(iS).Jitter(iJ).Shuffle(iSh).Post.P,PWord(iS).Jitter(iJ).Shuffle(iSh).Post.binaryIDs,PWord(iS).Jitter(iJ).Shuffle(iSh).Post.tsbinaryIDs] = ...
                                Pwords(WordPost(iS).Jitter(iJ).Shuffle(iSh).binary_array,CountPost(iS).Jitter(iJ).Shuffle(iSh).Nwords);

        end
    end
    %toc
end 
%toc


% save stuff
save(['Pword_Jittered_N' num2str(N) '_' type '_binsize_' num2str(binsize)], 'PWord','-v7.3');

