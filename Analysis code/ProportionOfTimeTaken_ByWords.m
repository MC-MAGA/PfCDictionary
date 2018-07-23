% proportion of time taken up by common and unique words
% Mark Humphries 25/4/2018
clear all; close all

type = 'Stable85'; % 'Learn'; % Stable85
N = 35; 

% load data
load(['Pword_Data_N' num2str(N) '_' type], 'PWord');  % load data on word IDs and their time-series
load(['UniqueWord_Data_N' num2str(N) '_' type], 'UWord');  % load data on unique and common words
load(['DataWords_And_Counts_N' num2str(N) '_' type],'binsizes');
Nsessions = numel(PWord);

PTime = emptyStruct({'Bins'},[Nsessions,1]);

%parfor iS = 1:Nsessions
for iS = 1:Nsessions    
   iS    
    for iB = 1:numel(binsizes)
        ixCommon = find(UWord(iS).Bins(iB).Trials.PrePostMatch);       % set of common words to all epochs

        % proportion of time taken up by words common to all epochs
        TrialsTotalActiveTime = numel(PWord(iS).Bins(iB).Trials.tsbinaryIDs); % total bins with active words
        PreTotalActiveTime = numel(PWord(iS).Bins(iB).Pre.tsbinaryIDs); % total bins with active words
        PostTotalActiveTime = numel(PWord(iS).Bins(iB).Post.tsbinaryIDs); % total bins with active words
        NTimeCommonTrials = zeros(numel(ixCommon),1); NTimeCommonPre = NTimeCommonTrials; NTimeCommonPost = NTimeCommonTrials; 
        for iW = 2:numel(ixCommon) % skip the empty word
            ID = PWord(iS).Bins(iB).Trials.binaryIDs(ixCommon(iW)); % get binary ID of this word
            NTimeCommonTrials(iW) = sum(PWord(iS).Bins(iB).Trials.tsbinaryIDs == ID);   % how many active bins contained this word?
            NTimeCommonPre(iW) = sum(PWord(iS).Bins(iB).Pre.tsbinaryIDs == ID);   % how many active bins contained this word?
            NTimeCommonPost(iW) = sum(PWord(iS).Bins(iB).Post.tsbinaryIDs == ID);   % how many active bins contained this word?
        end
        PTime(iS).Bins(iB).Trials.CommonPtime = sum(NTimeCommonTrials) ./ TrialsTotalActiveTime;
        PTime(iS).Bins(iB).Pre.CommonPtime = sum(NTimeCommonPre) ./ PreTotalActiveTime;
        PTime(iS).Bins(iB).Post.CommonPtime = sum(NTimeCommonPost) ./ PostTotalActiveTime;
        
        % time taken up by words common between sleep epochs
        ixSleepCommon = find(UWord(iS).Bins(iB).Pre.PostMatch);
        NTimeCommonPre = zeros(numel(ixSleepCommon),1); NTimeCommonPost = NTimeCommonPre;
        for iW = 2:numel(ixSleepCommon) % skip the empty word
            ID = PWord(iS).Bins(iB).Pre.binaryIDs(ixSleepCommon(iW)); % get binary ID of this word
            NTimeCommonPre(iW) = sum(PWord(iS).Bins(iB).Pre.tsbinaryIDs == ID);   % how many active bins contained this word?
            NTimeCommonPost(iW) = sum(PWord(iS).Bins(iB).Post.tsbinaryIDs == ID);   % how many active bins contained this word?
        end
        PTime(iS).Bins(iB).Pre.SleepPtime = sum(NTimeCommonPre) ./ PreTotalActiveTime;
        PTime(iS).Bins(iB).Post.SleepPtime = sum(NTimeCommonPost) ./ PostTotalActiveTime;        
        
        % time taken up by unique words, per epoch
        ixTrialUnique = find(~UWord(iS).Bins(iB).Trials.PreMatch & ~UWord(iS).Bins(iB).Trials.PostMatch);  % set of unique words        
        NTimeUnique = zeros(numel(ixTrialUnique),1);
        for iW = 1:numel(ixTrialUnique) 
            ID = PWord(iS).Bins(iB).Trials.binaryIDs(ixTrialUnique(iW)); % get binary ID of this word
            NTimeUnique(iW) = sum(PWord(iS).Bins(iB).Trials.tsbinaryIDs == ID);   % how many active bins contained this word?
        end        
        PTime(iS).Bins(iB).Trials.UniquePtime = sum(NTimeUnique) ./ TrialsTotalActiveTime;
    
        % time taken up by unique words in pre-training sleep
        ixPreUnique = find(~UWord(iS).Bins(iB).Pre.TrialsMatch & ~UWord(iS).Bins(iB).Pre.PostMatch);  % set of unique words
        NTimeUnique = zeros(numel(ixPreUnique),1);
        for iW = 1:numel(ixPreUnique) % no empty word
            ID = PWord(iS).Bins(iB).Pre.binaryIDs(ixPreUnique(iW)); % get binary ID of this word
            NTimeUnique(iW) = sum(PWord(iS).Bins(iB).Pre.tsbinaryIDs == ID);   % how many active bins contained this word?
        end        
        PTime(iS).Bins(iB).Pre.UniquePtime = sum(NTimeUnique) ./ PreTotalActiveTime;
        
        % time taken up by unique words in post-training sleep
        ixPostUnique = find(~UWord(iS).Bins(iB).Post.TrialsMatch & ~UWord(iS).Bins(iB).Post.PreMatch);  % set of unique words
        NTimeUnique = zeros(numel(ixPostUnique),1);
        for iW = 1:numel(ixPostUnique) % no empty word
            ID = PWord(iS).Bins(iB).Post.binaryIDs(ixPostUnique(iW)); % get binary ID of this word
            NTimeUnique(iW) = sum(PWord(iS).Bins(iB).Post.tsbinaryIDs == ID);   % how many active bins contained this word?
        end        
        PTime(iS).Bins(iB).Post.UniquePtime = sum(NTimeUnique) ./ PostTotalActiveTime;

    end
    
end

save(['PropTime_Data_N' num2str(N) '_' type], 'PTime');
