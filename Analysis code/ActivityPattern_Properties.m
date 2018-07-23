%% script to look at basic properties of words in data
% Counting emitted words (not size of dictionary: see Dictionary comparison
% scripts
% (1) How many errors over all sessions combined (proportion of 1s with
% more than one spike)
% (2) Proportion of words with K >=2 spikes (co-active words)
%
% At: each binsize
% Compared to: shuffle controls (N=20)

clear all; close all
addpath('../Helper functions/')

% where are the large intermediate results files?
filepath = 'C:\Users\lpzmdh\Dropbox\My Papers\PfC sampling hypothesis\Dictionary version 2\figures\Large_Intermediate_Results\';


% common parameters

type = 'Learn'; % 'Stable85';  %'Learn'
N = 35; % word-size

% analysis parameters
CI = 0.99;




%% process Data
load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type],'CountData','binsizes')
Nsessions = numel(CountData);


% proportion of errors at each bin size
for iC = 1:Nsessions
    for iB = 1:numel(binsizes)
        Data.ChangeCount.Trials(iC,iB) = CountData(iC).Bins(iB).Trials.Changed;
        Data.ChangeCount.Pre(iC,iB) = CountData(iC).Bins(iB).Pre.Changed;
        Data.ChangeCount.Post(iC,iB) = CountData(iC).Bins(iB).Post.Changed;
                                
        Data.NOnesCount.Trials(iC,iB) = sum(CountData(iC).Bins(iB).Trials.Khistogram .*CountData(iC).Bins(iB).Trials.K);   
        Data.NOnesCount.Pre(iC,iB) = sum(CountData(iC).Bins(iB).Pre.Khistogram .*CountData(iC).Bins(iB).Pre.K);   
        Data.NOnesCount.Post(iC,iB) = sum(CountData(iC).Bins(iB).Post.Khistogram .*CountData(iC).Bins(iB).Post.K);   
                
    end
end
Data.ChangeCount.All = Data.ChangeCount.Trials + Data.ChangeCount.Pre + Data.ChangeCount.Post;
Data.NOnesCount.All = Data.NOnesCount.Trials + Data.NOnesCount.Pre + Data.NOnesCount.Post;

% proportions, given sum over all sessions at each binsize
Data.PChange.Trials = sum(Data.ChangeCount.Trials) ./ sum(Data.NOnesCount.Trials);
Data.PChange.Pre = sum(Data.ChangeCount.Pre) ./ sum(Data.NOnesCount.Pre);
Data.PChange.Post = sum(Data.ChangeCount.Post) ./ sum(Data.NOnesCount.Post);
Data.PChange.All = sum(Data.ChangeCount.All) ./ sum(Data.NOnesCount.All);  % of all 1s in entire dataset, what proportion had more than one spike?

% proportion of K>=2 words (sanity checks)
for iC = 1:Nsessions
    for iB = 1:numel(binsizes)
        Data.K2.All(iC,iB) = [CountData(iC).Bins(iB).All.K2];
        Data.Nwords.All(iC,iB) = [CountData(iC).Bins(iB).All.Nwords];

        % by epoch
        Data.K2.Trials(iC,iB) = [CountData(iC).Bins(iB).Trials.K2];
        Data.Nwords.Trials(iC,iB) = [CountData(iC).Bins(iB).Trials.Nwords];
        Data.K2.Pre(iC,iB) = [CountData(iC).Bins(iB).Pre.K2];
        Data.Nwords.Pre(iC,iB) = [CountData(iC).Bins(iB).Pre.Nwords];
        Data.K2.Post(iC,iB) = [CountData(iC).Bins(iB).Post.K2];
        Data.Nwords.Post(iC,iB) = [CountData(iC).Bins(iB).Post.Nwords];
    end
end

% proportions, given sum over all sessions at that binsize
Data.Prop.All = sum(Data.K2.All) ./ sum(Data.Nwords.All);
Data.Prop.Trials = sum(Data.K2.Trials) ./ sum(Data.Nwords.Trials);
Data.Prop.Pre = sum(Data.K2.Pre) ./ sum(Data.Nwords.Pre);
Data.Prop.Post = sum(Data.K2.Post) ./ sum(Data.Nwords.Post);

