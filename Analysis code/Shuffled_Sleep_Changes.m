%% get P(words) and compute unique words
clear all; close all

type = 'Stable85'; % 'Learn'; % Stable85
N = 35;

% bootstrap parameters
nBoot = 20;
alpha = [0.95 0.99];


% load Pword
load(['Pword_Shuffled_N' num2str(N) '_' type], 'PWord');

switch type
    case 'Learn'
        load(['Shuffled_Words_And_Counts_N' num2str(N) '_' type],'CountData','binsizes');
    case 'Stable85'
        load(['Shuffled_Words_And_Counts_N' num2str(N) '_Learn'],'CountData','binsizes');  % have to load this just so parfor will run with that SWITCH statement in it 
        load(['Shuffled_Pre_Words_And_Counts_N' num2str(N) '_' type],'CountPre','binsizes');  % loads CountPre 
        load(['Shuffled_Post_Words_And_Counts_N' num2str(N) '_' type],'CountPost');  % loads CountPost       
end
            
Nsessions = numel(PWord);
Nshuffles = numel(PWord(1).Shuffle);

%% 
DeltaSleep = emptyStruct({'Shuffle'},[Nsessions,1]);

tic
parfor iS = 1:Nsessions
% for iS = 1:Nsessions    
    for iSh = 1:Nshuffles
        %tic
        for iB = 1:numel(binsizes)
            % compute distance between Pre and Post session sleep in the Data
            DeltaSleep(iS).Shuffle(iSh).Bins(iB).D_Pre_Post = full(Hellinger(PWord(iS).Shuffle(iSh).Bins(iB).Pre.P,PWord(iS).Shuffle(iSh).Bins(iB).Pre.binaryIDs,...
                                                    PWord(iS).Shuffle(iSh).Bins(iB).Post.P,PWord(iS).Shuffle(iSh).Bins(iB).Post.binaryIDs));
            nPre = numel(PWord(iS).Shuffle(iSh).Bins(iB).Pre.P);     % number of unique words
            nPost = numel(PWord(iS).Shuffle(iSh).Bins(iB).Post.P);

            % joint P(word) distribution
            switch type
                case 'Learn'
                    % HORRIBLE HACK: parfor crashes if this is uncommented
                    % and type = 'Stable85'; it appears that parfor insists
                    % on testing execution in this branch of the SWITCH for
                    % every loop; and so it crashes because iS > 10
                    % DESPITE this branch never being executed!!
