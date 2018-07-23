%% script to look at the conservation of the dictionary between epochs
% That is, is the data constrained to a more consistent set of states
% between epochs?
%
% At: each binsize
% Compared to: shuffle controls (N=20)

clear all; close all

filepath = 'C:\Users\lpzmdh\Dropbox\My Papers\PfC sampling hypothesis\Dictionary version 2\figures\Large_Intermediate_Results\';

type = 'Learn'; % 'Stable85';  %'Learn'
N = 35; % word-size

% analysis parameters
CI = 0.99;
alpha = 0.001;

load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type],'binsizes')

%% load Data and Shuffles
load([filepath 'UniqueWord_Shuffled_N' num2str(N) '_' type])
Nsessions = numel(UWord);
nShuffles = numel(UWord(1).Shuffle);
UShuffle = UWord;

load(['UniqueWord_Data_N' num2str(N) '_' type])

%% at each binsize, for each session, compare 

for iB = 1:numel(binsizes)
    for iS = 1:Nsessions
        % Proportions of unique words
        Data.Trials.Punique(iS,iB) = UWord(iS).Bins(iB).Trials.Punique;
        Data.Pre.Punique(iS,iB) = UWord(iS).Bins(iB).Pre.Punique;
        Data.Post.Punique(iS,iB) = UWord(iS).Bins(iB).Post.Punique;
        
        Data.Trials.PCommonWords(iS,iB) = UWord(iS).Bins(iB).Trials.PAllEpochs; % P of words in Trials also found in all others
        Data.Pre.PCommonWords(iS,iB) = UWord(iS).Bins(iB).Pre.PAllEpochs; 
        Data.Post.PCommonWords(iS,iB) = UWord(iS).Bins(iB).Post.PAllEpochs; 
       
        Data.Pre.PSleep(iS,iB) = UWord(iS).Bins(iB).Pre.PSleepEpochs;
        Data.Post.PSleep(iS,iB) = UWord(iS).Bins(iB).Post.PSleepEpochs;
        
        for iSh = 1:nShuffles
            % Proportions of unique words
            SData.Trials.Punique(iS,iB,iSh) = UShuffle(iS).Shuffle(iSh).Bins(iB).Trials.Punique;
            SData.Pre.Punique(iS,iB,iSh) = UShuffle(iS).Shuffle(iSh).Bins(iB).Pre.Punique;
            SData.Post.Punique(iS,iB,iSh) = UShuffle(iS).Shuffle(iSh).Bins(iB).Post.Punique;
            SData.Trials.PCommonWords(iS,iB,iSh) = UShuffle(iS).Shuffle(iSh).Bins(iB).Trials.PAllEpochs; 
            SData.Pre.PCommonWords(iS,iB,iSh) = UShuffle(iS).Shuffle(iSh).Bins(iB).Pre.PAllEpochs; 
            SData.Post.PCommonWords(iS,iB,iSh) = UShuffle(iS).Shuffle(iSh).Bins(iB).Post.PAllEpochs; 
            SData.Pre.PSleep(iS,iB,iSh) = UShuffle(iS).Shuffle(iSh).Bins(iB).Pre.PSleepEpochs;
            SData.Post.PSleep(iS,iB,iSh) = UShuffle(iS).Shuffle(iSh).Bins(iB).Post.PSleepEpochs;
        end
        SData.Trials.M_Punique(iS,iB) = mean(SData.Trials.Punique(iS,iB,:));
        SData.Trials.CI_Punique(iS,iB) = CIfromSEM(std(SData.Trials.Punique(iS,iB,:)),nShuffles,CI);
        SData.Pre.M_Punique(iS,iB) = mean(SData.Pre.Punique(iS,iB,:));
        SData.Pre.CI_Punique(iS,iB) = CIfromSEM(std(SData.Pre.Punique(iS,iB,:)),nShuffles,CI);
        SData.Post.M_Punique(iS,iB) = mean(SData.Post.Punique(iS,iB,:));
        SData.Post.CI_Punique(iS,iB) = CIfromSEM(std(SData.Post.Punique(iS,iB,:)),nShuffles,CI);

        SData.Trials.M_Pcommon(iS,iB) = mean(SData.Trials.PCommonWords(iS,iB,:));
        SData.Pre.M_Pcommon(iS,iB) = mean(SData.Pre.PCommonWords(iS,iB,:));
        SData.Post.M_Pcommon(iS,iB) = mean(SData.Post.PCommonWords(iS,iB,:));
        
        SData.Pre.M_Psleep(iS,iB) = mean(SData.Pre.PSleep(iS,iB,:));
        SData.Post.M_Psleep(iS,iB) = mean(SData.Post.PSleep(iS,iB,:));
        
        Data.Trials.unique_P(iS,iB) = signtest(Data.Trials.Punique(iS,iB)  - squeeze(SData.Trials.Punique(iS,iB,:)));
        Data.Pre.unique_P(iS,iB) = signtest(Data.Pre.Punique(iS,iB)  - squeeze(SData.Pre.Punique(iS,iB,:)));
        Data.Post.unique_P(iS,iB) = signtest(Data.Post.Punique(iS,iB)  - squeeze(SData.Post.Punique(iS,iB,:)));
      
        Data.Trials.common_P(iS,iB) = signtest(Data.Trials.PCommonWords(iS,iB)  - squeeze(SData.Trials.PCommonWords(iS,iB,:)));
        Data.Pre.common_P(iS,iB) = signtest(Data.Pre.PCommonWords(iS,iB)  - squeeze(SData.Pre.PCommonWords(iS,iB,:)));
        Data.Post.common_P(iS,iB) = signtest(Data.Post.PCommonWords(iS,iB)  - squeeze(SData.Post.PCommonWords(iS,iB,:)));

    end
end

%% differences between data and shuffle...
Data.Trials.Diff.Punique = Data.Trials.Punique - SData.Trials.M_Punique;
Data.Pre.Diff.Punique = Data.Pre.Punique - SData.Pre.M_Punique;
Data.Post.Diff.Punique = Data.Post.Punique - SData.Post.M_Punique;

Data.Trials.Diff.PCommonWords = Data.Trials.PCommonWords - SData.Trials.M_Pcommon;
Data.Pre.Diff.PCommonWords = Data.Pre.PCommonWords - SData.Pre.M_Pcommon;
Data.Post.Diff.PCommonWords = Data.Post.PCommonWords - SData.Post.M_Pcommon;

save(['ConservationOfDictionary_Analyses_N' num2str(N) '_' type],'Data','SData','CI','alpha')
        