%% process Shuffled
switch type
    case 'Learn'
        load([filepath 'Shuffled_Words_And_Counts_N' num2str(N) '_' type],'CountData')
        nShuffles = numel(CountData(1).Shuffle);
    case 'Stable85'
        load([filepath 'Shuffled_Trials_Words_And_Counts_N' num2str(N) '_' type],'CountTrials')
        load([filepath 'Shuffled_Post_Words_And_Counts_N' num2str(N) '_' type],'CountPost')
        load([filepath 'Shuffled_Pre_Words_And_Counts_N' num2str(N) '_' type],'CountPre')
        load([filepath 'Shuffled_All_Counts_N' num2str(N) '_' type],'CountAll')
        nShuffles = numel(CountAll(1).Shuffle);
        % map the split Stable Trial/Pre/Post/All separate files to common CountData
        for iSh = 1:nShuffles
            for iC = 1:Nsessions
                for iB = 1:numel(binsizes)
                    CountData(iC).Shuffle(iSh).Bins(iB).Trials = CountTrials(iC).Shuffle(iSh).Bins(iB);
                    CountData(iC).Shuffle(iSh).Bins(iB).Pre = CountPre(iC).Shuffle(iSh).Bins(iB);
                    CountData(iC).Shuffle(iSh).Bins(iB).Post = CountPost(iC).Shuffle(iSh).Bins(iB);
                    CountData(iC).Shuffle(iSh).Bins(iB).All = CountAll(iC).Shuffle(iSh).Bins(iB);
                end
            end
        end
        
end


% proportion of errors at each bin size
for iSh = 1:nShuffles
    for iC = 1:Nsessions
        for iB = 1:numel(binsizes)
            ChangeCount.Trials(iC,iB) = CountData(iC).Shuffle(iSh).Bins(iB).Trials.Changed;
            ChangeCount.Pre(iC,iB) = CountData(iC).Shuffle(iSh).Bins(iB).Pre.Changed;
            ChangeCount.Post(iC,iB) = CountData(iC).Shuffle(iSh).Bins(iB).Post.Changed;

            NOnesCount.Trials(iC,iB) = sum(CountData(iC).Shuffle(iSh).Bins(iB).Trials.Khistogram .*CountData(iC).Shuffle(iSh).Bins(iB).Trials.K);   
            NOnesCount.Pre(iC,iB) = sum(CountData(iC).Shuffle(iSh).Bins(iB).Pre.Khistogram .*CountData(iC).Shuffle(iSh).Bins(iB).Pre.K);   
            NOnesCount.Post(iC,iB) = sum(CountData(iC).Shuffle(iSh).Bins(iB).Post.Khistogram .*CountData(iC).Shuffle(iSh).Bins(iB).Post.K);   
          
        end
    end
    ChangeCount.All = ChangeCount.Trials + ChangeCount.Pre + ChangeCount.Post;
    NOnesCount.All = NOnesCount.Trials + NOnesCount.Pre + NOnesCount.Post;
    
    SData.PChange.Trials(iSh,:) = sum(ChangeCount.Trials) ./ sum(NOnesCount.Trials);  % of all 1s in entire dataset, what proportion had more than one spike?
    SData.PChange.Pre(iSh,:) = sum(ChangeCount.Pre) ./ sum(NOnesCount.Pre);  % of all 1s in entire dataset, what proportion had more than one spike?
    SData.PChange.Post(iSh,:) = sum(ChangeCount.Post) ./ sum(NOnesCount.Post);  % of all 1s in entire dataset, what proportion had more than one spike?

    SData.PChange.All(iSh,:) = sum(ChangeCount.All) ./ sum(NOnesCount.All);  % of all 1s in entire dataset, what proportion had more than one spike?