%                     NPreWords = round(PWord(iS).Shuffle(iSh).Bins(iB).Pre.P * CountData(iS).Shuffle(iSh).Bins(iB).Pre.Nwords);         % frequency of each word
%                     NPostWords = round(PWord(iS).Shuffle(iSh).Bins(iB).Post.P * CountData(iS).Shuffle(iSh).Bins(iB).Post.Nwords);      % frequency of each word in Post
%                     nPreTs = CountData(iS).Shuffle(iSh).Bins(iB).Pre.Nwords;   % number of words in Pre time-series
%                     nPostTs = CountData(iS).Shuffle(iSh).Bins(iB).Post.Nwords;
                case 'Stable85'
                    NPreWords = round(PWord(iS).Shuffle(iSh).Bins(iB).Pre.P * CountPre(iS).Shuffle(iSh).Bins(iB).Nwords);         % frequency of each word in Pre
                    NPostWords = round(PWord(iS).Shuffle(iSh).Bins(iB).Post.P * CountPost(iS).Shuffle(iSh).Bins(iB).Nwords);      % frequency of each word in Post
                    nPreTs = CountPre(iS).Shuffle(iSh).Bins(iB).Nwords;     % number of words in Pre time-series
                    nPostTs = CountPost(iS).Shuffle(iSh).Bins(iB).Nwords;
            end
            % combine into joint distribution of P(word) for all sleep
            DeltaSleep(iS).Shuffle(iSh).Bins(iB).JointIDs = union(full(PWord(iS).Shuffle(iSh).Bins(iB).Pre.binaryIDs),full(PWord(iS).Shuffle(iSh).Bins(iB).Post.binaryIDs));
            nJoint = numel(DeltaSleep(iS).Shuffle(iSh).Bins(iB).JointIDs);

            for iW = 1:nJoint         
                % for each word appearing either Pre or Post, compute its
                % proportion of appearances across both Pre and Post
                npre = NPreWords(PWord(iS).Shuffle(iSh).Bins(iB).Pre.binaryIDs == DeltaSleep(iS).Shuffle(iSh).Bins(iB).JointIDs(iW)); if isempty(npre) npre = 0; end
                npost = NPostWords(PWord(iS).Shuffle(iSh).Bins(iB).Post.binaryIDs == DeltaSleep(iS).Shuffle(iSh).Bins(iB).JointIDs(iW)); if isempty(npost) npost = 0; end
                DeltaSleep(iS).Shuffle(iSh).Bins(iB).JointP(iW) = (npre + npost) / (nPreTs + nPostTs);
            end


            % keyboard
            % for each repeat
            %tic
            edges = 0.5:1:nJoint+1;  % force histcounts to work properly
            for iBoot = 1:nBoot
                % re-sampling: sample new Pre* from P(word) === bootstrap from Pre
                % sample ID list with replacement
                X = discreteinvrnd(PWord(iS).Shuffle(iSh).Bins(iB).Pre.P,nPreTs,1); % random sample of same number of words: IDs into ID list      
                % compute P(word)* from new samples
                Pnew = histcounts(X,nPre,'Normalization','probability');
                % compute D(Pre|Pre*)  
                DeltaSleep(iS).Shuffle(iSh).Bins(iB).Boot.D_Pre_PreSamp(iBoot) = full(Hellinger(PWord(iS).Shuffle(iSh).Bins(iB).Pre.P,PWord(iS).Shuffle(iSh).Bins(iB).Pre.binaryIDs,...
                                                                        Pnew,PWord(iS).Shuffle(iSh).Bins(iB).Pre.binaryIDs));
                % permutation test   
                Xpre = discreteinvrnd(DeltaSleep(iS).Shuffle(iSh).Bins(iB).JointP,nPreTs,1);   % random sample of same number of words from Joint distribution: IDs into Joint ID list 
                PnewPre = histcounts(Xpre,edges,'Normalization','probability');
    %            PreIDs = DeltaSleep(iS).Shuffle(iSh).Bins(iB).JointIDs(PnewPre > 0); tempPpre = PnewPre(PnewPre > 0);

                Xpost = discreteinvrnd(DeltaSleep(iS).Shuffle(iSh).Bins(iB).JointP,nPostTs,1);   % random sample of same number of words from Joint distribution: IDs into Joint ID list 
                PnewPost = histcounts(Xpost,edges,'Normalization','probability');
    %            PostIDs = DeltaSleep(iS).Shuffle(iSh).Bins(iB).JointIDs(PnewPost > 0); tempPpost = PnewPost(PnewPost > 0);

                DeltaSleep(iS).Shuffle(iSh).Bins(iB).Perm.D_Pre_Post(iBoot) = full(Hellinger(PnewPre,DeltaSleep(iS).Shuffle(iSh).Bins(iB).JointIDs,PnewPost,DeltaSleep(iS).Shuffle(iSh).Bins(iB).JointIDs));

            end
            %toc

            %% summarise
            DeltaSleep(iS).Shuffle(iSh).Bins(iB).Boot.M_Pre_PreSamp = mean(DeltaSleep(iS).Shuffle(iSh).Bins(iB).Boot.D_Pre_PreSamp);
            DeltaSleep(iS).Shuffle(iSh).Bins(iB).Boot.SD_Pre_PreSamp = std(DeltaSleep(iS).Shuffle(iSh).Bins(iB).Boot.D_Pre_PreSamp);
            DeltaSleep(iS).Shuffle(iSh).Bins(iB).Boot.CI_Pre_PreSamp = CIfromSEM(DeltaSleep(iS).Shuffle(iSh).Bins(iB).Boot.SD_Pre_PreSamp,nBoot,alpha);
            % AND for Post...

            DeltaSleep(iS).Shuffle(iSh).Bins(iB).Perm.M_Pre_Post = mean(DeltaSleep(iS).Shuffle(iSh).Bins(iB).Perm.D_Pre_Post);
            DeltaSleep(iS).Shuffle(iSh).Bins(iB).Perm.SD_Pre_Post = std(DeltaSleep(iS).Shuffle(iSh).Bins(iB).Perm.D_Pre_Post);
            DeltaSleep(iS).Shuffle(iSh).Bins(iB).Perm.CI_Pre_Post = CIfromSEM(DeltaSleep(iS).Shuffle(iSh).Bins(iB).Perm.SD_Pre_Post,nBoot,alpha);

        end
    %toc
    end
end 
toc


% save stuff
save(['DeltaSleep_Shuffled_N' num2str(N) '_' type], 'DeltaSleep');

