%% script to get bootstrap or resample estimates of distances
% two stages:
% (1) sample from full set of words (eg either: N/4,N/2,N); or bootstrap
% (2) compute P(word) for each sample
% (3) do for Trial, Pre, and Post
% (4) Compute D(X|Y): either between bootstrap samples; or as function of
% N, and fit curve to extrapolate...
%  (5) Repeat per bin-size?

clear all; close all

if ispc
    filepath = 'C:\Users\lpzmdh\Dropbox\Analyses\PfC Sampling hypothesis\';
else
    filepath = '/Users/mqbssmhg/Dropbox/Analyses/PfC Sampling hypothesis/';
end

% which data
type = 'Learn'; % Stable85
N = 35;

% what parameters for analysis?
nBatch = 10;
samplesize = [0.25 0.5 0.75];  % and 1 will be the actual estimate

%% load words for data
load(['DataWords_And_Counts_N' num2str(N) '_' type]);

Nsessions = numel(CountData);

% count words in each epoch
PWord = emptyStruct({'Bins'},[Nsessions,1]);

tic
parfor iS = 1:Nsessions
% for iS = 1:Nsessions    
    % iS
    %tic
    for iB = 1:numel(binsizes)
        for iSamp = 1:nBatch
            % bootstrap word samples from binary array; for Pre, Post, Trials 
            
            % how to do this? binary_array is time-series of all non-zero
            % words; so we need to sample-with-replacement from each
            % OR: given data P(word), so we re-draw words with the same P
            % (as in the Pre:Post analysis): yes!
            
            % compute new P(words)
            [PWord(iS).Bins(iB).Trials.WordSet,PWord(iS).Bins(iB).Trials.P,PWord(iS).Bins(iB).Trials.binaryIDs,PWord(iS).Bins(iB).Trials.tsbinaryIDs] = ...
                                    Pwords(WordData(iS).Bins(iB).Trials.binary_array,CountData(iS).Bins(iB).Trials.Nwords);
            [PWord(iS).Bins(iB).Pre.WordSet,PWord(iS).Bins(iB).Pre.P,PWord(iS).Bins(iB).Pre.binaryIDs,PWord(iS).Bins(iB).Pre.tsbinaryIDs] = ...
                                    Pwords(WordData(iS).Bins(iB).Pre.binary_array,CountData(iS).Bins(iB).Pre.Nwords);
            [PWord(iS).Bins(iB).Post.WordSet,PWord(iS).Bins(iB).Post.P,PWord(iS).Bins(iB).Post.binaryIDs,PWord(iS).Bins(iB).Post.tsbinaryIDs] = ...
                                    Pwords(WordData(iS).Bins(iB).Post.binary_array,CountData(iS).Bins(iB).Post.Nwords);
            
            % Gte P(word) for trial-words only
            [~,~,trial_in_preIDs] = intersect(PWord(iS).Bins(iB).Trials.binaryIDs,PWord(iS).Bins(iB).Pre.binaryIDs);
            % renormalise to P=1: of all times at which Trial words appear,
            % what is proportion of each word?
            newP = PWord(iS).Bins(iB).Pre.P(trial_in_preIDs) ./ sum(PWord(iS).Bins(iB).Pre.P(trial_in_preIDs));  
            
            % compute distances
            % actual estimate
            Data.DTrial.TrialsPre(iS,iB) = full(Hellinger(PWord(iS).Bins(iB).Trials.P,PWord(iS).Bins(iB).Trials.binaryIDs,...
                                                    newP,PWord(iS).Bins(iB).Pre.binaryIDs(trial_in_preIDs)));   

            %% now for Post|Trials                                    
            [~,~,trial_in_postIDs] = intersect(PWord(iS).Bins(iB).Trials.binaryIDs,PWord(iS).Bins(iB).Post.binaryIDs);
            % renormalise to P=1: of all times at which Trial words appear,
            % what is proportion of each word?
            newP = PWord(iS).Bins(iB).Post.P(trial_in_postIDs) ./ sum(PWord(iS).Bins(iB).Post.P(trial_in_postIDs));  
            if isempty(newP)
                Data.DTrial.TrialsPost(iS,iB) = 1;
            else
                % bootstrap it

                Data.DTrial.TrialsPost(iS,iB) = full(Hellinger(PWord(iS).Bins(iB).Trials.P,PWord(iS).Bins(iB).Trials.binaryIDs,...
                                                    newP,PWord(iS).Bins(iB).Post.binaryIDs(trial_in_postIDs)));   
            end  
            
            % compute comparisons
            Data.DTrial.Delta(iS,iB) = Data.DTrial.TrialsPre(iS,iB)  - Data.DTrial.TrialsPost(iS,iB);
            Data.DTrial.IConvergence(iS,iB) = Data.DTrial.Delta(iS,iB) ./ (Data.DTrial.TrialsPre(iS,iB) + Data.DTrial.TrialsPost(iS,iB));
            
        end
    end
    %toc
end 
toc

save(['Bootstrap_Dictionary_Convergence_Analyses_N' num2str(N) '_' type],'Data')

