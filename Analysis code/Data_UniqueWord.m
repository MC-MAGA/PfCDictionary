%% get P(words) and compute unique words
clear all; close all

type = 'Stable85'; % 'Learn'; % Stable85
N = 35; 

% load Pword
load(['Pword_Data_N' num2str(N) '_' type], 'PWord');
load(['DataWords_And_Counts_N' num2str(N) '_' type],'binsizes');
Nsessions = numel(PWord);

%% count unique words
UWord = emptyStruct({'Bins'},[Nsessions,1]);

parfor iS = 1:Nsessions
% for iS = 1:Nsessions    
   
    % Cmn = @(x,y) isempty(setxor(x,y));
    
    for iB = 1:numel(binsizes)
        
        nTrialWords = numel(PWord(iS).Bins(iB).Trials.P);  % arrays of neuron IDs in each word
        nPreWords = numel(PWord(iS).Bins(iB).Pre.P);
        nPostWords = numel(PWord(iS).Bins(iB).Post.P);
        
        % iB
        % make ID sets for each group vectors
        UWord(iS).Bins(iB).Trials.WordIDs = WordIndices(PWord(iS).Bins(iB).Trials.WordSet);
        UWord(iS).Bins(iB).Pre.WordIDs = WordIndices(PWord(iS).Bins(iB).Pre.WordSet);
        UWord(iS).Bins(iB).Post.WordIDs = WordIndices(PWord(iS).Bins(iB).Post.WordSet);
        
        % make K ID sets for each group
        [UWord(iS).Bins(iB).Trials.K,UWord(iS).Bins(iB).Trials.K_IDs] = KIndices(PWord(iS).Bins(iB).Trials.WordSet);
        [UWord(iS).Bins(iB).Pre.K,UWord(iS).Bins(iB).Pre.K_IDs] = KIndices(PWord(iS).Bins(iB).Pre.WordSet);
        [UWord(iS).Bins(iB).Post.K,UWord(iS).Bins(iB).Post.K_IDs] = KIndices(PWord(iS).Bins(iB).Post.WordSet);
        
        
        % make storage for all detected matches  
        UWord(iS).Bins(iB).Trials.PreMatch = zeros(nTrialWords,1);
        UWord(iS).Bins(iB).Trials.PostMatch = zeros(nTrialWords,1);
        UWord(iS).Bins(iB).Trials.PrePostMatch = zeros(nTrialWords,1);
        
        UWord(iS).Bins(iB).Pre.TrialsMatch = zeros(nPreWords,1);
        UWord(iS).Bins(iB).Pre.PostMatch = zeros(nPreWords,1);
        
        UWord(iS).Bins(iB).Post.TrialsMatch = zeros(nPostWords,1);
        UWord(iS).Bins(iB).Post.PreMatch = zeros(nPostWords,1);
        

