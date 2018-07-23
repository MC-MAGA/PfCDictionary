%% get P(words) and compute unique words
clear all; close all

type = 'Learn'; % 'Learn'; % Stable85
N = 35; 

% load Pword
load(['Pword_Shuffled_N' num2str(N) '_' type], 'PWord');
load(['Shuffled_Words_And_Counts_N' num2str(N) '_' type],'binsizes');
Nsessions = numel(PWord);
Nshuffles = numel(PWord(1).Shuffle);
% CI
alpha = 0.01;  % 99% CIs

%% count unique words
DeltaWord = emptyStruct({'Shuffle'},[Nsessions,1]);

parfor iS = 1:Nsessions
% for iS = 1:Nsessions 
    
    for iSh = 1:Nshuffles
       
        for iB = 1:numel(binsizes)

            nTrialWords = numel(PWord(iS).Shuffle(iSh).Bins(iB).Trials.P);  % arrays of neuron IDs in each word
            nPreWords = numel(PWord(iS).Shuffle(iSh).Bins(iB).Pre.P);
            nPostWords = numel(PWord(iS).Shuffle(iSh).Bins(iB).Post.P);

            % make storage for all detected matches  
            DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.deltaPre = zeros(nTrialWords,1);
            DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.deltaPost = zeros(nTrialWords,1);
            DeltaWord(iS).Shuffle(iSh).Bins(iB).Pre.deltaPost = zeros(nPreWords,1);        
            DeltaWord(iS).Shuffle(iSh).Bins(iB).Post.deltaPre = zeros(nPostWords,1);

            DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.PreCI = zeros(nTrialWords,5);
            DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.PostCI = zeros(nTrialWords,5);
            DeltaWord(iS).Shuffle(iSh).Bins(iB).Post.PreCI = zeros(nPostWords,5);
            DeltaWord(iS).Shuffle(iSh).Bins(iB).Pre.PostCI = zeros(nPreWords,5);

            %% get DeltaP
            DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.deltaPre = PWord(iS).Shuffle(iSh).Bins(iB).Trials.P; % if Pre = 0, then deltaP = P.
            DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.deltaPost = PWord(iS).Shuffle(iSh).Bins(iB).Trials.P; % if Post = 0, then deltaP = P.
            DeltaWord(iS).Shuffle(iSh).Bins(iB).Pre.deltaPost = PWord(iS).Shuffle(iSh).Bins(iB).Pre.P; % if Pre = 0, then deltaP = P.
            DeltaWord(iS).Shuffle(iSh).Bins(iB).Post.deltaPre = PWord(iS).Shuffle(iSh).Bins(iB).Post.P; % if Post = 0, then deltaP = P.

           nTrials = numel(PWord(iS).Shuffle(iSh).Bins(iB).Trials.P);
           nPre = numel(PWord(iS).Shuffle(iSh).Bins(iB).Pre.P);
           nPost= numel(PWord(iS).Shuffle(iSh).Bins(iB).Post.P);

           %% differences for trials vs Post and trials vs Pre
            for iW = 1:nTrialWords
                 X = round(nTrials * PWord(iS).Shuffle(iSh).Bins(iB).Trials.P(iW)); % recover successes by round(P*Nwords)...

                ixPre = find(PWord(iS).Shuffle(iSh).Bins(iB).Trials.binaryIDs(iW) == PWord(iS).Shuffle(iSh).Bins(iB).Pre.binaryIDs);
                if ixPre
                    DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.deltaPre(iW) = PWord(iS).Shuffle(iSh).Bins(iB).Trials.P(iW) - PWord(iS).Shuffle(iSh).Bins(iB).Pre.P(ixPre);                
                    Y = round(nPre * PWord(iS).Shuffle(iSh).Bins(iB).Pre.P(ixPre));
                else 
                    Y = 0;
                end
                % compute CIs    
                [CI,pdiff,phat] = JeffreyDiffCI(X,nTrials,Y,nPre,alpha);
                DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.PreCI(iW,:) = [CI pdiff phat];

                ixPost = find(PWord(iS).Shuffle(iSh).Bins(iB).Trials.binaryIDs(iW) == PWord(iS).Shuffle(iSh).Bins(iB).Post.binaryIDs);
                if ixPost
                    DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.deltaPost(iW) = PWord(iS).Shuffle(iSh).Bins(iB).Trials.P(iW) - PWord(iS).Shuffle(iSh).Bins(iB).Post.P(ixPost);  
                    Y = round(nPost * PWord(iS).Shuffle(iSh).Bins(iB).Post.P(ixPost));
                else 
                    Y = 0;
                end
                % compute CIs    
                [CI,pdiff,phat] = JeffreyDiffCI(X,nTrials,Y,nPost,alpha);
                DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.PostCI(iW,:) = [CI pdiff phat]; 
            end

            % find non-overlapping CIs
            DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.ixNoOverlap = (DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.PostCI(:,1) >  DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.PreCI(:,2)) | (DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.PreCI(:,1) >  DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.PostCI(:,2)); 

            % Difference in differences: Post<Pre and Pre<Post
            DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.DifferencePost_minus_DifferencePre = DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.PostCI(:,3) - DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.PreCI(:,3);
            DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.IndexDifference = (abs(DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.PostCI(:,3)) - abs(DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.PreCI(:,3)))  ./ (abs(DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.PostCI(:,3)) + abs(DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.PreCI(:,3)));

            % separate into Post<Pre and Pre<Post by: DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.DifferencePost_minus_DifferencePre(DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.ixNoOverlap)

            % and for co-activation words
            ks = sum(PWord(iS).Shuffle(iSh).Bins(iB).Trials.WordSet);
            DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.ixCoAct = ks >= 2;

            DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.CoActixNoOverlap = intersect(find(DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.ixCoAct),find(DeltaWord(iS).Shuffle(iSh).Bins(iB).Trials.ixNoOverlap));

            %% differences between Pre and Post
            for iP = 1:nPreWords
                X = round(nPre * PWord(iS).Shuffle(iSh).Bins(iB).Pre.P(iP)); % recover successes by round(P*Nwords)...
                ixPost = find(PWord(iS).Shuffle(iSh).Bins(iB).Pre.binaryIDs(iP) == PWord(iS).Shuffle(iSh).Bins(iB).Post.binaryIDs);
                if ixPost
                    DeltaWord(iS).Shuffle(iSh).Bins(iB).Pre.deltaPost(iW) = PWord(iS).Shuffle(iSh).Bins(iB).Pre.P(iP) - PWord(iS).Shuffle(iSh).Bins(iB).Post.P(ixPost);  
                    Y = round(nPost * PWord(iS).Shuffle(iSh).Bins(iB).Post.P(ixPost));
                else 
                    Y = 0;
                end 
                [CI,pdiff,phat] = JeffreyDiffCI(X,nPre,Y,nPost,alpha);
                DeltaWord(iS).Shuffle(iSh).Bins(iB).Pre.PostCI(iP,:) = [CI pdiff phat]; 
            end

            for iP = 1:nPostWords
                X = round(nPost * PWord(iS).Shuffle(iSh).Bins(iB).Post.P(iP)); % recover successes by round(P*Nwords)...
                ixPre = find(PWord(iS).Shuffle(iSh).Bins(iB).Post.binaryIDs(iP) == PWord(iS).Shuffle(iSh).Bins(iB).Pre.binaryIDs);
                if ixPre
                    DeltaWord(iS).Shuffle(iSh).Bins(iB).Post.deltaPre(iW) = PWord(iS).Shuffle(iSh).Bins(iB).Post.P(iP) - PWord(iS).Shuffle(iSh).Bins(iB).Pre.P(ixPre);  
                    Y = round(nPre * PWord(iS).Shuffle(iSh).Bins(iB).Pre.P(ixPre));
                else 
                    Y = 0;
                end 
                [CI,pdiff,phat] = JeffreyDiffCI(X,nPost,Y,nPre,alpha);
                DeltaWord(iS).Shuffle(iSh).Bins(iB).Post.PreCI(iP,:) = [CI pdiff phat]; 
            end    
        end
    end
end

save(['delta_PWord_Shuffled_N' num2str(N) '_' type], 'DeltaWord');

