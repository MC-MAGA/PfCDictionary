%% get P(words) and compute unique words
clear all; close all

type = 'Stable85'; %'Learn'; % Stable85
N = 35;

% load words for data
switch type
    case 'Learn';
        load(['Shuffled_Words_And_Counts_N' num2str(N) '_' type]);  % CountData and WordData
        Nsessions = numel(CountData);
        Nshuffles = numel(WordData(1).Shuffle);

    case 'Stable85'
        load(['Shuffled_Trials_Words_And_Counts_N' num2str(N) '_Stable85']);  % loads CountTrials and WordTrials
        load(['Shuffled_Pre_Words_And_Counts_N' num2str(N) '_Stable85']);  % loads CountPre and WordPre
        load(['Shuffled_Post_Words_And_Counts_N' num2str(N) '_Stable85']);  % loads CountPost and WordPost
        Nsessions = numel(CountTrials);
        Nshuffles = numel(WordTrials(1).Shuffle);

end
       

% count words in each epoch
PWord = emptyStruct({'Shuffle'},[Nsessions,1]);

%tic
switch type
    case 'Learn'
        parfor iS = 1:Nsessions
        % for iS = 1:Nsessions    
            % iS
            %tic
            for iSh = 1:Nshuffles
                for iB = 1:numel(binsizes)
                    [PWord(iS).Shuffle(iSh).Bins(iB).Trials.WordSet,PWord(iS).Shuffle(iSh).Bins(iB).Trials.P,PWord(iS).Shuffle(iSh).Bins(iB).Trials.binaryIDs,PWord(iS).Shuffle(iSh).Bins(iB).Trials.tsbinaryIDs] = ...
                                        Pwords(WordData(iS).Shuffle(iSh).Bins(iB).Trials.binary_array,CountData(iS).Shuffle(iSh).Bins(iB).Trials.Nwords);
                    [PWord(iS).Shuffle(iSh).Bins(iB).Pre.WordSet,PWord(iS).Shuffle(iSh).Bins(iB).Pre.P,PWord(iS).Shuffle(iSh).Bins(iB).Pre.binaryIDs,PWord(iS).Shuffle(iSh).Bins(iB).Pre.tsbinaryIDs] = ...
                                        Pwords(WordData(iS).Shuffle(iSh).Bins(iB).Pre.binary_array,CountData(iS).Shuffle(iSh).Bins(iB).Pre.Nwords);
                    [PWord(iS).Shuffle(iSh).Bins(iB).Post.WordSet,PWord(iS).Shuffle(iSh).Bins(iB).Post.P,PWord(iS).Shuffle(iSh).Bins(iB).Post.binaryIDs,PWord(iS).Shuffle(iSh).Bins(iB).Post.tsbinaryIDs] = ...
                                        Pwords(WordData(iS).Shuffle(iSh).Bins(iB).Post.binary_array,CountData(iS).Shuffle(iSh).Bins(iB).Post.Nwords);                    
                end

            end
        end
    
    case 'Stable85'
        parfor iS = 1:Nsessions
        % for iS = 1:Nsessions    
            % iS
            %tic
            for iSh = 1:Nshuffles
                for iB = 1:numel(binsizes)
                    % different data passed to each Pword
                    [PWord(iS).Shuffle(iSh).Bins(iB).Trials.WordSet,PWord(iS).Shuffle(iSh).Bins(iB).Trials.P,PWord(iS).Shuffle(iSh).Bins(iB).Trials.binaryIDs,PWord(iS).Shuffle(iSh).Bins(iB).Trials.tsbinaryIDs] = ...
                                        Pwords(WordTrials(iS).Shuffle(iSh).Bins(iB).binary_array,CountTrials(iS).Shuffle(iSh).Bins(iB).Nwords);
                    [PWord(iS).Shuffle(iSh).Bins(iB).Pre.WordSet,PWord(iS).Shuffle(iSh).Bins(iB).Pre.P,PWord(iS).Shuffle(iSh).Bins(iB).Pre.binaryIDs,PWord(iS).Shuffle(iSh).Bins(iB).Pre.tsbinaryIDs] = ...
                                        Pwords(WordPre(iS).Shuffle(iSh).Bins(iB).binary_array,CountPre(iS).Shuffle(iSh).Bins(iB).Nwords);
                    [PWord(iS).Shuffle(iSh).Bins(iB).Post.WordSet,PWord(iS).Shuffle(iSh).Bins(iB).Post.P,PWord(iS).Shuffle(iSh).Bins(iB).Post.binaryIDs,PWord(iS).Shuffle(iSh).Bins(iB).Post.tsbinaryIDs] = ...
                                        Pwords(WordPost(iS).Shuffle(iSh).Bins(iB).binary_array,CountPost(iS).Shuffle(iSh).Bins(iB).Nwords);
                    
                end

            end
        end        
end 
%toc


% save stuff
save(['Pword_Shuffled_N' num2str(N) '_' type], 'PWord','-v7.3');