%         % for each word, get matching K set
%         tic
%         unchkdPreIDs = PWord(iS).Bins(iB).Pre.K_IDs;
%         unchkdPostIDs = PWord(iS).Bins(iB).Post.K_IDs;
%         for iW = 1:nTrialWords
%             Word = full(PWord(iS).Bins(iB).Trials.WordSet(:,iW));
%             Kword = sum(Word);
%             blnK = any(PWord(iS).Bins(iB).Pre.K == Kword); ixPre = [];
%                         
%             if blnK
%                 % add word to all
%                 ixsPre = unchkdPreIDs{PWord(iS).Bins(iB).Pre.K == Kword};  % get set of words to check
%                 smPre = bsxfun(@plus,PWord(iS).Bins(iB).Pre.WordSet(:,ixsPre),Word);  % add current word to each in set
%                 Ksm = sum(smPre > 1);   % matching word will have 2s in every entry; so its sum of elements alone will still be K
%                 ixPre = find(Ksm == Kword); 
%                 
%                 if ixPre
%                     PWord(iS).Bins(iB).Trials.PreMatch(iW) = 1; 
%                     PWord(iS).Bins(iB).Pre.TrialsMatch(ixsPre(ixPre)) = 1;
%                     unchkdPreIDs{PWord(iS).Bins(iB).Pre.K == Kword} = ixsPre((1:numel(ixsPre)) ~= ixPre); % eliminate the matched word from future checking
%                 end
%             end
%         
%             blnK = any(PWord(iS).Bins(iB).Post.K == Kword); ixPost = [];
%             if blnK
%                 % add word to all
%                 ixsPost = unchkdPostIDs{PWord(iS).Bins(iB).Post.K == Kword};  % get set of words to check
%                 smPost = bsxfun(@plus,PWord(iS).Bins(iB).Post.WordSet(:,ixsPost),Word);  % add current word to each in set
%                 Ksm = sum(smPost > 1);   % matching word will have 2s in every entry; so its sum of elements alone will still be K
%                 ixPost = find(Ksm == Kword); 
%                 
%                 if ixPost
%                     PWord(iS).Bins(iB).Trials.PostMatch(iW) = 1; 
%                     PWord(iS).Bins(iB).Post.TrialsMatch(ixsPost(ixPost)) = 1;
%                     unchkdPostIDs{PWord(iS).Bins(iB).Post.K == Kword} = ixsPost((1:numel(ixsPost)) ~= ixPost); % eliminate the matched word from future checking
%                 end
%             end
% 
%             % in trials and pre and post?
%             if PWord(iS).Bins(iB).Trials.PostMatch(iW) && PWord(iS).Bins(iB).Trials.PreMatch(iW)
%                 PWord(iS).Bins(iB).Trials.PrePostMatch(iW) = 1;
%                 % if both pre and post also have this word, then record
%                 PWord(iS).Bins(iB).Pre.PostMatch(ixsPre(ixPre)) = 1;
%                 PWord(iS).Bins(iB).Post.PreMatch(ixsPost(ixPost)) = 1;
%             end
%         end
%         toc
        
        %% binary number version
        for iW = 1:nTrialWords
            ixPre = find(PWord(iS).Bins(iB).Trials.binaryIDs(iW) == PWord(iS).Bins(iB).Pre.binaryIDs);
            ixPost = find(PWord(iS).Bins(iB).Trials.binaryIDs(iW) == PWord(iS).Bins(iB).Post.binaryIDs);
            if ixPre
                UWord(iS).Bins(iB).Trials.PreMatch(iW) = 1; 
                UWord(iS).Bins(iB).Pre.TrialsMatch(ixPre) = 1;
            end
             if ixPost
                UWord(iS).Bins(iB).Trials.PostMatch(iW) = 1; 
                UWord(iS).Bins(iB).Post.TrialsMatch(ixPost) = 1;
                
            end
            if ixPre & ixPost
                UWord(iS).Bins(iB).Trials.PrePostMatch(iW) = 1;
                % if both pre and post also have this word, then record
                UWord(iS).Bins(iB).Pre.PostMatch(ixPre) = 1;
                UWord(iS).Bins(iB).Post.PreMatch(ixPost) = 1;
            end

        end
        
            
        %% work out proportions: unique to this epoch; and found in all
        % epochs
        UWord(iS).Bins(iB).Trials.Punique = sum(~UWord(iS).Bins(iB).Trials.PreMatch & ~UWord(iS).Bins(iB).Trials.PostMatch) ./ nTrialWords;
        UWord(iS).Bins(iB).Trials.PAllEpochs = sum(UWord(iS).Bins(iB).Trials.PrePostMatch) ./ nTrialWords;
        
        % now check remaining Pre words against remaining Post words
        unchkdPre = find(~UWord(iS).Bins(iB).Pre.TrialsMatch);  % IDs into full set of words
        unchkdPost = find(~UWord(iS).Bins(iB).Post.TrialsMatch);  % IDs into full set of words
        PreIDs = full(PWord(iS).Bins(iB).Pre.binaryIDs(unchkdPre));
        PostIDs = full(PWord(iS).Bins(iB).Post.binaryIDs(unchkdPost));
    
        % now check each PreID
        for ID = PreIDs
            ixPost = find(ID == PostIDs); % find same number       
            if ixPost
                UWord(iS).Bins(iB).Pre.PostMatch(ID==PreIDs) = 1;
                UWord(iS).Bins(iB).Post.PreMatch(unchkdPost(ixPost)) = 1;
            end
        end

        % work out proportions: unique to each sleep epoch, all epochs, all
        % sleep
        UWord(iS).Bins(iB).Pre.Punique = sum(~UWord(iS).Bins(iB).Pre.TrialsMatch & ~UWord(iS).Bins(iB).Pre.PostMatch) ./ nPreWords;
        UWord(iS).Bins(iB).Pre.PAllEpochs = sum(UWord(iS).Bins(iB).Trials.PrePostMatch) ./ nPreWords;
        UWord(iS).Bins(iB).Pre.PSleepEpochs = sum(UWord(iS).Bins(iB).Pre.PostMatch) ./ nPreWords;
  
        UWord(iS).Bins(iB).Post.Punique = sum(~UWord(iS).Bins(iB).Post.TrialsMatch & ~UWord(iS).Bins(iB).Post.PreMatch) ./ nPostWords;
        UWord(iS).Bins(iB).Post.PAllEpochs = sum(UWord(iS).Bins(iB).Trials.PrePostMatch) ./ nPostWords;
        UWord(iS).Bins(iB).Post.PSleepEpochs = sum(UWord(iS).Bins(iB).Post.PreMatch) ./ nPostWords;
       
       
