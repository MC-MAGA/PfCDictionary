%% script to look at between Sleep changes using Jittered data

clear all; close all

type = 'Stable85'; % 'Learn'; % Stable85
N = 35;

% bootstrap parameters
nBoot = 20;
alpha = [0.95 0.99];

% load words for data
load(['Pword_Jittered_N' num2str(N) '_' type '_binsize_5'], 'PWord');
load(['Jittered_Pre_Words_And_Counts_N' num2str(N) '_' type '_binsize_5'],'CountPre','binsize')
load(['Jittered_Post_Words_And_Counts_N' num2str(N) '_' type '_binsize_5'],'CountPost')

Nsessions = numel(CountPre);
Njitters = numel(CountPre(1).Jitter);
Nshuffles = numel(CountPre(1).Jitter(1).Shuffle);

%% compute distances and controls
DeltaSleep = emptyStruct({'Jitter'},[Nsessions,1]);

parfor iS = 1:Nsessions
% for iS = 1:Nsessions    
    % iS
    %tic
    for iJ = 1:Njitters
       
        for iSh = 1:Nshuffles
            % iSh
            % compute distance between Pre and Post session sleep in the Data
            DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).D_Pre_Post = full(Hellinger(PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.P,PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.binaryIDs,...
                                                    PWord(iS).Jitter(iJ).Shuffle(iSh).Post.P,PWord(iS).Jitter(iJ).Shuffle(iSh).Post.binaryIDs));
            nPre = numel(PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.P);     % number of unique words
            nPost = numel(PWord(iS).Jitter(iJ).Shuffle(iSh).Post.P);

            % joint P(word) distribution
            NPreWords = round(PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.P * CountPre(iS).Jitter(iJ).Shuffle(iSh).Nwords);         % frequency of each word
            NPostWords = round(PWord(iS).Jitter(iJ).Shuffle(iSh).Post.P * CountPost(iS).Jitter(iJ).Shuffle(iSh).Nwords);      % frequency of each word in Post
            nPreTs = CountPre(iS).Jitter(iJ).Shuffle(iSh).Nwords;   % number of words in Pre time-series
            nPostTs = CountPost(iS).Jitter(iJ).Shuffle(iSh).Nwords;
            
            DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).JointIDs = union(full(PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.binaryIDs),full(PWord(iS).Jitter(iJ).Shuffle(iSh).Post.binaryIDs));
            nJoint = numel(DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).JointIDs);
            
            for iW = 1:nJoint         
                % for each word appearing either Pre or Post, compute its
                % proportion of appearances across both Pre and Post
                npre = NPreWords(PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.binaryIDs == DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).JointIDs(iW)); if isempty(npre) npre = 0; end
                npost = NPostWords(PWord(iS).Jitter(iJ).Shuffle(iSh).Post.binaryIDs == DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).JointIDs(iW)); if isempty(npost) npost = 0; end
                DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).JointP(iW) = (npre + npost) / (nPreTs + nPostTs);
            end
            
            edges = 0.5:1:nJoint+1;  % force histcounts to work properly
            for iBoot = 1:nBoot
                % re-sampling: sample new Pre* from P(word) === bootstrap from Pre
                % sample ID list with replacement
                X = discreteinvrnd(PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.P,nPreTs,1); % random sample of same number of words: IDs into ID list      
                % compute P(word)* from new samples
                Pnew = histcounts(X,nPre,'Normalization','probability');
                % compute D(Pre|Pre*)  
                DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).Boot.D_Pre_PreSamp(iBoot) = full(Hellinger(PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.P,PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.binaryIDs,...
                                                                        Pnew,PWord(iS).Jitter(iJ).Shuffle(iSh).Pre.binaryIDs));
                % permutation test   
                Xpre = discreteinvrnd(DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).JointP,nPreTs,1);   % random sample of same number of words from Joint distribution: IDs into Joint ID list 
                PnewPre = histcounts(Xpre,edges,'Normalization','probability');

                Xpost = discreteinvrnd(DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).JointP,nPostTs,1);   % random sample of same number of words from Joint distribution: IDs into Joint ID list 
                PnewPost = histcounts(Xpost,edges,'Normalization','probability');

                DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).Perm.D_Pre_Post(iBoot) = full(Hellinger(PnewPre,DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).JointIDs,PnewPost,DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).JointIDs));

            end
            %toc

            %% summarise
            DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).Boot.M_Pre_PreSamp = mean(DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).Boot.D_Pre_PreSamp);
            DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).Boot.SD_Pre_PreSamp = std(DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).Boot.D_Pre_PreSamp);
            DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).Boot.CI_Pre_PreSamp = CIfromSEM(DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).Boot.SD_Pre_PreSamp,nBoot,alpha);
            % AND for Post...

            DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).Perm.M_Pre_Post = mean(DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).Perm.D_Pre_Post);
            DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).Perm.SD_Pre_Post = std(DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).Perm.D_Pre_Post);
            DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).Perm.CI_Pre_Post = CIfromSEM(DeltaSleep(iS).Jitter(iJ).Shuffle(iSh).Perm.SD_Pre_Post,nBoot,alpha);

        end
    end
end

save(['DeltaSleep_Jittered_N' num2str(N) '_' type '_binsize_' num2str(binsize)], 'DeltaSleep');

