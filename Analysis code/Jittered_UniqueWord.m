%% get P(words) and compute unique words
clear all; close all

type = 'Learn'; % Stable85
N = 35; 
binsize = 5;

% load Pword
load(['Pword_Jittered_N' num2str(N) '_' type '_binsize_' num2str(binsize)]);

Nsessions = numel(PWord);
Njitters = numel(PWord(1).Jitter);
Nshuffles = numel(PWord(1).Jitter(1).Shuffle);

% count conservation of words in each epoch
UWord = emptyStruct({'Jitter'},[Nsessions,1]);


%% count unique words

parfor iS = 1:Nsessions
% for iS = 1:Nsessions    

    for iJ = 1:Njitters
        for iSh = 1:Nshuffles
            
            % iSh
            % make ID sets for each group vectors
            UWord(iS).Jitter(iJ).Shuffle(iSh).Trials.WordIDs = WordIndices(PWord(iS).Jitter(iJ).Shuffle(iSh).Trials.WordSet);
            UWord(iS).Jitter(iJ).Shuffle(iSh).Pre.WordIDs = WordIndices(PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.WordSet);
            UWord(iS).Jitter(iJ).Shuffle(iSh).Post.WordIDs = WordIndices(PWord(iS).Jitter(iJ).Shuffle(iSh).Post.WordSet);
            
            % make K ID sets for each group
            [UWord(iS).Jitter(iJ).Shuffle(iSh).Trials.K,UWord(iS).Jitter(iJ).Shuffle(iSh).Trials.K_IDs] = KIndices(PWord(iS).Jitter(iJ).Shuffle(iSh).Trials.WordSet);
            [UWord(iS).Jitter(iJ).Shuffle(iSh).Pre.K,UWord(iS).Jitter(iJ).Shuffle(iSh).Pre.K_IDs] = KIndices(PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.WordSet);
            [UWord(iS).Jitter(iJ).Shuffle(iSh).Post.K,UWord(iS).Jitter(iJ).Shuffle(iSh).Post.K_IDs] = KIndices(PWord(iS).Jitter(iJ).Shuffle(iSh).Post.WordSet);
            
            % make storage for all detected matches
            nTrialWords = numel(PWord(iS).Jitter(iJ).Shuffle(iSh).Trials.P);
            nPreWords = numel(PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.P);
            nPostWords = numel(PWord(iS).Jitter(iJ).Shuffle(iSh).Post.P);
            
            UWord(iS).Jitter(iJ).Shuffle(iSh).Trials.PreMatch = zeros(nTrialWords,1);
            UWord(iS).Jitter(iJ).Shuffle(iSh).Trials.PostMatch = zeros(nTrialWords,1);
            UWord(iS).Jitter(iJ).Shuffle(iSh).Trials.PrePostMatch = zeros(nTrialWords,1);
            
            UWord(iS).Jitter(iJ).Shuffle(iSh).Pre.TrialsMatch = zeros(nPreWords,1);
            UWord(iS).Jitter(iJ).Shuffle(iSh).Pre.PostMatch = zeros(nPreWords,1);
            
            UWord(iS).Jitter(iJ).Shuffle(iSh).Post.TrialsMatch = zeros(nPostWords,1);
            UWord(iS).Jitter(iJ).Shuffle(iSh).Post.PreMatch = zeros(nPostWords,1);
            

            %% binary number version
            for iW = 1:nTrialWords
                ixPre = find(PWord(iS).Jitter(iJ).Shuffle(iSh).Trials.binaryIDs(iW) == PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.binaryIDs);
                ixPost = find(PWord(iS).Jitter(iJ).Shuffle(iSh).Trials.binaryIDs(iW) == PWord(iS).Jitter(iJ).Shuffle(iSh).Post.binaryIDs);
                if ixPre
                    UWord(iS).Jitter(iJ).Shuffle(iSh).Trials.PreMatch(iW) = 1; 
                    UWord(iS).Jitter(iJ).Shuffle(iSh).Pre.TrialsMatch(ixPre) = 1;
                end
                 if ixPost
                    UWord(iS).Jitter(iJ).Shuffle(iSh).Trials.PostMatch(iW) = 1; 
                    UWord(iS).Jitter(iJ).Shuffle(iSh).Post.TrialsMatch(ixPost) = 1;

                end
                if ixPre & ixPost
                    UWord(iS).Jitter(iJ).Shuffle(iSh).Trials.PrePostMatch(iW) = 1;
                    % if both pre and post also have this word, then record
                    UWord(iS).Jitter(iJ).Shuffle(iSh).Pre.PostMatch(ixPre) = 1;
                    UWord(iS).Jitter(iJ).Shuffle(iSh).Post.PreMatch(ixPost) = 1;
                end

            end      
            
            % work out proportions: unique to this epoch; and found in all
            % epochs
            UWord(iS).Jitter(iJ).Shuffle(iSh).Trials.Punique = sum(~UWord(iS).Jitter(iJ).Shuffle(iSh).Trials.PreMatch & ~UWord(iS).Jitter(iJ).Shuffle(iSh).Trials.PostMatch) ./ nTrialWords;
            UWord(iS).Jitter(iJ).Shuffle(iSh).Trials.PAllEpochs = sum(UWord(iS).Jitter(iJ).Shuffle(iSh).Trials.PrePostMatch) ./ nTrialWords;
            
            
            % now check remaining Pre words against remaining Post words
            unchkdPre = find(~UWord(iS).Jitter(iJ).Shuffle(iSh).Pre.TrialsMatch);  % IDs into full set of words
            unchkdPost = find(~UWord(iS).Jitter(iJ).Shuffle(iSh).Post.TrialsMatch);  % IDs into full set of words
            PreIDs = PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.binaryIDs(unchkdPre);
            PostIDs = PWord(iS).Jitter(iJ).Shuffle(iSh).Post.binaryIDs(unchkdPost);

            for ID = PreIDs
                ixPost = find(ID == PostIDs); % find same number       
                if ixPost
                    UWord(iS).Jitter(iJ).Shuffle(iSh).Pre.PostMatch(ID==PreIDs) = 1;
                    UWord(iS).Jitter(iJ).Shuffle(iSh).Post.PreMatch(unchkdPost(ixPost)) = 1;
                end
            end

            % work out proportions: unique to each sleep epoch, all epochs, all
            % sleep
            UWord(iS).Jitter(iJ).Shuffle(iSh).Pre.Punique = sum(~UWord(iS).Jitter(iJ).Shuffle(iSh).Pre.TrialsMatch & ~UWord(iS).Jitter(iJ).Shuffle(iSh).Pre.PostMatch) ./ nPreWords;
            UWord(iS).Jitter(iJ).Shuffle(iSh).Pre.PAllEpochs = sum(UWord(iS).Jitter(iJ).Shuffle(iSh).Trials.PrePostMatch) ./ nPreWords;
            UWord(iS).Jitter(iJ).Shuffle(iSh).Pre.PSleepEpochs = sum(UWord(iS).Jitter(iJ).Shuffle(iSh).Pre.PostMatch) ./ nPreWords;
            
            UWord(iS).Jitter(iJ).Shuffle(iSh).Post.Punique = sum(~UWord(iS).Jitter(iJ).Shuffle(iSh).Post.TrialsMatch & ~UWord(iS).Jitter(iJ).Shuffle(iSh).Post.PreMatch) ./ nPostWords;
            UWord(iS).Jitter(iJ).Shuffle(iSh).Post.PAllEpochs = sum(UWord(iS).Jitter(iJ).Shuffle(iSh).Trials.PrePostMatch) ./ nPostWords;
            UWord(iS).Jitter(iJ).Shuffle(iSh).Post.PSleepEpochs = sum(UWord(iS).Jitter(iJ).Shuffle(iSh).Post.PreMatch) ./ nPostWords;
            
            

        
        end
    end
   
end

save(['UniqueWord_Jittered_N' num2str(N) '_' type '_binsize_' num2str(binsize)], 'UWord','-v6');