end
SData.MeanPChange.Trials = mean(SData.PChange.Trials);
SData.CI_PChange.Trials = CIfromSEM(std(SData.PChange.Trials)',zeros(numel(binsizes),1)+nShuffles,CI);
SData.MeanPChange.Pre = mean(SData.PChange.Pre);
SData.CI_PChange.Pre = CIfromSEM(std(SData.PChange.Pre)',zeros(numel(binsizes),1)+nShuffles,CI);
SData.MeanPChange.Post = mean(SData.PChange.Post);
SData.CI_PChange.Post = CIfromSEM(std(SData.PChange.Post)',zeros(numel(binsizes),1)+nShuffles,CI);

SData.MeanPChange.All = mean(SData.PChange.All);
SData.CI_PChange.All = CIfromSEM(std(SData.PChange.All)',zeros(numel(binsizes),1)+nShuffles,CI);

% difference from Data
Data.PChange.Diff.All = Data.PChange.All - SData.MeanPChange.All;
Data.PChange.Diff.Trials = Data.PChange.Trials - SData.MeanPChange.Trials;
Data.PChange.Diff.Pre = Data.PChange.Pre - SData.MeanPChange.Pre;
Data.PChange.Diff.Post = Data.PChange.Post - SData.MeanPChange.Post


% proportions of K>=2 words
for iSh = 1:nShuffles
    K2.All = zeros(Nsessions,numel(binsizes));
    K2.Trials = K2.All; K2.Pre = K2.All; K2.Post = K2.All;
    Nwords.All = K2.All; Nwords.Trials = K2.All; Nwords.Pre = K2.All; Nwords.Post = K2.All;
    for iC = 1:Nsessions
        for iB = 1:numel(binsizes)
            K2.All(iC,iB) = [CountData(iC).Shuffle(iSh).Bins(iB).All.K2];
            Nwords.All(iC,iB) = [CountData(iC).Shuffle(iSh).Bins(iB).All.Nwords];
            
            K2.Trials(iC,iB) = [CountData(iC).Shuffle(iSh).Bins(iB).Trials.K2];
            Nwords.Trials(iC,iB) = [CountData(iC).Shuffle(iSh).Bins(iB).Trials.Nwords];
            K2.Pre(iC,iB) = [CountData(iC).Shuffle(iSh).Bins(iB).Pre.K2];
            Nwords.Pre(iC,iB) = [CountData(iC).Shuffle(iSh).Bins(iB).Pre.Nwords];
            K2.Post(iC,iB) = [CountData(iC).Shuffle(iSh).Bins(iB).Post.K2];
            Nwords.Post(iC,iB) = [CountData(iC).Shuffle(iSh).Bins(iB).Post.Nwords];

        end
    end
    SData.Prop.All(iSh,:) = sum(K2.All) ./ sum(Nwords.All);
    SData.Prop.Trials(iSh,:) = sum(K2.Trials) ./ sum(Nwords.Trials);
    SData.Prop.Pre(iSh,:) = sum(K2.Pre) ./ sum(Nwords.Pre);
    SData.Prop.Post(iSh,:) = sum(K2.Post) ./ sum(Nwords.Post);
    
    % difference from data: per session, per binsize...
    Data.Prop.EachDiff.Trials(iSh,:,:) = Data.K2.Trials./Data.Nwords.Trials - K2.Trials ./ Nwords.Trials;
    Data.Prop.EachDiff.Pre(iSh,:,:) = Data.K2.Pre./Data.Nwords.Pre - K2.Pre ./ Nwords.Pre;
    Data.Prop.EachDiff.Post(iSh,:,:) = Data.K2.Post./Data.Nwords.Post - K2.Post ./ Nwords.Post;

    Data.Prop.EachDiff.All(iSh,:,:) = Data.K2.All./Data.Nwords.All - K2.All ./ Nwords.All;
    
end
% shuffled data summaries
SData.MeanProp.All = mean(SData.Prop.All);
SData.CIProp.All = CIfromSEM(std(SData.Prop.All)',zeros(numel(binsizes),1)+nShuffles,CI);

SData.MeanProp.Trials = mean(SData.Prop.Trials);
SData.CIProp.Trials = CIfromSEM(std(SData.Prop.Trials)',zeros(numel(binsizes),1)+nShuffles,CI);
SData.MeanProp.Pre = mean(SData.Prop.Pre);
SData.CIProp.Pre = CIfromSEM(std(SData.Prop.Pre)',zeros(numel(binsizes),1)+nShuffles,CI);
SData.MeanProp.Post = mean(SData.Prop.Post);
SData.CIProp.Post = CIfromSEM(std(SData.Prop.Post)',zeros(numel(binsizes),1)+nShuffles,CI);

% mean differences per session, per binsize
Data.Prop.MeanEachDiff.Trials = squeeze(mean(Data.Prop.EachDiff.Trials,1));
Data.Prop.MeanEachDiff.Pre = squeeze(mean(Data.Prop.EachDiff.Pre,1));
Data.Prop.MeanEachDiff.Post = squeeze(mean(Data.Prop.EachDiff.Post,1));

% difference for all words pooled over all sessions
Data.Prop.Diff.All = Data.Prop.All - mean(SData.Prop.All);
Data.Prop.Diff.Trials = Data.Prop.Trials - mean(SData.Prop.Trials);
Data.Prop.Diff.Pre = Data.Prop.Pre - mean(SData.Prop.Pre);
Data.Prop.Diff.Post = Data.Prop.Post - mean(SData.Prop.Post);


% save(['ActivityPattern_Analyses_N' num2str(N) '_' type],'Data','SData','CI')



