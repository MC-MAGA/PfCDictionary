%% convergence for K>=2 words

clear all; close all

% where are the data? Intermediate results too large for GitHub
filepath = 'C:\Users\lpzmdh\Dropbox\My Papers\PfC sampling hypothesis\Dictionary version 2\figures\Large_Intermediate_Results\';

% common parameters
type = 'Learn';  % 'Stable85';  %'Learn'
N = 35; % word-size
binsize = 5;

% analysis parameters
threshK = 2;  % all co-activation words
CI = 0.99;
alpha = 0.001;

load([filepath 'DataWords_And_Counts_N' num2str(N) '_' type],'binsizes')
load([filepath 'Jittered_TrialsSpike_Data_N' num2str(N) '_' type],'jittersize')
ixData = find(binsize == binsizes);     % which binsize in Data was used for jittered data words

%% analyse distances between dictionaries

% Shuffles
load([filepath 'PWord_Shuffled_N' num2str(N) '_' type])
Nsessions = numel(PWord);
nShuffles = numel(PWord(1).Shuffle);
PShuffle = PWord;

% load Jittered
load([filepath 'PWord_Jittered_N' num2str(N) '_' type '_binsize_' num2str(binsize)])
nSamples = numel(PWord(1).Jitter(1).Shuffle);
nJitters = numel(jittersize);
PJitter = PWord;

% load Data
load([filepath 'PWord_Data_N' num2str(N) '_' type])

%% for each session: do data, do shuffles, do jitter

