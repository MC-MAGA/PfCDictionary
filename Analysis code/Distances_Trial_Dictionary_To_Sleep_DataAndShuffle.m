%% script to analyse changes through training: is dictionary in trials systematically closer to that in Sleep?
% do Data and Shuffles together, and also compare them...

clear all; close all

% where are the data? Intermediate results too large for GitHub
filepath = 'C:\Users\lpzmdh\Dropbox\My Papers\PfC sampling hypothesis\Dictionary version 2\figures\Large_Intermediate_Results\';

type = 'Learn'; % 'Stable85';  %'Learn'
N = 35; % word-size

% analysis parameters
CI = 0.99;

alpha = 0.001;
load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type],'CountData','binsizes')


%% analyse distances between dictionaries

% load Shuffles
load([filepath 'PWord_Shuffled_N' num2str(N) '_' type])
Nsessions = numel(PWord);
nShuffles = numel(PWord(1).Shuffle);
PShuffle = PWord;

% load Data
load([filepath 'PWord_Data_N' num2str(N) '_' type])
load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type],'binsizes')

%% Distances per bin-size
for iB = 1:numel(binsizes)
    iB
    for iS = 1:Nsessions
        % compute distances on all IDs in both epochs
        Data.D.TrialsPre(iS,iB) = full(Hellinger(PWord(iS).Bins(iB).Trials.P,PWord(iS).Bins(iB).Trials.binaryIDs,...
                                                PWord(iS).Bins(iB).Pre.P,PWord(iS).Bins(iB).Pre.binaryIDs));
        Data.D.TrialsPost(iS,iB) = full(Hellinger(PWord(iS).Bins(iB).Trials.P,PWord(iS).Bins(iB).Trials.binaryIDs,...
                                                PWord(iS).Bins(iB).Post.P,PWord(iS).Bins(iB).Post.binaryIDs));
       
        % compute distances on trial IDs only...
        [~,~,trial_in_preIDs] = intersect(PWord(iS).Bins(iB).Trials.binaryIDs,PWord(iS).Bins(iB).Pre.binaryIDs);
        % renormalise to P=1: of all times at which Trial words appear,
        % what is proportion of each word?
        newP = PWord(iS).Bins(iB).Pre.P(trial_in_preIDs) ./ sum(PWord(iS).Bins(iB).Pre.P(trial_in_preIDs));  
        Data.DTrial.TrialsPre(iS,iB) = full(Hellinger(PWord(iS).Bins(iB).Trials.P,PWord(iS).Bins(iB).Trials.binaryIDs,...
                                                newP,PWord(iS).Bins(iB).Pre.binaryIDs(trial_in_preIDs)));   
        [~,~,trial_in_postIDs] = intersect(PWord(iS).Bins(iB).Trials.binaryIDs,PWord(iS).Bins(iB).Post.binaryIDs);
        % renormalise to P=1: of all times at which Trial words appear,
        % what is proportion of each word?
        newP = PWord(iS).Bins(iB).Post.P(trial_in_postIDs) ./ sum(PWord(iS).Bins(iB).Post.P(trial_in_postIDs));  
        if isempty(newP)
            Data.DTrial.TrialsPost(iS,iB) = 1;
        else
            Data.DTrial.TrialsPost(iS,iB) = full(Hellinger(PWord(iS).Bins(iB).Trials.P,PWord(iS).Bins(iB).Trials.binaryIDs,...
                                                newP,PWord(iS).Bins(iB).Post.binaryIDs(trial_in_postIDs)));   
        end
        
        % Delta and Convergence for Data
        Data.Delta(iS,iB) = Data.D.TrialsPre(iS,iB)  - Data.D.TrialsPost(iS,iB);
        Data.Convergence(iS,iB) = Data.Delta(iS,iB) ./ max([Data.D.TrialsPre(iS,iB),Data.D.TrialsPost(iS,iB)]);
        Data.IConvergence(iS,iB) = Data.Delta(iS,iB) ./ (Data.D.TrialsPre(iS,iB) + Data.D.TrialsPost(iS,iB));
       
        Data.DTrial.Delta(iS,iB) = Data.DTrial.TrialsPre(iS,iB)  - Data.DTrial.TrialsPost(iS,iB);
        Data.DTrial.Convergence(iS,iB) = Data.DTrial.Delta(iS,iB) ./ max([Data.DTrial.TrialsPre(iS,iB),Data.DTrial.TrialsPost(iS,iB)]);
        Data.DTrial.IConvergence(iS,iB) = Data.DTrial.Delta(iS,iB) ./ (Data.DTrial.TrialsPre(iS,iB) + Data.DTrial.TrialsPost(iS,iB));
        
        for iSh = 1:nShuffles
            % distance between epochs within each shuffle
            SData.D.TrialsPre(iS,iB,iSh) = full(Hellinger(PShuffle(iS).Shuffle(iSh).Bins(iB).Trials.P,PShuffle(iS).Shuffle(iSh).Bins(iB).Trials.binaryIDs,...
                                                    PShuffle(iS).Shuffle(iSh).Bins(iB).Pre.P,PShuffle(iS).Shuffle(iSh).Bins(iB).Pre.binaryIDs));
            SData.D.TrialsPost(iS,iB,iSh) = full(Hellinger(PShuffle(iS).Shuffle(iSh).Bins(iB).Trials.P,PShuffle(iS).Shuffle(iSh).Bins(iB).Trials.binaryIDs,...
                                                    PShuffle(iS).Shuffle(iSh).Bins(iB).Post.P,PShuffle(iS).Shuffle(iSh).Bins(iB).Post.binaryIDs));
            
            % limited to words appearing the Trials
            [~,~,trial_in_preIDs] = intersect(PShuffle(iS).Shuffle(iSh).Bins(iB).Trials.binaryIDs,PShuffle(iS).Shuffle(iSh).Bins(iB).Pre.binaryIDs);
            newP = PShuffle(iS).Shuffle(iSh).Bins(iB).Pre.P(trial_in_preIDs) ./ sum(PShuffle(iS).Shuffle(iSh).Bins(iB).Pre.P(trial_in_preIDs));  
            if isempty(newP)
                SData.DTrial.TrialsPre(iS,iB,iSh) = 1;
            else
                SData.DTrial.TrialsPre(iS,iB,iSh) = full(Hellinger(PShuffle(iS).Shuffle(iSh).Bins(iB).Trials.P,PShuffle(iS).Shuffle(iSh).Bins(iB).Trials.binaryIDs,...
                                                newP,PShuffle(iS).Shuffle(iSh).Bins(iB).Pre.binaryIDs(trial_in_preIDs)));   
            end
            
            [~,~,trial_in_PostIDs] = intersect(PShuffle(iS).Shuffle(iSh).Bins(iB).Trials.binaryIDs,PShuffle(iS).Shuffle(iSh).Bins(iB).Post.binaryIDs);
            newP = PShuffle(iS).Shuffle(iSh).Bins(iB).Post.P(trial_in_PostIDs) ./ sum(PShuffle(iS).Shuffle(iSh).Bins(iB).Post.P(trial_in_PostIDs));  
            if isempty(newP)
                SData.DTrial.TrialsPost(iS,iB,iSh) = 1;
            else
                SData.DTrial.TrialsPost(iS,iB,iSh) = full(Hellinger(PShuffle(iS).Shuffle(iSh).Bins(iB).Trials.P,PShuffle(iS).Shuffle(iSh).Bins(iB).Trials.binaryIDs,...
                                                newP,PShuffle(iS).Shuffle(iSh).Bins(iB).Post.binaryIDs(trial_in_PostIDs)));   
            end
            
             % Delta and Convergence for this shuffle
            SData.Delta(iS,iB,iSh) = SData.D.TrialsPre(iS,iB,iSh)  - SData.D.TrialsPost(iS,iB,iSh) ;
            SData.Convergence(iS,iB,iSh) = SData.Delta(iS,iB,iSh) ./ max([SData.D.TrialsPre(iS,iB,iSh),SData.D.TrialsPost(iS,iB,iSh)]);
            SData.IConvergence(iS,iB,iSh) = SData.Delta(iS,iB,iSh) ./ (SData.D.TrialsPre(iS,iB,iSh) + SData.D.TrialsPost(iS,iB,iSh));

            SData.DTrial.Delta(iS,iB,iSh) = SData.DTrial.TrialsPre(iS,iB,iSh)  - SData.DTrial.TrialsPost(iS,iB,iSh) ;
            SData.DTrial.Convergence(iS,iB,iSh) = SData.DTrial.Delta(iS,iB,iSh) ./ max([SData.DTrial.TrialsPre(iS,iB,iSh),SData.DTrial.TrialsPost(iS,iB,iSh)]);
            SData.DTrial.IConvergence(iS,iB,iSh) = SData.DTrial.Delta(iS,iB,iSh) ./ (SData.DTrial.TrialsPre(iS,iB,iSh) + SData.DTrial.TrialsPost(iS,iB,iSh));

        end

        % difference between data and shuffles
        delta = Data.Delta(iS,iB) - squeeze(SData.Delta(iS,iB,:));  % differences between this data point and each shuffle
        Data.Diff.Delta.M(iS,iB) = mean(delta);
        Data.Diff.Delta.CI(iS,iB) = CIfromSEM(std(delta),nShuffles,CI);        
        Data.Diff.Delta.P(iS,iB) = signtest(delta);

        delta = Data.Convergence(iS,iB) - squeeze(SData.Convergence(iS,iB,:));  % differences between this data point and each shuffle
        Data.Diff.Convergence.M(iS,iB) = mean(delta);
        Data.Diff.Convergence.CI(iS,iB) = CIfromSEM(std(delta),nShuffles,CI);        
        Data.Diff.Convergence.P(iS,iB) = signtest(delta);
  
        delta = Data.IConvergence(iS,iB) - squeeze(SData.IConvergence(iS,iB,:));  % differences between this data point and each shuffle
        Data.Diff.IConvergence.M(iS,iB) = mean(delta);
        Data.Diff.IConvergence.CI(iS,iB) = CIfromSEM(std(delta),nShuffles,CI);        
        Data.Diff.IConvergence.P(iS,iB) = signtest(delta);
        
        % and for Trials only...
        delta = Data.DTrial.Delta(iS,iB) - squeeze(SData.DTrial.Delta(iS,iB,:));  % differences between this data point and each shuffle
        Data.DiffTrial.Delta.M(iS,iB) = mean(delta);
        Data.DiffTrial.Delta.CI(iS,iB) = CIfromSEM(std(delta),nShuffles,CI);        
        Data.DiffTrial.Delta.P(iS,iB) = signtest(delta);

        delta = Data.DTrial.Convergence(iS,iB) - squeeze(SData.DTrial.Convergence(iS,iB,:));  % differences between this data point and each shuffle
        Data.DiffTrial.Convergence.M(iS,iB) = mean(delta);
        Data.DiffTrial.Convergence.CI(iS,iB) = CIfromSEM(std(delta),nShuffles,CI);        
        Data.DiffTrial.Convergence.P(iS,iB) = signtest(delta);
  
        delta = Data.DTrial.IConvergence(iS,iB) - squeeze(SData.DTrial.IConvergence(iS,iB,:));  % differences between this data point and each shuffle
        Data.DiffTrial.IConvergence.M(iS,iB) = mean(delta);
        Data.DiffTrial.IConvergence.CI(iS,iB) = CIfromSEM(std(delta),nShuffles,CI);        
        Data.DiffTrial.IConvergence.P(iS,iB) = signtest(delta);
        

    end
    
    % difference between sessions in Data
    Data.D.Delta.P(iB) = signtest(Data.Delta(:,iB)); % test for systematic difference between distances 
    Data.D.Convergence.P(iB) = signtest(Data.Convergence(:,iB)); % test for systematic difference between distances 
    Data.D.IConvergence.P(iB) = signtest(Data.IConvergence(:,iB)); % test for systematic difference between distances 

    Data.DTrial.P.Delta(iB) = signtest(Data.DTrial.Delta(:,iB)); % test for systematic difference between distances 
    Data.DTrial.P.IConvergence(iB) = signtest(Data.DTrial.IConvergence(:,iB)); % test for systematic difference between distances 

end

save(['Dictionary_Convergence_Analyses_N' num2str(N) '_' type],'Data','SData','CI','alpha')

