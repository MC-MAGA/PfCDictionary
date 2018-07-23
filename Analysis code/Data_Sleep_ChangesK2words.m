%% get P(words) and compute unique words
clear all; close all

type = 'Learn'; % 'Learn'; % Stable85
N = 35;

threshK = 2;  % all co-activation words

% bootstrap parameters
nBoot = 20;
alpha = [0.95 0.99];

% load Pword
load(['Pword_Data_N' num2str(N) '_' type], 'PWord');  % data Pword, and the binary IDs of each word
load(['DataWords_And_Counts_N' num2str(N) '_' type],'binsizes','CountData'); % number of words in total per epoch
Nsessions = numel(PWord);

%% count words in each epoch
DeltaSleep = emptyStruct({'Bins'},[Nsessions,1]);
NewPWord = emptyStruct({'Bins'},[Nsessions,1]);

tic
parfor iS = 1:Nsessions
% for iS = 1:Nsessions    
    % iS
    %tic
    for iB = 1:numel(binsizes)
        % iB
        % get K>=2 word distributions
        [NewPWord(iS).Bins(iB).Pre.P,NewPWord(iS).Bins(iB).Pre.ID] = RenormalisedPword(PWord(iS).Bins(iB).Pre.WordSet,PWord(iS).Bins(iB).Pre.P,PWord(iS).Bins(iB).Pre.binaryIDs,threshK);
        [NewPWord(iS).Bins(iB).Post.P,NewPWord(iS).Bins(iB).Post.ID] = RenormalisedPword(PWord(iS).Bins(iB).Post.WordSet,PWord(iS).Bins(iB).Post.P,PWord(iS).Bins(iB).Post.binaryIDs,threshK);

        % compute distance between Pre and Post session sleep in the Data
        DeltaSleep(iS).Bins(iB).D_Pre_Post = full(Hellinger(NewPWord(iS).Bins(iB).Pre.P,NewPWord(iS).Bins(iB).Pre.ID,NewPWord(iS).Bins(iB).Post.P,NewPWord(iS).Bins(iB).Post.ID));
%         
        nPre = numel(NewPWord(iS).Bins(iB).Pre.P);     % number of unique words
        nPost = numel(NewPWord(iS).Bins(iB).Post.P);
        
        % joint P(word) distribution
        NPreWords = round(NewPWord(iS).Bins(iB).Pre.P * CountData(iS).Bins(iB).Pre.K2);         % actual number of words
        NPostWords = round(NewPWord(iS).Bins(iB).Post.P * CountData(iS).Bins(iB).Post.K2);      % actual number of words
        
        % combine into single joint Distribution 
        DeltaSleep(iS).Bins(iB).JointIDs = union(full(NewPWord(iS).Bins(iB).Pre.ID),full(NewPWord(iS).Bins(iB).Post.ID));
        nJoint = numel(DeltaSleep(iS).Bins(iB).JointIDs);
        
        for iW = 1:nJoint         
            npre = NPreWords(NewPWord(iS).Bins(iB).Pre.ID == DeltaSleep(iS).Bins(iB).JointIDs(iW)); if isempty(npre) npre = 0; end
            npost = NPostWords(NewPWord(iS).Bins(iB).Post.ID == DeltaSleep(iS).Bins(iB).JointIDs(iW)); if isempty(npost) npost = 0; end
            DeltaSleep(iS).Bins(iB).JointP(iW) = (npre + npost) / (CountData(iS).Bins(iB).Pre.K2 + CountData(iS).Bins(iB).Post.K2);
        end
        
        
        % keyboard
        % for each repeat
        %tic
        edges = 0.5:1:nJoint+1;  % force histcounts to work properly
        for iBoot = 1:nBoot
            % re-sampling: sample new Pre* from P(word) === bootstrap from Pre
            % sample ID list with replacement
            X = discreteinvrnd(NewPWord(iS).Bins(iB).Pre.P,CountData(iS).Bins(iB).Pre.K2,1); % random sample of same number of words: IDs into ID list      
            % compute P(word)* from new samples
            Pnew = histcounts(X,nPre,'Normalization','probability');
            % compute D(Pre|Pre*)  
            DeltaSleep(iS).Bins(iB).Boot.D_Pre_PreSamp(iBoot) = full(Hellinger(NewPWord(iS).Bins(iB).Pre.P,NewPWord(iS).Bins(iB).Pre.ID,...
                                                                    Pnew,NewPWord(iS).Bins(iB).Pre.ID));
            % permutation test   
            Xpre = discreteinvrnd(DeltaSleep(iS).Bins(iB).JointP,CountData(iS).Bins(iB).Pre.K2,1);   % random sample of same number of words from Joint distribution: IDs into Joint ID list 
            PnewPre = histcounts(Xpre,edges,'Normalization','probability');
%            PreIDs = DeltaSleep(iS).Bins(iB).JointIDs(PnewPre > 0); tempPpre = PnewPre(PnewPre > 0);
            
            Xpost = discreteinvrnd(DeltaSleep(iS).Bins(iB).JointP,CountData(iS).Bins(iB).Post.K2,1);   % random sample of same number of words from Joint distribution: IDs into Joint ID list 
            PnewPost = histcounts(Xpost,edges,'Normalization','probability');
%            PostIDs = DeltaSleep(iS).Bins(iB).JointIDs(PnewPost > 0); tempPpost = PnewPost(PnewPost > 0);
               
            DeltaSleep(iS).Bins(iB).Perm.D_Pre_Post(iBoot) = full(Hellinger(PnewPre,DeltaSleep(iS).Bins(iB).JointIDs,PnewPost,DeltaSleep(iS).Bins(iB).JointIDs));
            
        end
        %toc

        %% summarise
        DeltaSleep(iS).Bins(iB).Boot.M_Pre_PreSamp = mean(DeltaSleep(iS).Bins(iB).Boot.D_Pre_PreSamp);
        DeltaSleep(iS).Bins(iB).Boot.SD_Pre_PreSamp = std(DeltaSleep(iS).Bins(iB).Boot.D_Pre_PreSamp);
        DeltaSleep(iS).Bins(iB).Boot.CI_Pre_PreSamp = CIfromSEM(DeltaSleep(iS).Bins(iB).Boot.SD_Pre_PreSamp,nBoot,alpha);
        % AND for Post...
            
        DeltaSleep(iS).Bins(iB).Perm.M_Pre_Post = mean(DeltaSleep(iS).Bins(iB).Perm.D_Pre_Post);
        DeltaSleep(iS).Bins(iB).Perm.SD_Pre_Post = std(DeltaSleep(iS).Bins(iB).Perm.D_Pre_Post);
        DeltaSleep(iS).Bins(iB).Perm.CI_Pre_Post = CIfromSEM(DeltaSleep(iS).Bins(iB).Perm.SD_Pre_Post,nBoot,alpha);
           
    end
    %toc
end 
toc


% save stuff
save(['DeltaSleep_K2_Data_N' num2str(N) '_' type], 'DeltaSleep');