for iS = 1:Nsessions
    % Data and Shuffled Data per binsize
    for iB = 1:numel(binsizes)
    
        %% make P(word | K>=2)
        [NewPWord.Trials.P,NewPWord.Trials.ID] = RenormalisedPword(PWord(iS).Bins(iB).Trials.WordSet,PWord(iS).Bins(iB).Trials.P,PWord(iS).Bins(iB).Trials.binaryIDs,threshK);
        [NewPWord.Pre.P,NewPWord.Pre.ID] = RenormalisedPword(PWord(iS).Bins(iB).Pre.WordSet,PWord(iS).Bins(iB).Pre.P,PWord(iS).Bins(iB).Pre.binaryIDs,threshK);
        [NewPWord.Post.P,NewPWord.Post.ID] = RenormalisedPword(PWord(iS).Bins(iB).Post.WordSet,PWord(iS).Bins(iB).Post.P,PWord(iS).Bins(iB).Post.binaryIDs,threshK);
        
        % compute distances between Data distribitions
        Data.D.TrialsPre(iS,iB) = Hellinger(NewPWord.Trials.P,NewPWord.Trials.ID,NewPWord.Pre.P,NewPWord.Pre.ID);
        Data.D.TrialsPost(iS,iB) = Hellinger(NewPWord.Trials.P,NewPWord.Trials.ID,NewPWord.Post.P,NewPWord.Post.ID);
        Data.D.PrePost(iS,iB) = Hellinger(NewPWord.Pre.P,NewPWord.Pre.ID,NewPWord.Post.P,NewPWord.Post.ID);
             
        % restrict to only words in Trials: Trial dictionary
        [~,~,trial_in_preIDs] = intersect(NewPWord.Trials.ID,NewPWord.Pre.ID);  
        % renormalise to P=1: of all times at which Trial words appear; and
        % then compute new distancesfor Trial dictionary only
        newP = NewPWord.Pre.P(trial_in_preIDs) ./ sum(NewPWord.Pre.P(trial_in_preIDs));  
        Data.DTrial.TrialsPre(iS,iB) = full(Hellinger(NewPWord.Trials.P,NewPWord.Trials.ID,newP,NewPWord.Pre.ID(trial_in_preIDs)));   
       
        [~,~,trial_in_postIDs] = intersect(NewPWord.Trials.ID,NewPWord.Post.ID);  
        % renormalise to P=1: of all times at which Trial words appear; and
        % then compute new distancesfor Trial dictionary only
        newP = NewPWord.Post.P(trial_in_postIDs) ./ sum(NewPWord.Post.P(trial_in_postIDs));  
        if isempty(newP)
            Data.DTrial.TrialsPost(iS,iB) = 1;
        else
            Data.DTrial.TrialsPost(iS,iB) = full(Hellinger(NewPWord.Trials.P,NewPWord.Trials.ID,newP,NewPWord.Post.ID(trial_in_postIDs)));   
        end
        
        % Delta and Convergence for Data
        Data.Delta(iS,iB) = Data.D.TrialsPre(iS,iB)  - Data.D.TrialsPost(iS,iB);
        Data.Convergence(iS,iB) = Data.Delta(iS,iB) ./ max([Data.D.TrialsPre(iS,iB),Data.D.TrialsPost(iS,iB)]);
        Data.IConvergence(iS,iB) = Data.Delta(iS,iB) ./ (Data.D.TrialsPre(iS,iB) + Data.D.TrialsPost(iS,iB));
 
        Data.DTrial.Delta(iS,iB) = Data.DTrial.TrialsPre(iS,iB)  - Data.DTrial.TrialsPost(iS,iB);
        Data.DTrial.Convergence(iS,iB) = Data.DTrial.Delta(iS,iB) ./ max([Data.DTrial.TrialsPre(iS,iB),Data.DTrial.TrialsPost(iS,iB)]);
        Data.DTrial.IConvergence(iS,iB) = Data.DTrial.Delta(iS,iB) ./ (Data.DTrial.TrialsPre(iS,iB) + Data.DTrial.TrialsPost(iS,iB));

        % do Shuffles
        for iSh = 1:nShuffles
            [NewPShuffle.Trials.P,NewPShuffle.Trials.ID] = RenormalisedPword(PShuffle(iS).Shuffle(iSh).Bins(iB).Trials.WordSet,PShuffle(iS).Shuffle(iSh).Bins(iB).Trials.P,PShuffle(iS).Shuffle(iSh).Bins(iB).Trials.binaryIDs,threshK);
            [NewPShuffle.Pre.P,NewPShuffle.Pre.ID] = RenormalisedPword(PShuffle(iS).Shuffle(iSh).Bins(iB).Pre.WordSet,PShuffle(iS).Shuffle(iSh).Bins(iB).Pre.P,PShuffle(iS).Shuffle(iSh).Bins(iB).Pre.binaryIDs,threshK);
            [NewPShuffle.Post.P,NewPShuffle.Post.ID] = RenormalisedPword(PShuffle(iS).Shuffle(iSh).Bins(iB).Post.WordSet,PShuffle(iS).Shuffle(iSh).Bins(iB).Post.P,PShuffle(iS).Shuffle(iSh).Bins(iB).Post.binaryIDs,threshK);

            % distance between epochs within each shuffle
            SData.D.TrialsPre(iS,iB,iSh) = full(Hellinger(NewPShuffle.Trials.P,NewPShuffle.Trials.ID,NewPShuffle.Pre.P,NewPShuffle.Pre.ID));
            SData.D.TrialsPost(iS,iB,iSh) = full(Hellinger(NewPShuffle.Trials.P,NewPShuffle.Trials.ID,NewPShuffle.Post.P,NewPShuffle.Post.ID));
            SData.D.PrePost(iS,iB,iSh) = full(Hellinger(NewPShuffle.Trials.P,NewPShuffle.Trials.ID,NewPShuffle.Post.P,NewPShuffle.Post.ID));

            % restrict to only words in Trials: Trial dictionary
            [~,~,trial_in_preIDs] = intersect(NewPShuffle.Trials.ID,NewPShuffle.Pre.ID);  
            newP = NewPShuffle.Pre.P(trial_in_preIDs) ./ sum(NewPShuffle.Pre.P(trial_in_preIDs)); 
            if isempty(newP)
                SData.DTrial.TrialsPre(iS,iB,iSh) = 1;
            else
                SData.DTrial.TrialsPre(iS,iB,iSh) = full(Hellinger(NewPShuffle.Trials.P,NewPShuffle.Trials.ID,newP,NewPShuffle.Pre.ID(trial_in_preIDs)));   
            end
            
            [~,~,trial_in_postIDs] = intersect(NewPShuffle.Trials.ID,NewPShuffle.Post.ID);  
            newP = NewPShuffle.Post.P(trial_in_postIDs) ./ sum(NewPShuffle.Post.P(trial_in_postIDs));  
            if isempty(newP)
                SData.DTrial.TrialsPost(iS,iB,iSh) = 1;
            else
                SData.DTrial.TrialsPost(iS,iB,iSh) = full(Hellinger(NewPShuffle.Trials.P,NewPShuffle.Trials.ID,newP,NewPShuffle.Post.ID(trial_in_postIDs)));   
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
    
    % do Jittered Data per Jitter size, compared to Data at chosen binsize
    for iJ = 1:nJitters
        for iSh = 1:nSamples
            %% make P(word | K>=2)
            [NewPJitter.Trials.P,NewPJitter.Trials.ID] = RenormalisedPword(PJitter(iS).Jitter(iJ).Shuffle(iSh).Trials.WordSet,PJitter(iS).Jitter(iJ).Shuffle(iSh).Trials.P,PJitter(iS).Jitter(iJ).Shuffle(iSh).Trials.binaryIDs,threshK);
            [NewPJitter.Pre.P,NewPJitter.Pre.ID] = RenormalisedPword(PJitter(iS).Jitter(iJ).Shuffle(iSh).Pre.WordSet,PJitter(iS).Jitter(iJ).Shuffle(iSh).Pre.P,PJitter(iS).Jitter(iJ).Shuffle(iSh).Pre.binaryIDs,threshK);
            [NewPJitter.Post.P,NewPJitter.Post.ID] = RenormalisedPword(PJitter(iS).Jitter(iJ).Shuffle(iSh).Post.WordSet,PJitter(iS).Jitter(iJ).Shuffle(iSh).Post.P,PJitter(iS).Jitter(iJ).Shuffle(iSh).Post.binaryIDs,threshK);

            % distance between epochs within each shuffle
            JData.D.TrialsPre(iS,iJ,iSh) = full(Hellinger(NewPJitter.Trials.P,NewPJitter.Trials.ID,NewPJitter.Pre.P,NewPJitter.Pre.ID));
            JData.D.TrialsPost(iS,iJ,iSh) = full(Hellinger(NewPJitter.Trials.P,NewPJitter.Trials.ID,NewPJitter.Post.P,NewPJitter.Post.ID));

            % restrict to only words in Trials: Trial dictionary
            [~,~,trial_in_preIDs] = intersect(NewPJitter.Trials.ID,NewPJitter.Pre.ID);  
            % renormalise to P=1: of all times at which Trial words appear; and
            % then compute new distancesfor Trial dictionary only
            newP = NewPJitter.Pre.P(trial_in_preIDs) ./ sum(NewPJitter.Pre.P(trial_in_preIDs));  
            JData.DTrial.TrialsPre(iS,iJ,iSh) = full(Hellinger(NewPJitter.Trials.P,NewPJitter.Trials.ID,newP,NewPJitter.Pre.ID(trial_in_preIDs)));   

            [~,~,trial_in_postIDs] = intersect(NewPJitter.Trials.ID,NewPJitter.Post.ID);  
            % renormalise to P=1: of all times at which Trial words appear; and
            % then compute new distancesfor Trial dictionary only
            newP = NewPJitter.Post.P(trial_in_postIDs) ./ sum(NewPJitter.Post.P(trial_in_postIDs));  
            JData.DTrial.TrialsPost(iS,iJ,iSh) = full(Hellinger(NewPJitter.Trials.P,NewPJitter.Trials.ID,newP,NewPJitter.Post.ID(trial_in_postIDs)));   
            
             % Delta and Convergence for this shuffle
            JData.Delta(iS,iJ,iSh) = JData.D.TrialsPre(iS,iJ,iSh)  - JData.D.TrialsPost(iS,iJ,iSh) ;
            JData.Convergence(iS,iJ,iSh) = JData.Delta(iS,iJ,iSh) ./ max([JData.D.TrialsPre(iS,iJ,iSh),JData.D.TrialsPost(iS,iJ,iSh)]);
            JData.IConvergence(iS,iJ,iSh) = JData.Delta(iS,iJ,iSh) ./ (JData.D.TrialsPre(iS,iJ,iSh) + JData.D.TrialsPost(iS,iJ,iSh));
            
            JData.DTrial.Delta(iS,iJ,iSh) = JData.DTrial.TrialsPre(iS,iJ,iSh)  - JData.DTrial.TrialsPost(iS,iJ,iSh) ;
            JData.DTrial.Convergence(iS,iJ,iSh) = JData.DTrial.Delta(iS,iJ,iSh) ./ max([JData.DTrial.TrialsPre(iS,iJ,iSh),JData.DTrial.TrialsPost(iS,iJ,iSh)]);
            JData.DTrial.IConvergence(iS,iJ,iSh) = JData.DTrial.Delta(iS,iJ,iSh) ./ (JData.DTrial.TrialsPre(iS,iJ,iSh) + JData.DTrial.TrialsPost(iS,iJ,iSh));

        end

        % difference between data and jitters
        delta = Data.Delta(iS,ixData) - squeeze(JData.Delta(iS,iJ,:));  % differences between this data point and each shuffle
        JData.Diff.Delta.M(iS,iJ) = mean(delta);
        JData.Diff.Delta.CI(iS,iJ) = CIfromSEM(std(delta),nShuffles,CI);        
        JData.Diff.Delta.P(iS,iJ) = signtest(delta);

        delta = Data.Convergence(iS,ixData) - squeeze(JData.Convergence(iS,iJ,:));  % differences between this Data point and each shuffle
        JData.Diff.Convergence.M(iS,iJ) = mean(delta);
        JData.Diff.Convergence.CI(iS,iJ) = CIfromSEM(std(delta),nShuffles,CI);        
        JData.Diff.Convergence.P(iS,iJ) = signtest(delta);

        delta = Data.IConvergence(iS,ixData) - squeeze(JData.IConvergence(iS,iJ,:));  % differences between this Data point and each shuffle
        JData.Diff.IConvergence.M(iS,iJ) = mean(delta);
        JData.Diff.IConvergence.CI(iS,iJ) = CIfromSEM(std(delta),nShuffles,CI);        
        JData.Diff.IConvergence.P(iS,iJ) = signtest(delta);
        
         % difference between data and jitters: Trials only
        delta = Data.DTrial.Delta(iS,ixData) - squeeze(JData.DTrial.Delta(iS,iJ,:));  % differences between this data point and each shuffle
        JData.DiffTrial.Delta.M(iS,iJ) = mean(delta);
        JData.DiffTrial.Delta.CI(iS,iJ) = CIfromSEM(std(delta),nShuffles,CI);        
        JData.DiffTrial.Delta.P(iS,iJ) = signtest(delta);

        delta = Data.DTrial.Convergence(iS,ixData) - squeeze(JData.DTrial.Convergence(iS,iJ,:));  % differences between this Data point and each shuffle
        JData.DiffTrial.Convergence.M(iS,iJ) = mean(delta);
        JData.DiffTrial.Convergence.CI(iS,iJ) = CIfromSEM(std(delta),nShuffles,CI);        
        JData.DiffTrial.Convergence.P(iS,iJ) = signtest(delta);

        delta = Data.DTrial.IConvergence(iS,ixData) - squeeze(JData.DTrial.IConvergence(iS,iJ,:));  % differences between this Data point and each shuffle
        JData.DiffTrial.IConvergence.M(iS,iJ) = mean(delta);
        JData.DiffTrial.IConvergence.CI(iS,iJ) = CIfromSEM(std(delta),nShuffles,CI);        
        JData.DiffTrial.IConvergence.P(iS,iJ) = signtest(delta);

    end
end

%% stats on measured differences within Data 
for iB = 1:numel(binsizes)
    % difference between sessions in Data
    Data.D.Delta.P(iB) = signtest(Data.Delta(:,iB)); % test for systematic difference between distances 
    Data.D.Convergence.P(iB) = signtest(Data.Convergence(:,iB)); % test for systematic difference between distances 
    Data.D.IConvergence.P(iB) = signtest(Data.IConvergence(:,iB)); % test for systematic difference between distances 
    
    % and for trial-only dictionaries
    Data.Trial.Delta.P(iB) = signtest(Data.DTrial.Delta(:,iB)); % test for systematic difference between distances 
    Data.Trial.Convergence.P(iB) = signtest(Data.DTrial.Convergence(:,iB)); % test for systematic difference between distances 
    Data.Trial.IConvergence.P(iB) = signtest(Data.DTrial.IConvergence(:,iB)); % test for systematic difference between distances 

end

save(['Plasticity_K2_Convergence_Analyses_N' num2str(N) '_' type],'Data','SData','JData','CI','alpha')