%         % for each word in Trials, find it in Pre or Post or both
%         unchkdPreIDs = PWord(iS).Bins(iB).Pre.K_IDs;
%         unchkdPostIDs = PWord(iS).Bins(iB).Post.K_IDs;
%         tic
%         for iW = 1:nTrialWords
%             Kword = numel(PWord(iS).Bins(iB).Trials.WordIDs{iW});
%             blnK = any(PWord(iS).Bins(iB).Pre.K == Kword);
%             iPre = 0;
%             if blnK
%                 ixsPre = unchkdPreIDs{PWord(iS).Bins(iB).Pre.K == Kword}; % set of Pre-session words with this same K
%                 % if there are unchecked words at this K in Pre-session epoch
%                 blnMatch = 0; 
%                 while ~blnMatch && iPre < numel(ixsPre) 
%                     % find any case where the indices match between this Trial word and any Pre word
%                     iPre = iPre+1;  % only run loop until found match
%                     blnMatch = Cmn(PWord(iS).Bins(iB).Pre.WordIDs{ixsPre(iPre)},PWord(iS).Bins(iB).Trials.WordIDs{iW});
%                 end
%             end
%             if iPre > 0
%                 PWord(iS).Bins(iB).Trials.PreMatch(iW) = 1; 
%                 PWord(iS).Bins(iB).Pre.TrialsMatch(ixsPre(iPre)) = 1;
%                 unchkdPreIDs{PWord(iS).Bins(iB).Pre.K == Kword} = ixsPre((1:numel(ixsPre)) ~= iPre); % eliminate the matched word from future checking
%             end
%             
%             blnK = any(PWord(iS).Bins(iB).Post.K == Kword);
%             iPost = 0;
%             if blnK
%                 ixsPost = unchkdPostIDs{PWord(iS).Bins(iB).Post.K == Kword}; % set of Post-session words with this same K
%                 % if there are unchecked words at this K in Post-session epoch
%                 blnMatch = 0; 
%                 while ~blnMatch && iPost < numel(ixsPost) 
%                     % find any case where the indices match between this Trial word and any Post word
%                     iPost = iPost+1;  % only run loop until found match
%                     blnMatch = Cmn(PWord(iS).Bins(iB).Post.WordIDs{ixsPost(iPost)},PWord(iS).Bins(iB).Trials.WordIDs{iW});
%                 end
%             end
%             if iPost > 0
%                 PWord(iS).Bins(iB).Trials.PostMatch(iW) = 1; 
%                 PWord(iS).Bins(iB).Post.TrialsMatch(ixsPost(iPost)) = 1;
%                 unchkdPostIDs{PWord(iS).Bins(iB).Post.K == Kword} = ixsPost((1:numel(ixsPost)) ~= iPost); % eliminate the matched word from future checking
%             end    
%             
%             % in trials and pre and post?
%             if PWord(iS).Bins(iB).Trials.PostMatch(iW) && PWord(iS).Bins(iB).Trials.PreMatch(iW)
%                 PWord(iS).Bins(iB).Trials.PrePostMatch(iW) = 1;
%                 % if both pre and post also have this word, then record
%                 PWord(iS).Bins(iB).Pre.PostMatch(ixsPre(iPre)) = 1;
%                 PWord(iS).Bins(iB).Post.PreMatch(ixsPost(iPost)) = 1;
%             end
%         end
%         toc
%         
%         
%         % for each word not accounted for, check between Pre and Post
%         % i.e. leave out everything already tagged as a 1 in Pre.TrialMatch
%         % and Post.TrialMatch: either they both have it (so is a 1 in
%         % Post.PreMatch) or one is missing that word (so it is only in
%         % Pre.TrialMatch or Post.TrialMatch)
%         
%         unchkdPre = find(~PWord(iS).Bins(iB).Pre.TrialsMatch);
%         unchkdPost = find(~PWord(iS).Bins(iB).Post.TrialsMatch);
%         for iW = unchkdPre'
%             blnMatch = 0; ctr = 0;
%             while ~blnMatch && ctr < numel(unchkdPost)
%                 ctr = ctr + 1;
%                 blnMatch = Cmn(PWord(iS).Bins(iB).Post.WordIDs{unchkdPost(ctr)},PWord(iS).Bins(iB).Pre.WordIDs{iW});
%             end
%              if ctr > 0
%                 PWord(iS).Bins(iB).Pre.PostMatch(iW) = 1; 
%                 PWord(iS).Bins(iB).Post.PreMatch(unchkdPost(ctr)) = 1;
%             end
%         end
        

    end
   
end

save(['UniqueWord_Data_N' num2str(N) '_' type], 'UWord');
